require('dotenv').config();
const express = require('express');
const cors = require('cors');

// Inicializa a conexão e schema do banco
const { dbFile } = require('./db/connection');
const { initializeSchema } = require('./db/schema');
initializeSchema();

// Importa Rotas
const authRoutes = require('./routes/auth');
const syncRoutes = require('./routes/sync');
const usersRoutes = require('./routes/users');
const adminRoutes = require('./routes/admin');
const subscriptionRoutes = require('./routes/subscription');
const vetRoutes = require('./routes/vet');

// Importa Middlewares para testes
const authenticate = require('./middlewares/authenticate');
const requireRole = require('./middlewares/requireRole');
const requireEntitlement = require('./middlewares/requireEntitlement');
const authorizeGrant = require('./middlewares/authorizeGrant');

const app = express();

const allowedOrigins = (process.env.CORS_ORIGINS || '').split(',').map(o => o.trim()).filter(Boolean);
app.use(cors({
  origin: (origin, callback) => {
    // Permite requisições sem origin (ex.: apps mobile, curl, Postman)
    if (!origin || allowedOrigins.includes('*') || allowedOrigins.includes(origin)) {
      return callback(null, true);
    }
    return callback(new Error('Origem não permitida por CORS'));
  }
}));
app.use(express.json({ limit: '10mb' }));

// Monta Rotas
app.use('/v1/auth', authRoutes);
app.use('/v1/sync', syncRoutes);
app.use('/v1/users', usersRoutes);
app.use('/v1/admin', adminRoutes);
app.use('/v1/subscription', subscriptionRoutes);
app.use('/v1/vet', vetRoutes);

// Helper methods para testes
app.requireRole = requireRole;
app.authenticate = authenticate;
app.requireEntitlement = requireEntitlement;
app.authorizeGrant = authorizeGrant;

const PORT = process.env.PORT || 3000;
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
  });
}

module.exports = app;
