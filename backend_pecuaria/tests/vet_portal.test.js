process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test_secret_for_automated_testing_12345';
const request = require('supertest');
const app = require('../app');
const crypto = require('crypto');
const { runAsync } = require('../db/connection');
const { projectEntity } = require('../services/projector');

describe('Portal Veterinário — Dashboard Consolidado e Agenda (Onda 6)', () => {
  let ownerAToken, contaIdA;
  let ownerBToken, contaIdB;
  let vetToken, vetUserId, veterinarianId;
  let grantAId;

  beforeAll(async () => {
    // 1. Produtor Fazenda A (com animais e carência sanitária)
    const resA = await request(app).post('/v1/auth/register').send({
      nome: 'Produtor Portal A',
      cpfCnpj: '11188833311',
      email: 'fazendaPortalA@teste.com',
      senha: 'senhaOwner123',
      perfil: 'proprietario'
    });
    ownerAToken = resA.body.token;
    contaIdA = resA.body.user.contaId;

    // Projetar Fazenda A, animais e aplicação sanitária com carência
    const nowIso = new Date().toISOString();
    await projectEntity('fazendas', 'faz-A-01', contaIdA, { nome: 'Fazenda Santa Maria', cidade: 'Barretos', estado: 'SP' }, nowIso, null);
    await projectEntity('animais', 'ani-A-01', contaIdA, { brinco: 'BOV-001', raca: 'Nelore', pesoKg: 480 }, nowIso, null);
    await projectEntity('animais', 'ani-A-02', contaIdA, { brinco: 'BOV-002', raca: 'Angus', pesoKg: 520 }, nowIso, null);
    // Aplicação com carência ativa de 30 dias a partir de hoje
    await projectEntity('aplicacoes_sanitarias', 'app-san-01', contaIdA, {
      animalId: 'ani-A-01',
      produtoId: 'prod-vacina',
      dataAplicacao: nowIso.split('T')[0],
      carenciaDias: 30
    }, nowIso, null);

    // 2. Produtor Fazenda B (Sem grant ativo)
    const resB = await request(app).post('/v1/auth/register').send({
      nome: 'Produtor Portal B',
      cpfCnpj: '22288844422',
      email: 'fazendaPortalB@teste.com',
      senha: 'senhaOwner123',
      perfil: 'proprietario'
    });
    ownerBToken = resB.body.token;
    contaIdB = resB.body.user.contaId;

    // 3. Veterinário Profissional com plano VET_PRO
    const resVet = await request(app).post('/v1/auth/register').send({
      nome: 'Dra. Camila Veterinária',
      cpfCnpj: '77744411199',
      crmv: 'CRMV-MG-44556',
      email: 'camila@vet.com',
      senha: 'senhaVet123',
      perfil: 'veterinario'
    });
    vetToken = resVet.body.token;
    vetUserId = resVet.body.user.id;
    veterinarianId = resVet.body.user.veterinarianId;

    // 4. Produtor A convida Dra. Camila e ela aceita o convite
    const grantRes = await request(app)
      .post('/v1/vet/grants')
      .set('Authorization', `Bearer ${ownerAToken}`)
      .send({ crmv: 'CRMV-MG-44556', permissions: ['consulta', 'tecnico'] });
    grantAId = grantRes.body.grant.id;

    await request(app)
      .post(`/v1/vet/grants/${grantAId}/accept`)
      .set('Authorization', `Bearer ${vetToken}`)
      .send({ termsVersion: 'v1.0' });
  });

  it('1. GET /v1/vet/dashboard agrega indicadores de todas as fazendas autorizadas', async () => {
    const res = await request(app)
      .get('/v1/vet/dashboard')
      .set('Authorization', `Bearer ${vetToken}`);

    expect(res.status).toBe(200);
    expect(res.body.overview).toBeDefined();
    expect(res.body.overview.totalFazendasConectadas).toBe(1);
    expect(res.body.overview.totalAnimais).toBe(2);
    expect(res.body.overview.totalAlertasCarencia).toBe(1);

    expect(res.body.fazendas.length).toBe(1);
    const fA = res.body.fazendas[0];
    expect(fA.tenantContaId).toBe(contaIdA);
    expect(fA.fazendaNome).toBe('Fazenda Santa Maria');
    expect(fA.indicadores.animais).toBe(2);
    expect(fA.indicadores.carenciasAtivas).toBe(1);
  });

  it('2. Fazenda B (sem grant) NÃO aparece no dashboard do veterinário', async () => {
    const res = await request(app)
      .get('/v1/vet/dashboard')
      .set('Authorization', `Bearer ${vetToken}`);

    expect(res.status).toBe(200);
    const fazendaB = res.body.fazendas.find(f => f.tenantContaId === contaIdB);
    expect(fazendaB).toBeUndefined();
  });

  it('3. POST /v1/vet/agenda cria visita em fazenda com grant ativo', async () => {
    const res = await request(app)
      .post('/v1/vet/agenda')
      .set('Authorization', `Bearer ${vetToken}`)
      .send({
        tenantContaId: contaIdA,
        titulo: 'Exame Andrológico dos Touros',
        descricao: 'Avaliação clínica reprodutiva',
        dataHora: '2026-09-15T09:00:00.000Z',
        tipo: 'visita'
      });

    expect(res.status).toBe(201);
    expect(res.body.appointment.titulo).toBe('Exame Andrológico dos Touros');
    expect(res.body.appointment.status).toBe('agendado');

    const agendaId = res.body.appointment.id;

    // Atualiza status da visita
    const patchRes = await request(app)
      .patch(`/v1/vet/agenda/${agendaId}`)
      .set('Authorization', `Bearer ${vetToken}`)
      .send({ status: 'realizado' });

    expect(patchRes.status).toBe(200);
    expect(patchRes.body.status).toBe('realizado');
  });

  it('4. POST /v1/vet/agenda bloqueia (403) agendamento em fazenda sem grant', async () => {
    const res = await request(app)
      .post('/v1/vet/agenda')
      .set('Authorization', `Bearer ${vetToken}`)
      .send({
        tenantContaId: contaIdB,
        titulo: 'Tentativa não autorizada',
        dataHora: '2026-09-20T10:00:00.000Z',
        tipo: 'visita'
      });

    expect(res.status).toBe(403);
    expect(res.body.error).toContain('não possui um compartilhamento ativo');
  });
});
