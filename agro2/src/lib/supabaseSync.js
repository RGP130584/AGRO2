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

let realtimeChannel = null;

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
                await db[payload.table].put({
                  ...payload.new,
                  sync_status: 'synced'
                });
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
 * E executa reconciliação de registros locais que estejam ausentes na nuvem
 */
export async function pushSyncToSupabase() {
  try {
    const activeFazendaId = await getActiveFazendaId();

    // 1. Processa a outbox pendente (sync_queue)
    const pendingEvents = await db.sync_queue.where('status').equals('pending').toArray();
    for (const ev of pendingEvents) {
      if (ev.entidade && TABLES_TO_SYNC.includes(ev.entidade)) {
        let error = null;
        try {
          if (ev.acao === 'delete') {
            ({ error } = await supabase.from(ev.entidade).delete().eq('id', ev.entidade_id));
          } else if (ev.payload) {
            const cleanPayload = { ...ev.payload };
            delete cleanPayload.sync_status;
            if (cleanPayload.fazenda_id && activeFazendaId && activeFazendaId !== 'faz-1') {
              cleanPayload.fazenda_id = activeFazendaId;
            }
            ({ error } = await supabase.from(ev.entidade).upsert(cleanPayload));
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
          continue;
        }
      }

      await db.sync_queue.update(ev.id, {
        status: 'synced',
        synced_at: new Date().toISOString()
      });
    }

    // 2. Reconciliação Local -> Nuvem: Puxa todos os registros das tabelas locais
    // Se o registro não estiver marcado como 'synced' ou se for um registro antigo, envia para o Supabase
    for (const tableName of TABLES_TO_SYNC) {
      if (!db[tableName]) continue;
      try {
        const localItems = await db[tableName].toArray();
        for (const item of localItems) {
          if (item && item.id && item.sync_status !== 'synced') {
            const cleanPayload = { ...item };
            delete cleanPayload.sync_status;
            if (cleanPayload.fazenda_id && activeFazendaId && activeFazendaId !== 'faz-1') {
              cleanPayload.fazenda_id = activeFazendaId;
            }
            const { error } = await supabase.from(tableName).upsert(cleanPayload);
            if (!error) {
              await db[tableName].update(item.id, {
                fazenda_id: cleanPayload.fazenda_id || item.fazenda_id,
                sync_status: 'synced'
              });
            }
          }
        }
      } catch (recErr) {
        console.warn(`[Reconciliation Push Exception] ${tableName}:`, recErr.message);
      }
    }
  } catch (err) {
    console.error('[Supabase Push Error]:', err);
  }
}

/**
 * Puxa todos os dados do Supabase para o IndexedDB local e alinha registros legados
 */
export async function pullSyncFromSupabase() {
  try {
    const activeFazendaId = await getActiveFazendaId();
    let hasChanges = false;

    for (const tableName of TABLES_TO_SYNC) {
      try {
        const { data, error } = await supabase.from(tableName).select('*');
        if (error) {
          console.error(`[Pull Error] ${tableName}:`, error.message, error);
          continue;
        }

        if (Array.isArray(data) && data.length > 0) {
          const supabaseIds = new Set(data.map((d) => d.id));

          for (const item of data) {
            if (item && item.id && db[tableName]) {
              let targetFazendaId = item.fazenda_id;
              // Normaliza a fazenda de registros legados criados sob IDs antigos
              if (targetFazendaId && activeFazendaId && activeFazendaId !== 'faz-1' && targetFazendaId !== activeFazendaId) {
                targetFazendaId = activeFazendaId;
                // Atualiza também no Supabase para sincronizar a nuvem
                supabase.from(tableName).update({ fazenda_id: activeFazendaId }).eq('id', item.id);
              }

              await db[tableName].put({
                ...item,
                fazenda_id: targetFazendaId || item.fazenda_id,
                sync_status: 'synced'
              });
              hasChanges = true;
            }
          }

          // Se existir algum registro no IndexedDB local que NÃO está na nuvem (legado preso), sobe ele agora
          if (db[tableName]) {
            const localItems = await db[tableName].toArray();
            for (const localItem of localItems) {
              if (localItem && localItem.id && !supabaseIds.has(localItem.id)) {
                const cleanPayload = { ...localItem };
                delete cleanPayload.sync_status;
                if (cleanPayload.fazenda_id && activeFazendaId && activeFazendaId !== 'faz-1') {
                  cleanPayload.fazenda_id = activeFazendaId;
                }
                const { error: pushLegacyErr } = await supabase.from(tableName).upsert(cleanPayload);
                if (!pushLegacyErr) {
                  await db[tableName].update(localItem.id, {
                    fazenda_id: cleanPayload.fazenda_id || localItem.fazenda_id,
                    sync_status: 'synced'
                  });
                  hasChanges = true;
                }
              }
            }
          }
        } else if (db[tableName]) {
          // Se o Supabase estiver vazio nessa tabela mas o IndexedDB local tiver dados legados, sobe tudo
          const localItems = await db[tableName].toArray();
          for (const localItem of localItems) {
            if (localItem && localItem.id) {
              const cleanPayload = { ...localItem };
              delete cleanPayload.sync_status;
              if (cleanPayload.fazenda_id && activeFazendaId && activeFazendaId !== 'faz-1') {
                cleanPayload.fazenda_id = activeFazendaId;
              }
              const { error: pushLegacyErr } = await supabase.from(tableName).upsert(cleanPayload);
              if (!pushLegacyErr) {
                await db[tableName].update(localItem.id, {
                  fazenda_id: cleanPayload.fazenda_id || localItem.fazenda_id,
                  sync_status: 'synced'
                });
                hasChanges = true;
              }
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
  } catch (err) {
    console.error('[Supabase Pull Error]:', err);
  }
}

