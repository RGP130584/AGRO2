process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test_secret_for_automated_testing_12345';
const request = require('supertest');
const app = require('../app');
const crypto = require('crypto');
const { getAsync } = require('../db/connection');
const { projectEntity } = require('../services/projector');

describe('Operação Profissional — Visitas, Laudos e Faturamento (Onda 9)', () => {
  let ownerToken, contaId;
  let vetToken, vetUserId, veterinarianId;
  const animalId = 'animal-op-01';
  let visitaId, osId;

  beforeAll(async () => {
    // 1. Produtor da Fazenda
    const resOwner = await request(app).post('/v1/auth/register').send({
      nome: 'Produtor Fazenda Bela Vista',
      cpfCnpj: '55522233344',
      email: 'fazendaBelaVista@teste.com',
      senha: 'senhaOwner123',
      perfil: 'proprietario'
    });
    ownerToken = resOwner.body.token;
    contaId = resOwner.body.user.contaId;

    // Projeta fazenda e animal
    const now = new Date().toISOString();
    await projectEntity('fazendas', 'faz-bv-01', contaId, { nome: 'Fazenda Bela Vista', cidade: 'Uberaba', estado: 'MG' }, now, null);
    await projectEntity('animais', animalId, contaId, { brinco: 'BV-101', raca: 'Nelore', sexo: 'M', pesoKg: 490 }, now, null);

    // 2. Veterinário
    const resVet = await request(app).post('/v1/auth/register').send({
      nome: 'Dr. Roberto Santos',
      cpfCnpj: '99988877711',
      crmv: 'CRMV-SP-99881',
      telefone: '(11) 98888-7777',
      email: 'roberto@vetsantos.com',
      senha: 'senhaVet123',
      perfil: 'veterinario'
    });
    vetToken = resVet.body.token;
    vetUserId = resVet.body.user.id;
    veterinarianId = resVet.body.user.veterinarianId;

    // Conceder grant Intervenção para Dr. Roberto
    const grantRes = await request(app)
      .post('/v1/vet/grants')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({ crmv: 'CRMV-SP-99881', permissions: ['consulta', 'tecnico', 'intervencao'] });

    await request(app)
      .post(`/v1/vet/grants/${grantRes.body.grant.id}/accept`)
      .set('Authorization', `Bearer ${vetToken}`)
      .send({ termsVersion: 'v1.0' });
  });

  it('1. Veterinário agenda visita técnica na fazenda', async () => {
    const res = await request(app)
      .post('/v1/vet/visitas')
      .set('Authorization', `Bearer ${vetToken}`)
      .send({
        tenantContaId: contaId,
        dataHora: '2026-09-10T08:30:00.000Z',
        observacoes: 'Visita periódica para avaliação sanitária e andrológica'
      });

    expect(res.status).toBe(201);
    expect(res.body.visita.status).toBe('agendada');
    visitaId = res.body.visita.id;

    const dbVisita = await getAsync(`SELECT * FROM vet_visitas WHERE id = ?`, [visitaId]);
    expect(dbVisita).toBeTruthy();
  });

  it('2. Veterinário registra intervenção vinculada à visita técnica', async () => {
    const res = await request(app)
      .post('/v1/vet/intervencoes')
      .set('Authorization', `Bearer ${vetToken}`)
      .send({
        animalId,
        tenantContaId: contaId,
        visitaId,
        tipo: 'avaliacao',
        payload: {
          diagnostico: 'Animal com bom estado nutricional e aptidão reprodutiva confirmada.',
          escoreCorporal: 4.0
        }
      });

    expect(res.status).toBe(201);
    expect(res.body.intervencao.visitaId).toBe(visitaId);
  });

  it('3. Veterinário conclui a visita técnica', async () => {
    const res = await request(app)
      .patch(`/v1/vet/visitas/${visitaId}/concluir`)
      .set('Authorization', `Bearer ${vetToken}`)
      .send({ observacoesFinais: 'Atendimento finalizado com sucesso. Rebanho sadio.' });

    expect(res.status).toBe(200);
    expect(res.body.status).toBe('concluida');
  });

  it('4. Veterinário gera Ordem de Serviço vinculada à visita', async () => {
    const res = await request(app)
      .post('/v1/vet/ordens-servico')
      .set('Authorization', `Bearer ${vetToken}`)
      .send({
        visitaId,
        tenantContaId: contaId,
        descricao: 'Honorários de Consultoria Técnica e Exame Andrológico',
        itens: [
          { servico: 'Diária de Consultoria de Campo', quantidade: 1, valorUnitario: 1200.0, subtotal: 1200.0 },
          { servico: 'Exame Andrológico por Animal', quantidade: 1, valorUnitario: 150.0, subtotal: 150.0 }
        ],
        dataVencimento: '2026-09-25'
      });

    expect(res.status).toBe(201);
    expect(res.body.ordemServico.valorTotal).toBe(1350.0);
    expect(res.body.ordemServico.status).toBe('aberta');
    osId = res.body.ordemServico.id;
  });

  it('5. Baixa manual de pagamento na Ordem de Serviço', async () => {
    const res = await request(app)
      .patch(`/v1/vet/ordens-servico/${osId}/pagamento`)
      .set('Authorization', `Bearer ${vetToken}`)
      .send({ status: 'paga', dataPagamento: '2026-09-20' });

    expect(res.status).toBe(200);
    expect(res.body.status).toBe('paga');
    expect(res.body.dataPagamento).toBe('2026-09-20');
  });

  it('6. GET /v1/vet/visitas/:id/laudo emite laudo técnico consolidado', async () => {
    const res = await request(app)
      .get(`/v1/vet/visitas/${visitaId}/laudo`)
      .set('Authorization', `Bearer ${vetToken}`);

    expect(res.status).toBe(200);
    expect(res.body.laudoId).toBeDefined();
    expect(res.body.veterinario.nome).toBe('Dr. Roberto Santos');
    expect(res.body.veterinario.crmv).toBe('CRMV-SP-99881');
    expect(res.body.propriedade.fazendaNome).toBe('Fazenda Bela Vista');
    expect(res.body.totalAnimaisAtendidos).toBe(1);
    expect(res.body.intervencoesRealizadas.length).toBe(1);
    expect(res.body.faturamento).toBeDefined();
    expect(res.body.faturamento.valorTotal).toBe(1350.0);
    expect(res.body.faturamento.status).toBe('paga');
  });
});
