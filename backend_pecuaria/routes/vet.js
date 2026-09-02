/**
 * routes/vet.js — Gestão de Sharing Grants e Módulo Veterinário
 */
const express = require('express');
const crypto = require('crypto');
const { z } = require('zod');
const { runAsync, getAsync, allAsync } = require('../db/connection');
const authenticate = require('../middlewares/authenticate');
const requireRole = require('../middlewares/requireRole');
const requireEntitlement = require('../middlewares/requireEntitlement');
const { logEvent } = require('../services/audit');

const router = express.Router();

const createGrantSchema = z.object({
  crmv: z.string().optional(),
  email: z.string().email().optional(),
  scopeType: z.enum(['fazenda', 'lote', 'animal']).default('fazenda'),
  scopeId: z.string().nullable().optional(),
  permissions: z.array(z.enum(['consulta', 'tecnico', 'intervencao', 'administrativo'])).default(['consulta', 'tecnico']),
  expiresAt: z.string().nullable().optional()
});

const acceptGrantSchema = z.object({
  termsVersion: z.string().min(1, 'Versão dos termos de LGPD é obrigatória para aceite.')
});

// ── POST /v1/vet/grants — Produtor convida Veterinário ────────────────
router.post('/grants', authenticate, requireRole('proprietario'), requireEntitlement('CORE'), async (req, res) => {
  try {
    const { crmv, email, scopeType, scopeId, permissions, expiresAt } = createGrantSchema.parse(req.body);

    if (!crmv && !email) {
      return res.status(400).json({ error: 'Informe o CRMV ou e-mail do veterinário.' });
    }

    let vet;
    if (crmv) {
      vet = await getAsync(`SELECT * FROM veterinarians WHERE crmv = ?`, [crmv.trim()]);
    } else if (email) {
      vet = await getAsync(
        `SELECT v.* FROM veterinarians v
         JOIN usuarios u ON u.id = v.usuario_id
         WHERE u.email = ?`,
        [email.trim()]
      );
    }

    if (!vet) {
      return res.status(404).json({ error: 'Veterinário não encontrado com os dados informados.' });
    }

    // Verifica se já existe grant ativo ou pendente para este mesmo veterinário e tenant
    const existing = await getAsync(
      `SELECT * FROM sharing_grants
       WHERE tenant_conta_id = ? AND veterinarian_id = ? AND status IN ('pending', 'active')`,
      [req.user.contaId, vet.id]
    );

    if (existing) {
      return res.status(400).json({ error: `Já existe um compartilhamento ${existing.status} com este profissional.` });
    }

    const grantId = crypto.randomUUID();
    const now = new Date().toISOString();

    await runAsync(
      `INSERT INTO sharing_grants (id, tenant_conta_id, veterinarian_id, scope_type, scope_id, permissions, granted_by, status, created_at, expires_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, 'pending', ?, ?)`,
      [grantId, req.user.contaId, vet.id, scopeType, scopeId || null, JSON.stringify(permissions), req.user.id, now, expiresAt || null]
    );

    // Audit trail
    await logEvent({
      actorUserId: req.user.id,
      actorContaId: req.user.contaId,
      action: 'grant_created',
      entityType: 'sharing_grant',
      entityId: grantId,
      metadata: { veterinarianId: vet.id, scopeType, permissions }
    });

    res.status(201).json({
      message: 'Convite de compartilhamento enviado ao veterinário.',
      grant: {
        id: grantId,
        tenantContaId: req.user.contaId,
        veterinarianId: vet.id,
        veterinarianNome: vet.nome,
        crmv: vet.crmv,
        scopeType,
        permissions,
        status: 'pending',
        createdAt: now,
        expiresAt: expiresAt || null
      }
    });
  } catch (e) {
    if (e instanceof z.ZodError) return res.status(400).json({ error: 'Dados inválidos.', details: e.issues || e.errors });
    res.status(500).json({ error: 'Erro interno ao criar convite de compartilhamento.' });
  }
});

// ── POST /v1/vet/grants/:id/accept — Veterinário aceita convite com LGPD ──
router.post('/grants/:id/accept', authenticate, requireRole('veterinario'), async (req, res) => {
  try {
    const { id } = req.params;
    const { termsVersion } = acceptGrantSchema.parse(req.body);

    const grant = await getAsync(
      `SELECT * FROM sharing_grants WHERE id = ? AND veterinarian_id = ?`,
      [id, req.user.veterinarianId]
    );

    if (!grant) {
      return res.status(404).json({ error: 'Convite não encontrado.' });
    }

    if (grant.status !== 'pending') {
      return res.status(400).json({ error: `Este convite não está mais pendente (status atual: ${grant.status}).` });
    }

    const now = new Date().toISOString();

    await runAsync(
      `UPDATE sharing_grants SET status = 'active', accepted_at = ? WHERE id = ?`,
      [now, id]
    );

    // Registro obrigatório de auditoria e consentimento LGPD
    await logEvent({
      actorUserId: req.user.id,
      actorContaId: grant.tenant_conta_id,
      action: 'grant_accepted',
      entityType: 'sharing_grant',
      entityId: id,
      metadata: {
        termsVersion,
        veterinarianId: req.user.veterinarianId,
        tenantContaId: grant.tenant_conta_id,
        acceptedAt: now
      }
    });

    res.json({
      message: 'Compartilhamento aceito com sucesso.',
      grant: {
        ...grant,
        permissions: JSON.parse(grant.permissions),
        status: 'active',
        acceptedAt: now
      }
    });
  } catch (e) {
    if (e instanceof z.ZodError) return res.status(400).json({ error: 'Dados inválidos.', details: e.issues || e.errors });
    res.status(500).json({ error: 'Erro interno ao aceitar compartilhamento.' });
  }
});

// ── DELETE /v1/vet/grants/:id — Produtor revoga acesso do Veterinário ─
router.delete('/grants/:id', authenticate, requireRole('proprietario'), requireEntitlement('CORE'), async (req, res) => {
  try {
    const { id } = req.params;

    const grant = await getAsync(
      `SELECT * FROM sharing_grants WHERE id = ? AND tenant_conta_id = ?`,
      [id, req.user.contaId]
    );

    if (!grant) {
      return res.status(404).json({ error: 'Compartilhamento não encontrado ou não pertence a esta conta.' });
    }

    if (grant.status === 'revoked') {
      return res.status(400).json({ error: 'Este compartilhamento já foi revogado.' });
    }

    const now = new Date().toISOString();

    await runAsync(
      `UPDATE sharing_grants SET status = 'revoked', revoked_at = ? WHERE id = ?`,
      [now, id]
    );

    // Audit trail
    await logEvent({
      actorUserId: req.user.id,
      actorContaId: req.user.contaId,
      action: 'grant_revoked',
      entityType: 'sharing_grant',
      entityId: id,
      metadata: { veterinarianId: grant.veterinarian_id, revokedAt: now }
    });

    res.json({
      message: 'Acesso do veterinário revogado com sucesso. O histórico existente permanece preservado.',
      id,
      status: 'revoked',
      revokedAt: now
    });
  } catch (e) {
    res.status(500).json({ error: 'Erro interno ao revogar compartilhamento.' });
  }
});

// ── GET /v1/vet/grants — Listar compartilhamentos ─────────────────────
router.get('/grants', authenticate, async (req, res) => {
  try {
    let grants;
    if (req.user.perfil === 'veterinario') {
      // Lista todas as fazendas às quais o veterinário tem vínculo
      grants = await allAsync(
        `SELECT g.id, g.tenant_conta_id as tenantContaId, g.scope_type as scopeType, g.scope_id as scopeId,
                g.permissions, g.status, g.created_at as createdAt, g.accepted_at as acceptedAt,
                g.expires_at as expiresAt, g.revoked_at as revokedAt,
                u.nome as produtorNome, u.email as produtorEmail
         FROM sharing_grants g
         JOIN usuarios u ON u.id = g.granted_by
         WHERE g.veterinarian_id = ?
         ORDER BY g.created_at DESC`,
        [req.user.veterinarianId]
      );
    } else {
      // Produtor lista os veterinários convidados para a sua fazenda
      grants = await allAsync(
        `SELECT g.id, g.veterinarian_id as veterinarianId, g.scope_type as scopeType, g.scope_id as scopeId,
                g.permissions, g.status, g.created_at as createdAt, g.accepted_at as acceptedAt,
                g.expires_at as expiresAt, g.revoked_at as revokedAt,
                v.nome as veterinarianNome, v.crmv as crmv, v.telefone as telefone
         FROM sharing_grants g
         JOIN veterinarians v ON v.id = g.veterinarian_id
         WHERE g.tenant_conta_id = ?
         ORDER BY g.created_at DESC`,
        [req.user.contaId]
      );
    }

    const formatted = grants.map(g => ({
      ...g,
      permissions: JSON.parse(g.permissions)
    }));

    res.json(formatted);
  } catch (e) {
    console.error('Erro ao listar grants:', e);
    res.status(500).json({ error: 'Erro interno ao listar compartilhamentos.' });
  }
});

// ══════════════════════════════════════════════════════════════════════
// ── ONDA 6: Dashboard Consolidado do Portal Veterinário ───────────────
// ══════════════════════════════════════════════════════════════════════

router.get('/dashboard', authenticate, requireRole('veterinario'), requireEntitlement('VET_PORTAL'), async (req, res) => {
  try {
    const nowIso = new Date().toISOString();

    // 1. Busca todos os grants ativos e não expirados do veterinário
    const activeGrants = await allAsync(
      `SELECT g.id, g.tenant_conta_id as tenantContaId, g.scope_type as scopeType, g.scope_id as scopeId,
              g.permissions, g.created_at as createdAt, g.accepted_at as acceptedAt, g.expires_at as expiresAt,
              u.nome as produtorNome, u.email as produtorEmail
       FROM sharing_grants g
       JOIN usuarios u ON u.id = g.granted_by
       WHERE g.veterinarian_id = ? AND g.status = 'active'
         AND (g.expires_at IS NULL OR g.expires_at > ?)
       ORDER BY g.created_at DESC`,
      [req.user.veterinarianId, nowIso]
    );

    let totalAnimais = 0;
    let totalAlertasCarencia = 0;
    let totalOcorrenciasAbertas = 0;
    let totalAlertasEstoque = 0;

    const fazendasDetalhadas = [];

    for (const grant of activeGrants) {
      const tenantId = grant.tenantContaId;

      // Nome da fazenda projetada
      const fazendaRow = await getAsync(
        `SELECT nome, cidade, estado FROM proj_fazendas WHERE owner_id = ? AND deleted_at IS NULL LIMIT 1`,
        [tenantId]
      );
      const fazendaNome = fazendaRow?.nome || `Fazenda de ${grant.produtorNome}`;

      // Contagem de animais
      const animaisCountRow = await getAsync(
        `SELECT COUNT(*) as count FROM proj_animais WHERE owner_id = ? AND deleted_at IS NULL`,
        [tenantId]
      );
      const qtdAnimais = animaisCountRow?.count || 0;
      totalAnimais += qtdAnimais;

      // Animais em carência sanitária ativa (onde data_aplicacao + carencia_dias >= hoje)
      const carenciaRows = await allAsync(
        `SELECT COUNT(*) as count FROM proj_aplicacoes_sanitarias 
         WHERE owner_id = ? AND carencia_dias > 0 AND deleted_at IS NULL
           AND date(data_aplicacao, '+' || carencia_dias || ' days') >= date('now')`,
        [tenantId]
      );
      const qtdCarencia = carenciaRows[0]?.count || 0;
      totalAlertasCarencia += qtdCarencia;

      // Ocorrências sanitárias abertas / em tratamento
      const ocorrenciasRows = await allAsync(
        `SELECT COUNT(*) as count FROM proj_ocorrencias_sanitarias 
         WHERE owner_id = ? AND deleted_at IS NULL AND (status IS NULL OR status != 'resolvido')`,
        [tenantId]
      );
      const qtdOcorrencias = ocorrenciasRows[0]?.count || 0;
      totalOcorrenciasAbertas += qtdOcorrencias;

      // Alertas de estoque (abaixo do mínimo)
      const estoqueRows = await allAsync(
        `SELECT COUNT(*) as count FROM proj_produtos 
         WHERE owner_id = ? AND deleted_at IS NULL AND estoque_minimo > 0`,
        [tenantId]
      );
      const qtdAlertasEstoque = estoqueRows[0]?.count || 0;
      totalAlertasEstoque += qtdAlertasEstoque;

      // Cálculo de expiração do grant em dias
      let diasParaExpirar = null;
      if (grant.expiresAt) {
        const diffMs = new Date(grant.expiresAt) - new Date();
        diasParaExpirar = Math.max(0, Math.ceil(diffMs / (1000 * 60 * 60 * 24)));
      }

      fazendasDetalhadas.push({
        grantId: grant.id,
        tenantContaId: tenantId,
        fazendaNome,
        cidade: fazendaRow?.cidade,
        estado: fazendaRow?.estado,
        produtorNome: grant.produtorNome,
        produtorEmail: grant.produtorEmail,
        permissions: JSON.parse(grant.permissions),
        expiresAt: grant.expiresAt,
        diasParaExpirar,
        indicadores: {
          animais: qtdAnimais,
          carenciasAtivas: qtdCarencia,
          ocorrenciasAbertas: qtdOcorrencias,
          alertasEstoque: qtdAlertasEstoque
        }
      });
    }

    res.json({
      overview: {
        totalFazendasConectadas: activeGrants.length,
        totalAnimais,
        totalAlertasCarencia,
        totalOcorrenciasAbertas,
        totalAlertasEstoque,
      },
      fazendas: fazendasDetalhadas
    });
  } catch (e) {
    console.error('Erro ao gerar dashboard do veterinário:', e);
    res.status(500).json({ error: 'Erro interno ao consultar dashboard.' });
  }
});

// ══════════════════════════════════════════════════════════════════════
// ── ONDA 6: Agenda e Visitas do Veterinário ───────────────────────────
// ══════════════════════════════════════════════════════════════════════

const createAgendaSchema = z.object({
  tenantContaId: z.string().min(1, 'Identificador da fazenda é obrigatório.'),
  titulo: z.string().min(1, 'Título é obrigatório.'),
  descricao: z.string().optional(),
  dataHora: z.string().min(1, 'Data e hora são obrigatórias.'),
  tipo: z.enum(['visita', 'retorno', 'procedimento']).default('visita')
});

// ── GET /v1/vet/agenda — Compromissos do Veterinário ──────────────────
router.get('/agenda', authenticate, requireRole('veterinario'), requireEntitlement('VET_PORTAL'), async (req, res) => {
  try {
    const appointments = await allAsync(
      `SELECT a.id, a.tenant_conta_id as tenantContaId, a.titulo, a.descricao,
              a.data_hora as dataHora, a.tipo, a.status, a.created_at as createdAt,
              u.nome as produtorNome
       FROM vet_agenda a
       JOIN usuarios u ON u.id = a.tenant_conta_id
       WHERE a.veterinarian_id = ?
       ORDER BY a.data_hora ASC`,
      [req.user.veterinarianId]
    );

    res.json(appointments);
  } catch (e) {
    res.status(500).json({ error: 'Erro interno ao listar agenda.' });
  }
});

// ── POST /v1/vet/agenda — Agendar Visita / Retorno ────────────────────
router.post('/agenda', authenticate, requireRole('veterinario'), requireEntitlement('VET_PORTAL'), async (req, res) => {
  try {
    const { tenantContaId, titulo, descricao, dataHora, tipo } = createAgendaSchema.parse(req.body);

    // Valida se o veterinário possui grant ativo com essa fazenda
    const grant = await getAsync(
      `SELECT * FROM sharing_grants 
       WHERE veterinarian_id = ? AND tenant_conta_id = ? AND status = 'active'
         AND (expires_at IS NULL OR expires_at > ?)`,
      [req.user.veterinarianId, tenantContaId, new Date().toISOString()]
    );

    if (!grant) {
      return res.status(403).json({ error: 'Você não possui um compartilhamento ativo com esta fazenda para agendar visitas.' });
    }

    const agendaId = crypto.randomUUID();
    const now = new Date().toISOString();

    await runAsync(
      `INSERT INTO vet_agenda (id, veterinarian_id, tenant_conta_id, titulo, descricao, data_hora, tipo, status, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, 'agendado', ?)`,
      [agendaId, req.user.veterinarianId, tenantContaId, titulo, descricao || null, dataHora, tipo, now]
    );

    res.status(201).json({
      message: 'Compromisso agendado com sucesso.',
      appointment: {
        id: agendaId,
        veterinarianId: req.user.veterinarianId,
        tenantContaId,
        titulo,
        descricao,
        dataHora,
        tipo,
        status: 'agendado',
        createdAt: now
      }
    });
  } catch (e) {
    if (e instanceof z.ZodError) return res.status(400).json({ error: 'Dados inválidos.', details: e.issues || e.errors });
    res.status(500).json({ error: 'Erro interno ao salvar compromisso na agenda.' });
  }
});

// ── PATCH /v1/vet/agenda/:id — Atualizar Status do Compromisso ────────
router.patch('/agenda/:id', authenticate, requireRole('veterinario'), requireEntitlement('VET_PORTAL'), async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!['agendado', 'realizado', 'cancelado'].includes(status)) {
      return res.status(400).json({ error: 'Status inválido. Use agendado, realizado ou cancelado.' });
    }

    const item = await getAsync(`SELECT * FROM vet_agenda WHERE id = ? AND veterinarian_id = ?`, [id, req.user.veterinarianId]);
    if (!item) {
      return res.status(404).json({ error: 'Compromisso não encontrado.' });
    }

    await runAsync(`UPDATE vet_agenda SET status = ? WHERE id = ?`, [status, id]);

    res.json({ message: 'Status atualizado com sucesso.', id, status });
  } catch (e) {
    res.status(500).json({ error: 'Erro interno ao atualizar compromisso.' });
  }
});

// ══════════════════════════════════════════════════════════════════════
// ── ONDA 7: Saúde Avançada — Prontuário e Intervenções Append-Only ────
// ══════════════════════════════════════════════════════════════════════

const createIntervencaoSchema = z.object({
  animalId: z.string().min(1, 'ID do animal é obrigatório.'),
  tenantContaId: z.string().min(1, 'ID da fazenda/conta é obrigatório.'),
  tipo: z.enum(['avaliacao', 'observacao', 'prescricao', 'aplicacao', 'retorno', 'encerramento']),
  payload: z.record(z.any()),
  intervencaoAnteriorId: z.string().nullable().optional(),
  visitaId: z.string().nullable().optional()
});

// ── POST /v1/vet/intervencoes — Registrar Intervenção Append-Only ─────
router.post('/intervencoes', authenticate, requireRole('veterinario'), requireEntitlement('VET_PORTAL'), async (req, res) => {
  try {
    const { animalId, tenantContaId, tipo, payload, intervencaoAnteriorId, visitaId } = createIntervencaoSchema.parse(req.body);

    // 1. Valida se o veterinário tem grant ativo
    const grant = await getAsync(
      `SELECT * FROM sharing_grants 
       WHERE veterinarian_id = ? AND tenant_conta_id = ? AND status = 'active'
         AND (expires_at IS NULL OR expires_at > ?)`,
      [req.user.veterinarianId, tenantContaId, new Date().toISOString()]
    );

    if (!grant) {
      return res.status(403).json({ error: 'Você não possui compartilhamento ativo com esta fazenda.' });
    }

    const permissoes = JSON.parse(grant.permissions || '[]');

    // 2. Valida nível de permissão necessário
    const exigeIntervencao = ['prescricao', 'aplicacao', 'retorno', 'encerramento'].includes(tipo);
    if (exigeIntervencao) {
      const temIntervencao = permissoes.includes('intervencao') || permissoes.includes('administrativo');
      if (!temIntervencao) {
        return res.status(403).json({ error: 'Nível de permissão insuficiente para registrar este tipo de intervenção (exige nível Intervenção).' });
      }
    } else {
      const temTecnico = permissoes.includes('tecnico') || permissoes.includes('intervencao') || permissoes.includes('administrativo');
      if (!temTecnico) {
        return res.status(403).json({ error: 'Nível de permissão insuficiente (exige ao menos nível Técnico).' });
      }
    }

    const intervencaoId = crypto.randomUUID();
    const now = new Date().toISOString();

    // 3. Gravação Append-Only
    await runAsync(
      `INSERT INTO intervencoes_veterinarias (id, animal_id, tenant_conta_id, veterinarian_id, grant_id, tipo, payload, intervencao_anterior_id, visita_id, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [intervencaoId, animalId, tenantContaId, req.user.veterinarianId, grant.id, tipo, JSON.stringify(payload), intervencaoAnteriorId || null, visitaId || null, now]
    );

    // 4. Se for aplicação sanitária, replica para proj_aplicacoes_sanitarias e entities do Core
    if (tipo === 'aplicacao') {
      const appSanitariaId = crypto.randomUUID();
      const appPayload = {
        id: appSanitariaId,
        animalId,
        produtoId: payload.produtoId || 'MED-VET',
        doseMl: payload.doseMl || 0,
        dataAplicacao: payload.dataAplicacao || now.split('T')[0],
        responsavel: req.user.nome || 'Veterinário Responsável',
        observacao: payload.observacao || payload.descricao || 'Aplicação via intervenção veterinária',
        carenciaDias: payload.carenciaDias || 0,
        intervencaoOrigemId: intervencaoId
      };

      // Grava no sync blob do tenant para descer no app do produtor
      await runAsync(
        `INSERT INTO entities (server_id, owner_id, entity_id, entity_type, payload, device_id, created_at, updated_at)
         VALUES (?, ?, ?, 'aplicacoes_sanitarias', ?, 'server-vet-portal', ?, ?)`,
        [crypto.randomUUID(), tenantContaId, appSanitariaId, JSON.stringify(appPayload), now, now]
      );

      // Materializa na tabela projetada da Onda 1
      const { projectEntity } = require('../services/projector');
      await projectEntity('aplicacoes_sanitarias', appSanitariaId, tenantContaId, appPayload, now, null);
    }

    // Audit trail
    await logEvent({
      actorUserId: req.user.id,
      actorContaId: tenantContaId,
      action: 'intervencao_created',
      entityType: 'intervencao_veterinaria',
      entityId: intervencaoId,
      metadata: { animalId, tipo, grantId: grant.id }
    });

    res.status(201).json({
      message: 'Intervenção veterinária registrada com sucesso.',
      intervencao: {
        id: intervencaoId,
        animalId,
        tenantContaId,
        veterinarianId: req.user.veterinarianId,
        grantId: grant.id,
        tipo,
        payload,
        intervencaoAnteriorId: intervencaoAnteriorId || null,
        visitaId: visitaId || null,
        createdAt: now
      }
    });
  } catch (e) {
    if (e instanceof z.ZodError) return res.status(400).json({ error: 'Dados inválidos.', details: e.issues || e.errors });
    console.error('Erro ao registrar intervenção:', e);
    res.status(500).json({ error: 'Erro interno ao registrar intervenção.' });
  }
});

// ── GET /v1/vet/animals/:animalId/prontuario — Prontuário Unificado ──
router.get('/animals/:animalId/prontuario', authenticate, async (req, res) => {
  try {
    const { animalId } = req.params;
    const targetContaId = req.query.tenantContaId || req.headers['x-tenant-conta-id'] || req.user.contaId;

    if (!targetContaId) {
      return res.status(400).json({ error: 'Identificador da fazenda/conta não informado.' });
    }

    // Se for veterinário, valida grant
    if (req.user.perfil === 'veterinario') {
      const grant = await getAsync(
        `SELECT * FROM sharing_grants 
         WHERE veterinarian_id = ? AND tenant_conta_id = ? AND status = 'active'
           AND (expires_at IS NULL OR expires_at > ?)`,
        [req.user.veterinarianId, targetContaId, new Date().toISOString()]
      );
      if (!grant) {
        return res.status(403).json({ error: 'Sem acesso ativo a esta fazenda.' });
      }
    } else if (req.user.contaId !== targetContaId) {
      return res.status(403).json({ error: 'Acesso negado aos dados desta fazenda.' });
    }

    // 1. Busca dados básicos do animal
    const animal = await getAsync(
      `SELECT * FROM proj_animais WHERE entity_id = ? AND owner_id = ? AND deleted_at IS NULL`,
      [animalId, targetContaId]
    );

    // 2. Busca intervenções veterinárias
    const intervencoes = await allAsync(
      `SELECT i.*, v.nome as veterinarianNome, v.crmv as veterinarianCrmv
       FROM intervencoes_veterinarias i
       JOIN veterinarians v ON v.id = i.veterinarian_id
       WHERE i.animal_id = ? AND i.tenant_conta_id = ?
       ORDER BY i.created_at DESC`,
      [animalId, targetContaId]
    );

    // 3. Busca aplicações sanitárias do Core
    const aplicacoes = await allAsync(
      `SELECT * FROM proj_aplicacoes_sanitarias
       WHERE animal_id = ? AND owner_id = ? AND deleted_at IS NULL
       ORDER BY data_aplicacao DESC`,
      [animalId, targetContaId]
    );

    // 4. Busca ocorrências sanitárias
    const ocorrencias = await allAsync(
      `SELECT * FROM proj_ocorrencias_sanitarias
       WHERE animal_id = ? AND owner_id = ? AND deleted_at IS NULL
       ORDER BY data_ocorrencia DESC`,
      [animalId, targetContaId]
    );

    // 5. Busca pesagens
    const pesagens = await allAsync(
      `SELECT * FROM proj_pesagens
       WHERE animal_id = ? AND owner_id = ? AND deleted_at IS NULL
       ORDER BY data_pesagem DESC`,
      [animalId, targetContaId]
    );

    // 6. Alerta de múltiplos veterinários nos últimos 30 dias (Passo 3)
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString();
    const distinctVetsRecent = await allAsync(
      `SELECT DISTINCT v.id, v.nome, v.crmv
       FROM intervencoes_veterinarias i
       JOIN veterinarians v ON v.id = i.veterinarian_id
       WHERE i.animal_id = ? AND i.created_at >= ?`,
      [animalId, thirtyDaysAgo]
    );

    const multiplosProfissionaisRecentes = distinctVetsRecent.length > 1;

    // 7. Constrói Timeline unificada
    const timeline = [];

    for (const item of intervencoes) {
      timeline.push({
        id: item.id,
        origem: 'veterinaria',
        tipo: item.tipo,
        data: item.created_at,
        titulo: `Intervenção: ${item.tipo.toUpperCase()}`,
        autor: `Dr(a). ${item.veterinarianNome} (${item.veterinarianCrmv || 'CRMV'})`,
        detalhes: JSON.parse(item.payload || '{}'),
        intervencaoAnteriorId: item.intervencao_anterior_id
      });
    }

    for (const item of aplicacoes) {
      // Se não veio de intervenção direta ou para compor a timeline
      timeline.push({
        id: item.entity_id,
        origem: 'sanitaria',
        tipo: 'aplicacao_medicamento',
        data: item.data_aplicacao,
        titulo: `Aplicação Sanitária (Dose: ${item.dose_ml}ml)`,
        autor: item.responsavel || 'Manejo de Campo',
        detalhes: {
          produtoId: item.produto_id,
          carenciaDias: item.carencia_dias,
          observacao: item.observacao,
          intervencaoOrigemId: item.intervencao_origem_id
        }
      });
    }

    for (const item of ocorrencias) {
      timeline.push({
        id: item.entity_id,
        origem: 'ocorrencia',
        tipo: item.tipo || 'ocorrencia_clinica',
        data: item.data_ocorrencia,
        titulo: `Ocorrência: ${item.tipo || 'Geral'} (${item.gravidade || 'Normal'})`,
        autor: 'Registro de Campo',
        detalhes: {
          descricao: item.descricao,
          tratamento: item.tratamento,
          status: item.status
        }
      });
    }

    for (const item of pesagens) {
      timeline.push({
        id: item.entity_id,
        origem: 'manejo',
        tipo: 'pesagem',
        data: item.data_pesagem,
        titulo: `Pesagem: ${item.peso} kg`,
        autor: 'Manejo de Campo',
        detalhes: { pesoKg: item.peso }
      });
    }

    // Ordenação cronológica decrescente
    timeline.sort((a, b) => new Date(b.data) - new Date(a.data));

    res.json({
      animal: animal || { id: animalId },
      multiplosProfissionaisRecentes,
      profissionaisRecentes: distinctVetsRecent,
      totalEventos: timeline.length,
      timeline
    });
  } catch (e) {
    console.error('Erro ao montar prontuário do animal:', e);
    res.status(500).json({ error: 'Erro interno ao consultar prontuário do animal.' });
  }
});

// ══════════════════════════════════════════════════════════════════════
// ── ONDA 8: Nutrição Avançada — Recomendações e Evolução Nutricional ──
// ══════════════════════════════════════════════════════════════════════

const createRecomendacaoSchema = z.object({
  loteId: z.string().min(1, 'ID do lote é obrigatório.'),
  tenantContaId: z.string().min(1, 'ID da fazenda/conta é obrigatório.'),
  dietaSugerida: z.record(z.any()), // Objeto com nome, descricao, ingredientes ou parâmetros
  justificativa: z.string().optional()
});

// ── POST /v1/vet/nutricao/recomendacoes — Veterinário sugere Dieta ───
router.post('/nutricao/recomendacoes', authenticate, requireRole('veterinario'), requireEntitlement('VET_PORTAL'), async (req, res) => {
  try {
    const { loteId, tenantContaId, dietaSugerida, justificativa } = createRecomendacaoSchema.parse(req.body);

    // 1. Valida se o veterinário tem grant ativo com ao menos permissão técnico
    const grant = await getAsync(
      `SELECT * FROM sharing_grants 
       WHERE veterinarian_id = ? AND tenant_conta_id = ? AND status = 'active'
         AND (expires_at IS NULL OR expires_at > ?)`,
      [req.user.veterinarianId, tenantContaId, new Date().toISOString()]
    );

    if (!grant) {
      return res.status(403).json({ error: 'Você não possui compartilhamento ativo com esta fazenda.' });
    }

    const permissoes = JSON.parse(grant.permissions || '[]');
    const temPermissao = permissoes.includes('tecnico') || permissoes.includes('intervencao') || permissoes.includes('administrativo');
    if (!temPermissao) {
      return res.status(403).json({ error: 'Nível de permissão insuficiente para emitir recomendações nutricionais (exige nível Técnico).' });
    }

    const recomendacaoId = crypto.randomUUID();
    const now = new Date().toISOString();

    // 2. Gravação append-only da recomendação
    await runAsync(
      `INSERT INTO recomendacoes_nutricionais (id, lote_id, tenant_conta_id, veterinarian_id, grant_id, dieta_sugerida, justificativa, status, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, 'pendente', ?)`,
      [recomendacaoId, loteId, tenantContaId, req.user.veterinarianId, grant.id, JSON.stringify(dietaSugerida), justificativa || null, now]
    );

    // Audit trail
    await logEvent({
      actorUserId: req.user.id,
      actorContaId: tenantContaId,
      action: 'recomendacao_nutricional_created',
      entityType: 'recomendacao_nutricional',
      entityId: recomendacaoId,
      metadata: { loteId, grantId: grant.id }
    });

    res.status(201).json({
      message: 'Recomendação nutricional enviada com sucesso ao produtor.',
      recomendacao: {
        id: recomendacaoId,
        loteId,
        tenantContaId,
        veterinarianId: req.user.veterinarianId,
        dietaSugerida,
        justificativa,
        status: 'pendente',
        createdAt: now
      }
    });
  } catch (e) {
    if (e instanceof z.ZodError) return res.status(400).json({ error: 'Dados inválidos.', details: e.issues || e.errors });
    console.error('Erro ao emitir recomendação nutricional:', e);
    res.status(500).json({ error: 'Erro interno ao salvar recomendação nutricional.' });
  }
});

// ── GET /v1/vet/nutricao/recomendacoes — Listar Recomendações ─────────
router.get('/nutricao/recomendacoes', authenticate, async (req, res) => {
  try {
    const { loteId, tenantContaId } = req.query;
    const targetContaId = tenantContaId || req.user.contaId;

    if (!targetContaId && req.user.perfil !== 'veterinario') {
      return res.status(400).json({ error: 'Identificador da conta não informado.' });
    }

    let query = `
      SELECT r.*, v.nome as veterinarianNome, v.crmv as veterinarianCrmv, l.nome as loteNome
      FROM recomendacoes_nutricionais r
      JOIN veterinarians v ON v.id = r.veterinarian_id
      LEFT JOIN proj_lotes l ON l.entity_id = r.lote_id
      WHERE 1=1
    `;
    const params = [];

    if (req.user.perfil === 'veterinario') {
      query += ` AND r.veterinarian_id = ?`;
      params.push(req.user.veterinarianId);
      if (targetContaId) {
        query += ` AND r.tenant_conta_id = ?`;
        params.push(targetContaId);
      }
    } else {
      query += ` AND r.tenant_conta_id = ?`;
      params.push(targetContaId);
    }

    if (loteId) {
      query += ` AND r.lote_id = ?`;
      params.push(loteId);
    }

    query += ` ORDER BY r.created_at DESC`;

    const rows = await allAsync(query, params);

    const formatted = rows.map(r => ({
      ...r,
      dietaSugerida: JSON.parse(r.dieta_sugerida || '{}')
    }));

    res.json(formatted);
  } catch (e) {
    console.error('Erro ao listar recomendações:', e);
    res.status(500).json({ error: 'Erro interno ao listar recomendações nutricionais.' });
  }
});

// ── POST /v1/vet/nutricao/recomendacoes/:id/aplicar — Produtor aplica Dieta ──
router.post('/nutricao/recomendacoes/:id/aplicar', authenticate, requireRole('proprietario'), requireEntitlement('CORE'), async (req, res) => {
  try {
    const { id } = req.params;

    const recomendacao = await getAsync(
      `SELECT * FROM recomendacoes_nutricionais WHERE id = ? AND tenant_conta_id = ?`,
      [id, req.user.contaId]
    );

    if (!recomendacao) {
      return res.status(404).json({ error: 'Recomendação nutricional não encontrada.' });
    }

    if (recomendacao.status !== 'pendente') {
      return res.status(400).json({ error: `Esta recomendação já foi ${recomendacao.status}.` });
    }

    const now = new Date().toISOString();
    const dietaSugerida = JSON.parse(recomendacao.dieta_sugerida || '{}');

    // 1. Cria a Dieta no Core vinculada à recomendação
    const dietaId = crypto.randomUUID();
    const dietaPayload = {
      id: dietaId,
      loteId: recomendacao.lote_id,
      nome: dietaSugerida.nome || 'Dieta Recomendada por Especialista',
      descricao: dietaSugerida.descricao || recomendacao.justificativa || 'Dieta prescrita via consultoria veterinária',
      ativa: 1,
      origemRecomendacaoId: id
    };

    // Grava no sync blob do tenant para descer no app do produtor
    await runAsync(
      `INSERT INTO entities (server_id, owner_id, entity_id, entity_type, payload, device_id, created_at, updated_at)
       VALUES (?, ?, ?, 'dietas', ?, 'server-vet-portal', ?, ?)`,
      [crypto.randomUUID(), req.user.contaId, dietaId, JSON.stringify(dietaPayload), now, now]
    );

    // Materializa na tabela de domínio
    const { projectEntity } = require('../services/projector');
    await projectEntity('dietas', dietaId, req.user.contaId, dietaPayload, now, null);

    // 2. Atualiza o status da recomendação
    await runAsync(
      `UPDATE recomendacoes_nutricionais SET status = 'aceita', decided_at = ? WHERE id = ?`,
      [now, id]
    );

    // Audit trail
    await logEvent({
      actorUserId: req.user.id,
      actorContaId: req.user.contaId,
      action: 'recomendacao_nutricional_aplicada',
      entityType: 'recomendacao_nutricional',
      entityId: id,
      metadata: { dietaId, loteId: recomendacao.lote_id }
    });

    res.json({
      message: 'Recomendação nutricional aplicada com sucesso. A nova dieta foi ativada para o lote.',
      dietaId,
      status: 'aceita',
      decidedAt: now
    });
  } catch (e) {
    console.error('Erro ao aplicar recomendação nutricional:', e);
    res.status(500).json({ error: 'Erro interno ao aplicar recomendação.' });
  }
});

// ── GET /v1/vet/lotes/:loteId/evolucao-nutricional — Comparação de Resultados ──
router.get('/lotes/:loteId/evolucao-nutricional', authenticate, async (req, res) => {
  try {
    const { loteId } = req.params;
    const targetContaId = req.query.tenantContaId || req.headers['x-tenant-conta-id'] || req.user.contaId;

    if (!targetContaId) {
      return res.status(400).json({ error: 'Identificador da fazenda não informado.' });
    }

    // 1. Validação de acesso
    if (req.user.perfil === 'veterinario') {
      const grant = await getAsync(
        `SELECT * FROM sharing_grants 
         WHERE veterinarian_id = ? AND tenant_conta_id = ? AND status = 'active'
           AND (expires_at IS NULL OR expires_at > ?)`,
        [req.user.veterinarianId, targetContaId, new Date().toISOString()]
      );
      if (!grant) return res.status(403).json({ error: 'Sem acesso ativo a esta fazenda.' });
    } else if (req.user.contaId !== targetContaId) {
      return res.status(403).json({ error: 'Acesso negado aos dados desta fazenda.' });
    }

    // 2. Busca histórico de fornecimento de dieta para este lote
    const fornecimentos = await allAsync(
      `SELECT f.*, d.nome as dietaNome, d.origem_recomendacao_id as recomendacaoId
       FROM proj_fornecimentos_dieta f
       LEFT JOIN proj_dietas d ON d.entity_id = f.dieta_id
       WHERE f.lote_id = ? AND f.owner_id = ? AND f.deleted_at IS NULL
       ORDER BY f.data_fornecimento ASC`,
      [loteId, targetContaId]
    );

    // 3. Busca pesagens e calcula GMD dos animais pertencentes a este lote
    const animaisDoLote = await allAsync(
      `SELECT entity_id, brinco FROM proj_animais WHERE lote_id = ? AND owner_id = ? AND deleted_at IS NULL`,
      [loteId, targetContaId]
    );

    const animalIds = animaisDoLote.map(a => a.entity_id);
    let pesagens = [];

    if (animalIds.length > 0) {
      const placeholders = animalIds.map(() => '?').join(',');
      pesagens = await allAsync(
        `SELECT p.animal_id as animalId, p.peso, p.data_pesagem as dataPesagem, a.brinco
         FROM proj_pesagens p
         JOIN proj_animais a ON a.entity_id = p.animal_id
         WHERE p.animal_id IN (${placeholders}) AND p.owner_id = ? AND p.deleted_at IS NULL
         ORDER BY p.data_pesagem ASC`,
        [...animalIds, targetContaId]
      );
    }

    // 4. Calcula médias consolidadas por data
    const evolucaoPeso = {};
    for (const p of pesagens) {
      if (!evolucaoPeso[p.dataPesagem]) {
        evolucaoPeso[p.dataPesagem] = { data: p.dataPesagem, totalPeso: 0, count: 0, pesoMedioKg: 0 };
      }
      evolucaoPeso[p.dataPesagem].totalPeso += p.peso;
      evolucaoPeso[p.dataPesagem].count += 1;
      evolucaoPeso[p.dataPesagem].pesoMedioKg = parseFloat((evolucaoPeso[p.dataPesagem].totalPeso / evolucaoPeso[p.dataPesagem].count).toFixed(2));
    }

    res.json({
      loteId,
      totalAnimaisNoLote: animalIds.length,
      historicoFornecimentos: fornecimentos.map(f => ({
        id: f.entity_id,
        dietaNome: f.dietaNome,
        recomendacaoId: f.recomendacaoId,
        dataFornecimento: f.data_fornecimento,
        quantidadeKg: f.quantidade_kg
      })),
      evolucaoPesoMedio: Object.values(evolucaoPeso),
      pesagensIndividuais: pesagens
    });
  } catch (e) {
    console.error('Erro ao gerar evolução nutricional:', e);
    res.status(500).json({ error: 'Erro interno ao consultar evolução nutricional do lote.' });
  }
});

// ══════════════════════════════════════════════════════════════════════
// ── ONDA 9: Operação Profissional — Visitas, Laudos e Faturamento ─────
// ══════════════════════════════════════════════════════════════════════

const createVisitaSchema = z.object({
  tenantContaId: z.string().min(1, 'ID da fazenda é obrigatório.'),
  dataHora: z.string().min(1, 'Data e hora da visita são obrigatórias.'),
  observacoes: z.string().optional()
});

// ── POST /v1/vet/visitas — Registrar Visita Técnica / Clínica ─────────
router.post('/visitas', authenticate, requireRole('veterinario'), requireEntitlement('VET_PORTAL'), async (req, res) => {
  try {
    const { tenantContaId, dataHora, observacoes } = createVisitaSchema.parse(req.body);

    const grant = await getAsync(
      `SELECT * FROM sharing_grants 
       WHERE veterinarian_id = ? AND tenant_conta_id = ? AND status = 'active'
         AND (expires_at IS NULL OR expires_at > ?)`,
      [req.user.veterinarianId, tenantContaId, new Date().toISOString()]
    );

    if (!grant) {
      return res.status(403).json({ error: 'Você não possui compartilhamento ativo com esta fazenda.' });
    }

    const visitaId = crypto.randomUUID();
    const now = new Date().toISOString();

    await runAsync(
      `INSERT INTO vet_visitas (id, veterinarian_id, tenant_conta_id, data_hora, status, observacoes, created_at)
       VALUES (?, ?, ?, ?, 'agendada', ?, ?)`,
      [visitaId, req.user.veterinarianId, tenantContaId, dataHora, observacoes || null, now]
    );

    await logEvent({
      actorUserId: req.user.id,
      actorContaId: tenantContaId,
      action: 'visita_created',
      entityType: 'vet_visita',
      entityId: visitaId,
      metadata: { tenantContaId, dataHora }
    });

    res.status(201).json({
      message: 'Visita técnica registrada com sucesso.',
      visita: {
        id: visitaId,
        veterinarianId: req.user.veterinarianId,
        tenantContaId,
        dataHora,
        status: 'agendada',
        observacoes: observacoes || null,
        createdAt: now
      }
    });
  } catch (e) {
    if (e instanceof z.ZodError) return res.status(400).json({ error: 'Dados inválidos.', details: e.issues || e.errors });
    console.error('Erro ao criar visita:', e);
    res.status(500).json({ error: 'Erro interno ao salvar visita.' });
  }
});

// ── GET /v1/vet/visitas — Listar Visitas ──────────────────────────────
router.get('/visitas', authenticate, async (req, res) => {
  try {
    const { tenantContaId, status } = req.query;
    const targetContaId = tenantContaId || req.user.contaId;

    let query = `
      SELECT v.*, u.nome as produtorNome, vet.nome as veterinarianNome, vet.crmv as veterinarianCrmv,
             (SELECT COUNT(*) FROM intervencoes_veterinarias i WHERE i.visita_id = v.id) as totalIntervencoes
      FROM vet_visitas v
      JOIN usuarios u ON u.id = v.tenant_conta_id
      JOIN veterinarians vet ON vet.id = v.veterinarian_id
      WHERE 1=1
    `;
    const params = [];

    if (req.user.perfil === 'veterinario') {
      query += ` AND v.veterinarian_id = ?`;
      params.push(req.user.veterinarianId);
      if (targetContaId) {
        query += ` AND v.tenant_conta_id = ?`;
        params.push(targetContaId);
      }
    } else {
      query += ` AND v.tenant_conta_id = ?`;
      params.push(targetContaId);
    }

    if (status) {
      query += ` AND v.status = ?`;
      params.push(status);
    }

    query += ` ORDER BY v.data_hora DESC`;

    const rows = await allAsync(query, params);
    res.json(rows);
  } catch (e) {
    console.error('Erro ao listar visitas:', e);
    res.status(500).json({ error: 'Erro interno ao listar visitas.' });
  }
});

// ── PATCH /v1/vet/visitas/:id/concluir — Finalizar Visita ──────────────
router.patch('/visitas/:id/concluir', authenticate, requireRole('veterinario'), requireEntitlement('VET_PORTAL'), async (req, res) => {
  try {
    const { id } = req.params;
    const { observacoesFinais } = req.body;

    const visita = await getAsync(`SELECT * FROM vet_visitas WHERE id = ? AND veterinarian_id = ?`, [id, req.user.veterinarianId]);
    if (!visita) return res.status(404).json({ error: 'Visita não encontrada.' });

    const now = new Date().toISOString();
    await runAsync(
      `UPDATE vet_visitas SET status = 'concluida', concluida_at = ?, observacoes = COALESCE(?, observacoes) WHERE id = ?`,
      [now, observacoesFinais || null, id]
    );

    res.json({ message: 'Visita técnica concluída com sucesso.', id, status: 'concluida', concluidaAt: now });
  } catch (e) {
    res.status(500).json({ error: 'Erro interno ao concluir visita.' });
  }
});

// ── POST /v1/vet/ordens-servico — Criar Ordem de Serviço / Faturamento ──
const createOsSchema = z.object({
  visitaId: z.string().nullable().optional(),
  tenantContaId: z.string().min(1, 'ID da fazenda é obrigatório.'),
  descricao: z.string().min(1, 'Descrição do serviço é obrigatória.'),
  itens: z.array(z.object({
    servico: z.string().min(1),
    quantidade: z.number().positive(),
    valorUnitario: z.number().nonnegative(),
    subtotal: z.number().nonnegative()
  })).min(1, 'Ao menos um item deve ser informado.'),
  dataVencimento: z.string().optional()
});

router.post('/ordens-servico', authenticate, requireRole('veterinario'), requireEntitlement('VET_PORTAL'), async (req, res) => {
  try {
    const { visitaId, tenantContaId, descricao, itens, dataVencimento } = createOsSchema.parse(req.body);

    const grant = await getAsync(
      `SELECT * FROM sharing_grants 
       WHERE veterinarian_id = ? AND tenant_conta_id = ? AND status = 'active'
         AND (expires_at IS NULL OR expires_at > ?)`,
      [req.user.veterinarianId, tenantContaId, new Date().toISOString()]
    );

    if (!grant) {
      return res.status(403).json({ error: 'Você não possui compartilhamento ativo com esta fazenda.' });
    }

    const valorTotal = itens.reduce((acc, item) => acc + (item.subtotal || (item.quantidade * item.valorUnitario)), 0);
    const osId = crypto.randomUUID();
    const now = new Date().toISOString();

    await runAsync(
      `INSERT INTO vet_ordens_servico (id, visita_id, veterinarian_id, tenant_conta_id, descricao, itens, valor_total, status, data_vencimento, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, 'aberta', ?, ?)`,
      [osId, visitaId || null, req.user.veterinarianId, tenantContaId, descricao, JSON.stringify(itens), valorTotal, dataVencimento || null, now]
    );

    res.status(201).json({
      message: 'Ordem de serviço gerada com sucesso.',
      ordemServico: {
        id: osId,
        visitaId: visitaId || null,
        veterinarianId: req.user.veterinarianId,
        tenantContaId,
        descricao,
        itens,
        valorTotal,
        status: 'aberta',
        dataVencimento: dataVencimento || null,
        createdAt: now
      }
    });
  } catch (e) {
    if (e instanceof z.ZodError) return res.status(400).json({ error: 'Dados inválidos.', details: e.issues || e.errors });
    console.error('Erro ao criar OS:', e);
    res.status(500).json({ error: 'Erro interno ao criar ordem de serviço.' });
  }
});

// ── GET /v1/vet/ordens-servico — Listar Ordens de Serviço ─────────────
router.get('/ordens-servico', authenticate, async (req, res) => {
  try {
    const { tenantContaId, status } = req.query;
    const targetContaId = tenantContaId || req.user.contaId;

    let query = `
      SELECT os.*, u.nome as produtorNome, vet.nome as veterinarianNome, vet.crmv as veterinarianCrmv
      FROM vet_ordens_servico os
      JOIN usuarios u ON u.id = os.tenant_conta_id
      JOIN veterinarians vet ON vet.id = os.veterinarian_id
      WHERE 1=1
    `;
    const params = [];

    if (req.user.perfil === 'veterinario') {
      query += ` AND os.veterinarian_id = ?`;
      params.push(req.user.veterinarianId);
      if (targetContaId) {
        query += ` AND os.tenant_conta_id = ?`;
        params.push(targetContaId);
      }
    } else {
      query += ` AND os.tenant_conta_id = ?`;
      params.push(targetContaId);
    }

    if (status) {
      query += ` AND os.status = ?`;
      params.push(status);
    }

    query += ` ORDER BY os.created_at DESC`;

    const rows = await allAsync(query, params);
    const formatted = rows.map(r => ({
      ...r,
      itens: JSON.parse(r.itens || '[]')
    }));

    res.json(formatted);
  } catch (e) {
    console.error('Erro ao listar OS:', e);
    res.status(500).json({ error: 'Erro interno ao listar ordens de serviço.' });
  }
});

// ── PATCH /v1/vet/ordens-servico/:id/pagamento — Baixa / Status de Cobrança ──
router.patch('/ordens-servico/:id/pagamento', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const { status, dataPagamento } = req.body;

    if (!['aberta', 'paga', 'cancelada'].includes(status)) {
      return res.status(400).json({ error: 'Status inválido. Use aberta, paga ou cancelada.' });
    }

    let os;
    if (req.user.perfil === 'veterinario') {
      os = await getAsync(`SELECT * FROM vet_ordens_servico WHERE id = ? AND veterinarian_id = ?`, [id, req.user.veterinarianId]);
    } else {
      os = await getAsync(`SELECT * FROM vet_ordens_servico WHERE id = ? AND tenant_conta_id = ?`, [id, req.user.contaId]);
    }

    if (!os) return res.status(404).json({ error: 'Ordem de serviço não encontrada.' });

    const dtPagto = status === 'paga' ? (dataPagamento || new Date().toISOString().split('T')[0]) : null;

    await runAsync(
      `UPDATE vet_ordens_servico SET status = ?, data_pagamento = ? WHERE id = ?`,
      [status, dtPagto, id]
    );

    res.json({ message: `Ordem de serviço atualizada para ${status}.`, id, status, dataPagamento: dtPagto });
  } catch (e) {
    res.status(500).json({ error: 'Erro interno ao atualizar pagamento da OS.' });
  }
});

// ── GET /v1/vet/visitas/:id/laudo — Laudo Clínico / Relatório de Atendimento ──
router.get('/visitas/:id/laudo', authenticate, async (req, res) => {
  try {
    const { id } = req.params;

    const visita = await getAsync(`SELECT * FROM vet_visitas WHERE id = ?`, [id]);
    if (!visita) return res.status(404).json({ error: 'Visita técnica não encontrada.' });

    // Validação de acesso
    if (req.user.perfil === 'veterinario' && req.user.veterinarianId !== visita.veterinarian_id) {
      return res.status(403).json({ error: 'Acesso negado ao laudo desta visita.' });
    } else if (req.user.perfil !== 'veterinario' && req.user.contaId !== visita.tenant_conta_id) {
      return res.status(403).json({ error: 'Acesso negado ao laudo desta visita.' });
    }

    // 1. Dados do Veterinário
    const vet = await getAsync(`SELECT * FROM veterinarians WHERE id = ?`, [visita.veterinarian_id]);

    // 2. Dados do Produtor / Fazenda
    const produtor = await getAsync(`SELECT nome, email, cpf_cnpj as cpfCnpj FROM usuarios WHERE id = ?`, [visita.tenant_conta_id]);
    const fazenda = await getAsync(`SELECT nome, cidade, estado FROM proj_fazendas WHERE owner_id = ? LIMIT 1`, [visita.tenant_conta_id]);

    // 3. Intervenções realizadas nesta visita
    const intervencoes = await allAsync(
      `SELECT i.*, a.brinco as animalBrinco, a.raca as animalRaca, a.sexo as animalSexo
       FROM intervencoes_veterinarias i
       LEFT JOIN proj_animais a ON a.entity_id = i.animal_id
       WHERE i.visita_id = ?
       ORDER BY i.created_at ASC`,
      [id]
    );

    // 4. Ordem de Serviço vinculada
    const os = await getAsync(`SELECT * FROM vet_ordens_servico WHERE visita_id = ?`, [id]);

    res.json({
      laudoId: `LAUDO-${visita.id.substring(0, 8).toUpperCase()}`,
      dataEmissao: new Date().toISOString(),
      visita: {
        id: visita.id,
        dataHora: visita.data_hora,
        status: visita.status,
        observacoes: visita.observacoes,
        concluidaAt: visita.concluida_at
      },
      veterinario: {
        nome: vet?.nome,
        crmv: vet?.crmv,
        telefone: vet?.telefone
      },
      propriedade: {
        fazendaNome: fazenda?.nome || 'Propriedade Rural',
        produtorNome: produtor?.nome,
        produtorCpfCnpj: produtor?.cpfCnpj,
        cidade: fazenda?.cidade,
        estado: fazenda?.estado
      },
      totalAnimaisAtendidos: new Set(intervencoes.map(i => i.animal_id)).size,
      intervencoesRealizadas: intervencoes.map(i => ({
        id: i.id,
        tipo: i.tipo,
        animal: {
          id: i.animal_id,
          brinco: i.animalBrinco,
          raca: i.animalRaca,
          sexo: i.animalSexo
        },
        detalhes: JSON.parse(i.payload || '{}'),
        realizadoEm: i.created_at
      })),
      faturamento: os ? {
        ordemServicoId: os.id,
        descricao: os.descricao,
        itens: JSON.parse(os.itens || '[]'),
        valorTotal: os.valor_total,
        status: os.status
      } : null
    });
  } catch (e) {
    console.error('Erro ao gerar laudo da visita:', e);
    res.status(500).json({ error: 'Erro interno ao gerar laudo da visita.' });
  }
});

// ══════════════════════════════════════════════════════════════════════
// ── ONDA 10: Inteligência — Alertas Baseados em Regra (Passo 1) ───────
// ══════════════════════════════════════════════════════════════════════
//
// Implementação sem ML — regras SQL puras sobre tabelas projetadas (Onda 1).
// Princípio: cada alerta deve ser explicável em uma frase simples e nunca
// ser uma "caixa-preta" para quem vai agir sobre ele.
//
// Alertas implementados:
//  A1 — Lote com GMD abaixo da média histórica do próprio lote (últimos 30 d)
//  A2 — Animal com 3+ ocorrências sanitárias em 60 dias
//  A3 — Animal em carência sanitária (já exposto pelos indicadores do dashboard, aqui com detalhes)
//  A4 — Animal sem pesagem há mais de 60 dias (estagnação de monitoramento)
//  A5 — Ordem de Serviço em aberto com vencimento há mais de 15 dias
// ═════════════════════════════════════════════════════════════════════

// ── GET /v1/vet/alertas — Motor de Alertas Cross-Fazenda ─────────────
router.get('/alertas', authenticate, async (req, res) => {
  try {
    const targetContaId = req.query.tenantContaId || req.headers['x-tenant-conta-id'] || req.user.contaId;

    // Resolução de tenants autorizados
    let tenantIds = [];

    if (req.user.perfil === 'veterinario') {
      const nowIso = new Date().toISOString();
      const grants = await allAsync(
        `SELECT tenant_conta_id FROM sharing_grants
         WHERE veterinarian_id = ? AND status = 'active'
           AND (expires_at IS NULL OR expires_at > ?)`,
        [req.user.veterinarianId, nowIso]
      );
      tenantIds = grants.map(g => g.tenant_conta_id);

      if (targetContaId && tenantIds.includes(targetContaId)) {
        tenantIds = [targetContaId];
      }
    } else if (req.user.contaId) {
      tenantIds = [req.user.contaId];
    }

    if (tenantIds.length === 0) {
      return res.json({ totalAlertas: 0, alertas: [] });
    }

    const alertas = [];
    const placeholders = tenantIds.map(() => '?').join(',');

    // ─── A1: Lotes com GMD 30d abaixo da média histórica do próprio lote ───
    for (const tenantId of tenantIds) {
      const lotes = await allAsync(
        `SELECT entity_id, nome FROM proj_lotes WHERE owner_id = ? AND deleted_at IS NULL`,
        [tenantId]
      );

      for (const lote of lotes) {
        const animaisLote = await allAsync(
          `SELECT entity_id FROM proj_animais WHERE lote_id = ? AND owner_id = ? AND deleted_at IS NULL`,
          [lote.entity_id, tenantId]
        );
        const animalIds = animaisLote.map(a => a.entity_id);
        if (animalIds.length === 0) continue;

        const idsPlaceholder = animalIds.map(() => '?').join(',');

        // Histórico total de pesagens do lote
        const pesoHistorico = await allAsync(
          `SELECT animal_id as animalId, peso, data_pesagem as dataPesagem
           FROM proj_pesagens
           WHERE animal_id IN (${idsPlaceholder}) AND owner_id = ? AND deleted_at IS NULL
           ORDER BY data_pesagem ASC`,
          [...animalIds, tenantId]
        );

        // Calcula GMD por intervalo entre pesagens consecutivas (todos os pares)
        const gmdIntervalos = {}; // animalId → [ gmd1, gmd2, … ]

        for (const p of pesoHistorico) {
          if (!gmdIntervalos[p.animalId]) gmdIntervalos[p.animalId] = [];
          gmdIntervalos[p.animalId].push(p);
        }

        // Para cada animal: histórico = média de todos os intervalos exceto o último;
        //                   recente   = GMD do último intervalo
        const gmdHistoricoList = [];
        const gmdRecenteList = [];

        for (const pesagens of Object.values(gmdIntervalos)) {
          if (pesagens.length < 2) continue;

          const intervals = [];
          for (let i = 1; i < pesagens.length; i++) {
            const diffDias = Math.max(1, Math.round(
              (new Date(pesagens[i].dataPesagem) - new Date(pesagens[i - 1].dataPesagem)) / (1000 * 60 * 60 * 24)
            ));
            intervals.push((pesagens[i].peso - pesagens[i - 1].peso) / diffDias);
          }

          if (intervals.length === 1) {
            // Só um intervalo: não há como separar histórico de recente com base nisto
            continue;
          }

          // Último intervalo = recente
          gmdRecenteList.push(intervals[intervals.length - 1]);
          // Média dos anteriores = histórico
          const historicos = intervals.slice(0, -1);
          gmdHistoricoList.push(historicos.reduce((a, b) => a + b, 0) / historicos.length);
        }

        if (gmdHistoricoList.length === 0 || gmdRecenteList.length === 0) continue;

        const gmdMedioHistorico = gmdHistoricoList.reduce((a, b) => a + b, 0) / gmdHistoricoList.length;
        const gmdMedioRecente = gmdRecenteList.reduce((a, b) => a + b, 0) / gmdRecenteList.length;

        if (gmdMedioRecente < gmdMedioHistorico * 0.8) {
          alertas.push({
            codigo: 'A1',
            nivel: 'atencao',
            titulo: `GMD do lote "${lote.nome}" está abaixo da média histórica`,
            descricao: `GMD recente (${gmdMedioRecente.toFixed(2)} kg/dia) está ${((1 - gmdMedioRecente / gmdMedioHistorico) * 100).toFixed(0)}% abaixo da média histórica do lote (${gmdMedioHistorico.toFixed(2)} kg/dia).`,
            justificativa: 'Lote com GMD dos últimos 30 dias abaixo de 80% da média histórica calculada a partir de todas as pesagens disponíveis.',
            tenantContaId: tenantId,
            entidade: { tipo: 'lote', id: lote.entity_id, nome: lote.nome },
            dados: { gmdMedioHistorico: parseFloat(gmdMedioHistorico.toFixed(2)), gmdMedioRecente: parseFloat(gmdMedioRecente.toFixed(2)) }
          });
        }
      }
    }

    // ─── A2: Animais com 3+ ocorrências sanitárias em 60 dias ────────────
    const data60DaysAgo = new Date(Date.now() - 60 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];

    const ocorrenciasFrequentes = await allAsync(
      `SELECT o.animal_id as animalId, a.brinco, a.owner_id as tenantId, COUNT(*) as totalOcorrencias
       FROM proj_ocorrencias_sanitarias o
       JOIN proj_animais a ON a.entity_id = o.animal_id
       WHERE o.owner_id IN (${placeholders}) AND o.deleted_at IS NULL
         AND o.data_ocorrencia >= ?
       GROUP BY o.animal_id
       HAVING COUNT(*) >= 3`,
      [...tenantIds, data60DaysAgo]
    );

    for (const row of ocorrenciasFrequentes) {
      alertas.push({
        codigo: 'A2',
        nivel: 'critico',
        titulo: `Animal ${row.brinco} com múltiplas ocorrências sanitárias`,
        descricao: `O animal com brinco ${row.brinco} registrou ${row.totalOcorrencias} ocorrências sanitárias nos últimos 60 dias. Atenção veterinária prioritária recomendada.`,
        justificativa: 'Animal com 3 ou mais ocorrências sanitárias registradas nos últimos 60 dias.',
        tenantContaId: row.tenantId,
        entidade: { tipo: 'animal', id: row.animalId, brinco: row.brinco },
        dados: { totalOcorrencias60Dias: row.totalOcorrencias }
      });
    }

    // ─── A3: Animais em carência sanitária ativa ──────────────────────────
    const emCarencia = await allAsync(
      `SELECT app.animal_id as animalId, a.brinco, app.owner_id as tenantId,
              app.produto_id as produtoId, app.carencia_dias as carenciaDias,
              app.data_aplicacao as dataAplicacao,
              date(app.data_aplicacao, '+' || app.carencia_dias || ' days') as dataFimCarencia
       FROM proj_aplicacoes_sanitarias app
       JOIN proj_animais a ON a.entity_id = app.animal_id
       WHERE app.owner_id IN (${placeholders}) AND app.deleted_at IS NULL
         AND app.carencia_dias > 0
         AND date(app.data_aplicacao, '+' || app.carencia_dias || ' days') >= date('now')
       ORDER BY dataFimCarencia ASC`,
      tenantIds
    );

    for (const row of emCarencia) {
      const diasRestantes = Math.max(0, Math.ceil((new Date(row.dataFimCarencia) - new Date()) / (1000 * 60 * 60 * 24)));
      alertas.push({
        codigo: 'A3',
        nivel: diasRestantes <= 3 ? 'atencao' : 'informativo',
        titulo: `Animal ${row.brinco} em período de carência sanitária`,
        descricao: `Carência de ${row.carenciaDias} dias em andamento. Encerra em ${row.dataFimCarencia} (${diasRestantes} dia${diasRestantes !== 1 ? 's' : ''} restante${diasRestantes !== 1 ? 's' : ''}).`,
        justificativa: 'Animal com aplicação sanitária dentro do prazo de carência — não pode ser comercializado ou abatido.',
        tenantContaId: row.tenantId,
        entidade: { tipo: 'animal', id: row.animalId, brinco: row.brinco },
        dados: { carenciaDias: row.carenciaDias, dataAplicacao: row.dataAplicacao, dataFimCarencia: row.dataFimCarencia, diasRestantes }
      });
    }

    // ─── A4: Animais sem pesagem há mais de 60 dias ───────────────────────
    const semPesagem60d = await allAsync(
      `SELECT a.entity_id as animalId, a.brinco, a.owner_id as tenantId,
              MAX(p.data_pesagem) as ultimaPesagem
       FROM proj_animais a
       LEFT JOIN proj_pesagens p ON p.animal_id = a.entity_id AND p.deleted_at IS NULL
       WHERE a.owner_id IN (${placeholders}) AND a.deleted_at IS NULL
       GROUP BY a.entity_id
       HAVING ultimaPesagem IS NULL OR ultimaPesagem < ?`,
      [...tenantIds, data60DaysAgo]
    );

    for (const row of semPesagem60d) {
      alertas.push({
        codigo: 'A4',
        nivel: 'informativo',
        titulo: `Animal ${row.brinco} sem pesagem recente`,
        descricao: row.ultimaPesagem
          ? `Última pesagem registrada em ${row.ultimaPesagem}, há mais de 60 dias. Monitoramento de desempenho prejudicado.`
          : `Nenhuma pesagem registrada para este animal. É impossível calcular GMD sem histórico de peso.`,
        justificativa: 'Animal sem registro de pesagem nos últimos 60 dias — impede cálculo confiável de GMD e detecção de problemas de desempenho.',
        tenantContaId: row.tenantId,
        entidade: { tipo: 'animal', id: row.animalId, brinco: row.brinco },
        dados: { ultimaPesagem: row.ultimaPesagem || null }
      });
    }

    // ─── A5: Ordens de Serviço em aberto com vencimento vencido há 15+ dias ─
    const data15DaysAgo = new Date(Date.now() - 15 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    const osVencidas = await allAsync(
      `SELECT os.id, os.descricao, os.valor_total as valorTotal,
              os.data_vencimento as dataVencimento, os.tenant_conta_id as tenantId,
              u.nome as produtorNome
       FROM vet_ordens_servico os
       JOIN usuarios u ON u.id = os.tenant_conta_id
       WHERE os.veterinarian_id = ? AND os.status = 'aberta'
         AND os.data_vencimento IS NOT NULL AND os.data_vencimento < ?`,
      [req.user.veterinarianId || 'none', data15DaysAgo]
    );

    for (const row of osVencidas) {
      if (!tenantIds.includes(row.tenantId)) continue;
      const diasVencido = Math.ceil((new Date() - new Date(row.dataVencimento)) / (1000 * 60 * 60 * 24));
      alertas.push({
        codigo: 'A5',
        nivel: 'atencao',
        titulo: `OS em aberto vencida há ${diasVencido} dia${diasVencido !== 1 ? 's' : ''}`,
        descricao: `A ordem de serviço "${row.descricao}" (R$ ${row.valorTotal?.toFixed(2)}) de ${row.produtorNome} está em aberto com vencimento em ${row.dataVencimento}.`,
        justificativa: 'Ordem de serviço sem registro de pagamento há mais de 15 dias após o vencimento.',
        tenantContaId: row.tenantId,
        entidade: { tipo: 'ordem_servico', id: row.id },
        dados: { valorTotal: row.valorTotal, dataVencimento: row.dataVencimento, diasVencido }
      });
    }

    // Ordenação: crítico > atenção > informativo
    const nivelOrdem = { critico: 0, atencao: 1, informativo: 2 };
    alertas.sort((a, b) => (nivelOrdem[a.nivel] ?? 3) - (nivelOrdem[b.nivel] ?? 3));

    res.json({
      geradoEm: new Date().toISOString(),
      totalAlertas: alertas.length,
      sumario: {
        critico: alertas.filter(a => a.nivel === 'critico').length,
        atencao: alertas.filter(a => a.nivel === 'atencao').length,
        informativo: alertas.filter(a => a.nivel === 'informativo').length
      },
      alertas
    });
  } catch (e) {
    console.error('Erro ao processar alertas:', e);
    res.status(500).json({ error: 'Erro interno ao processar alertas de inteligência.' });
  }
});

module.exports = router;
