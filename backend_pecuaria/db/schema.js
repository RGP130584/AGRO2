/**
 * db/schema.js — DDLs de todas as tabelas do backend
 *
 * Inclui:
 * - Tabela genérica `entities` (sync blob — retrocompatibilidade)
 * - Tabela `usuarios` (auth/RBAC/tenancy)
 * - Tabelas de domínio projetadas (Onda 1): populadas pelo projector a partir dos payloads
 * - Tabela `audit_events` (Onda 3): observabilidade e audit trail
 */
const { db } = require('./connection');

function initializeSchema() {
  db.serialize(() => {
    // ── Tabela genérica de Sincronização (existente) ──────────────────
    db.run(`
      CREATE TABLE IF NOT EXISTS entities (
        server_id TEXT PRIMARY KEY,
        owner_id TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        payload TEXT NOT NULL,
        device_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_entities_owner_updated ON entities (owner_id, updated_at)`);
    db.run(`CREATE INDEX IF NOT EXISTS idx_entities_owner_entity ON entities (owner_id, entity_id)`);

    // ── Tabela de Usuários (existente) ────────────────────────────────
    db.run(`
      CREATE TABLE IF NOT EXISTS usuarios (
        id TEXT PRIMARY KEY,
        conta_id TEXT,
        nome TEXT NOT NULL,
        cpf_cnpj TEXT UNIQUE NOT NULL,
        email TEXT,
        senha_hash TEXT NOT NULL,
        perfil TEXT DEFAULT 'proprietario',
        token_version INTEGER DEFAULT 1,
        reset_token_hash TEXT,
        reset_token_expires INTEGER,
        criado_em TEXT NOT NULL
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_usuarios_conta ON usuarios (conta_id)`);

    // ══════════════════════════════════════════════════════════════════
    // ── ONDA 1: Tabelas de Domínio Projetadas ────────────────────────
    // ══════════════════════════════════════════════════════════════════

    db.run(`
      CREATE TABLE IF NOT EXISTS proj_fazendas (
        entity_id TEXT PRIMARY KEY,
        owner_id TEXT NOT NULL,
        nome TEXT,
        cpf_cnpj TEXT,
        responsavel TEXT,
        cidade TEXT,
        estado TEXT,
        updated_at TEXT,
        deleted_at TEXT
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_proj_fazendas_owner ON proj_fazendas (owner_id)`);

    db.run(`
      CREATE TABLE IF NOT EXISTS proj_piquetes (
        entity_id TEXT PRIMARY KEY,
        owner_id TEXT NOT NULL,
        fazenda_id TEXT,
        nome TEXT,
        coordenadas TEXT,
        area_hectares REAL,
        capacidade_cabecas INTEGER,
        updated_at TEXT,
        deleted_at TEXT
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_proj_piquetes_owner ON proj_piquetes (owner_id)`);

    db.run(`
      CREATE TABLE IF NOT EXISTS proj_lotes (
        entity_id TEXT PRIMARY KEY,
        owner_id TEXT NOT NULL,
        fazenda_id TEXT,
        piquete_id TEXT,
        nome TEXT,
        categoria TEXT,
        quantidade INTEGER,
        updated_at TEXT,
        deleted_at TEXT
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_proj_lotes_owner ON proj_lotes (owner_id)`);

    db.run(`
      CREATE TABLE IF NOT EXISTS proj_animais (
        entity_id TEXT PRIMARY KEY,
        owner_id TEXT NOT NULL,
        lote_id TEXT,
        brinco TEXT,
        tipo_animal TEXT,
        categoria TEXT,
        raca TEXT,
        sexo TEXT,
        data_nascimento TEXT,
        peso_kg REAL,
        prenha INTEGER,
        data_cobertura TEXT,
        data_parto_previsto TEXT,
        data_parto TEXT,
        qtd_filhotes INTEGER,
        qtd_filhotes_vivos INTEGER,
        updated_at TEXT,
        deleted_at TEXT
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_proj_animais_owner ON proj_animais (owner_id)`);
    db.run(`CREATE INDEX IF NOT EXISTS idx_proj_animais_brinco ON proj_animais (owner_id, brinco)`);
    db.run(`CREATE INDEX IF NOT EXISTS idx_proj_animais_lote ON proj_animais (owner_id, lote_id)`);

    db.run(`
      CREATE TABLE IF NOT EXISTS proj_pesagens (
        entity_id TEXT PRIMARY KEY,
        owner_id TEXT NOT NULL,
        animal_id TEXT,
        peso REAL,
        data_pesagem TEXT,
        updated_at TEXT,
        deleted_at TEXT
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_proj_pesagens_owner ON proj_pesagens (owner_id)`);

    db.run(`
      CREATE TABLE IF NOT EXISTS proj_aplicacoes_sanitarias (
        entity_id TEXT PRIMARY KEY,
        owner_id TEXT NOT NULL,
        animal_id TEXT,
        lote_id TEXT,
        produto_id TEXT,
        dose_ml REAL,
        data_aplicacao TEXT,
        responsavel TEXT,
        observacao TEXT,
        carencia_dias INTEGER,
        intervencao_origem_id TEXT,
        updated_at TEXT,
        deleted_at TEXT
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_proj_aplicacoes_owner ON proj_aplicacoes_sanitarias (owner_id)`);

    db.run(`
      CREATE TABLE IF NOT EXISTS proj_ocorrencias_sanitarias (
        entity_id TEXT PRIMARY KEY,
        owner_id TEXT NOT NULL,
        animal_id TEXT,
        tipo TEXT,
        descricao TEXT,
        data_ocorrencia TEXT,
        gravidade TEXT,
        tratamento TEXT,
        status TEXT,
        updated_at TEXT,
        deleted_at TEXT
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_proj_ocorrencias_owner ON proj_ocorrencias_sanitarias (owner_id)`);

    db.run(`
      CREATE TABLE IF NOT EXISTS proj_dietas (
        entity_id TEXT PRIMARY KEY,
        owner_id TEXT NOT NULL,
        lote_id TEXT,
        nome TEXT,
        descricao TEXT,
        ativa INTEGER,
        origem_recomendacao_id TEXT,
        updated_at TEXT,
        deleted_at TEXT
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_proj_dietas_owner ON proj_dietas (owner_id)`);

    db.run(`
      CREATE TABLE IF NOT EXISTS proj_fornecimentos_dieta (
        entity_id TEXT PRIMARY KEY,
        owner_id TEXT NOT NULL,
        lote_id TEXT,
        dieta_id TEXT,
        data_fornecimento TEXT,
        quantidade_kg REAL,
        observacao TEXT,
        updated_at TEXT,
        deleted_at TEXT
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_proj_fornecimentos_owner ON proj_fornecimentos_dieta (owner_id)`);

    db.run(`
      CREATE TABLE IF NOT EXISTS proj_produtos (
        entity_id TEXT PRIMARY KEY,
        owner_id TEXT NOT NULL,
        nome TEXT,
        categoria TEXT,
        unidade TEXT,
        estoque_minimo REAL,
        updated_at TEXT,
        deleted_at TEXT
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_proj_produtos_owner ON proj_produtos (owner_id)`);

    db.run(`
      CREATE TABLE IF NOT EXISTS proj_estoque_movimentos (
        entity_id TEXT PRIMARY KEY,
        owner_id TEXT NOT NULL,
        produto_id TEXT,
        tipo TEXT,
        quantidade REAL,
        data_movimento TEXT,
        observacao TEXT,
        data_validade TEXT,
        updated_at TEXT,
        deleted_at TEXT
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_proj_estoque_mov_owner ON proj_estoque_movimentos (owner_id)`);

    db.run(`
      CREATE TABLE IF NOT EXISTS proj_lancamentos_financeiros (
        entity_id TEXT PRIMARY KEY,
        owner_id TEXT NOT NULL,
        fazenda_id TEXT,
        tipo TEXT,
        categoria TEXT,
        descricao TEXT,
        valor REAL,
        data_lancamento TEXT,
        updated_at TEXT,
        deleted_at TEXT
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_proj_lanc_fin_owner ON proj_lancamentos_financeiros (owner_id)`);

    // ══════════════════════════════════════════════════════════════════
    // ── ONDA 3: Audit Trail ──────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════

    db.run(`
      CREATE TABLE IF NOT EXISTS audit_events (
        id TEXT PRIMARY KEY,
        actor_user_id TEXT NOT NULL,
        actor_conta_id TEXT,
        action TEXT NOT NULL,
        entity_type TEXT,
        entity_id TEXT,
        metadata TEXT,
        created_at TEXT NOT NULL
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_audit_actor_conta ON audit_events (actor_conta_id, created_at)`);
    db.run(`CREATE INDEX IF NOT EXISTS idx_audit_action ON audit_events (action, created_at)`);

    // ══════════════════════════════════════════════════════════════════
    // ── ONDA 4: Entitlements e Subscriptions ─────────────────────────
    // ══════════════════════════════════════════════════════════════════

    db.run(`
      CREATE TABLE IF NOT EXISTS plans (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        entitlements TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    `);

    db.run(`
      CREATE TABLE IF NOT EXISTS subscriptions (
        id TEXT PRIMARY KEY,
        conta_id TEXT NOT NULL,
        plan_id TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        starts_at TEXT NOT NULL,
        ends_at TEXT,
        created_at TEXT NOT NULL
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_subscriptions_conta ON subscriptions (conta_id, status)`);

    // Inserir planos padrão (CORE e VET_PRO) se ainda não existirem
    const now = new Date().toISOString();
    db.run(
      `INSERT OR IGNORE INTO plans (id, nome, entitlements, created_at) VALUES (?, ?, ?, ?)`,
      ['CORE', 'Plano Produtor Core', JSON.stringify(['CORE']), now]
    );
    db.run(
      `INSERT OR IGNORE INTO plans (id, nome, entitlements, created_at) VALUES (?, ?, ?, ?)`,
      ['VET_PRO', 'Plano Veterinário Profissional', JSON.stringify(['CORE', 'VET_PORTAL', 'VET_CLIENTS']), now]
    );

    // Migrar automaticamente contas existentes que ainda não têm subscription ativa
    db.run(`
      INSERT INTO subscriptions (id, conta_id, plan_id, status, starts_at, ends_at, created_at)
      SELECT 
        'sub-' || u.conta_id, 
        u.conta_id, 
        'CORE', 
        'active', 
        u.criado_em,
        NULL,
        u.criado_em
      FROM usuarios u
      WHERE u.conta_id IS NOT NULL 
        AND NOT EXISTS (SELECT 1 FROM subscriptions s WHERE s.conta_id = u.conta_id)
      GROUP BY u.conta_id
    `);

    // ══════════════════════════════════════════════════════════════════
    // ── ONDA 5: Sharing Grants & Módulo Veterinário ──────────────────
    // ══════════════════════════════════════════════════════════════════

    db.run(`
      CREATE TABLE IF NOT EXISTS veterinarians (
        id TEXT PRIMARY KEY,
        usuario_id TEXT NOT NULL UNIQUE,
        nome TEXT NOT NULL,
        crmv TEXT UNIQUE,
        telefone TEXT,
        criado_em TEXT NOT NULL
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_vets_usuario ON veterinarians (usuario_id)`);
    db.run(`CREATE INDEX IF NOT EXISTS idx_vets_crmv ON veterinarians (crmv)`);

    db.run(`
      CREATE TABLE IF NOT EXISTS sharing_grants (
        id TEXT PRIMARY KEY,
        tenant_conta_id TEXT NOT NULL,
        veterinarian_id TEXT NOT NULL,
        scope_type TEXT NOT NULL DEFAULT 'fazenda',
        scope_id TEXT,
        permissions TEXT NOT NULL,
        granted_by TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        created_at TEXT NOT NULL,
        accepted_at TEXT,
        expires_at TEXT,
        revoked_at TEXT
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_grants_tenant ON sharing_grants (tenant_conta_id, status)`);
    db.run(`CREATE INDEX IF NOT EXISTS idx_grants_vet ON sharing_grants (veterinarian_id, status)`);

    // ══════════════════════════════════════════════════════════════════
    // ── ONDA 6: Agenda e Alertas do Portal Veterinário ───────────────
    // ══════════════════════════════════════════════════════════════════

    db.run(`
      CREATE TABLE IF NOT EXISTS vet_agenda (
        id TEXT PRIMARY KEY,
        veterinarian_id TEXT NOT NULL,
        tenant_conta_id TEXT NOT NULL,
        titulo TEXT NOT NULL,
        descricao TEXT,
        data_hora TEXT NOT NULL,
        tipo TEXT NOT NULL DEFAULT 'visita',
        status TEXT NOT NULL DEFAULT 'agendado',
        created_at TEXT NOT NULL
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_agenda_vet ON vet_agenda (veterinarian_id, data_hora)`);
    db.run(`CREATE INDEX IF NOT EXISTS idx_agenda_tenant ON vet_agenda (tenant_conta_id)`);

    // ══════════════════════════════════════════════════════════════════
    // ── ONDA 7: Saúde Avançada — Intervenções Append-Only ─────────────
    // ══════════════════════════════════════════════════════════════════

    db.run(`
      CREATE TABLE IF NOT EXISTS intervencoes_veterinarias (
        id TEXT PRIMARY KEY,
        animal_id TEXT NOT NULL,
        tenant_conta_id TEXT NOT NULL,
        veterinarian_id TEXT NOT NULL,
        grant_id TEXT NOT NULL,
        tipo TEXT NOT NULL,
        payload TEXT NOT NULL,
        intervencao_anterior_id TEXT,
        visita_id TEXT,
        created_at TEXT NOT NULL
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_intervencoes_animal ON intervencoes_veterinarias (animal_id, created_at)`);
    db.run(`CREATE INDEX IF NOT EXISTS idx_intervencoes_tenant ON intervencoes_veterinarias (tenant_conta_id, created_at)`);

    // ══════════════════════════════════════════════════════════════════
    // ── ONDA 8: Nutrição Avançada — Recomendações do Veterinário ──────
    // ══════════════════════════════════════════════════════════════════

    db.run(`
      CREATE TABLE IF NOT EXISTS recomendacoes_nutricionais (
        id TEXT PRIMARY KEY,
        lote_id TEXT NOT NULL,
        tenant_conta_id TEXT NOT NULL,
        veterinarian_id TEXT NOT NULL,
        grant_id TEXT NOT NULL,
        dieta_sugerida TEXT NOT NULL,
        justificativa TEXT,
        status TEXT NOT NULL DEFAULT 'pendente',
        created_at TEXT NOT NULL,
        decided_at TEXT
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_recom_nutri_lote ON recomendacoes_nutricionais (lote_id, created_at)`);
    db.run(`CREATE INDEX IF NOT EXISTS idx_recom_nutri_tenant ON recomendacoes_nutricionais (tenant_conta_id, status)`);

    // ══════════════════════════════════════════════════════════════════
    // ── ONDA 9: Operação Profissional (Visitas, Laudos e OS) ──────────
    // ══════════════════════════════════════════════════════════════════

    db.run(`
      CREATE TABLE IF NOT EXISTS vet_visitas (
        id TEXT PRIMARY KEY,
        veterinarian_id TEXT NOT NULL,
        tenant_conta_id TEXT NOT NULL,
        data_hora TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'agendada',
        observacoes TEXT,
        created_at TEXT NOT NULL,
        concluida_at TEXT
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_visitas_vet ON vet_visitas (veterinarian_id, data_hora)`);
    db.run(`CREATE INDEX IF NOT EXISTS idx_visitas_tenant ON vet_visitas (tenant_conta_id)`);

    db.run(`
      CREATE TABLE IF NOT EXISTS vet_ordens_servico (
        id TEXT PRIMARY KEY,
        visita_id TEXT,
        veterinarian_id TEXT NOT NULL,
        tenant_conta_id TEXT NOT NULL,
        descricao TEXT NOT NULL,
        itens TEXT NOT NULL,
        valor_total REAL NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'aberta',
        data_vencimento TEXT,
        data_pagamento TEXT,
        created_at TEXT NOT NULL
      )
    `);
    db.run(`CREATE INDEX IF NOT EXISTS idx_os_vet ON vet_ordens_servico (veterinarian_id, status)`);
    db.run(`CREATE INDEX IF NOT EXISTS idx_os_tenant ON vet_ordens_servico (tenant_conta_id)`);
  });
}

module.exports = { initializeSchema };
