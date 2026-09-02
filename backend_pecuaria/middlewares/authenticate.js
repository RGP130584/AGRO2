/**
 * middlewares/authenticate.js — JWT Authentication com verificação de revogação e Tenancy
 */
const jwt = require('jsonwebtoken');
const { getAsync } = require('../db/connection');

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

    let veterinarianId = decoded.veterinarianId || null;
    if (user.perfil === 'veterinario' && !veterinarianId) {
      const vet = await getAsync(`SELECT id FROM veterinarians WHERE usuario_id = ?`, [user.id]);
      if (vet) veterinarianId = vet.id;
    }

    req.user = {
      id: user.id,
      contaId: user.perfil === 'veterinario' ? null : (user.conta_id || user.id),
      cpfCnpj: decoded.cpfCnpj,
      perfil: user.perfil || 'proprietario',
      veterinarianId
    };
    next();
  } catch (e) {
    return res.status(401).json({ error: 'Token inválido ou expirado.' });
  }
};

module.exports = authenticate;
