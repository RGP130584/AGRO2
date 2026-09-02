/**
 * routes/users.js — Rotas de Usuários e Convites de Equipe
 */
const express = require('express');
const crypto = require('crypto');
const bcrypt = require('bcrypt');
const { z } = require('zod');
const { runAsync, getAsync, allAsync } = require('../db/connection');
const authenticate = require('../middlewares/authenticate');
const requireRole = require('../middlewares/requireRole');
const requireEntitlement = require('../middlewares/requireEntitlement');
const { logEvent } = require('../services/audit');

const router = express.Router();

const inviteSchema = z.object({
  nome: z.string().min(1),
  cpfCnpj: z.string().min(11),
  email: z.string().email().optional().or(z.literal('')),
  senha: z.string().min(6),
  perfil: z.enum(['funcionario', 'proprietario']).default('funcionario')
});

// ── Convite de Membro da Equipe ──────────────────────────────────────
router.post('/invite', authenticate, requireRole('proprietario'), requireEntitlement('CORE'), async (req, res) => {
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

    // Audit trail
    await logEvent({
      actorUserId: req.user.id,
      actorContaId: contaId,
      action: 'invite',
      entityType: 'usuario',
      entityId: id,
      metadata: { convidado_perfil: perfil }
    });

    res.status(201).json({
      message: `Usuário cadastrado com sucesso na equipe.`,
      user: { id, contaId, nome, cpfCnpj, email, perfil }
    });
  } catch (e) {
    if (e instanceof z.ZodError) return res.status(400).json({ error: 'Dados inválidos.', details: e.issues || e.errors });
    res.status(500).json({ error: 'Erro interno' });
  }
});

// ── Listar Membros da Equipe ─────────────────────────────────────────
router.get('/', authenticate, requireRole('proprietario'), requireEntitlement('CORE'), async (req, res) => {
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

module.exports = router;
