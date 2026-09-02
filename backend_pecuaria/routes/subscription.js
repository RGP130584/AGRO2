/**
 * routes/subscription.js — Consulta de Assinatura e Entitlements Ativos
 */
const express = require('express');
const { getAsync } = require('../db/connection');
const authenticate = require('../middlewares/authenticate');

const router = express.Router();

// ── GET /v1/subscription — Detalhes da assinatura e recursos ativos ──
router.get('/', authenticate, async (req, res) => {
  try {
    const sub = await getAsync(
      `SELECT s.id as subscriptionId, s.status, s.starts_at as startsAt, s.ends_at as endsAt,
              p.id as planId, p.nome as planNome, p.entitlements
       FROM subscriptions s
       JOIN plans p ON p.id = s.plan_id
       WHERE s.conta_id = ? AND s.status = 'active'
       AND (s.ends_at IS NULL OR s.ends_at > ?)
       ORDER BY s.created_at DESC
       LIMIT 1`,
      [req.user.contaId, new Date().toISOString()]
    );

    if (!sub) {
      return res.json({
        hasActiveSubscription: false,
        plan: null,
        entitlements: []
      });
    }

    res.json({
      hasActiveSubscription: true,
      subscriptionId: sub.subscriptionId,
      status: sub.status,
      startsAt: sub.startsAt,
      endsAt: sub.endsAt,
      plan: {
        id: sub.planId,
        nome: sub.planNome,
      },
      entitlements: JSON.parse(sub.entitlements)
    });
  } catch (error) {
    console.error('Erro ao buscar subscription:', error);
    res.status(500).json({ error: 'Erro interno ao consultar assinatura' });
  }
});

module.exports = router;
