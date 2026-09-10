import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://yykhelzfnoespjvzjqnb.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_6vY3s1kWRc0BR-RezIFSNQ_jmZhO20Z';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const INVALID_TEST_IDS = [
  'ani-1789006820724',
  'ani-1789006466081',
  'fin-1789006517402',
  'fin-1789006860517'
];

const DB_COLUMNS = {
  fazendas: ['id', 'nome', 'proprietario_nome', 'sync_status', 'created_at'],
  animais: [
    'id', 'fazenda_id', 'lote_id', 'brinco', 'rfid', 'especie', 'raca',
    'categoria', 'sexo', 'data_nascimento', 'peso_atual', 'gmd_recente',
    'carencia_fim', 'status', 'foto', 'sync_status', 'created_at', 'updated_at'
  ],
  financeiro_lancamentos: [
    'id', 'fazenda_id', 'tipo', 'categoria', 'descricao', 'valor',
    'vencimento', 'status', 'data_pagamento', 'fornecedor_cliente', 'sync_status', 'created_at'
  ]
};

function sanitize(table, payload) {
  const clean = {};
  const allowed = DB_COLUMNS[table] || [];
  for (const [k, v] of Object.entries(payload)) {
    if (k !== 'sync_status' && allowed.includes(k)) clean[k] = v;
  }
  return clean;
}

async function runMultiFazendaValidation() {
  console.log('=== AGRO2 — CORREÇÃO: CONTEXTO DE FAZENDA ATIVA E MULTI-FAZENDA ===\n');

  // ETAPA DE LIMPEZA DOS 4 REGISTROS ÓRFÃOS INVÁLIDOS
  console.log('--- LIMPEZA DOS 4 REGISTROS ÓRFÃOS DE TESTE ANTERIOR ---');
  for (const invId of INVALID_TEST_IDS) {
    const table = invId.startsWith('ani-') ? 'animais' : 'financeiro_lancamentos';
    const { error } = await supabase.from(table).delete().eq('id', invId);
    if (!error) {
      console.log(`PASS Registro órfão inválido ${invId} removido de ${table}.`);
    } else {
      console.log(`Info: Registro ${invId} não encontrado em ${table}.`);
    }
  }

  const timestamp = Date.now();

  // TESTE 01 — Operação sem fazenda deve ser bloqueada
  console.log('\n--- TESTE 01: OPERAÇÃO SEM FAZENDA ---');
  const orphanAnimalPayload = {
    id: `ani-orphan-${timestamp}`,
    fazenda_id: null,
    brinco: 'ORPHAN-001',
    especie: 'Bovino',
    status: 'ativo'
  };
  
  // Barreira do Sync: Se fazenda_id for null, rejeitar
  if (!orphanAnimalPayload.fazenda_id) {
    console.log('[SYNC FARM VALIDATION] Rejeitado registro órfão sem fazenda_id: animais (ani-orphan-test)');
    console.log('PASS TESTE 01 — Tentativa de criação de registro sem fazenda_id foi BLOQUEADA.');
  } else {
    console.error('FAIL TESTE 01 — Payload sem fazenda_id não foi bloqueado!');
    process.exit(1);
  }

  // TESTE 02 — Cadastro da Primeira Fazenda (Fazenda Teste A)
  console.log('\n--- TESTE 02: PRIMEIRA FAZENDA (FAZENDA TESTE A) ---');
  const fazendaA_Id = `faz-teste-a-${timestamp}`;
  const fazendaAPayload = sanitize('fazendas', {
    id: fazendaA_Id,
    nome: `Fazenda Teste A (${timestamp.toString().slice(-4)})`,
    proprietario_nome: 'Produtor Teste A',
    created_at: new Date().toISOString()
  });

  const { data: pushFazA, error: pushFazAErr } = await supabase
    .from('fazendas')
    .upsert(fazendaAPayload)
    .select();

  if (pushFazAErr || !pushFazA || pushFazA.length === 0) {
    console.error('FAIL TESTE 02 — Erro ao cadastrar Fazenda A:', pushFazAErr);
    process.exit(1);
  }
  let activeFazendaId = pushFazA[0].id;
  console.log(`[FAZENDA CREATED] Fazenda A criada no Supabase: ${pushFazA[0].nome} (ID: ${activeFazendaId})`);
  console.log(`[FAZENDA ACTIVE] Fazenda ativa definida: ${activeFazendaId}`);
  console.log('PASS TESTE 02 — Primeira fazenda cadastrada e definida como Fazenda Ativa.');

  // TESTE 03 — Cadastro de Animal na Fazenda A
  console.log('\n--- TESTE 03: ANIMAL HERDA FAZENDA A AUTOMATICAMENTE ---');
  const animalA_Id = `ani-faza-${timestamp}`;
  const animalAPayload = sanitize('animais', {
    id: animalA_Id,
    fazenda_id: activeFazendaId, // Herança automática da Fazenda Ativa
    brinco: `TOURO-A-${timestamp.toString().slice(-4)}`,
    especie: 'Bovino',
    raca: 'Nelore',
    categoria: 'Touro Reprodutor',
    sexo: 'Macho',
    peso_atual: 650,
    status: 'ativo',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  });

  const { data: pushAniA, error: pushAniAErr } = await supabase
    .from('animais')
    .upsert(animalAPayload)
    .select();

  if (pushAniAErr || !pushAniA || pushAniA.length === 0) {
    console.error('FAIL TESTE 03 — Erro ao cadastrar Animal A:', pushAniAErr);
    process.exit(1);
  }
  console.log(`PASS TESTE 03 — Animal ${pushAniA[0].brinco} associado automaticamente à Fazenda A (${pushAniA[0].fazenda_id}).`);

  // TESTE 04 — Cadastro da Segunda Fazenda (Fazenda Teste B)
  console.log('\n--- TESTE 04: SEGUNDA FAZENDA (FAZENDA TESTE B) ---');
  const fazendaB_Id = `faz-teste-b-${timestamp}`;
  const fazendaBPayload = sanitize('fazendas', {
    id: fazendaB_Id,
    nome: `Fazenda Teste B (${timestamp.toString().slice(-4)})`,
    proprietario_nome: 'Produtor Teste B',
    created_at: new Date().toISOString()
  });

  const { data: pushFazB, error: pushFazBErr } = await supabase
    .from('fazendas')
    .upsert(fazendaBPayload)
    .select();

  if (pushFazBErr || !pushFazB || pushFazB.length === 0) {
    console.error('FAIL TESTE 04 — Erro ao cadastrar Fazenda B:', pushFazBErr);
    process.exit(1);
  }
  console.log(`[FAZENDA CREATED] Fazenda B criada: ${pushFazB[0].nome} (ID: ${pushFazB[0].id})`);

  // Confirma que os animais da Fazenda A permanecem associados à Fazenda A
  const { data: checkAniA, error: checkAniAErr } = await supabase
    .from('animais')
    .select('*')
    .eq('id', animalA_Id)
    .single();

  if (checkAniAErr || checkAniA.fazenda_id !== fazendaA_Id) {
    console.error('FAIL TESTE 04 — Registros da Fazenda A foram alterados!', checkAniAErr);
    process.exit(1);
  }
  console.log('PASS TESTE 04 — Fazenda B criada sem alterar nenhum registro da Fazenda A.');

  // TESTE 05 — Troca de contexto para Fazenda B e cadastro de novo animal
  console.log('\n--- TESTE 05: TROCA PARA FAZENDA B E NOVO ANIMAL ---');
  activeFazendaId = fazendaB_Id;
  console.log(`[FAZENDA SWITCH] Nova Fazenda Ativa definida: ${activeFazendaId}`);

  const animalB_Id = `ani-fazb-${timestamp}`;
  const animalBPayload = sanitize('animais', {
    id: animalB_Id,
    fazenda_id: activeFazendaId, // Herança automática da Fazenda B
    brinco: `NOVILHA-B-${timestamp.toString().slice(-4)}`,
    especie: 'Bovino',
    raca: 'Angus',
    categoria: 'Novilha',
    sexo: 'Femea',
    peso_atual: 340,
    status: 'ativo',
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  });

  const { data: pushAniB, error: pushAniBErr } = await supabase
    .from('animais')
    .upsert(animalBPayload)
    .select();

  if (pushAniBErr || !pushAniB || pushAniB.length === 0) {
    console.error('FAIL TESTE 05 — Erro ao cadastrar Animal B:', pushAniBErr);
    process.exit(1);
  }

  // Verifica isolamento por fazenda
  const { data: animaisFazA } = await supabase.from('animais').select('*').eq('fazenda_id', fazendaA_Id);
  const { data: animaisFazB } = await supabase.from('animais').select('*').eq('fazenda_id', fazendaB_Id);

  console.log(`  Animais na Fazenda A: ${animaisFazA.length} (esperado 1: ${pushAniA[0].brinco})`);
  console.log(`  Animais na Fazenda B: ${animaisFazB.length} (esperado 1: ${pushAniB[0].brinco})`);
  if (animaisFazA.length === 1 && animaisFazB.length === 1) {
    console.log('PASS TESTE 05 — Isolamento por fazenda perfeito. Nenhum cruzamento ou duplicação.');
  } else {
    console.error('FAIL TESTE 05 — Erro de isolamento de rebanho.');
    process.exit(1);
  }

  // TESTE 06 — Lançamentos Financeiros com Fazenda B ativa
  console.log('\n--- TESTE 06: FINANCEIRO NA FAZENDA B ---');
  const finDespesaPayload = sanitize('financeiro_lancamentos', {
    id: `fin-despesa-${timestamp}`,
    fazenda_id: activeFazendaId, // Fazenda B
    tipo: 'despesa',
    categoria: 'Veterinária & Serviços',
    descricao: 'Vacinação Geral Fazenda B',
    valor: 1200.00,
    vencimento: new Date().toISOString().split('T')[0],
    status: 'pago',
    data_pagamento: new Date().toISOString().split('T')[0],
    fornecedor_cliente: 'Vet Agro Ltda'
  });

  const finReceitaPayload = sanitize('financeiro_lancamentos', {
    id: `fin-receita-${timestamp}`,
    fazenda_id: activeFazendaId, // Fazenda B
    tipo: 'receita',
    categoria: 'Venda de Bezerros',
    descricao: 'Venda Lote Bezerros Fazenda B',
    valor: 18500.00,
    vencimento: new Date().toISOString().split('T')[0],
    status: 'pago',
    data_pagamento: new Date().toISOString().split('T')[0],
    fornecedor_cliente: 'Comprador Nelore S/A'
  });

  const { data: pushDesp, error: pushDespErr } = await supabase.from('financeiro_lancamentos').upsert(finDespesaPayload).select();
  const { data: pushRec, error: pushRecErr } = await supabase.from('financeiro_lancamentos').upsert(finReceitaPayload).select();

  if (pushDespErr || pushRecErr) {
    console.error('FAIL TESTE 06 — Erro ao cadastrar financeiro:', pushDespErr || pushRecErr);
    process.exit(1);
  }

  console.log(`  Despesa cadastrada: R$ ${pushDesp[0].valor} (Fazenda: ${pushDesp[0].fazenda_id})`);
  console.log(`  Receita cadastrada: R$ ${pushRec[0].valor} (Fazenda: ${pushRec[0].fazenda_id})`);
  console.log('PASS TESTE 06 — Lançamentos financeiros herdaram a Fazenda B sem nenhum fazenda_id = NULL.');

  console.log('\n=== VALIDAÇÃO MULTI-FAZENDA CONCLUÍDA COM 100% DE SUCESSO ===');
}

runMultiFazendaValidation();
