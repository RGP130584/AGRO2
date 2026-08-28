require('dotenv').config();
const express = require('express');
const cors = require('cors');
const sqlite3 = require('sqlite3').verbose();
const crypto = require('crypto');
const rateLimit = require('express-rate-limit');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { z } = require('zod');

const app = express();

// Hardening: CORS limits
const allowedOrigins = (process.env.CORS_ORIGINS || '').split(',');
app.use(cors({
    origin: (origin, callback) => {
        if (!origin || allowedOrigins.includes(origin) || allowedOrigins.includes('*')) {
            callback(null, true);
        } else {
            callback(new Error('Not allowed by CORS'));
        }
    }
}));

// Hardening: Body limit
app.use(express.json({ limit: '10mb' }));

// Configura o banco SQLite em memória ou arquivo
const db = new sqlite3.Database('./backend.db', (err) => {
    if (err) console.error(err.message);
    else console.log('Conectado ao SQLite backend.db');
});

// Tabela genérica para armazenar as entidades de negócio (offline-first) + Tabela usuarios
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

    db.run(`
        CREATE TABLE IF NOT EXISTS usuarios (
            id TEXT PRIMARY KEY,
            nome TEXT NOT NULL,
            cpf_cnpj TEXT UNIQUE NOT NULL,
            email TEXT,
            senha_hash TEXT NOT NULL,
            reset_token TEXT,
            reset_token_expires INTEGER,
            criado_em TEXT NOT NULL
        )
    `);
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

// Rate limiting para rotas de auth
const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutos
    max: 20, // Limite de 20 requisições por IP
    message: { error: 'Muitas tentativas de acesso, tente novamente mais tarde.' }
});

// Zod schemas
const registerSchema = z.object({
    nome: z.string().min(1),
    cpfCnpj: z.string().min(11),
    email: z.string().email().optional().or(z.literal('')),
    senha: z.string().min(6)
});
const loginSchema = z.object({
    cpfCnpj: z.string().min(11),
    senha: z.string().min(6)
});
const requestResetSchema = z.object({ email: z.string().email() });
const confirmResetSchema = z.object({ token: z.string(), novaSenha: z.string().min(6) });

// Rotas de Autenticação
app.post('/v1/auth/register', authLimiter, async (req, res) => {
    try {
        const { nome, cpfCnpj, email, senha } = registerSchema.parse(req.body);
        const existing = await getAsync(`SELECT id FROM usuarios WHERE cpf_cnpj = ?`, [cpfCnpj]);
        if (existing) {
            return res.status(400).json({ error: 'CPF/CNPJ já cadastrado.' });
        }
        
        const salt = await bcrypt.genSalt(10);
        const hash = await bcrypt.hash(senha, salt);
        const id = crypto.randomUUID();
        const now = new Date().toISOString();

        await runAsync(
            `INSERT INTO usuarios (id, nome, cpf_cnpj, email, senha_hash, criado_em) VALUES (?, ?, ?, ?, ?, ?)`,
            [id, nome, cpfCnpj, email || null, hash, now]
        );

        const token = jwt.sign({ id, cpfCnpj }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN || '30d' });
        res.status(201).json({ token, user: { id, nome, cpfCnpj, email } });
    } catch (e) {
        console.error(e);
        if (e instanceof z.ZodError) return res.status(400).json({ error: 'Dados inválidos.', details: e.errors });
        res.status(500).json({ error: 'Erro interno' });
    }
});

app.post('/v1/auth/login', authLimiter, async (req, res) => {
    try {
        const { cpfCnpj, senha } = loginSchema.parse(req.body);
        const user = await getAsync(`SELECT * FROM usuarios WHERE cpf_cnpj = ?`, [cpfCnpj]);
        if (!user) return res.status(401).json({ error: 'Credenciais inválidas.' });

        const isMatch = await bcrypt.compare(senha, user.senha_hash);
        if (!isMatch) return res.status(401).json({ error: 'Credenciais inválidas.' });

        const token = jwt.sign({ id: user.id, cpfCnpj: user.cpf_cnpj }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN || '30d' });
        res.json({ token, user: { id: user.id, nome: user.nome, cpfCnpj: user.cpf_cnpj, email: user.email } });
    } catch (e) {
        if (e instanceof z.ZodError) return res.status(400).json({ error: 'Dados inválidos.' });
        res.status(500).json({ error: 'Erro interno' });
    }
});

app.post('/v1/auth/password-reset/request', authLimiter, async (req, res) => {
    try {
        const { email } = requestResetSchema.parse(req.body);
        const user = await getAsync(`SELECT id FROM usuarios WHERE email = ?`, [email]);
        if (!user) {
            // Retorna 200 sempre para evitar vazamento de emails cadastrados
            return res.json({ message: 'Se o e-mail existir, um código foi enviado.' });
        }
        
        const token = crypto.randomUUID().substring(0, 8).toUpperCase(); // Token simples de 8 chars
        const expires = Date.now() + 15 * 60 * 1000; // 15 minutos

        await runAsync(`UPDATE usuarios SET reset_token = ?, reset_token_expires = ? WHERE id = ?`, [token, expires, user.id]);
        
        // Simulação de envio de e-mail (TODO: integrar provedor real se aplicável)
        console.log(`[EMAIL SIMULADO] Para: ${email} | Token de Recuperação: ${token}`);
        
        res.json({ message: 'Se o e-mail existir, um código foi enviado.' });
    } catch (e) {
        res.status(400).json({ error: 'Dados inválidos.' });
    }
});

app.post('/v1/auth/password-reset/confirm', authLimiter, async (req, res) => {
    try {
        const { token, novaSenha } = confirmResetSchema.parse(req.body);
        const user = await getAsync(`SELECT id, reset_token_expires FROM usuarios WHERE reset_token = ?`, [token]);
        
        if (!user || user.reset_token_expires < Date.now()) {
            return res.status(400).json({ error: 'Token inválido ou expirado.' });
        }

        const salt = await bcrypt.genSalt(10);
        const hash = await bcrypt.hash(novaSenha, salt);

        await runAsync(`UPDATE usuarios SET senha_hash = ?, reset_token = NULL, reset_token_expires = NULL WHERE id = ?`, [hash, user.id]);
        res.json({ message: 'Senha atualizada com sucesso.' });
    } catch (e) {
        res.status(400).json({ error: 'Dados inválidos.' });
    }
});

// Middleware de Autenticação JWT
const authenticate = (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Token não fornecido.' });
    }
    const token = authHeader.split(' ')[1];
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;
        next();
    } catch (e) {
        return res.status(401).json({ error: 'Token inválido ou expirado.' });
    }
};

app.post('/v1/sync', authenticate, async (req, res) => {
    const { outbox = [], lastSyncAt = "1970-01-01T00:00:00.000Z" } = req.body;
    
    const results = [];
    const now = new Date().toISOString();

    try {
        for (const item of outbox) {
            const { id: queueId, entityType, entityId, action, payload, deviceId, createdAt } = item;
            
            const existing = await getAsync(`SELECT * FROM entities WHERE entity_id = ?`, [entityId]);
            
            if (existing) {
                const isConflict = existing.updated_at > createdAt && existing.device_id !== deviceId;
                
                if (isConflict && action !== 'delete') {
                    results.push({ id: queueId, status: 'conflict', serverId: existing.server_id });
                    continue; 
                } else {
                    let newDeletedAt = action === 'delete' ? createdAt : null;
                    await runAsync(
                        `UPDATE entities SET payload = ?, updated_at = ?, deleted_at = ?, device_id = ? WHERE server_id = ?`,
                        [JSON.stringify(payload), createdAt, newDeletedAt, deviceId, existing.server_id]
                    );
                    results.push({ id: queueId, status: 'synced', serverId: existing.server_id });
                }
            } else {
                if (action === 'delete') {
                    results.push({ id: queueId, status: 'synced', serverId: null });
                } else {
                    const serverId = crypto.randomUUID();
                    await runAsync(
                        `INSERT INTO entities (server_id, entity_id, entity_type, payload, device_id, created_at, updated_at) 
                         VALUES (?, ?, ?, ?, ?, ?, ?)`,
                        [serverId, entityId, entityType, JSON.stringify(payload), deviceId, createdAt, createdAt]
                    );
                    results.push({ id: queueId, status: 'synced', serverId: serverId });
                }
            }
        }

        const changesRows = await allAsync(`SELECT * FROM entities WHERE updated_at > ?`, [lastSyncAt]);
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
if (require.main === module) {
    app.listen(PORT, () => {
        console.log(`Servidor rodando na porta ${PORT}`);
    });
}
module.exports = app;
