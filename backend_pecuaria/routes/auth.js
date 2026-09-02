/**
 * routes/auth.js — Rotas de Autenticação (register, login, password-reset)
 */
const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const { z } = require('zod');
const rateLimit = require('express-rate-limit');
const { runAsync, getAsync } = require('../db/connection');
const { logEvent } = require('../services/audit');

const router = express.Router();

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
  perfil: z.enum(['proprietario', 'funcionario', 'veterinario']).default('proprietario'),
  crmv: z.string().optional(),
  telefone: z.string().optional()
});
const loginSchema = z.object({
  cpfCnpj: z.string().min(11),
  senha: z.string().min(6)
});
const requestResetSchema = z.object({ email: z.string().email() });
const confirmResetSchema = z.object({ token: z.string(), novaSenha: z.string().min(6) });

// Helper para hash do token de reset
const hashResetToken = (token) => crypto.createHash('sha256').update(token).digest('hex');

// ── Register ─────────────────────────────────────────────────────────
router.post('/register', authLimiter, async (req, res) => {
  try {
    const { nome, cpfCnpj, email, senha, perfil, crmv, telefone } = registerSchema.parse(req.body);
    const existing = await getAsync(`SELECT id FROM usuarios WHERE cpf_cnpj = ?`, [cpfCnpj]);
    if (existing) {
      return res.status(400).json({ error: 'CPF/CNPJ já cadastrado.' });
    }

    if (perfil === 'veterinario' && crmv) {
      const existingCrmv = await getAsync(`SELECT id FROM veterinarians WHERE crmv = ?`, [crmv]);
      if (existingCrmv) {
        return res.status(400).json({ error: 'CRMV já cadastrado.' });
      }
    }

    const salt = await bcrypt.genSalt(10);
    const hash = await bcrypt.hash(senha, salt);
    const id = crypto.randomUUID();
    const contaId = perfil === 'veterinario' ? null : id; // Veterinário não tem conta_id fixo
    const now = new Date().toISOString();
    const tokenVersion = 1;

    await runAsync(
      `INSERT INTO usuarios (id, conta_id, nome, cpf_cnpj, email, senha_hash, perfil, token_version, criado_em) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [id, contaId, nome, cpfCnpj, email || null, hash, perfil, tokenVersion, now]
    );

    let veterinarianId = null;
    if (perfil === 'veterinario') {
      veterinarianId = crypto.randomUUID();
      await runAsync(
        `INSERT INTO veterinarians (id, usuario_id, nome, crmv, telefone, criado_em) VALUES (?, ?, ?, ?, ?, ?)`,
        [veterinarianId, id, nome, crmv || null, telefone || null, now]
      );

      // Subscription VET_PRO para o veterinário
      await runAsync(
        `INSERT INTO subscriptions (id, conta_id, plan_id, status, starts_at, ends_at, created_at) VALUES (?, ?, ?, ?, ?, NULL, ?)`,
        [crypto.randomUUID(), id, 'VET_PRO', 'active', now, now]
      );
    } else {
      // Cria subscription padrão CORE ativa para a nova conta de produtor
      await runAsync(
        `INSERT INTO subscriptions (id, conta_id, plan_id, status, starts_at, ends_at, created_at) VALUES (?, ?, ?, ?, ?, NULL, ?)`,
        [crypto.randomUUID(), contaId, 'CORE', 'active', now, now]
      );
    }

    const tokenPayload = {
      id,
      contaId,
      cpfCnpj,
      perfil,
      tokenVersion,
      ...(veterinarianId && { veterinarianId })
    };

    const token = jwt.sign(
      tokenPayload,
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '30d' }
    );

    // Audit trail
    await logEvent({ actorUserId: id, actorContaId: contaId, action: 'register', entityType: 'usuario', entityId: id });

    res.status(201).json({
      token,
      user: {
        id,
        contaId,
        nome,
        cpfCnpj,
        email,
        perfil,
        ...(veterinarianId && { veterinarianId, crmv })
      }
    });
  } catch (e) {
    if (e instanceof z.ZodError) return res.status(400).json({ error: 'Dados inválidos.', details: e.issues || e.errors });
    res.status(500).json({ error: 'Erro interno' });
  }
});

// ── Login ────────────────────────────────────────────────────────────
router.post('/login', authLimiter, async (req, res) => {
  try {
    const { cpfCnpj, senha } = loginSchema.parse(req.body);
    const user = await getAsync(`SELECT * FROM usuarios WHERE cpf_cnpj = ?`, [cpfCnpj]);
    if (!user) return res.status(401).json({ error: 'Credenciais inválidas.' });

    const isMatch = await bcrypt.compare(senha, user.senha_hash);
    if (!isMatch) return res.status(401).json({ error: 'Credenciais inválidas.' });

    const tokenVersion = user.token_version || 1;
    const perfil = user.perfil || 'proprietario';
    const contaId = perfil === 'veterinario' ? null : (user.conta_id || user.id);

    let veterinarianId = null;
    let crmv = null;
    if (perfil === 'veterinario') {
      const vet = await getAsync(`SELECT id, crmv FROM veterinarians WHERE usuario_id = ?`, [user.id]);
      if (vet) {
        veterinarianId = vet.id;
        crmv = vet.crmv;
      }
    }

    const tokenPayload = {
      id: user.id,
      contaId,
      cpfCnpj: user.cpf_cnpj,
      perfil,
      tokenVersion,
      ...(veterinarianId && { veterinarianId })
    };

    const token = jwt.sign(
      tokenPayload,
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '30d' }
    );

    // Audit trail
    await logEvent({ actorUserId: user.id, actorContaId: contaId, action: 'login', entityType: 'usuario', entityId: user.id });

    res.json({
      token,
      user: {
        id: user.id,
        contaId,
        nome: user.nome,
        cpfCnpj: user.cpf_cnpj,
        email: user.email,
        perfil,
        ...(veterinarianId && { veterinarianId, crmv })
      }
    });
  } catch (e) {
    if (e instanceof z.ZodError) return res.status(400).json({ error: 'Dados inválidos.', details: e.issues || e.errors });
    res.status(500).json({ error: 'Erro interno' });
  }
});

// ── Request Password Reset ───────────────────────────────────────────
router.post('/password-reset/request', authLimiter, async (req, res) => {
  try {
    const { email } = requestResetSchema.parse(req.body);
    const user = await getAsync(`SELECT id FROM usuarios WHERE email = ?`, [email]);

    if (user) {
      const rawToken = crypto.randomBytes(4).toString('hex').toUpperCase(); // 8 chars
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

// ── Confirm Password Reset ──────────────────────────────────────────
router.post('/password-reset/confirm', authLimiter, async (req, res) => {
  try {
    const { token, novaSenha } = confirmResetSchema.parse(req.body);
    const hashedToken = hashResetToken(token.trim().toUpperCase());

    const user = await getAsync(
      `SELECT id, conta_id, token_version, reset_token_expires FROM usuarios WHERE reset_token_hash = ?`,
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

    // Audit trail
    await logEvent({
      actorUserId: user.id,
      actorContaId: user.conta_id || user.id,
      action: 'password_reset',
      entityType: 'usuario',
      entityId: user.id,
    });

    res.json({ message: 'Senha atualizada com sucesso. Faça login novamente.' });
  } catch (e) {
    if (e instanceof z.ZodError) return res.status(400).json({ error: 'Dados inválidos.', details: e.issues || e.errors });
    res.status(400).json({ error: 'Dados inválidos.' });
  }
});

module.exports = router;
