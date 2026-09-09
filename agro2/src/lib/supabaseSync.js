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

/**
 * Sincroniza a fila de pendências locais para o Supabase
 */
export async function pushSyncToSupabase() {
  try {
    const pendingEvents = await db.sync_queue.where('status').equals('pending').toArray();
    for (const ev of pendingEvents) {
      if (ev.entidade && TABLES_TO_SYNC.includes(ev.entidade)) {
        try {
          if (ev.acao === 'delete') {
            await supabase.from(ev.entidade).delete().eq('id', ev.entidade_id);
          } else if (ev.payload) {
            const cleanPayload = { ...ev.payload };
            delete cleanPayload.sync_status;
            await supabase.from(ev.entidade).upsert(cleanPayload);
          }
        } catch (subErr) {
          console.warn(`[Supabase Push] Falha ao enviar ${ev.entidade}:`, subErr.message);
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
 * Puxa dados atualizados do Supabase para o IndexedDB local
 */
export async function pullSyncFromSupabase() {
  try {
    for (const tableName of TABLES_TO_SYNC) {
      try {
        const { data, error } = await supabase.from(tableName).select('*');
        if (!error && Array.isArray(data) && data.length > 0) {
          for (const item of data) {
            if (item && item.id && db[tableName]) {
              await db[tableName].put({
                ...item,
                sync_status: 'synced'
              });
            }
          }
        }
      } catch (tableErr) {
        console.warn(`[Supabase Pull] Tabela ${tableName}:`, tableErr.message);
      }
    }
  } catch (err) {
    console.error('[Supabase Pull Error]:', err);
  }
}
