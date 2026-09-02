process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test_secret_for_automated_testing_12345';
const request = require('supertest');
const app = require('../app');
const crypto = require('crypto');
const { getAsync } = require('../db/connection');
const { projectEntity } = require('../services/projector');

describe('Saúde Avançada — Prontuário e Intervenções Append-Only (Onda 7)', () => {
  let ownerToken, contaId;
  let vet1Token, vet1Id;
  let vet2Token, vet2Id;
  const animalId = 'animal-prontuario-99';

  beforeAll(async () => {
    // 1. Produtor da Fazenda
    const resOwner = await request(app).post('/v1/auth/register').send({
      nome: 'Produtor Fazenda Ouro Verde',
      cpfCnpj: '44411122233',
      email: 'fazendaOuro@teste.com',
      senha: 'senhaOwner123',
      perfil: 'proprietario'
    });
    ownerToken = resOwner.body.token;
    contaId = resOwner.body.user.contaId;

    // Cadastra animal e pesagem prévia
    const now = new Date().toISOString();
    await projectEntity('animais', animalId, contaId, { brinco: 'OURO-099', raca: 'Nelore', pesoKg: 420 }, now, null);
    await projectEntity('pesagens', 'pes-099', contaId, { animalId, peso: 420, dataPesagem: '2026-08-15' }, now, null);

    // 2. Veterinário 1 (Dr. Marcos - Permissão Intervenção)
    const resVet1 = await request(app).post('/v1/auth/register').send({
      nome: 'Dr. Marcos Veterinário',
      cpfCnpj: '88811133355',
      crmv: 'CRMV-GO-11223',
      email: 'marcos@vet.com',
      senha: 'senhaVet123',
      perfil: 'veterinario'
    });
    vet1Token = resVet1.body.token;
    vet1Id = resVet1.body.user.veterinarianId;

    // Conceder grant Intervenção para Dr. Marcos
    const grant1Res = await request(app)
      .post('/v1/vet/grants')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({ crmv: 'CRMV-GO-11223', permissions: ['consulta', 'tecnico', 'intervencao'] });

    await request(app)
      .post(`/v1/vet/grants/${grant1Res.body.grant.id}/accept`)
      .set('Authorization', `Bearer ${vet1Token}`)
      .send({ termsVersion: 'v1.0' });

    // 3. Veterinário 2 (Dra. Juliana - Permissão Técnico)
    const resVet2 = await request(app).post('/v1/auth/register').send({
      nome: 'Dra. Juliana Especialista',
      cpfCnpj: '88822244466',
      crmv: 'CRMV-GO-55667',
      email: 'juliana@vet.com',
      senha: 'senhaVet123',
      perfil: 'veterinario'
    });
    vet2Token = resVet2.body.token;
    vet2Id = resVet2.body.user.veterinarianId;

    // Conceder grant Técnico para Dra. Juliana
    const grant2Res = await request(app)
      .post('/v1/vet/grants')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({ crmv: 'CRMV-GO-55667', permissions: ['consulta', 'tecnico'] });

    await request(app)
      .post(`/v1/vet/grants/${grant2Res.body.grant.id}/accept`)
      .set('Authorization', `Bearer ${vet2Token}`)
      .send({ termsVersion: 'v1.0' });
  });

  it('1. Dr. Marcos registra intervenção de aplicação sanitária com replicação no Core', async () => {
    const res = await request(app)
      .post('/v1/vet/intervencoes')
      .set('Authorization', `Bearer ${vet1Token}`)
      .send({
        animalId,
        tenantContaId: contaId,
        tipo: 'aplicacao',
        payload: {
          produtoId: 'PROD-ANTIBIOTICO',
          doseMl: 15.5,
          carenciaDias: 14,
          dataAplicacao: '2026-09-02',
          observacao: 'Tratamento de pneumonia bacteriana'
        }
      });

    expect(res.status).toBe(201);
    expect(res.body.intervencao.tipo).toBe('aplicacao');
    const intervencaoId = res.body.intervencao.id;

    // Verifica gravação append-only em intervencoes_veterinarias
    const dbIntervencao = await getAsync(`SELECT * FROM intervencoes_veterinarias WHERE id = ?`, [intervencaoId]);
    expect(dbIntervencao).toBeTruthy();

    // Verifica replicação em proj_aplicacoes_sanitarias com o link da intervenção de origem
    const dbAplicacao = await getAsync(`SELECT * FROM proj_aplicacoes_sanitarias WHERE intervencao_origem_id = ?`, [intervencaoId]);
    expect(dbAplicacao).toBeTruthy();
    expect(dbAplicacao.dose_ml).toBe(15.5);
    expect(dbAplicacao.carencia_dias).toBe(14);
  });

  it('2. Dra. Juliana registra avaliação clínica (permitido com nível Técnico)', async () => {
    const res = await request(app)
      .post('/v1/vet/intervencoes')
      .set('Authorization', `Bearer ${vet2Token}`)
      .send({
        animalId,
        tenantContaId: contaId,
        tipo: 'avaliacao',
        payload: {
          escoreCorporal: 3.5,
          auscultacao: 'Ruídos pulmonares diminuídos',
          prognostico: 'Favorável'
        }
      });

    expect(res.status).toBe(201);
    expect(res.body.intervencao.tipo).toBe('avaliacao');
  });

  it('3. Dra. Juliana é BLOQUEADA (403) ao tentar registrar aplicação (exige nível Intervenção)', async () => {
    const res = await request(app)
      .post('/v1/vet/intervencoes')
      .set('Authorization', `Bearer ${vet2Token}`)
      .send({
        animalId,
        tenantContaId: contaId,
        tipo: 'aplicacao',
        payload: { doseMl: 10 }
      });

    expect(res.status).toBe(403);
    expect(res.body.error).toContain('Nível de permissão insuficiente');
  });

  it('4. GET /v1/vet/animals/:animalId/prontuario retorna timeline unificada com alerta de múltiplos profissionais', async () => {
    const res = await request(app)
      .get(`/v1/vet/animals/${animalId}/prontuario?tenantContaId=${contaId}`)
      .set('Authorization', `Bearer ${vet1Token}`);

    expect(res.status).toBe(200);
    expect(res.body.timeline).toBeDefined();
    expect(res.body.timeline.length).toBeGreaterThanOrEqual(3); // Pesagem + Aplicação + Avaliação + Replicação

    // Verifica que múltiplos profissionais foram detectados nos últimos 30 dias (Dr. Marcos + Dra. Juliana)
    expect(res.body.multiplosProfissionaisRecentes).toBe(true);
    expect(res.body.profissionaisRecentes.length).toBe(2);
    expect(res.body.profissionaisRecentes.map(p => p.crmv)).toContain('CRMV-GO-11223');
    expect(res.body.profissionaisRecentes.map(p => p.crmv)).toContain('CRMV-GO-55667');
  });
});
