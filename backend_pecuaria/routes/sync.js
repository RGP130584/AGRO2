/**
 * routes/sync.js — Endpoint de Sincronização com Projeção de Domínio
 */
const express = require('express');
const crypto = require('crypto');
const { runAsync, getAsync, allAsync } = require('../db/connection');
const authenticate = require('../middlewares/authenticate');
const requireEntitlement = require('../middlewares/requireEntitlement');
const authorizeGrant = require('../middlewares/authorizeGrant');
const { projectEntity } = require('../services/projector');

const router = express.Router();

// ── POST /v1/sync — Sincronização Isolada por Conta/Tenant ou Grant ──
router.post('/', authenticate, requireEntitlement('CORE'), authorizeGrant('consulta'), async (req, res) => {
  const { outbox = [], lastSyncAt = "1970-01-01T00:00:00.000Z" } = req.body;
  const ownerId = req.effectiveOwnerId || req.user.contaId;
  const results = [];
  const now = new Date().toISOString();

  // Se for veterinário e estiver tentando enviar alterações (push)
  if (req.user.perfil === 'veterinario' && outbox.length > 0) {
    const permissoes = JSON.parse(req.grant?.permissions || '[]');
    const podeAlterar = permissoes.includes('intervencao') || permissoes.includes('tecnico') || permissoes.includes('administrativo');
    if (!podeAlterar) {
      return res.status(403).json({ error: 'Nível de permissão insuficiente para enviar alterações (exige técnico ou intervenção).' });
    }
  }

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

          // Projetar para tabela de domínio (Onda 1)
          await projectEntity(entityType, entityId, ownerId, payload, createdAt, newDeletedAt);
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

          // Projetar para tabela de domínio (Onda 1)
          await projectEntity(entityType, entityId, ownerId, payload, createdAt, null);
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

module.exports = router;
