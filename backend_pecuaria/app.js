const express = require('express');
const cors = require('cors');
const sqlite3 = require('sqlite3').verbose();
const { v4: uuidv4 } = require('uuid');

const app = express();
app.use(cors());
app.use(express.json({ limit: '50mb' }));

// Configura o banco SQLite em memória ou arquivo
const db = new sqlite3.Database('./backend.db', (err) => {
    if (err) console.error(err.message);
    else console.log('Conectado ao SQLite backend.db');
});

// Tabela genérica para armazenar as entidades de negócio (offline-first)
db.serialize(() => {
    db.run(`
        CREATE TABLE IF NOT EXISTS entities (
            server_id TEXT PRIMARY KEY,
            entity_id TEXT NOT NULL,
            entity_type TEXT NOT NULL,
            payload TEXT,
            device_id TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            deleted_at TEXT
        )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_entities_updated ON entities (updated_at)`);
    db.run(`CREATE INDEX IF NOT EXISTS idx_entities_entity_id ON entities (entity_id)`);
});

// Helper para executar SQL com Promises
const runAsync = (sql, params = []) => new Promise((resolve, reject) => {
    db.run(sql, params, function (err) {
        if (err) reject(err);
        else resolve(this);
    });
});
const getAsync = (sql, params = []) => new Promise((resolve, reject) => {
    db.get(sql, params, (err, row) => {
        if (err) reject(err);
        else resolve(row);
    });
});
const allAsync = (sql, params = []) => new Promise((resolve, reject) => {
    db.all(sql, params, (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
    });
});

app.post('/v1/sync', async (req, res) => {
    const { outbox = [], lastSyncAt = "1970-01-01T00:00:00.000Z" } = req.body;
    
    const results = [];
    const now = new Date().toISOString();

    try {
        // 1. Processar a outbox (operações do cliente)
        for (const item of outbox) {
            const { id: queueId, entityType, entityId, action, payload, deviceId, createdAt } = item;
            
            // Busca a entidade atual no backend para verificar colisão
            const existing = await getAsync(`SELECT * FROM entities WHERE entity_id = ?`, [entityId]);
            
            if (existing) {
                // Existe. Verificar colisão
                const isConflict = existing.updated_at > createdAt && existing.device_id !== deviceId;
                
                if (isConflict && action !== 'delete') {
                    // CONFLITO! A versão remota é mais nova e veio de outro dispositivo
                    results.push({ id: queueId, status: 'conflict', serverId: existing.server_id });
                    continue; // Pula a gravação
                } else {
                    // Update ou Delete
                    let newDeletedAt = action === 'delete' ? createdAt : null;
                    await runAsync(
                        `UPDATE entities SET payload = ?, updated_at = ?, deleted_at = ?, device_id = ? WHERE server_id = ?`,
                        [JSON.stringify(payload), createdAt, newDeletedAt, deviceId, existing.server_id]
                    );
                    results.push({ id: queueId, status: 'synced', serverId: existing.server_id });
                }
            } else {
                // Não existe, é um CREATE
                if (action === 'delete') {
                    // Se não existe e mandou deletar, já consideramos resolvido
                    results.push({ id: queueId, status: 'synced', serverId: null });
                } else {
                    const serverId = uuidv4();
                    await runAsync(
                        `INSERT INTO entities (server_id, entity_id, entity_type, payload, device_id, created_at, updated_at) 
                         VALUES (?, ?, ?, ?, ?, ?, ?)`,
                        [serverId, entityId, entityType, JSON.stringify(payload), deviceId, createdAt, createdAt]
                    );
                    results.push({ id: queueId, status: 'synced', serverId: serverId });
                }
            }
        }

        // 2. Buscar as "changes" (Pull) - registros modificados após o lastSyncAt informado
        // que não foram gerados pelo próprio device nesta exata requisição.
        // Simplificação: retornamos tudo que foi atualizado após lastSyncAt.
        const changesRows = await allAsync(`SELECT * FROM entities WHERE updated_at > ?`, [lastSyncAt]);
        
        // Formatar as changes para o formato esperado pelo app
        const changes = changesRows.map(row => ({
            serverId: row.server_id,
            entityId: row.entity_id,
            entityType: row.entity_type,
            payload: JSON.parse(row.payload),
            deviceId: row.device_id,
            updatedAt: row.updated_at,
            deletedAt: row.deleted_at
        }));

        res.json({ results, changes, serverTime: now });
    } catch (error) {
        console.error('Erro na sincronização:', error);
        res.status(500).json({ error: 'Erro interno no servidor' });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});
