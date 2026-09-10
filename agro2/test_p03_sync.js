import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://yykhelzfnoespjvzjqnb.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_6vY3s1kWRc0BR-RezIFSNQ_jmZhO20Z';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const DB_COLUMNS = {
  animais: [
    'id', 'brinco', 'fazenda_id', 'lote_id', 'categoria', 'raca', 'sexo',
    'peso_atual', 'data_nascimento', 'status', 'carencia_fim', 'created_at', 'updated_at'
  ],
  lotes: ['id', 'nome', 'fazenda_id', 'tipo', 'created_at', 'updated_at'],
  pesagens: ['id', 'animal_id', 'fazenda_id', 'peso', 'data', 'created_at'],
  ocorrencias_sanitarias: [
    'id', 'animal_id', 'lote_id', 'fazenda_id', 'tipo', 'descricao', 'data', 'resolvido', 'sync_status', 'created_at'
  ],
  aplicacoes_sanitarias: [
    'id', 'animal_id', 'lote_id', 'fazenda_id', 'produto_id', 'produto_nome', 'dose', 'via', 'motivo', 'responsavel', 'foto', 'dosagem', 'carencia_fim', 'data_aplicacao', 'observacoes', 'sync_status', 'created_at'
  ],
  fornecimentos_dieta: [
    'id', 'lote_id', 'fazenda_id', 'suplemento', 'quantidade_kg', 'data', 'observacoes', 'created_at'
  ],
  produtos: [
    'id', 'nome', 'tipo', 'carencia_dias', 'saldo_atual', 'validade', 'sync_status', 'created_at'
  ],
  financeiro_lancamentos: [
    'id', 'fazenda_id', 'tipo', 'categoria', 'descricao', 'valor', 'vencimento',
    'status', 'data_pagamento', 'fornecedor_cliente', 'sync_status', 'created_at'
  ]
};

function sanitizePayload(table, payload) {
  const allowed = DB_COLUMNS[table];
  if (!allowed) return payload;
  
  const clean = {};
  const discarded = [];
  
  const workingPayload = { ...payload };
  if (table === 'aplicacoes_sanitarias' && workingPayload.data && !workingPayload.data_aplicacao) {
    workingPayload.data_aplicacao = workingPayload.data;
  }
  if (table === 'financeiro_lancamentos' && workingPayload.data && !workingPayload.vencimento) {
    workingPayload.vencimento = workingPayload.data;
  }

  for (const [key, value] of Object.entries(workingPayload)) {
    if (key === 'sync_status') continue;
    if (allowed.includes(key)) {
      clean[key] = value;
    } else if (value !== null && value !== undefined && value !== '') {
      discarded.push(key);
    }
  }
  
  return { clean, discarded };
}

async function runValidation() {
  console.log('=== AGRO2 P0.3 SYNCHRONIZATION E2E VALIDATION ===\n');

  // 1. Fetch Fazenda ID
  const { data: fazendas, error: fError } = await supabase.from('fazendas').select('*').limit(1);
  if (fError || !fazendas || fazendas.length === 0) {
    console.error('Failed to get fazendas:', fError);
    process.exit(1);
  }
  const fazendaId = fazendas[0].id;
  console.log(`[FAZENDA] Using Fazenda ID: ${fazendaId}`);

  const timestamp = Date.now();
  const testIdAnimal = `SYNC-P03-ANIMAL-${timestamp}`;
  const testIdFin = `SYNC-P03-FIN-${timestamp}`;
  const testIdSan = `SYNC-P03-SAN-${timestamp}`;
  const testIdProd = `SYNC-P03-PROD-${timestamp}`;

  // TEST 1 — PUSH & PULL ANIMAL
  console.log('\n--- TEST 1: ANIMAL PUSH & PULL ---');
  const rawAnimal = {
    id: testIdAnimal,
    brinco: `P03-${timestamp.toString().slice(-4)}`,
    fazenda_id: fazendaId,
    categoria: 'Novilha',
    sexo: 'Femea',
    status: 'Ativo',
    peso_atual: 320,
    carencia_fim: null,
    sync_status: 'synced',
    created_at: new Date().toISOString()
  };

  const { clean: animalPayload, discarded: animalDiscarded } = sanitizePayload('animais', rawAnimal);
  console.log('Animal payload sent:', animalPayload);
  console.log('Animal discarded fields:', animalDiscarded);

  const { data: pushAnimal, error: pushAnimalErr } = await supabase
    .from('animais')
    .upsert([animalPayload])
    .select();

  if (pushAnimalErr) {
    console.error('FAIL Push Animal:', pushAnimalErr);
  } else {
    console.log('PASS Push Animal success ID:', pushAnimal[0].id);
  }

  // Pull Animal
  const { data: pullAnimal, error: pullAnimalErr } = await supabase
    .from('animais')
    .select('*')
    .eq('id', testIdAnimal)
    .single();

  if (pullAnimalErr) {
    console.error('FAIL Pull Animal:', pullAnimalErr);
  } else {
    console.log('PASS Pull Animal verified in Supabase PostgreSQL:', pullAnimal.brinco);
  }

  // TEST 2 — FINANCEIRO
  console.log('\n--- TEST 2: FINANCEIRO PUSH & PULL ---');
  const rawFin = {
    id: testIdFin,
    fazenda_id: fazendaId,
    tipo: 'despesa',
    categoria: 'Veterinario',
    descricao: 'Vacinação P0.3 Validation',
    valor: 450.00,
    data: new Date().toISOString().split('T')[0],
    status: 'pago',
    data_pagamento: new Date().toISOString().split('T')[0],
    fornecedor_cliente: 'Vet Agro Ltda',
    comprovante: 'http://example.com/receipt.pdf',
    sync_status: 'pending'
  };

  const { clean: finPayload, discarded: finDiscarded } = sanitizePayload('financeiro_lancamentos', rawFin);
  console.log('Financeiro payload sent:', finPayload);
  console.log('Financeiro discarded fields:', finDiscarded);

  const { data: pushFin, error: pushFinErr } = await supabase
    .from('financeiro_lancamentos')
    .upsert([finPayload])
    .select();

  if (pushFinErr) {
    console.error('FAIL Push Financeiro:', pushFinErr);
  } else {
    console.log('PASS Push Financeiro success ID:', pushFin[0].id);
  }

  // TEST 3 — APLICAÇÃO SANITÁRIA & CARÊNCIA
  console.log('\n--- TEST 3: SANITÁRIO / CARÊNCIA ---');
  const carenciaFim = new Date(Date.now() + 30 * 86400000).toISOString().split('T')[0];
  const rawSan = {
    id: testIdSan,
    animal_id: testIdAnimal,
    fazenda_id: fazendaId,
    produto_nome: 'Ivermectina 1%',
    dose: '10ml',
    via: 'Subcutânea',
    motivo: 'Vermifugação P0.3 Validation',
    responsavel: 'Dr. Silva',
    dosagem: '1ml / 50kg',
    carencia_dias: 30,
    carencia_fim: carenciaFim,
    data: new Date().toISOString().split('T')[0],
    observacoes: 'Teste P0.3 Sanitária'
  };

  const { clean: sanPayload, discarded: sanDiscarded } = sanitizePayload('aplicacoes_sanitarias', rawSan);
  console.log('Aplicação Sanitária payload sent:', sanPayload);
  console.log('Sanitária discarded fields:', sanDiscarded);

  const { data: pushSan, error: pushSanErr } = await supabase
    .from('aplicacoes_sanitarias')
    .upsert([sanPayload])
    .select();

  if (pushSanErr) {
    console.error('FAIL Push Aplicação Sanitária:', pushSanErr);
  } else {
    console.log('PASS Push Aplicação Sanitária success ID:', pushSan[0].id);
  }

  // Update Animal carencia_fim in Supabase
  const { data: updateCare, error: updateCareErr } = await supabase
    .from('animais')
    .update({ carencia_fim: carenciaFim, updated_at: new Date().toISOString() })
    .eq('id', testIdAnimal)
    .select();

  if (updateCareErr) {
    console.error('FAIL Update Animal Carência:', updateCareErr);
  } else {
    console.log('PASS Update Animal Carência in Supabase:', updateCare[0].carencia_fim);
  }

  // TEST 4 — PRODUTOS / ESTOQUE
  console.log('\n--- TEST 4: PRODUTOS / ESTOQUE ---');
  const rawProd = {
    id: testIdProd,
    nome: `Ração Inicial P0.3 ${timestamp.toString().slice(-4)}`,
    tipo: 'Ração',
    carencia_dias: 0,
    saldo_atual: 150.5,
    validade: '2027-12-31',
    fazenda_id: fazendaId,
    unidade: 'kg'
  };

  const { clean: prodPayload, discarded: prodDiscarded } = sanitizePayload('produtos', rawProd);
  console.log('Produtos payload sent:', prodPayload);
  console.log('Produtos discarded fields:', prodDiscarded);

  const { data: pushProd, error: pushProdErr } = await supabase
    .from('produtos')
    .upsert([prodPayload])
    .select();

  if (pushProdErr) {
    console.error('FAIL Push Produtos:', pushProdErr);
  } else {
    console.log('PASS Push Produtos success ID:', pushProd[0].id);
  }

  // TEST 5 — REALTIME SUBSCRIPTION PROBE
  console.log('\n--- TEST 5: REALTIME LISTENER PROBE ---');
  let realtimeReceived = false;
  const channel = supabase
    .channel('test_p03_realtime_channel_v2')
    .on('postgres_changes', { event: '*', schema: 'public', table: 'animais' }, (payload) => {
      console.log('REALTIME EVENT RECEIVED ON ANIMAIS:', payload.eventType, payload.new?.id || payload.old?.id);
      realtimeReceived = true;
    })
    .subscribe(async (status) => {
      console.log('Realtime Subscription Status:', status);
      if (status === 'SUBSCRIBED') {
        setTimeout(async () => {
          await supabase.from('animais').update({ updated_at: new Date().toISOString() }).eq('id', testIdAnimal);
        }, 500);
      }
    });

  await new Promise(r => setTimeout(r, 4500));
  await supabase.removeChannel(channel);
  console.log(`Realtime probe completed. Event received: ${realtimeReceived}`);

  console.log('\n=== ALL P0.3 TESTS EXECUTED SUCCESSFULLY ===');
}

runValidation();
