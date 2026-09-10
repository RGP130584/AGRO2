# AGRO2 P0 Sync Status

## Código
- [x] DB_COLUMNS alinhado
- [x] Financeiro alinhado (inclui data_pagamento e fornecedor_cliente)
- [x] Aplicações alinhadas (sanitizadas contra schema relacional)
- [x] Estoque alinhado (preserva referencia_id e responsavel)
- [x] Pesagens analisadas (gmd/dias_decorridos preservados localmente)
- [x] Fornecimentos analisados
- [x] Ocorrências analisadas
- [x] fazenda_id preservado (refeita a regra: proibididissímo sobrescrever fazenda_id original)
- [x] pull seguro (preserva pendências locais sem sobrescrever com rascunhos remotos)
- [x] outbox seguro (valida confirmação HTTP antes de alterar para synced)
- [x] realtime tratado (ouvinte escuta e atualiza IndexedDB reativamente)
- [x] offline preservado
- [x] retry preservado

## Testes
- [x] Build (`PASS` — `logs/tests/build.log`)
- [x] Push (`PASS` — `logs/sync/push.log`)
- [x] Pull (`PASS` — `logs/sync/pull.log`)
- [x] Realtime (`PASS` — `logs/sync/realtime.log`)
- [x] Offline (`PASS` — `logs/tests/offline.log`)
- [x] Retry (`PASS` — `logs/tests/retry.log`)
- [x] Financeiro (`PASS` — `logs/tests/finance.log`)
- [x] Animal (`PASS` — `logs/tests/animal.log`)
- [x] Sanitário (`PASS` — `logs/tests/sanitary.log`)
- [x] Estoque (`PASS` — `logs/tests/stock.log`)
- [x] PC → Mobile (`PASS` — `logs/tests/pc-to-mobile.log`)
- [x] Mobile → PC (`PASS` — `logs/tests/mobile-to-pc.log`)

## Supabase
- [x] Nenhuma alteração DDL/migration executada pelo Antigravity diretamente no banco
- [x] Pendências documentadas em `logs/supabase/findings.md`
