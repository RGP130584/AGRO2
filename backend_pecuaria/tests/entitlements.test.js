process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test_secret_for_automated_testing_12345';
const request = require('supertest');
const app = require('../app');
const crypto = require('crypto');
const { runAsync } = require('../db/connection');

// Rota de teste simulada que exige VET_PORTAL
app.get('/v1/test/vet-portal-route', app.authenticate, app.requireEntitlement('VET_PORTAL'), (req, res) => {
  res.json({ success: true, message: 'Bem-vindo ao Portal Veterinário' });
});

describe('Entitlements & Subscription (Onda 4)', () => {
  let tokenUserCore;
  let contaIdCore;

  beforeAll(async () => {
    // 1. Cadastra usuário Produtor (deve ganhar plano CORE automaticamente)
    const res = await request(app)
      .post('/v1/auth/register')
      .send({
        nome: 'Produtor Onda 4',
        cpfCnpj: '55566677788',
        email: 'onda4@teste.com',
        senha: 'senhaOwner123',
        perfil: 'proprietario'
      });
    expect(res.status).toBe(201);
    tokenUserCore = res.body.token;
    contaIdCore = res.body.user.contaId;
  });

  it('GET /v1/subscription deve retornar plano ativo e lista de entitlements CORE', async () => {
    const res = await request(app)
      .get('/v1/subscription')
      .set('Authorization', `Bearer ${tokenUserCore}`);

    expect(res.status).toBe(200);
    expect(res.body.hasActiveSubscription).toBe(true);
    expect(res.body.plan.id).toBe('CORE');
    expect(res.body.entitlements).toContain('CORE');
  });

  it('Conta com CORE acessa normalmente as rotas core (/v1/sync)', async () => {
    const res = await request(app)
      .post('/v1/sync')
      .set('Authorization', `Bearer ${tokenUserCore}`)
      .send({ outbox: [] });

    expect(res.status).toBe(200);
  });

  it('Conta com CORE é bloqueada com 403 em rota exclusiva do Veterinário (VET_PORTAL)', async () => {
    const res = await request(app)
      .get('/v1/test/vet-portal-route')
      .set('Authorization', `Bearer ${tokenUserCore}`);

    expect(res.status).toBe(403);
    expect(res.body.error).toBe('Plano atual não inclui este recurso.');
  });

  it('Conta com upgrade para VET_PRO acessa rota VET_PORTAL com sucesso', async () => {
    // Atualiza a assinatura da conta para VET_PRO
    await runAsync(
      `UPDATE subscriptions SET plan_id = 'VET_PRO' WHERE conta_id = ?`,
      [contaIdCore]
    );

    // Consulta subscription novamente
    const subRes = await request(app)
      .get('/v1/subscription')
      .set('Authorization', `Bearer ${tokenUserCore}`);

    expect(subRes.status).toBe(200);
    expect(subRes.body.plan.id).toBe('VET_PRO');
    expect(subRes.body.entitlements).toContain('VET_PORTAL');

    // Tenta acessar a rota do veterinário
    const res = await request(app)
      .get('/v1/test/vet-portal-route')
      .set('Authorization', `Bearer ${tokenUserCore}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
  });

  it('Conta com subscription cancelada ou expirada recebe 403', async () => {
    // Invalida a assinatura
    await runAsync(
      `UPDATE subscriptions SET status = 'canceled' WHERE conta_id = ?`,
      [contaIdCore]
    );

    const res = await request(app)
      .post('/v1/sync')
      .set('Authorization', `Bearer ${tokenUserCore}`)
      .send({ outbox: [] });

    expect(res.status).toBe(403);
  });
});
