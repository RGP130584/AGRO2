process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test_secret_for_automated_testing_12345';
const request = require('supertest');
const app = require('../app');
const crypto = require('crypto');

describe('Multi-Tenancy & Sync Isolation', () => {
  let tokenUserA, tokenUserB;
  let userAId, userBId;

  beforeAll(async () => {
    // Registra Usuário A
    const resA = await request(app).post('/v1/auth/register').send({
      nome: 'Usuario A (Proprietario Fazenda Sol)',
      cpfCnpj: '11111111111',
      email: 'usera@fazenda.com',
      senha: 'password123',
      perfil: 'proprietario'
    });
    tokenUserA = resA.body.token;
    userAId = resA.body.user.id;

    // Registra Usuário B
    const resB = await request(app).post('/v1/auth/register').send({
      nome: 'Usuario B (Proprietario Fazenda Lua)',
      cpfCnpj: '22222222222',
      email: 'userb@fazenda.com',
      senha: 'password123',
      perfil: 'proprietario'
    });
    tokenUserB = resB.body.token;
    userBId = resB.body.user.id;
  });

  it('should allow User A to sync an entity to their own account', async () => {
    const entityIdA = crypto.randomUUID();
    const res = await request(app)
      .post('/v1/sync')
      .set('Authorization', `Bearer ${tokenUserA}`)
      .send({
        outbox: [
          {
            id: 1,
            entityType: 'fazendas',
            entityId: entityIdA,
            action: 'create',
            payload: { id: entityIdA, nome: 'Fazenda Sol Nascente' },
            deviceId: 'device_a_01',
            createdAt: new Date().toISOString()
          }
        ],
        lastSyncAt: '1970-01-01T00:00:00.000Z'
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.results).toHaveLength(1);
    expect(res.body.results[0].status).toBe('synced');
    expect(res.body.changes).toHaveLength(1);
    expect(res.body.changes[0].payload.nome).toBe('Fazenda Sol Nascente');
  });

  it('should NEVER return User A entities to User B during sync pull (Data Isolation)', async () => {
    const res = await request(app)
      .post('/v1/sync')
      .set('Authorization', `Bearer ${tokenUserB}`)
      .send({
        outbox: [],
        lastSyncAt: '1970-01-01T00:00:00.000Z'
      });

    expect(res.statusCode).toBe(200);
    // Usuário B não deve receber nenhuma alteração do Usuário A!
    expect(res.body.changes).toHaveLength(0);
  });

  it('should reject sync requests without valid JWT token', async () => {
    const res = await request(app)
      .post('/v1/sync')
      .send({
        outbox: [],
        lastSyncAt: '1970-01-01T00:00:00.000Z'
      });

    expect(res.statusCode).toBe(401);
  });
});
