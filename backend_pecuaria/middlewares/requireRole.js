/**
 * middlewares/requireRole.js — Autorização baseada em papéis (RBAC)
 */
const requireRole = (...perfisPermitidos) => {
  return (req, res, next) => {
    if (!req.user || !perfisPermitidos.includes(req.user.perfil)) {
      return res.status(403).json({ error: 'Acesso negado para o perfil do usuário.' });
    }
    next();
  };
};

module.exports = requireRole;
