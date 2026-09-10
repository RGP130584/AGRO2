import { db } from '../db/database.js';

const ACTIVE_FAZENDA_KEY = 'agro2_active_fazenda_id';

/**
 * Obtém o ID da Fazenda Ativa no sistema.
 * 1. Tenta recuperar do localStorage (`agro2_active_fazenda_id`) e valida se a fazenda ainda existe.
 * 2. Se não houver no localStorage ou se inválida, pega a primeira fazenda cadastrada localmente (IndexedDB).
 * 3. Se não houver no IndexedDB, busca a primeira fazenda cadastrada no Supabase.
 * Retorna null se nenhuma fazenda existir no sistema.
 */
export async function getActiveFazendaId() {
  try {
    const savedId = typeof localStorage !== 'undefined' ? localStorage.getItem(ACTIVE_FAZENDA_KEY) : null;
    
    if (savedId) {
      const existsLocally = await db.fazendas.get(savedId);
      if (existsLocally) {
        console.log(`[FAZENDA ACTIVE] Fazenda ativa local: ${savedId}`);
        return savedId;
      }
    }

    // Busca a primeira fazenda cadastrada no Dexie
    const firstLocal = await db.fazendas.toCollection().first();
    if (firstLocal && firstLocal.id) {
      if (typeof localStorage !== 'undefined') {
        localStorage.setItem(ACTIVE_FAZENDA_KEY, firstLocal.id);
      }
      console.log(`[FAZENDA ACTIVE] Fazenda ativa definida (primeira local): ${firstLocal.id}`);
      return firstLocal.id;
    }

    // Se o IndexedDB ainda não tem fazenda gravada, busca do Supabase
    try {
      const { supabase } = await import('../lib/supabase.js');
      const { data } = await supabase.from('fazendas').select('*').limit(1);
      if (Array.isArray(data) && data.length > 0) {
        await db.fazendas.put({ ...data[0], sync_status: 'synced' });
        const farmId = data[0].id;
        if (typeof localStorage !== 'undefined') {
          localStorage.setItem(ACTIVE_FAZENDA_KEY, farmId);
        }
        console.log(`[FAZENDA ACTIVE] Fazenda ativa definida (remota Supabase): ${farmId}`);
        return farmId;
      }
    } catch (sbErr) {
      console.warn('[getActiveFazendaId fetch error]:', sbErr);
    }

    console.warn('[FAZENDA CONTEXT ERROR] Nenhuma fazenda cadastrada.');
    return null;
  } catch (err) {
    console.error('[getActiveFazendaId error]:', err);
    return null;
  }
}

/**
 * Exige o ID da Fazenda Ativa para cadastros e operações dependentes.
 * Lança um erro controlado com mensagem de domínio se nenhuma fazenda estiver cadastrada.
 * NUNCA retorna null.
 */
export async function requireActiveFazendaId() {
  const fazendaId = await getActiveFazendaId();
  if (!fazendaId) {
    console.error('[FAZENDA REQUIRED] Nenhuma fazenda cadastrada.');
    throw new Error('Nenhuma fazenda cadastrada. Cadastre uma fazenda para iniciar a operação.');
  }
  return fazendaId;
}

/**
 * Define explicitamente a Fazenda Ativa no contexto e dispara evento de mudança
 */
export async function setActiveFazendaId(fazendaId) {
  if (!fazendaId) return;
  if (typeof localStorage !== 'undefined') {
    localStorage.setItem(ACTIVE_FAZENDA_KEY, fazendaId);
  }
  console.log(`[FAZENDA SWITCH] Nova fazenda ativa: ${fazendaId}`);
  if (typeof window !== 'undefined') {
    window.dispatchEvent(new CustomEvent('agro2_fazenda_changed', { detail: fazendaId }));
  }
  return fazendaId;
}

/**
 * Retorna o objeto completo da Fazenda Ativa
 */
export async function getActiveFazenda() {
  const id = await getActiveFazendaId();
  if (!id) return null;
  return await db.fazendas.get(id);
}

/**
 * Retorna a lista de todas as fazendas disponíveis para o usuário
 */
export async function getFazendasList() {
  try {
    const list = await db.fazendas.toArray();
    if (list.length > 0) return list;

    const { supabase } = await import('../lib/supabase.js');
    const { data } = await supabase.from('fazendas').select('*');
    if (Array.isArray(data) && data.length > 0) {
      for (const f of data) {
        await db.fazendas.put({ ...f, sync_status: 'synced' });
      }
      return data;
    }
    return [];
  } catch (err) {
    console.error('[getFazendasList error]:', err);
    return [];
  }
}
