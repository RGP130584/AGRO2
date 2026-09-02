/**
 * middlewares/requireEntitlement.js — Controle de Acesso por Entitlements / Plano
 */
const { getAsync } = require('../db/connection');

const requireEntitlement = (...entitlementsNecessarios) => async (req, res, next) => {
  try {
    const lookupContaId = req.user.contaId || req.user.id;
    const sub = await getAsync(
      `SELECT p.entitlements FROM subscriptions s
       JOIN plans p ON p.id = s.plan_id
       WHERE s.conta_id = ? AND s.status = 'active'
       AND (s.ends_at IS NULL OR s.ends_at > ?)`,
      [lookupContaId, new Date().toISOString()]
    );

    const entitlements = sub ? JSON.parse(sub.entitlements) : [];
    const temAcesso = entitlementsNecessarios.every(e => entitlements.includes(e));

    if (!temAcesso) {
      return res.status(403).json({ error: 'Plano atual não inclui este recurso.' });
    }

    next();
  } catch (err) {
    console.error('Erro ao verificar entitlements:', err);
    res.status(500).json({ error: 'Erro interno ao validar plano.' });
  }
};

module.exports = requireEntitlement;
