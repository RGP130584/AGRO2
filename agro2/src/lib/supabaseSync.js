import { supabase } from './supabase.js';
import { db } from '../db/database.js';
import { getActiveFazendaId } from '../utils/fazendaHelper.js';

export const TABLES_TO_SYNC = [
  'usuarios',
  'fazendas',
  'piquetes',
  'lotes',
  'animais',
  'produtos',
  'aplicacoes_sanitarias',
  'ocorrencias_sanitarias',
  'dietas',
  'fornecimentos_dieta',
  'pesagens',
  'estoque_movimentos',
  'financeiro_lancamentos'
];

/**
 * Contrato de colunas permitidas no schema relacional PostgreSQL real do Supabase
 */
export const DB_COLUMNS = {
  usuarios: ['id', 'email', 'nome', 'senha', 'perfil', 'ativo', 'created_at'],
  fazendas: ['id', 'nome', 'proprietario_nome', 'sync_status', 'created_at'],
  piquetes: ['id', 'fazenda_id', 'nome', 'capacidade', 'sync_status', 'created_at'],
  lotes: ['id', 'fazenda_id', 'piquete_id', 'nome', 'categoria', 'especie', 'sync_status', 'created_at'],
  animais: [
    'id',
    'fazenda_id',
    'lote_id',
    'brinco',
    'rfid',
    'especie',
    'raca',
    'categoria',
    'sexo',
    'data_nascimento',
    'peso_atual',
    'gmd_recente',
    'carencia_fim',
    'status',
    'foto',
    'sync_status',
    'created_at',
    'updated_at'
  ],
  produtos: ['id', 'nome', 'tipo', 'carencia_dias', 'saldo_atual', 'validade', 'sync_status', 'created_at'],
  aplicacoes_sanitarias: [
    'id',
    'animal_id',
    'lote_id',
    'fazenda_id',
    'produto_id',
    'data_aplicacao',
    'carencia_fim',
    'dosagem',
    'observacoes',
    'produto_nome',
    'dose',
    'via',
    'motivo',
    'responsavel',
    'foto',
    'sync_status',
    'created_at'
  ],
  ocorrencias_sanitarias: [
    'id',
    'fazenda_id',
    'animal_id',
    'lote_id',
    'tipo',
    'descricao',
    'data',
    'resolvido',
    'sync_status',
    'created_at'
  ],
  dietas: ['id', 'fazenda_id', 'lote_id', 'nome', 'categoria', 'ativa', 'sync_status', 'created_at'],
  fornecimentos_dieta: ['id', 'fazenda_id', 'lote_id', 'dieta_id', 'produto_id', 'quantidade', 'data', 'sync_status', 'created_at'],
  pesagens: ['id', 'animal_id', 'lote_id', 'fazenda_id', 'data', 'peso', 'sync_status', 'created_at'],
  estoque_movimentos: ['id', 'fazenda_id', 'produto_id', 'tipo', 'quantidade', 'data', 'motivo', 'referencia_id', 'responsavel', 'sync_status', 'created_at'],
  financeiro_lancamentos: [
    'id',
    'fazenda_id',
    'tipo',
    'categoria',
    'descricao',
    'valor',
    'vencimento',
    'status',
    'data_pagamento',
    'fornecedor_cliente',
    'sync_status',
    'created_at'
  ]
};

let realtimeChannel = null;

/**
 * Sanitiza genericamente qualquer payload contra o contrato explícito DB_COLUMNS.
 * Evita perda silenciosa de dados exibindo warning no console para campos não configurados no PostgreSQL.
 * Preserva estritamente o fazenda_id original do payload.
 */
export function sanitizePayload(table, payload) {
  const allowedColumns = DB_COLUMNS[table];
  if (!allowedColumns) {
    throw new Error(`Tabela não configurada para sincronização: ${table}`);
  }

  const clean = {};
  const discarded = [];

  // Field mapping aliases for schema alignment
  const workingPayload = { ...payload };
  if (table === 'aplicacoes_sanitarias' && workingPayload.data && !workingPayload.data_aplicacao) {
    workingPayload.data_aplicacao = workingPayload.data;
  }
  if (table === 'financeiro_lancamentos' && workingPayload.data && !workingPayload.vencimento) {
    workingPayload.vencimento = workingPayload.data;
  }

  for (const [key, value] of Object.entries(workingPayload)) {
    if (key === 'sync_status') continue;
    if (allowedColumns.includes(key)) {
      clean[key] = value;
    } else if (value !== null && value !== undefined && value !== '') {
      discarded.push(key);
    }
  }

  if (discarded.length > 0) {
    console.warn(`[sanitizePayload Warning] ${table} descartou campos locais ausentes no PostgreSQL:`, discarded.join(', '));
  }

  return clean;
}

/**
 * Inscreve no canal WebSockets do Supabase para receber atualizações instantâneas de outros dispositivos
 */
export function subscribeToRealtimeSync() {
  if (realtimeChannel) return;

  try {
    realtimeChannel = supabase
      .channel('agro2-realtime-changes')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public' },
        async (payload) => {
          console.log('[Supabase Realtime Event]:', payload.eventType, payload.table);
          if (payload.table && TABLES_TO_SYNC.includes(payload.table)) {
            if (payload.eventType === 'DELETE' && payload.old && payload.old.id) {
              if (db[payload.table]) {
                await db[payload.table].delete(payload.old.id);
              }
            } else if (payload.new && payload.new.id) {
              if (db[payload.table]) {
                // Preserva alteração local se estiver pendente de push
                const localItem = await db[payload.table].get(payload.new.id);
                if (!localItem || (localItem.sync_status !== 'pending' && localItem.sync_status !== 'error')) {
                  await db[payload.table].put({
                    ...payload.new,
                    sync_status: 'synced'
                  });

                  // Cascata: Se for aplicação sanitária, atualiza a carência no cadastro do animal local
                  if (payload.table === 'aplicacoes_sanitarias' && payload.new.animal_id) {
                    const anim = await db.animais.get(payload.new.animal_id);
                    if (anim) {
                      await db.animais.update(anim.id, {
                        carencia_fim: payload.new.carencia_fim || anim.carencia_fim,
                        sync_status: 'synced'
                      });
                    }
                  }
                }
              }
            }
            window.dispatchEvent(new CustomEvent('agro2_sync_updated'));
          }
        }
      )
      .subscribe((status) => {
        console.log('[Supabase Realtime Status]:', status);
      });
  } catch (err) {
    console.warn('[Supabase Realtime Error]:', err.message);
  }
}

/**
 * Envia todos os eventos pendentes locais para o Supabase
 * APENAS marca como 'synced' se o Supabase responder sem erro HTTP/PostgREST.
 */
export async function pushSyncToSupabase() {
  const activeFazendaId = await getActiveFazendaId();
  let hasErrors = false;

  // 1. Processa a outbox pendente (sync_queue)
  const pendingEvents = await db.sync_queue.where('status').equals('pending').toArray();
  for (const ev of pendingEvents) {
    if (ev.entidade && TABLES_TO_SYNC.includes(ev.entidade)) {
      let error = null;
      try {
        if (ev.acao === 'delete') {
          ({ error } = await supabase.from(ev.entidade).delete().eq('id', ev.entidade_id));
        } else if (ev.payload) {
          const cleanPayload = sanitizePayload(ev.entidade, ev.payload);
          const res = await supabase.from(ev.entidade).upsert(cleanPayload).select();
          error = res.error;
          if (!error && (!res.data || res.data.length === 0)) {
            error = new Error('Operação de upsert não retornou confirmação de dados.');
          }
        }
      } catch (subErr) {
        error = subErr;
      }

      if (error) {
        console.error(`[Sync Error] ${ev.entidade} (${ev.acao}):`, error.message, error);
        await db.sync_queue.update(ev.id, {
          status: 'error',
          error_msg: error.message || String(error)
        });
        hasErrors = true;
        continue;
      }
    }

    await db.sync_queue.update(ev.id, {
      status: 'synced',
      synced_at: new Date().toISOString()
    });
  }

  // 2. Reconciliação Local -> Nuvem: Puxa todos os registros das tabelas locais com status pending/error
  for (const tableName of TABLES_TO_SYNC) {
    if (!db[tableName]) continue;
    try {
      const localItems = await db[tableName].toArray();
      for (const item of localItems) {
        if (item && item.id && (item.sync_status === 'pending' || item.sync_status === 'error')) {
          const cleanPayload = sanitizePayload(tableName, item);
          const { data, error } = await supabase.from(tableName).upsert(cleanPayload).select();
          if (!error && data && data.length > 0) {
            await db[tableName].update(item.id, {
              sync_status: 'synced'
            });
          } else if (error) {
            console.warn(`[Reconciliation Push Error] ${tableName}:`, error.message);
            hasErrors = true;
          }
        }
      }
    } catch (recErr) {
      console.warn(`[Reconciliation Push Exception] ${tableName}:`, recErr.message);
      hasErrors = true;
    }
  }

  if (hasErrors) {
    throw new Error('Houve falhas no envio de algumas operações da outbox.');
  }
}

/**
 * Puxa todos os dados do Supabase para o IndexedDB local sem destruir alterações locais pendentes
 * Preserva o fazenda_id original remoto retornado do Supabase
 */
export async function pullSyncFromSupabase() {
  let hasChanges = false;

  for (const tableName of TABLES_TO_SYNC) {
    try {
      const { data, error } = await supabase.from(tableName).select('*');
      if (error) {
        console.error(`[Pull Error] ${tableName}:`, error.message, error);
        continue;
      }

      if (Array.isArray(data) && data.length > 0) {
        for (const item of data) {
          if (item && item.id && db[tableName]) {
            // Preserva alteração local pendente sem sobrescrever
            const localItem = await db[tableName].get(item.id);
            if (localItem && (localItem.sync_status === 'pending' || localItem.sync_status === 'error')) {
              continue;
            }

            await db[tableName].put({
              ...item,
              sync_status: 'synced'
            });

            if (tableName === 'aplicacoes_sanitarias' && item.animal_id) {
              const anim = await db.animais.get(item.animal_id);
              if (anim) {
                await db.animais.update(anim.id, {
                  carencia_fim: item.carencia_fim || anim.carencia_fim,
                  sync_status: 'synced'
                });
              }
            }
            hasChanges = true;
          }
        }
      }
    } catch (tableErr) {
      console.warn(`[Supabase Pull Exception] ${tableName}:`, tableErr.message);
    }
  }

  if (hasChanges) {
    window.dispatchEvent(new CustomEvent('agro2_sync_updated'));
  }
}
