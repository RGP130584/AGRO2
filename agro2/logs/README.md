# AGRO2 — REGISTRO E EVIDÊNCIAS DE SINCRONIZAÇÃO P0.2

Este diretório armazena os logs de execução, auditorias e evidências empíricas dos testes de sincronização bidirecional entre PWA/React, IndexedDB local e Supabase PostgreSQL.

## Estrutura dos Logs
- `sync/`: Registros de push, pull, realtime, outbox e erros de execução.
- `tests/`: Evidências individuais dos cenários de teste funcionais e de estresse.
- `supabase/`: Apontamentos de schema e ações necessárias no banco relacional (`findings.md`).
- `audits/`: Status consolidado de prontidão (`P0_SYNC_STATUS.md`).

## Formato Padrão
Todos os testes e logs observam o formato com ISO-8601, ambiente, pré-condições, ações, payload, respostas HTTP/PostgREST e evidências reais sem declaração artificial de PASS.
