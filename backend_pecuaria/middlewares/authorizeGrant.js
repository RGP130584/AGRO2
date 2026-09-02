/**
 * middlewares/authorizeGrant.js — Autorização e Resolução de Escopo por Sharing Grant
 */
const { getAsync } = require('../db/connection');

/**
 * Middleware para validar se um usuário tem permissão sobre um determinado tenant/fazenda.
 * Se o usuário for proprietário ou funcionário da própria conta, concede acesso direto.
 * Se for veterinário, valida se existe um sharing_grant ativo cobrindo o escopo e a permissão mínima.
 * 
 * @param {string} permissaoMinima - 'consulta' | 'tecnico' | 'intervencao' | 'administrativo'
 */
const authorizeGrant = (permissaoMinima = 'consulta') => async (req, res, next) => {
  try {
    const targetContaId = req.params.contaId || req.params.fazendaId || req.query.tenantContaId || req.body.tenantContaId || req.headers['x-tenant-conta-id'] || req.user.contaId;

    if (!targetContaId) {
      return res.status(400).json({ error: 'Identificador da fazenda/conta não informado.' });
    }

    // Se o usuário faz parte da própria conta (proprietário ou funcionário)
    if (req.user.contaId && req.user.contaId === targetContaId) {
      req.effectiveOwnerId = targetContaId;
      return next();
    }

    // Se for veterinário, verifica o sharing_grant
    if (req.user.perfil === 'veterinario') {
      if (!req.user.veterinarianId) {
        return res.status(403).json({ error: 'Perfil profissional de veterinário não configurado.' });
      }

      const grant = await getAsync(
        `SELECT * FROM sharing_grants
         WHERE veterinarian_id = ? AND tenant_conta_id = ? AND status = 'active'
         AND (expires_at IS NULL OR expires_at > ?)`,
        [req.user.veterinarianId, targetContaId, new Date().toISOString()]
      );

      if (!grant) {
        return res.status(403).json({ error: 'Sem acesso ativo a esta fazenda.' });
      }

      const permissoes = JSON.parse(grant.permissions || '[]');
      const ordem = ['consulta', 'tecnico', 'intervencao', 'administrativo'];
      const indexMinimo = ordem.indexOf(permissaoMinima);
      const niveisConcedidos = permissoes.map(p => ordem.indexOf(p)).filter(idx => idx >= 0);
      const maxPermissaoUsuario = niveisConcedidos.length > 0 ? Math.max(...niveisConcedidos) : -1;

      if (indexMinimo > maxPermissaoUsuario) {
        return res.status(403).json({ error: 'Nível de permissão insuficiente para esta operação.' });
      }

      req.grant = grant;
      req.effectiveOwnerId = targetContaId;
      return next();
    }

    return res.status(403).json({ error: 'Acesso negado a esta fazenda.' });
  } catch (err) {
    console.error('Erro na autorização de grant:', err);
    res.status(500).json({ error: 'Erro interno ao validar autorização de acesso.' });
  }
};

module.exports = authorizeGrant;
