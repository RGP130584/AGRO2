require('dotenv').config();
const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const { z } = require('zod');
const rateLimit = require('express-rate-limit');
const crypto = require('crypto');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json({ limit: '10mb' }));

// Configuração do SQLite: usa :memory: em testes automatizados, arquivo em produção
const dbFile = process.env.NODE_ENV === 'test' 
  ? ':memory:' 
  : path.resolve(__dirname, process.env.DB_FILE || 'backend.db');

const db = new sqlite3.Database(dbFile, (err) => {
    if (err) {
        console.error('Erro ao conectar ao SQLite:', err.message);
    } else {
        console.log(`Conectado ao SQLite (${process.env.NODE_ENV === 'test' ? ':memory:' : dbFile})`);
    }
});

// Inicialização do Schema
db.serialize(() => {
    db.run(`
        CREATE TABLE IF NOT EXISTS entities (
            server_id TEXT PRIMARY KEY,
            owner_id TEXT NOT NULL,
            entity_id TEXT NOT NULL,
            entity_type TEXT NOT NULL,
            payload TEXT NOT NULL,
            device_id TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            deleted_at TEXT
        )
    `);

    db.run(`CREATE INDEX IF NOT EXISTS idx_entities_owner_updated ON entities (owner_id, updated_at)`);
    db.run(`CREATE INDEX IF NOT EXISTS idx_entities_owner_entity ON entities (owner_id, entity_id)`);

    db.run(`
        CREATE TABLE IF NOT EXISTS usuarios (
            id TEXT PRIMARY KEY,
            conta_id TEXT,
            nome TEXT NOT NULL,
            cpf_cnpj TEXT UNIQUE NOT NULL,
            email TEXT,
            senha_hash TEXT NOT NULL,
            perfil TEXT DEFAULT 'proprietario',
            token_version INTEGER DEFAULT 1,
            reset_token_hash TEXT,
            reset_token_expires INTEGER,
            criado_em TEXT NOT NULL
        )
    `);

    db.run(`CREATE INDEX IF NOT EXISTS idx_usuarios_conta ON usuarios (conta_id)`);
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
    senha: z.string().min(6),
    perfil: z.enum(['proprietario', 'funcionario']).default('proprietario')
});
const loginSchema = z.object({
    cpfCnpj: z.string().min(11),
    senha: z.string().min(6)
});
const requestResetSchema = z.object({ email: z.string().email() });
const confirmResetSchema = z.object({ token: z.string(), novaSenha: z.string().min(6) });

// Helper para hash do token de reset
const hashResetToken = (token) => crypto.createHash('sha256').update(token).digest('hex');

// Rotas de Autenticação
app.post('/v1/auth/register', authLimiter, async (req, res) => {
    try {
        const { nome, cpfCnpj, email, senha, perfil } = registerSchema.parse(req.body);
        const existing = await getAsync(`SELECT id FROM usuarios WHERE cpf_cnpj = ?`, [cpfCnpj]);
        if (existing) {
            return res.status(400).json({ error: 'CPF/CNPJ já cadastrado.' });
        }
        
        const salt = await bcrypt.genSalt(10);
        const hash = await bcrypt.hash(senha, salt);
        const id = crypto.randomUUID();
        const contaId = id; // Para proprietário criando a conta principal
        const now = new Date().toISOString();
        const tokenVersion = 1;

        await runAsync(
            `INSERT INTO usuarios (id, conta_id, nome, cpf_cnpj, email, senha_hash, perfil, token_version, criado_em) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [id, contaId, nome, cpfCnpj, email || null, hash, perfil, tokenVersion, now]
        );

        const token = jwt.sign(
            { id, contaId, cpfCnpj, perfil, tokenVersion }, 
            process.env.JWT_SECRET, 
            { expiresIn: process.env.JWT_EXPIRES_IN || '30d' }
        );
        res.status(201).json({ token, user: { id, contaId, nome, cpfCnpj, email, perfil } });
    } catch (e) {
        if (e instanceof z.ZodError) return res.status(400).json({ error: 'Dados inválidos.', details: e.issues || e.errors });
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

        const tokenVersion = user.token_version || 1;
        const perfil = user.perfil || 'proprietario';
        const contaId = user.conta_id || user.id;

        const token = jwt.sign(
            { id: user.id, contaId, cpfCnpj: user.cpf_cnpj, perfil, tokenVersion }, 
            process.env.JWT_SECRET, 
            { expiresIn: process.env.JWT_EXPIRES_IN || '30d' }
        );
        res.json({ token, user: { id: user.id, contaId, nome: user.nome, cpfCnpj: user.cpf_cnpj, email: user.email, perfil } });
    } catch (e) {
        if (e instanceof z.ZodError) return res.status(400).json({ error: 'Dados inválidos.', details: e.issues || e.errors });
        res.status(500).json({ error: 'Erro interno' });
    }
});

app.post('/v1/auth/password-reset/request', authLimiter, async (req, res) => {
    try {
        const { email } = requestResetSchema.parse(req.body);
        const user = await getAsync(`SELECT id FROM usuarios WHERE email = ?`, [email]);
        
        if (user) {
            const rawToken = crypto.randomBytes(4).toString('hex').toUpperCase(); // 8 chars alfanuméricos legíveis
            const hashedToken = hashResetToken(rawToken);
            const expires = Date.now() + 15 * 60 * 1000; // 15 minutos
            
            await runAsync(`UPDATE usuarios SET reset_token_hash = ?, reset_token_expires = ? WHERE id = ?`, [hashedToken, expires, user.id]);
            
            // Simulação de envio seguro de e-mail (em produção conectar com SES/Sendgrid)
            console.log(`[EMAIL SIMULADO] Para: ${email} | Token de Recuperação: ${rawToken}`);
        }
        
        res.json({ message: 'Se o e-mail estiver cadastrado, você receberá um código de recuperação.' });
    } catch (e) {
        if (e instanceof z.ZodError) return res.status(400).json({ error: 'E-mail inválido.', details: e.issues || e.errors });
        res.status(500).json({ error: 'Erro interno' });
    }
});

app.post('/v1/auth/password-reset/confirm', authLimiter, async (req, res) => {
    try {
        const { token, novaSenha } = confirmResetSchema.parse(req.body);
        const hashedToken = hashResetToken(token.trim().toUpperCase());
        
        const user = await getAsync(
            `SELECT id, token_version, reset_token_expires FROM usuarios WHERE reset_token_hash = ?`, 
            [hashedToken]
        );
        
        if (!user || user.reset_token_expires < Date.now()) {
            return res.status(400).json({ error: 'Token inválido ou expirado.' });
        }

        const salt = await bcrypt.genSalt(10);
        const hash = await bcrypt.hash(novaSenha, salt);
        const nextTokenVersion = (user.token_version || 1) + 1; // Invalida todas as sessões ativas

        await runAsync(
            `UPDATE usuarios SET senha_hash = ?, reset_token_hash = NULL, reset_token_expires = NULL, token_version = ? WHERE id = ?`, 
            [hash, nextTokenVersion, user.id]
        );
        res.json({ message: 'Senha atualizada com sucesso. Faça login novamente.' });
    } catch (e) {
        if (e instanceof z.ZodError) return res.status(400).json({ error: 'Dados inválidos.', details: e.issues || e.errors });
        res.status(400).json({ error: 'Dados inválidos.' });
    }
});

// Middleware de Autenticação JWT com verificação de revogação de sessão e Tenancy
const authenticate = async (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Token não fornecido.' });
    }
    const token = authHeader.split(' ')[1];
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        
        // Verifica se o token continua válido ou se foi revogado por troca de senha
        const user = await getAsync(`SELECT id, conta_id, perfil, token_version FROM usuarios WHERE id = ?`, [decoded.id]);
        if (!user) {
            return res.status(401).json({ error: 'Usuário não encontrado.' });
        }
        if (user.token_version !== decoded.tokenVersion) {
            return res.status(401).json({ error: 'Sessão expirada ou revogada. Faça login novamente.' });
        }

        req.user = {
            id: user.id,
            contaId: user.conta_id || user.id,
            cpfCnpj: decoded.cpfCnpj,
            perfil: user.perfil || 'proprietario'
        };
        next();
    } catch (e) {
        return res.status(401).json({ error: 'Token inválido ou expirado.' });
    }
};

// Middleware para autorização baseada em papéis (RBAC)
const requireRole = (...perfisPermitidos) => {
    return (req, res, next) => {
        if (!req.user || !perfisPermitidos.includes(req.user.perfil)) {
            return res.status(403).json({ error: 'Acesso negado para o perfil do usuário.' });
        }
        next();
    };
};

// Endpoint de Sincronização Isolado por Conta/Tenant (Multi-Tenancy)
app.post('/v1/sync', authenticate, async (req, res) => {
    const { outbox = [], lastSyncAt = "1970-01-01T00:00:00.000Z" } = req.body;
    const ownerId = req.user.contaId; // Compartilhado por todos os membros da mesma conta/fazenda
    const results = [];
    const now = new Date().toISOString();

    try {
        for (const item of outbox) {
            const { id: queueId, entityType, entityId, action, payload, deviceId, createdAt } = item;
            
            // Busca apenas entidade pertencente à conta autenticada
            const existing = await getAsync(`SELECT * FROM entities WHERE entity_id = ? AND owner_id = ?`, [entityId, ownerId]);
            
            if (existing) {
                const isConflict = existing.updated_at > createdAt && existing.device_id !== deviceId;
                
                if (isConflict && action !== 'delete') {
                    results.push({ id: queueId, status: 'conflict', serverId: existing.server_id });
                    continue; 
                } else {
                    let newDeletedAt = action === 'delete' ? createdAt : null;
                    await runAsync(
                        `UPDATE entities SET payload = ?, updated_at = ?, deleted_at = ?, device_id = ? WHERE server_id = ? AND owner_id = ?`,
                        [JSON.stringify(payload), createdAt, newDeletedAt, deviceId, existing.server_id, ownerId]
                    );
                    results.push({ id: queueId, status: 'synced', serverId: existing.server_id });
                }
            } else {
                if (action === 'delete') {
                    results.push({ id: queueId, status: 'synced', serverId: null });
                } else {
                    const serverId = crypto.randomUUID();
                    await runAsync(
                        `INSERT INTO entities (server_id, owner_id, entity_id, entity_type, payload, device_id, created_at, updated_at) 
                         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
                        [serverId, ownerId, entityId, entityType, JSON.stringify(payload), deviceId, createdAt, createdAt]
                    );
                    results.push({ id: queueId, status: 'synced', serverId: serverId });
                }
            }
        }

        // Pull de alterações filtrando estritamente pelo owner_id (conta_id)
        const changesRows = await allAsync(`SELECT * FROM entities WHERE owner_id = ? AND updated_at > ?`, [ownerId, lastSyncAt]);
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

// Gestão de Equipe e Convites (RBAC restrito a 'proprietario' e escopado por conta_id)
const inviteSchema = z.object({
    nome: z.string().min(1),
    cpfCnpj: z.string().min(11),
    email: z.string().email().optional().or(z.literal('')),
    senha: z.string().min(6),
    perfil: z.enum(['funcionario', 'proprietario']).default('funcionario')
});

app.post('/v1/users/invite', authenticate, requireRole('proprietario'), async (req, res) => {
    try {
        const { nome, cpfCnpj, email, senha, perfil } = inviteSchema.parse(req.body);
        const existing = await getAsync(`SELECT id FROM usuarios WHERE cpf_cnpj = ?`, [cpfCnpj]);
        if (existing) {
            return res.status(400).json({ error: 'CPF/CNPJ já cadastrado.' });
        }

        const salt = await bcrypt.genSalt(10);
        const hash = await bcrypt.hash(senha, salt);
        const id = crypto.randomUUID();
        const contaId = req.user.contaId; // Vinculado à conta do proprietário que convidou
        const now = new Date().toISOString();

        await runAsync(
            `INSERT INTO usuarios (id, conta_id, nome, cpf_cnpj, email, senha_hash, perfil, token_version, criado_em) VALUES (?, ?, ?, ?, ?, ?, ?, 1, ?)`,
            [id, contaId, nome, cpfCnpj, email || null, hash, perfil, now]
        );

        res.status(201).json({
            message: `Usuário cadastrado com sucesso na equipe.`,
            user: { id, contaId, nome, cpfCnpj, email, perfil }
        });
    } catch (e) {
        if (e instanceof z.ZodError) return res.status(400).json({ error: 'Dados inválidos.', details: e.issues || e.errors });
        res.status(500).json({ error: 'Erro interno' });
    }
});

app.get('/v1/users', authenticate, requireRole('proprietario'), async (req, res) => {
    try {
        // Retorna APENAS os membros da própria conta do proprietário solicitante
        const users = await allAsync(
            `SELECT id, conta_id as contaId, nome, cpf_cnpj as cpfCnpj, email, perfil, criado_em as criadoEm FROM usuarios WHERE conta_id = ?`,
            [req.user.contaId]
        );
        res.json(users);
    } catch (e) {
        res.status(500).json({ error: 'Erro interno ao listar usuários' });
    }
});

const PORT = process.env.PORT || 3000;
if (require.main === module) {
    app.listen(PORT, () => {
        console.log(`Servidor rodando na porta ${PORT}`);
    });
}

app.requireRole = requireRole;
app.authenticate = authenticate;
module.exports = app;
