# AGRO2 DATA CONTRACT V1

Este contrato oficializa as regras de troca de dados entre a aplicação Web (PWA/React), IndexedDB local e Supabase PostgreSQL.

## 1. Regra de Identificação Primária (IDs)
- Todas as entidades utilizam strings únicas prefixadas no formato:
  - `ani-{timestamp}` para Animais
  - `apl-{timestamp}-{random}` para Aplicações Sanitárias
  - `pes-{timestamp}` para Pesagens
  - `faz-{timestamp}` para Fazendas
  - `lot-{timestamp}` para Lotes
  - `user-{timestamp}` para Usuários

## 2. Regra de Status de Sincronização (`sync_status`)
- `pending`: O registro foi alterado localmente e está aguardando confirmação de upload.
- `synced`: O registro foi confirmado e aceito pelo Supabase sem erros (HTTP 200/201).
- `error`: O upload do registro falhou e está retido para retry.

## 3. Regra do Campo Carência (`carencia_fim`)
- Representado como String no formato ISO Data `YYYY-MM-DD` (ex: `2026-09-30`).
- Atualizado em `aplicacoes_sanitarias` e propagado obrigatoriamente para a tabela `animais` (`animais.carencia_fim`).
- Qualquer atualização em `carencia_fim` exige o disparo simultâneo de evento na outbox (`queueSyncEvent('animais', id, 'update', payload)`) e notificação via Realtime.

## 4. Contrato da Outbox (`sync_queue`)
- `id` (String PK)
- `entidade` (String: tabela afetada)
- `entidade_id` (String: ID da entidade)
- `acao` (String: create, update, delete)
- `payload` (Object: dados completos)
- `status` (String: pending, synced, error)
- `created_at` (String ISO Timestamp)
