import { db } from '../db/database.js';

export async function getActiveFazendaId() {
  try {
    const first = await db.fazendas.toCollection().first();
    if (first && first.id) {
      return first.id;
    }

    // Se o IndexedDB ainda não tem fazenda gravada, busca do Supabase
    try {
      const { supabase } = await import('../lib/supabase.js');
      const { data } = await supabase.from('fazendas').select('*').limit(1);
      if (Array.isArray(data) && data.length > 0) {
        await db.fazendas.put({ ...data[0], sync_status: 'synced' });
        return data[0].id;
      }
    } catch (sbErr) {
      console.warn('[getActiveFazendaId fetch error]:', sbErr);
    }

    return 'faz-1';
  } catch (err) {
    return 'faz-1';
  }
}

