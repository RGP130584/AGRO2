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
  });
}

module.exports = { initializeSchema };
