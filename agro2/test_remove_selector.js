import fs from 'fs';
import path from 'path';

async function runRemoveSelectorValidation() {
  console.log('=== AGRO2 — CORREÇÃO: REMOVER SELETOR DE FAZENDA DA INTERFACE ===\n');

  // TESTE 01 — Verificar Código Fonte do Header.jsx
  console.log('--- TESTE 01: INTERFACE HEADER CLEAN ---');
  const headerPath = path.resolve('src/components/Header.jsx');
  const headerContent = fs.readFileSync(headerPath, 'utf8');

  const hasSelect = headerContent.includes('<select') || headerContent.includes('handleSelectFazenda');
  const hasFarmImport = headerContent.includes('fazendaHelper');

  if (hasSelect || hasFarmImport) {
    console.error('FAIL TESTE 01 — Seletor de fazenda ainda está presente no Header.jsx!');
    process.exit(1);
  } else {
    console.log('PASS TESTE 01 — Header.jsx limpo: nenhum seletor ou dropdown de fazenda presente na interface.');
  }

  // TESTE 02 — Verificar Validação de Background em fazendaHelper.js
  console.log('\n--- TESTE 02: CONTEXTO AUTOMÁTICO BACKGROUND ---');
  const helperPath = path.resolve('src/utils/fazendaHelper.js');
  const helperContent = fs.readFileSync(helperPath, 'utf8');

  const hasRequire = helperContent.includes('requireActiveFazendaId') && helperContent.includes('getActiveFazendaId');
  if (hasRequire) {
    console.log('PASS TESTE 02 — requireActiveFazendaId() e getActiveFazendaId() mantidos intactos no background.');
  } else {
    console.error('FAIL TESTE 02 — Funções de contexto automático ausentes!');
    process.exit(1);
  }

  // TESTE 03 — Barreira de Proteção do Sync
  console.log('\n--- TESTE 03: BARREIRA DE PROTEÇÃO DO SYNC ---');
  const syncPath = path.resolve('src/lib/supabaseSync.js');
  const syncContent = fs.readFileSync(syncPath, 'utf8');

  const hasSyncBarrier = syncContent.includes('[SYNC FARM VALIDATION]') && syncContent.includes('cleanPayload.fazenda_id');
  if (hasSyncBarrier) {
    console.log('PASS TESTE 03 — Barreira de proteção contra registros órfãos mantida no pushSyncToSupabase().');
  } else {
    console.error('FAIL TESTE 03 — Barreira do Sync ausente!');
    process.exit(1);
  }

  console.log('\n=== VALIDAÇÃO DA REMOÇÃO DO SELETOR CONCLUÍDA COM 100% DE SUCESSO ===');
}

runRemoveSelectorValidation();
