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

// Importa Middlewares para testes
const authenticate = require('./middlewares/authenticate');
const requireRole = require('./middlewares/requireRole');

const app = express();
app.use(cors());
app.use(express.json({ limit: '10mb' }));

// Monta Rotas
app.use('/v1/auth', authRoutes);
app.use('/v1/sync', syncRoutes);
app.use('/v1/users', usersRoutes);
app.use('/v1/admin', adminRoutes);

// Helper methods para testes
app.requireRole = requireRole;
app.authenticate = authenticate;

const PORT = process.env.PORT || 3000;
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
  });
}

module.exports = app;
