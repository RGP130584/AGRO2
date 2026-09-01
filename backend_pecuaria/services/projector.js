/**
 * services/projector.js — Projeção de Entidades para Tabelas de Domínio
 *
 * Onda 1: Ao receber cada entity via /v1/sync, além do blob em `entities`,
 * projeta os campos relevantes em tabelas reais de domínio.
 *
 * Mapa explícito entityType → tabela/colunas (whitelist, sem SQL dinâmico).
 */
const { runAsync } = require('../db/connection');

/**
 * Mapa de projeção: entityType → { table, columns }
 * `columns` lista o nome da coluna na tabela projetada e o caminho no payload.
 */
const PROJECTION_MAP = {
  fazendas: {
    table: 'proj_fazendas',
    columns: {
      nome: 'nome',
      cpf_cnpj: 'cpfCnpj',
      responsavel: 'responsavel',
      cidade: 'cidade',
      estado: 'estado',
    }
  },
  piquetes: {
    table: 'proj_piquetes',
    columns: {
      fazenda_id: 'fazendaId',
      nome: 'nome',
      coordenadas: 'coordenadas',
      area_hectares: 'areaHectares',
      capacidade_cabecas: 'capacidadeCabecas',
    }
  },
  lotes: {
    table: 'proj_lotes',
    columns: {
      fazenda_id: 'fazendaId',
      piquete_id: 'piqueteId',
      nome: 'nome',
      categoria: 'categoria',
      quantidade: 'quantidade',
    }
  },
  animais: {
    table: 'proj_animais',
    columns: {
      lote_id: 'loteId',
      brinco: 'brinco',
      tipo_animal: 'tipoAnimal',
      categoria: 'categoria',
      raca: 'raca',
      sexo: 'sexo',
      data_nascimento: 'dataNascimento',
      peso_kg: 'pesoKg',
      prenha: 'prenha',
      data_cobertura: 'dataCobertura',
      data_parto_previsto: 'dataPartoPrevisto',
      data_parto: 'dataParto',
      qtd_filhotes: 'qtdFilhotes',
      qtd_filhotes_vivos: 'qtdFilhotesVivos',
    }
  },
  pesagens: {
    table: 'proj_pesagens',
    columns: {
      animal_id: 'animalId',
      peso: 'peso',
      data_pesagem: 'dataPesagem',
    }
  },
  aplicacoes_sanitarias: {
    table: 'proj_aplicacoes_sanitarias',
    columns: {
      animal_id: 'animalId',
      lote_id: 'loteId',
      produto_id: 'produtoId',
      dose_ml: 'doseMl',
      data_aplicacao: 'dataAplicacao',
      responsavel: 'responsavel',
      observacao: 'observacao',
      carencia_dias: 'carenciaDias',
    }
  },
  ocorrencias_sanitarias: {
    table: 'proj_ocorrencias_sanitarias',
    columns: {
      animal_id: 'animalId',
      tipo: 'tipo',
      descricao: 'descricao',
      data_ocorrencia: 'dataOcorrencia',
      gravidade: 'gravidade',
      tratamento: 'tratamento',
      status: 'status',
    }
  },
  dietas: {
    table: 'proj_dietas',
    columns: {
      lote_id: 'loteId',
      nome: 'nome',
      descricao: 'descricao',
      ativa: 'ativa',
    }
  },
  fornecimentos_dieta: {
    table: 'proj_fornecimentos_dieta',
    columns: {
      lote_id: 'loteId',
      dieta_id: 'dietaId',
      data_fornecimento: 'dataFornecimento',
      quantidade_kg: 'quantidadeKg',
      observacao: 'observacao',
    }
  },
  produtos: {
    table: 'proj_produtos',
    columns: {
      nome: 'nome',
      categoria: 'categoria',
      unidade: 'unidade',
      estoque_minimo: 'estoqueMinimo',
    }
  },
  estoque_movimentos: {
    table: 'proj_estoque_movimentos',
    columns: {
      produto_id: 'produtoId',
      tipo: 'tipo',
      quantidade: 'quantidade',
      data_movimento: 'dataMovimento',
      observacao: 'observacao',
      data_validade: 'dataValidade',
    }
  },
  lancamentos_financeiros: {
    table: 'proj_lancamentos_financeiros',
    columns: {
      fazenda_id: 'fazendaId',
      tipo: 'tipo',
      categoria: 'categoria',
      descricao: 'descricao',
      valor: 'valor',
      data_lancamento: 'dataLancamento',
    }
  },
};

/**
 * Projeta uma entidade sincronizada para a tabela de domínio correspondente.
 * Usa INSERT OR REPLACE (upsert por entity_id).
 *
 * @param {string} entityType - Tipo da entidade (deve ser chave do PROJECTION_MAP)
 * @param {string} entityId - UUID da entidade no app
 * @param {string} ownerId - conta_id do tenant
 * @param {object} payload - Payload JSON da entidade
 * @param {string} updatedAt - Timestamp da última atualização
 * @param {string|null} deletedAt - Timestamp de soft-delete (ou null)
 */
async function projectEntity(entityType, entityId, ownerId, payload, updatedAt, deletedAt) {
  const mapping = PROJECTION_MAP[entityType];
  if (!mapping) {
    // Tipo de entidade não mapeado — ignora silenciosamente (segurança)
    return;
  }

  const { table, columns } = mapping;

  // Colunas fixas: entity_id, owner_id, updated_at, deleted_at
  const colNames = ['entity_id', 'owner_id'];
  const colValues = [entityId, ownerId];

  // Colunas de domínio extraídas do payload
  for (const [dbCol, payloadKey] of Object.entries(columns)) {
    colNames.push(dbCol);
    colValues.push(payload[payloadKey] ?? null);
  }

  colNames.push('updated_at', 'deleted_at');
  colValues.push(updatedAt, deletedAt);

  const placeholders = colNames.map(() => '?').join(', ');
  const sql = `INSERT OR REPLACE INTO ${table} (${colNames.join(', ')}) VALUES (${placeholders})`;

  await runAsync(sql, colValues);
}

/**
 * Retorna a lista de entityTypes suportados pelo projector.
 */
function getSupportedEntityTypes() {
  return Object.keys(PROJECTION_MAP);
}

module.exports = { projectEntity, getSupportedEntityTypes, PROJECTION_MAP };
