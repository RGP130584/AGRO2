process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test_secret_for_automated_testing_12345';
const request = require('supertest');
const app = require('../app');
const { getAsync } = require('../db/connection');

describe('Sharing Grants & Módulo Veterinário (Onda 5)', () => {
  let ownerAToken, contaIdA;
  let ownerBToken, contaIdB;
  let vetToken, vetUserId, veterinarianId;
  let grantId;

  beforeAll(async () => {
    // 1. Registrar Proprietário Fazenda A
    const resOwnerA = await request(app).post('/v1/auth/register').send({
      nome: 'Proprietario Fazenda Alfa',
      cpfCnpj: '11133355577',
      email: 'fazendaAlfa@teste.com',
      senha: 'senhaOwner123',
      perfil: 'proprietario'
    });
    expect(resOwnerA.status).toBe(201);
    ownerAToken = resOwnerA.body.token;
    contaIdA = resOwnerA.body.user.contaId;

    // 2. Registrar Proprietário Fazenda B (Outro tenant)
    const resOwnerB = await request(app).post('/v1/auth/register').send({
      nome: 'Proprietario Fazenda Beta',
      cpfCnpj: '22244466688',
      email: 'fazendaBeta@teste.com',
      senha: 'senhaOwner123',
      perfil: 'proprietario'
    });
    expect(resOwnerB.status).toBe(201);
    ownerBToken = resOwnerB.body.token;
    contaIdB = resOwnerB.body.user.contaId;

    // 3. Registrar Veterinário Profissional
    const resVet = await request(app).post('/v1/auth/register').send({
      nome: 'Dr. Roberto Silva',
      cpfCnpj: '99988877766',
      crmv: 'CRMV-SP-99887',
      email: 'dr.roberto@vet.com',
      senha: 'senhaVet123',
      perfil: 'veterinario'
    });
    expect(resVet.status).toBe(201);
    vetToken = resVet.body.token;
    vetUserId = resVet.body.user.id;
    veterinarianId = resVet.body.user.veterinarianId;
    expect(veterinarianId).toBeDefined();
  });

  it('1. Produtor A convida Veterinário por CRMV -> cria grant pending', async () => {
    const res = await request(app)
      .post('/v1/vet/grants')
      .set('Authorization', `Bearer ${ownerAToken}`)
      .send({
        crmv: 'CRMV-SP-99887',
        scopeType: 'fazenda',
        permissions: ['consulta', 'tecnico', 'intervencao']
      });

    expect(res.status).toBe(201);
    expect(res.body.grant.status).toBe('pending');
    expect(res.body.grant.veterinarianId).toBe(veterinarianId);
    grantId = res.body.grant.id;

    // Verifica log de auditoria
    const audit = await getAsync(`SELECT * FROM audit_events WHERE action = 'grant_created' AND entity_id = ?`, [grantId]);
    expect(audit).toBeTruthy();
  });

  it('2. Veterinário lista convites pendentes e aceita com consentimento LGPD versionado', async () => {
    // Listar convites
    const listRes = await request(app)
      .get('/v1/vet/grants')
      .set('Authorization', `Bearer ${vetToken}`);

    expect(listRes.status).toBe(200);
    expect(listRes.body.length).toBeGreaterThan(0);
    const pendente = listRes.body.find(g => g.id === grantId);
    expect(pendente.status).toBe('pending');

    // Aceite exigindo termsVersion
    const acceptRes = await request(app)
      .post(`/v1/vet/grants/${grantId}/accept`)
      .set('Authorization', `Bearer ${vetToken}`)
      .send({ termsVersion: 'v2026.1-lgpd-operador' });

    expect(acceptRes.status).toBe(200);
    expect(acceptRes.body.grant.status).toBe('active');

    // Verifica se consentimento LGPD foi registrado no audit trail
    const auditAccept = await getAsync(`SELECT * FROM audit_events WHERE action = 'grant_accepted' AND entity_id = ?`, [grantId]);
    expect(auditAccept).toBeTruthy();
    const meta = JSON.parse(auditAccept.metadata);
    expect(meta.termsVersion).toBe('v2026.1-lgpd-operador');
  });

  it('3. Veterinário sincroniza dados na Fazenda A usando o grant ativo', async () => {
    const animalId = 'animal-vet-alfa-01';
    const syncRes = await request(app)
      .post('/v1/sync')
      .set('Authorization', `Bearer ${vetToken}`)
      .send({
        tenantContaId: contaIdA,
        outbox: [{
          id: 1,
          entityType: 'animais',
          entityId: animalId,
          action: 'insert',
          payload: { id: animalId, brinco: 'VET-BR-01', raca: 'Nelore PO' },
          deviceId: 'device-vet-tablet',
          createdAt: new Date().toISOString()
        }]
      });

    expect(syncRes.status).toBe(200);
    expect(syncRes.body.results[0].status).toBe('synced');

    // Produtor A faz sync e recebe o animal cadastrado pelo veterinário
    const pullA = await request(app)
      .post('/v1/sync')
      .set('Authorization', `Bearer ${ownerAToken}`)
      .send({ outbox: [] });

    expect(pullA.status).toBe(200);
    const encontrado = pullA.body.changes.find(c => c.entityId === animalId);
    expect(encontrado).toBeDefined();
    expect(encontrado.payload.brinco).toBe('VET-BR-01');
  });

  it('4. Veterinário é BLOQUEADO (403) ao tentar acessar Fazenda B sem grant', async () => {
    const syncB = await request(app)
      .post('/v1/sync')
      .set('Authorization', `Bearer ${vetToken}`)
      .send({
        tenantContaId: contaIdB,
        outbox: []
      });

    expect(syncB.status).toBe(403);
    expect(syncB.body.error).toContain('Sem acesso ativo');
  });

  it('5. Produtor A revoga acesso -> Veterinário perde acesso imediatamente', async () => {
    // Revogação pelo Produtor A
    const revokeRes = await request(app)
      .delete(`/v1/vet/grants/${grantId}`)
      .set('Authorization', `Bearer ${ownerAToken}`);

    expect(revokeRes.status).toBe(200);
    expect(revokeRes.body.status).toBe('revoked');

    // Nova tentativa de sync pelo Veterinário é rejeitada com 403
    const syncAposRevogacao = await request(app)
      .post('/v1/sync')
      .set('Authorization', `Bearer ${vetToken}`)
      .send({
        tenantContaId: contaIdA,
        outbox: []
      });

    expect(syncAposRevogacao.status).toBe(403);

    // Produtor A continua com acesso total e histórico preservado
    const pullAposRevogacao = await request(app)
      .post('/v1/sync')
      .set('Authorization', `Bearer ${ownerAToken}`)
      .send({ outbox: [] });

    expect(pullAposRevogacao.status).toBe(200);
    const animalPreservado = pullAposRevogacao.body.changes.find(c => c.entityId === 'animal-vet-alfa-01');
    expect(animalPreservado).toBeDefined();
  });
});
