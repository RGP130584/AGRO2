process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test_secret_for_automated_testing_12345';
const request = require('supertest');
const app = require('../app');
const { getAsync } = require('../db/connection');

describe('Audit Trail', () => {
  let token;
  let userId;
  let contaId;

  beforeAll(async () => {
    const res = await request(app)
      .post('/v1/auth/register')
      .send({
        nome: 'Proprietario Audit',
        cpfCnpj: '88899911122',
        email: 'audit@teste.com',
        senha: 'senhaOwner123',
        perfil: 'proprietario'
      });
    expect(res.status).toBe(201);
    token = res.body.token;
    userId = res.body.user.id;
    contaId = res.body.user.contaId;
  });

  it('deve logar evento de register', async () => {
    const audit = await getAsync(`SELECT * FROM audit_events WHERE action = 'register' AND actor_conta_id = ?`, [contaId]);
    expect(audit).toBeTruthy();
    expect(audit.actor_user_id).toBe(userId);
  });

  it('deve logar evento de login', async () => {
    const res = await request(app).post('/v1/auth/login').send({ cpfCnpj: '88899911122', senha: 'senhaOwner123' });
    expect(res.status).toBe(200);

    const audit = await getAsync(`SELECT * FROM audit_events WHERE action = 'login' AND actor_conta_id = ?`, [contaId]);
    expect(audit).toBeTruthy();
    expect(audit.actor_user_id).toBe(userId);
  });

  it('deve consultar eventos de auditoria', async () => {
    const res = await request(app)
      .get('/v1/admin/audit')
      .set('Authorization', `Bearer ${token}`);

    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    expect(res.body.length).toBeGreaterThanOrEqual(2);
  });
});
