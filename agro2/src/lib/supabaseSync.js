import { supabase } from './supabase.js';
import { db } from '../db/database.js';

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
 * APENAS marca como 'synced' se NÃO houver erro retornado pelo Supabase.
 */
export async function pushSyncToSupabase() {
  try {
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
          continue; // Não marca como synced se houver erro!
        }
      }

      await db.sync_queue.update(ev.id, {
        status: 'synced',
        synced_at: new Date().toISOString()
      });
    }
  } catch (err) {
    console.error('[Supabase Push Error]:', err);
  }
}

/**
 * Puxa todos os dados do Supabase para o IndexedDB local e notifica a interface
 */
export async function pullSyncFromSupabase() {
  try {
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
              await db[tableName].put({
                ...item,
                sync_status: 'synced'
              });
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
  } catch (err) {
    console.error('[Supabase Pull Error]:', err);
  }
}
