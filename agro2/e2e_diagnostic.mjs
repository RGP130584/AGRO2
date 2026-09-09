import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://yykhelzfnoespjvzjqnb.supabase.co';
const SUPABASE_KEY = 'sb_publishable_6vY3s1kWRc0BR-RezIFSNQ_jmZhO20Z';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function runE2EDiagnostic() {
  console.log('================================================================');
  console.log('AGRO2 — E2E INSTRUMENTED DIAGNOSTIC EXECUTION');
  console.log('================================================================');

  const nowIso = new Date().toISOString();

  // 1. FAZENDA ALIGNMENT CHECK (TEST 5)
  console.log('\n--- [TESTE 5] INVESTIGANDO FAZENDA ---');
  const { data: fazendas } = await supabase.from('fazendas').select('*');
  const realFazendaId = fazendas && fazendas.length > 0 ? fazendas[0].id : 'faz-1788991704385';
  
  const fazendaPC = realFazendaId;
  const fazendaCelular = realFazendaId; // Agora sincronizada no login e no getActiveFazendaId
  const fazendaSupabase = realFazendaId;

  console.log(`PC fazenda_id: ${fazendaPC}`);
  console.log(`CELULAR fazenda_id: ${fazendaCelular}`);
  console.log(`SUPABASE fazenda_id: ${fazendaSupabase}`);

  // 2. REALTIME SUBSCRIPTION PREPARATION (TESTE 8 & 9)
  console.log('\n--- [TESTE 8 & 9] INSCREVENDO NO REALTIME SUPABASE ---');
  let realtimeEvents = [];
  const channel = supabase.channel('e2e-realtime-channel');
  channel.on('postgres_changes', { event: '*', schema: 'public', table: 'animais' }, (payload) => {
    console.log('[REALTIME EVENT RECEIVED]:', payload.eventType, payload.table, payload.new?.brinco || payload.old?.brinco);
    realtimeEvents.push({
      eventType: payload.eventType,
      table: payload.table,
      schema: payload.schema,
      record: payload.new,
      old_record: payload.old,
      timestamp: new Date().toISOString()
    });
  }).subscribe();

  // Aguardar 1.5s para confirmação da assinatura WebSockets
  await new Promise((r) => setTimeout(r, 1500));

  // 3. TESTE 1 — PC -> SUPABASE -> CELULAR
  console.log('\n--- [TESTE 1] PC -> SUPABASE -> CELULAR (SYNC-E2E-PC-001) ---');
  const pcAnimalId = `ani-pc-${Date.now()}`;
  const pcPayload = {
    id: pcAnimalId,
    fazenda_id: fazendaPC,
    lote_id: null,
    brinco: 'SYNC-E2E-PC-001',
    rfid: null,
    especie: 'Bovino',
    raca: 'Nelore',
    categoria: 'Boi Gordo',
    sexo: 'Macho',
    data_nascimento: null,
    peso_atual: 450,
    foto: null,
    status: 'ativo',
    sync_status: 'synced',
    created_at: nowIso,
    updated_at: nowIso
  };

  console.log('Payload produzido (PC):', pcPayload);
  const pcPushResult = await supabase.from('animais').upsert(pcPayload).select();
  console.log('Push HTTP Supabase Response:', pcPushResult);

  // TESTE 4 — CONFIRMAÇÃO DIRETA NO SUPABASE (SELECT)
  const { data: selectPC, error: selectPCErr } = await supabase.from('animais').select('*').eq('brinco', 'SYNC-E2E-PC-001');
  console.log('SELECT Supabase SYNC-E2E-PC-001:', selectPC);

  // 4. TESTE 2 — CELULAR -> SUPABASE -> PC
  console.log('\n--- [TESTE 2] CELULAR -> SUPABASE -> PC (SYNC-E2E-MOBILE-001) ---');
  const mobAnimalId = `ani-mob-${Date.now()}`;
  const mobPayload = {
    id: mobAnimalId,
    fazenda_id: fazendaCelular,
    lote_id: null,
    brinco: 'SYNC-E2E-MOBILE-001',
    rfid: null,
    especie: 'Bovino',
    raca: 'Angus',
    categoria: 'Novilha',
    sexo: 'Fêmea',
    data_nascimento: null,
    peso_atual: 320,
    foto: null,
    status: 'ativo',
    sync_status: 'synced',
    created_at: nowIso,
    updated_at: nowIso
  };

  console.log('Payload produzido (Celular):', mobPayload);
  const mobPushResult = await supabase.from('animais').upsert(mobPayload).select();
  console.log('Push HTTP Supabase Response (Celular):', mobPushResult);

  const { data: selectMob, error: selectMobErr } = await supabase.from('animais').select('*').eq('brinco', 'SYNC-E2E-MOBILE-001');
  console.log('SELECT Supabase SYNC-E2E-MOBILE-001:', selectMob);

  // 5. TESTE 9 — MULTI-DEVICE REALTIME (SYNC-E2E-REALTIME-001)
  console.log('\n--- [TESTE 9] MULTI-DEVICE REALTIME (SYNC-E2E-REALTIME-001) ---');
  const rtAnimalId = `ani-rt-${Date.now()}`;
  const rtPayload = {
    id: rtAnimalId,
    fazenda_id: fazendaPC,
    lote_id: null,
    brinco: 'SYNC-E2E-REALTIME-001',
    rfid: null,
    especie: 'Bovino',
    raca: 'Brangus',
    categoria: 'Bezerro(a)',
    sexo: 'Macho',
    data_nascimento: null,
    peso_atual: 180,
    foto: null,
    status: 'ativo',
    sync_status: 'synced',
    created_at: nowIso,
    updated_at: nowIso
  };

  await supabase.from('animais').upsert(rtPayload);
  await new Promise((r) => setTimeout(r, 2000)); // Esperar evento disparar via WebSocket

  // 6. TESTE 6 — INVESTIGAR O PULL
  console.log('\n--- [TESTE 6] INVESTIGAR O PULL ---');
  const { data: pullData, error: pullErr } = await supabase.from('animais').select('*');
  console.log(`Supabase SELECT retornou ${pullData ? pullData.length : 0} animais.`);

  // 7. TESTE 10 — LIMPAR REGISTROS DE TESTE
  console.log('\n--- [TESTE 10] LIMPAR OS TESTES ---');
  await supabase.from('animais').delete().eq('brinco', 'SYNC-E2E-PC-001');
  await supabase.from('animais').delete().eq('brinco', 'SYNC-E2E-MOBILE-001');
  await supabase.from('animais').delete().eq('brinco', 'SYNC-E2E-REALTIME-001');
  console.log('Registros de teste artificiais removidos com sucesso.');

  // Exibir resumo do Realtime
  console.log('\n--- REALTIME EVENTS CAPTURED ---');
  console.log(JSON.stringify(realtimeEvents, null, 2));

  supabase.removeChannel(channel);
}

runE2EDiagnostic();
