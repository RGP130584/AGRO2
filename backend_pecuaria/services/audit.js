/**
 * services/audit.js — Audit Trail Service (Onda 3)
 *
 * Registra eventos auditáveis em `audit_events`.
 */
const crypto = require('crypto');
const { runAsync } = require('../db/connection');

/**
 * Grava um evento de auditoria.
 *
 * @param {object} params
 * @param {string} params.actorUserId - ID do usuário que executou a ação
 * @param {string} [params.actorContaId] - conta_id do ator (tenant)
 * @param {string} params.action - Ação executada (login, register, invite, password_reset, etc.)
 * @param {string} [params.entityType] - Tipo da entidade alvo (usuario, fazenda, animal, etc.)
 * @param {string} [params.entityId] - ID da entidade alvo
 * @param {object} [params.metadata] - Dados adicionais em formato JSON
 */
async function logEvent({ actorUserId, actorContaId, action, entityType, entityId, metadata }) {
  const id = crypto.randomUUID();
  const now = new Date().toISOString();
  const metadataJson = metadata ? JSON.stringify(metadata) : null;

  await runAsync(
    `INSERT INTO audit_events (id, actor_user_id, actor_conta_id, action, entity_type, entity_id, metadata, created_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [id, actorUserId, actorContaId || null, action, entityType || null, entityId || null, metadataJson, now]
  );
}

module.exports = { logEvent };
