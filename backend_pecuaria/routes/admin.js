/**
 * routes/admin.js — Rotas Administrativas (Auditoria e Reconciliação)
 */
const express = require('express');
const { runAsync, getAsync, allAsync } = require('../db/connection');
const authenticate = require('../middlewares/authenticate');
const requireRole = require('../middlewares/requireRole');
const { projectEntity, getSupportedEntityTypes } = require('../services/projector');

const router = express.Router();

// ── GET /v1/admin/audit — Audit Trail ────────────────────────────────
router.get('/audit', authenticate, requireRole('proprietario'), async (req, res) => {
  try {
    const limit = parseInt(req.query.limit, 10) || 50;
    
    // Proprietário só vê logs do seu próprio tenant
    const logs = await allAsync(
      `SELECT * FROM audit_events WHERE actor_conta_id = ? ORDER BY created_at DESC LIMIT ?`,
      [req.user.contaId, limit]
    );

    res.json(logs);
  } catch (e) {
    res.status(500).json({ error: 'Erro interno ao consultar auditoria' });
  }
});

// ── POST /v1/admin/reconcile — Reconstrói tabelas de domínio ─────────
router.post('/reconcile', authenticate, requireRole('proprietario'), async (req, res) => {
  try {
    const supportedTypes = getSupportedEntityTypes();
    const placeholders = supportedTypes.map(() => '?').join(',');
    
    // Reprojeta apenas os dados do próprio tenant
    const entities = await allAsync(
      `SELECT * FROM entities WHERE owner_id = ? AND entity_type IN (${placeholders})`,
      [req.user.contaId, ...supportedTypes]
    );

    let count = 0;
    for (const row of entities) {
      try {
        const payload = JSON.parse(row.payload);
        await projectEntity(
          row.entity_type,
          row.entity_id,
          row.owner_id,
          payload,
          row.updated_at,
          row.deleted_at
        );
        count++;
      } catch (err) {
        console.error(`Erro ao reprojetar entity_id ${row.entity_id}:`, err);
      }
    }

    res.json({ message: 'Reconciliação concluída com sucesso', count });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Erro interno durante reconciliação' });
  }
});

module.exports = router;
