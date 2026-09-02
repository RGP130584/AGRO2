process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test_secret_for_automated_testing_12345';
const request = require('supertest');
const app = require('../app');
const crypto = require('crypto');
const { getAsync } = require('../db/connection');
const { projectEntity } = require('../services/projector');

describe('Nutrição Avançada — Recomendações e Evolução Nutricional (Onda 8)', () => {
  let ownerToken, contaId;
  let vetToken, vetUserId, veterinarianId;
  const loteId = 'lote-nutri-01';
  const animal1Id = 'ani-nutri-01';
  const animal2Id = 'ani-nutri-02';
  let recomendacaoId;

  beforeAll(async () => {
    // 1. Produtor da Fazenda
    const resOwner = await request(app).post('/v1/auth/register').send({
      nome: 'Produtor Fazenda Nutri',
      cpfCnpj: '33355577799',
      email: 'fazendaNutri@teste.com',
      senha: 'senhaOwner123',
      perfil: 'proprietario'
    });
    ownerToken = resOwner.body.token;
    contaId = resOwner.body.user.contaId;

    // Cadastra Lote, Animais e Pesagens
    const now = new Date().toISOString();
    await projectEntity('lotes', loteId, contaId, { nome: 'Lote Confinamento A', quantidade: 2 }, now, null);
    await projectEntity('animais', animal1Id, contaId, { brinco: 'NUT-01', loteId, pesoKg: 350 }, now, null);
    await projectEntity('animais', animal2Id, contaId, { brinco: 'NUT-02', loteId, pesoKg: 360 }, now, null);
    await projectEntity('pesagens', 'pes-nut-01', contaId, { animalId: animal1Id, peso: 350, dataPesagem: '2026-08-01' }, now, null);
    await projectEntity('pesagens', 'pes-nut-02', contaId, { animalId: animal1Id, peso: 380, dataPesagem: '2026-08-30' }, now, null);

    // 2. Veterinário Especialista em Nutrição
    const resVet = await request(app).post('/v1/auth/register').send({
      nome: 'Dr. Leonardo Nutricionista',
      cpfCnpj: '77799922211',
      crmv: 'CRMV-PR-88990',
      email: 'leonardo@vetnutri.com',
      senha: 'senhaVet123',
      perfil: 'veterinario'
    });
    vetToken = resVet.body.token;
    vetUserId = resVet.body.user.id;
    veterinarianId = resVet.body.user.veterinarianId;

    // Conceder grant Técnico para Dr. Leonardo
    const grantRes = await request(app)
      .post('/v1/vet/grants')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({ crmv: 'CRMV-PR-88990', permissions: ['consulta', 'tecnico'] });

    await request(app)
      .post(`/v1/vet/grants/${grantRes.body.grant.id}/accept`)
      .set('Authorization', `Bearer ${vetToken}`)
      .send({ termsVersion: 'v1.0' });
  });

  it('1. Veterinário emite recomendação nutricional para o Lote Confinamento A', async () => {
    const res = await request(app)
      .post('/v1/vet/nutricao/recomendacoes')
      .set('Authorization', `Bearer ${vetToken}`)
      .send({
        loteId,
        tenantContaId: contaId,
        dietaSugerida: {
          nome: 'Dieta Terminação Alta Energia',
          descricao: 'Milho moído 65%, Farelo de Soja 20%, Núcleo Mineral 15%',
          consumoEsperadoKgDia: 12.5
        },
        justificativa: 'Acelerar ganho de peso para abate em 60 dias.'
      });

    expect(res.status).toBe(201);
    expect(res.body.recomendacao.status).toBe('pendente');
    expect(res.body.recomendacao.dietaSugerida.nome).toBe('Dieta Terminação Alta Energia');
    recomendacaoId = res.body.recomendacao.id;

    // Verifica no banco de dados
    const dbRec = await getAsync(`SELECT * FROM recomendacoes_nutricionais WHERE id = ?`, [recomendacaoId]);
    expect(dbRec).toBeTruthy();
    expect(dbRec.status).toBe('pendente');
  });

  it('2. Produtor lista recomendações pendentes recebidas do veterinário', async () => {
    const res = await request(app)
      .get(`/v1/vet/nutricao/recomendacoes?tenantContaId=${contaId}`)
      .set('Authorization', `Bearer ${ownerToken}`);

    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    const rec = res.body.find(r => r.id === recomendacaoId);
    expect(rec).toBeDefined();
    expect(rec.veterinarianNome).toBe('Dr. Leonardo Nutricionista');
    expect(rec.status).toBe('pendente');
  });

  it('3. Produtor aplica a recomendação -> cria Dieta no Core e atualiza status para aceita', async () => {
    const res = await request(app)
      .post(`/v1/vet/nutricao/recomendacoes/${recomendacaoId}/aplicar`)
      .set('Authorization', `Bearer ${ownerToken}`);

    expect(res.status).toBe(200);
    expect(res.body.status).toBe('aceita');
    const dietaId = res.body.dietaId;
    expect(dietaId).toBeDefined();

    // Verifica se a Dieta foi criada em proj_dietas com o vínculo de origem
    const dbDieta = await getAsync(`SELECT * FROM proj_dietas WHERE entity_id = ?`, [dietaId]);
    expect(dbDieta).toBeTruthy();
    expect(dbDieta.nome).toBe('Dieta Terminação Alta Energia');
    expect(dbDieta.origem_recomendacao_id).toBe(recomendacaoId);

    // Registra fornecimento dessa nova dieta para alimentar a evolução
    await projectEntity('fornecimentos_dieta', 'forn-01', contaId, {
      loteId,
      dietaId,
      dataFornecimento: '2026-08-15',
      quantidadeKg: 250
    }, new Date().toISOString(), null);
  });

  it('4. GET /v1/vet/lotes/:loteId/evolucao-nutricional cruza fornecimentos e pesagens/GMD', async () => {
    const res = await request(app)
      .get(`/v1/vet/lotes/${loteId}/evolucao-nutricional?tenantContaId=${contaId}`)
      .set('Authorization', `Bearer ${vetToken}`);

    expect(res.status).toBe(200);
    expect(res.body.totalAnimaisNoLote).toBe(2);
    expect(res.body.historicoFornecimentos.length).toBeGreaterThan(0);
    expect(res.body.evolucaoPesoMedio.length).toBeGreaterThan(0);
  });
});
