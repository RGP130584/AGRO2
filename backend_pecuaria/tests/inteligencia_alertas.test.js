process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test_secret_for_automated_testing_12345';
const request = require('supertest');
const app = require('../app');
const crypto = require('crypto');
const { projectEntity } = require('../services/projector');

describe('Inteligência — Motor de Alertas Baseados em Regra (Onda 10)', () => {
  let ownerToken, contaId;
  let vetToken, veterinarianId;
  const loteId = 'lote-alertas-01';
  const animal1Id = 'ani-alerta-01';
  const animal2Id = 'ani-alerta-02';

  beforeAll(async () => {
    // 1. Produtor
    const resOwner = await request(app).post('/v1/auth/register').send({
      nome: 'Produtor Fazenda Alertas',
      cpfCnpj: '77733388800',
      email: 'fazendaAlertas@teste.com',
      senha: 'senhaOwner123',
      perfil: 'proprietario'
    });
    ownerToken = resOwner.body.token;
    contaId = resOwner.body.user.contaId;

    // 2. Veterinário
    const resVet = await request(app).post('/v1/auth/register').send({
      nome: 'Dr. Fábio Alertas',
      cpfCnpj: '33377766644',
      crmv: 'CRMV-RJ-12333',
      email: 'fabio@vet.com',
      senha: 'senhaVet123',
      perfil: 'veterinario'
    });
    vetToken = resVet.body.token;
    veterinarianId = resVet.body.user.veterinarianId;

    const grantRes = await request(app)
      .post('/v1/vet/grants')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({ crmv: 'CRMV-RJ-12333', permissions: ['consulta', 'tecnico', 'intervencao'] });

    await request(app)
      .post(`/v1/vet/grants/${grantRes.body.grant.id}/accept`)
      .set('Authorization', `Bearer ${vetToken}`)
      .send({ termsVersion: 'v1.0' });

    // Projetar lote, animais e dados históricos
    const now = new Date().toISOString();

    await projectEntity('lotes', loteId, contaId, { nome: 'Lote Engorda I', quantidade: 2 }, now, null);

    // Animal 1 — terá GMD em queda (pesagens históricas boas, recente ruim)
    await projectEntity('animais', animal1Id, contaId, { brinco: 'ALERT-01', loteId, pesoKg: 300 }, now, null);

    // Pesagem histórica (90 dias atrás) - base
    const dt90 = new Date(Date.now() - 90 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    const dt60 = new Date(Date.now() - 60 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    const dt7 = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];

    // GMD histórico: (440-300)/30 = 4.67 kg/dia
    await projectEntity('pesagens', 'pes-a1-90', contaId, { animalId: animal1Id, peso: 300, dataPesagem: dt90 }, now, null);
    await projectEntity('pesagens', 'pes-a1-60', contaId, { animalId: animal1Id, peso: 440, dataPesagem: dt60 }, now, null);
    // GMD recente: (443-440)/7 = 0.43 kg/dia → muito abaixo do histórico → dispara A1
    await projectEntity('pesagens', 'pes-a1-7', contaId, { animalId: animal1Id, peso: 443, dataPesagem: dt7 }, now, null);

    // Animal 2 — 3 ocorrências sanitárias em 60 dias → dispara A2
    await projectEntity('animais', animal2Id, contaId, { brinco: 'ALERT-02', loteId, pesoKg: 410 }, now, null);
    const dt30 = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    const dt20 = new Date(Date.now() - 20 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    const dt10 = new Date(Date.now() - 10 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];

    await projectEntity('ocorrencias_sanitarias', 'oc-1', contaId, { animalId: animal2Id, tipo: 'respiratoria', descricao: 'Tosse', dataOcorrencia: dt30, gravidade: 'leve' }, now, null);
    await projectEntity('ocorrencias_sanitarias', 'oc-2', contaId, { animalId: animal2Id, tipo: 'digestiva', descricao: 'Diarreia', dataOcorrencia: dt20, gravidade: 'moderado' }, now, null);
    await projectEntity('ocorrencias_sanitarias', 'oc-3', contaId, { animalId: animal2Id, tipo: 'podal', descricao: 'Claudicação', dataOcorrencia: dt10, gravidade: 'moderado' }, now, null);
  });

  it('1. GET /v1/vet/alertas retorna alertas A1 e A2 corretamente para o veterinário', async () => {
    const res = await request(app)
      .get(`/v1/vet/alertas?tenantContaId=${contaId}`)
      .set('Authorization', `Bearer ${vetToken}`);

    expect(res.status).toBe(200);
    expect(res.body.totalAlertas).toBeGreaterThan(0);
    expect(res.body.sumario).toBeDefined();

    // A1 — GMD em queda
    const alertaA1 = res.body.alertas.find(a => a.codigo === 'A1');
    expect(alertaA1).toBeDefined();
    expect(alertaA1.nivel).toBe('atencao');
    expect(alertaA1.entidade.tipo).toBe('lote');
    expect(alertaA1.dados.gmdMedioRecente).toBeLessThan(alertaA1.dados.gmdMedioHistorico);

    // A2 — Múltiplas ocorrências
    const alertaA2 = res.body.alertas.find(a => a.codigo === 'A2');
    expect(alertaA2).toBeDefined();
    expect(alertaA2.nivel).toBe('critico');
    expect(alertaA2.entidade.brinco).toBe('ALERT-02');
    expect(alertaA2.dados.totalOcorrencias60Dias).toBeGreaterThanOrEqual(3);
  });

  it('2. Alertas têm justificativa explicável (sem caixa-preta)', async () => {
    const res = await request(app)
      .get(`/v1/vet/alertas?tenantContaId=${contaId}`)
      .set('Authorization', `Bearer ${vetToken}`);

    expect(res.status).toBe(200);
    for (const alerta of res.body.alertas) {
      expect(alerta.justificativa).toBeDefined();
      expect(alerta.justificativa.length).toBeGreaterThan(10);
      expect(alerta.descricao).toBeDefined();
      expect(alerta.titulo).toBeDefined();
    }
  });

  it('3. Alertas são ordenados por prioridade (critico > atencao > informativo)', async () => {
    const res = await request(app)
      .get(`/v1/vet/alertas?tenantContaId=${contaId}`)
      .set('Authorization', `Bearer ${vetToken}`);

    expect(res.status).toBe(200);
    const niveis = res.body.alertas.map(a => a.nivel);
    const ordemValida = { critico: 0, atencao: 1, informativo: 2 };
    for (let i = 1; i < niveis.length; i++) {
      expect(ordemValida[niveis[i]]).toBeGreaterThanOrEqual(ordemValida[niveis[i - 1]]);
    }
  });

  it('4. Produtor também pode consultar alertas da própria fazenda', async () => {
    const res = await request(app)
      .get('/v1/vet/alertas')
      .set('Authorization', `Bearer ${ownerToken}`);

    expect(res.status).toBe(200);
    expect(res.body.alertas).toBeDefined();
    // Produtor também vê os alertas da fazenda dele
    expect(Array.isArray(res.body.alertas)).toBe(true);
  });
});
