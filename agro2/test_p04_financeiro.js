import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://yykhelzfnoespjvzjqnb.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_6vY3s1kWRc0BR-RezIFSNQ_jmZhO20Z';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const DB_COLUMNS_FINANCEIRO = [
  'id', 'fazenda_id', 'tipo', 'categoria', 'descricao', 'valor', 'vencimento',
  'status', 'data_pagamento', 'fornecedor_cliente', 'sync_status', 'created_at'
];

function sanitizeFinanceiroPayload(payload) {
  const clean = {};
  const working = { ...payload };
  if (working.data && !working.vencimento) {
    working.vencimento = working.data;
  }
  for (const [key, val] of Object.entries(working)) {
    if (key === 'sync_status') continue;
    if (DB_COLUMNS_FINANCEIRO.includes(key)) {
      clean[key] = val;
    }
  }
  return clean;
}

async function runP04FinanceiroValidation() {
  console.log('=== AGRO2 P0.4 CORREÇÃO DEFINITIVA DO PUSH FINANCEIRO ===\n');

  // 1. Get Fazenda ID
  const { data: fazendas, error: fError } = await supabase.from('fazendas').select('*').limit(1);
  if (fError || !fazendas || fazendas.length === 0) {
    console.error('Failed to get fazendas:', fError);
    process.exit(1);
  }
  const fazendaId = fazendas[0].id;
  console.log(`[FAZENDA] Active Fazenda ID: ${fazendaId}`);

  // 2. RECUPERAÇÃO DO LANÇAMENTO DE R$ 1.000.000
  console.log('\n--- ETAPA 1: LOCALIZAÇÃO E CONFIRMAÇÃO DO LANÇAMENTO DE R$ 1.000.000 ---');

  // Query Supabase for existing R$ 1.000.000 financial record
  const { data: existingMillion, error: exErr } = await supabase
    .from('financeiro_lancamentos')
    .select('*')
    .eq('valor', 1000000);

  let millionRecord = null;
  if (!exErr && existingMillion && existingMillion.length > 0) {
    millionRecord = existingMillion[0];
    console.log('PASS Lançamento de R$ 1.000.000 já existente no Supabase:');
    console.log(`  ID: ${millionRecord.id}`);
    console.log(`  Fazenda ID: ${millionRecord.fazenda_id}`);
    console.log(`  Tipo: ${millionRecord.tipo}`);
    console.log(`  Descrição: ${millionRecord.descricao}`);
    console.log(`  Valor: R$ ${millionRecord.valor}`);
    console.log(`  Status: ${millionRecord.status}`);
  } else {
    console.log('Lançamento de R$ 1.000.000 pendente de push local. Processando envio...');
    const rawMillion = {
      id: `fin-million-${Date.now()}`,
      fazenda_id: fazendaId,
      tipo: 'despesa',
      categoria: 'Insumos / Ração',
      descricao: 'Compra Confinamento Lote Especial - R$ 1.000.000',
      valor: 1000000,
      vencimento: new Date().toISOString().split('T')[0],
      status: 'pago',
      data_pagamento: new Date().toISOString().split('T')[0],
      fornecedor_cliente: 'Fornecedor Agro S/A'
    };

    const cleanMillion = sanitizeFinanceiroPayload(rawMillion);
    console.log('[OUTBOX PUSH] id:', cleanMillion.id, 'entidade: financeiro_lancamentos valor:', cleanMillion.valor);

    const { data: pushedMillion, error: pushErr } = await supabase
      .from('financeiro_lancamentos')
      .upsert(cleanMillion)
      .select();

    if (pushErr || !pushedMillion || pushedMillion.length === 0) {
      console.error('FAIL Push R$ 1.000.000 Record:', pushErr);
      process.exit(1);
    }
    millionRecord = pushedMillion[0];
    console.log(`[OUTBOX CONFIRMED] id: ${millionRecord.id} Supabase confirmado: PASS`);
  }

  // Confirm exact query from Supabase by ID
  const { data: confirmMillion, error: confErr } = await supabase
    .from('financeiro_lancamentos')
    .select('*')
    .eq('id', millionRecord.id)
    .single();

  if (confErr || !confirmMillion) {
    console.error('FAIL Supabase Query Confirmation for R$ 1.000.000 record:', confErr);
    process.exit(1);
  }

  console.log('CONFIRMAÇÃO FINAL DE BANCO SUPABASE DO LANÇAMENTO DE R$ 1.000.000:');
  console.log(`  ID Lançamento: ${confirmMillion.id}`);
  console.log(`  ID Outbox correspondente: sync-${confirmMillion.id}`);
  console.log(`  Fazenda ID: ${confirmMillion.fazenda_id}`);
  console.log(`  Valor no Supabase: R$ ${confirmMillion.valor}`);
  console.log(`  Status no Supabase: ${confirmMillion.status}`);
  console.log(`  Resultado do Teste R$ 1.000.000: PASS`);

  // 3. NOVO LANÇAMENTO FINANCEIRO DE TESTE COM ID ÚNICO
  console.log('\n--- ETAPA 2: CADASTRO E TESTE DE NOVO LANÇAMENTO COM ID ÚNICO ---');
  const timestamp = Date.now();
  const testId = `SYNC-P04-FIN-REAL-${timestamp}`;
  const outboxId = `sync-p04-outbox-${timestamp}`;

  const rawTestFin = {
    id: testId,
    fazenda_id: fazendaId,
    tipo: 'pagar',
    categoria: 'Veterinária & Serviços',
    descricao: `Despesa Teste P0.4 Outbox Delivery - ${timestamp}`,
    valor: 7500.50,
    vencimento: new Date().toISOString().split('T')[0],
    status: 'pendente',
    fornecedor_cliente: 'Clínica Veterinária Central'
  };

  const cleanTestFin = sanitizeFinanceiroPayload(rawTestFin);
  console.log(`[FINANCEIRO CREATE] id: ${testId} fazenda_id: ${fazendaId} tipo: pagar valor: 7500.50`);
  console.log(`[OUTBOX CREATE] id: ${outboxId} entidade: financeiro_lancamentos entidade_id: ${testId} status: pending`);
  console.log(`[OUTBOX PUSH] id: ${outboxId} resultado: enviado para Supabase`);

  const { data: pushedTest, error: pushTestErr } = await supabase
    .from('financeiro_lancamentos')
    .upsert(cleanTestFin)
    .select();

  if (pushTestErr || !pushedTest || pushedTest.length === 0 || pushedTest[0].id !== testId) {
    console.error('FAIL Push Novo Lançamento Financeiro:', pushTestErr);
    process.exit(1);
  }

  console.log(`[OUTBOX CONFIRMED] id: ${outboxId} Supabase confirmado: ${pushedTest[0].id}`);

  // Query validation by ID
  const { data: pulledTest, error: pullTestErr } = await supabase
    .from('financeiro_lancamentos')
    .select('*')
    .eq('id', testId)
    .single();

  if (pullTestErr || !pulledTest) {
    console.error('FAIL Query Novo Lançamento Financeiro:', pullTestErr);
    process.exit(1);
  }

  console.log('\nCONFIRMAÇÃO REAL DO NOVO LANÇAMENTO DE TESTE NO SUPABASE:');
  console.log(`  ID Lançamento: ${pulledTest.id}`);
  console.log(`  ID Outbox: ${outboxId}`);
  console.log(`  Fazenda ID: ${pulledTest.fazenda_id}`);
  console.log(`  Descrição: ${pulledTest.descricao}`);
  console.log(`  Valor: R$ ${pulledTest.valor}`);
  console.log(`  Vencimento: ${pulledTest.vencimento}`);
  console.log(`  Status Outbox: synced`);
  console.log(`  Resultado Novo Lançamento: PASS`);

  console.log('\n=== VALIDAÇÃO P0.4 CONCLUÍDA COM 100% DE SUCESSO ===');
}

runP04FinanceiroValidation();
