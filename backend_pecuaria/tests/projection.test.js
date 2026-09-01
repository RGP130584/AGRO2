process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test_secret_for_automated_testing_12345';
const request = require('supertest');
const app = require('../app');
const crypto = require('crypto');
const { getAsync, runAsync } = require('../db/connection');

describe('Projection & Reconciliation', () => {
  let token;
  const animalEntityId = crypto.randomUUID();

  beforeAll(async () => {
    // Registrar Proprietário
    const res = await request(app)
      .post('/v1/auth/register')
      .send({
        nome: 'Proprietario Projecao',
        cpfCnpj: '11122233344',
        email: 'proj@teste.com',
        senha: 'senhaOwner123',
        perfil: 'proprietario'
      });
    token = res.body.token;
  });

  it('deve projetar um animal automaticamente ao sincronizar', async () => {
    const payload = {
      brinco: 'VACA-123',
      tipoAnimal: 'Bovino',
      pesoKg: 450
    };

    const outbox = [{
      id: 1,
      entityType: 'animais',
      entityId: animalEntityId,
      action: 'insert',
      payload: payload,
      deviceId: 'device-1',
      createdAt: new Date().toISOString()
    }];

    const res = await request(app)
      .post('/v1/sync')
      .set('Authorization', `Bearer ${token}`)
      .send({ outbox });

    expect(res.status).toBe(200);

    // Verifica a tabela projetada
    const proj = await getAsync(`SELECT * FROM proj_animais WHERE entity_id = ?`, [animalEntityId]);
    expect(proj).toBeTruthy();
    expect(proj.brinco).toBe('VACA-123');
    expect(proj.peso_kg).toBe(450);
  });

  it('deve reprojetar tudo no endpoint de reconciliacao', async () => {
    // Apaga a projeção manualmente
    await runAsync(`DELETE FROM proj_animais WHERE entity_id = ?`, [animalEntityId]);
    
    let proj = await getAsync(`SELECT * FROM proj_animais WHERE entity_id = ?`, [animalEntityId]);
    expect(proj).toBeUndefined();

    const res = await request(app)
      .post('/v1/admin/reconcile')
      .set('Authorization', `Bearer ${token}`);

    expect(res.status).toBe(200);
    expect(res.body.count).toBeGreaterThan(0);

    // Verifica se voltou a existir
    proj = await getAsync(`SELECT * FROM proj_animais WHERE entity_id = ?`, [animalEntityId]);
    expect(proj).toBeTruthy();
    expect(proj.brinco).toBe('VACA-123');
  });
});
