# SYNC_AUDIT.md — AGRO2 Architecture Audit

## 1. Arquivos Envolvidos
- `agro2/src/lib/supabase.js`: Inicialização do cliente Supabase (URL e Publishable Anon Key).
- `agro2/src/lib/supabaseSync.js`: Funções `pushSyncToSupabase()`, `pullSyncFromSupabase()`, `subscribeToRealtimeSync()`.
- `agro2/src/contexts/SyncContext.jsx`: Gerenciamento da fila (outbox) local, eventos `queueSyncEvent()`, timers de disparo e escuta de estado de rede (online/offline).
- `agro2/src/contexts/AuthContext.jsx`: Autenticação e sincronização de usuários e fazendas com Supabase.
- `agro2/src/db/database.js`: Definição do schema do IndexedDB local via Dexie.js.
- `agro2/src/db/clearDemo.js`: Purga de dados fictícios locais/nuvem.
- `agro2/src/utils/fazendaHelper.js`: Resolvedor dinâmico da fazenda ativa.

## 2. Tabelas Sincronizadas (13 Entidades)
1. `usuarios`
2. `fazendas`
3. `piquetes`
4. `lotes`
5. `animais`
6. `produtos`
7. `aplicacoes_sanitarias`
8. `ocorrencias_sanitarias`
9. `dietas`
10. `fornecimentos_dieta`
11. `pesagens`
12. `estoque_movimentos`
13. `financeiro_lancamentos`

## 3. Fluxo de Push (Local → Outbox → Supabase)
1. O formulário salva o objeto no Dexie IndexedDB local com `sync_status: 'pending'`.
2. O formulário chama `queueSyncEvent(entidade, id, acao, payload)`.
3. `queueSyncEvent` insere o item na tabela `db.sync_queue` local e dispara `syncNow()`.
4. `pushSyncToSupabase()` busca pendências em `db.sync_queue`.
5. Chama `supabase.from(entidade).upsert(cleanPayload)` ou `delete()`.
6. Se retornar `{ error }`: atualiza item na `sync_queue` para `status: 'error'` com `error_msg` e NUNCA marca como `synced`.
7. Se retornar sucesso (`error == null`): atualiza item na `sync_queue` para `status: 'synced'`.

## 4. Fluxo de Pull (Supabase → IndexedDB → UI)
1. `pullSyncFromSupabase()` executa `supabase.from(tableName).select('*')`.
2. Se retornar erro: registra log e interrompe a tabela com segurança.
3. Se retornar dados: faz `db[tableName].put({...item, sync_status: 'synced'})`.
4. Se houver alterações: dispara o evento customizado `window.dispatchEvent(new CustomEvent('agro2_sync_updated'))`.

## 5. Fluxo de Realtime WebSockets
1. `subscribeToRealtimeSync()` assina o canal `supabase.channel('agro2-realtime-changes')`.
2. Ouve eventos `postgres_changes` na tabela `public.*`.
3. Em caso de `INSERT` ou `UPDATE`: atualiza IndexedDB local e dispara `agro2_sync_updated`.
4. Em caso de `DELETE`: remove registro no IndexedDB local e dispara `agro2_sync_updated`.

## 6. Fallback Offline
- Quando desconectado (`navigator.onLine === false`), as ações são registradas localmente e mantidas como `pending` na outbox.
- Ao reconectar (`online`), `syncNow()` é acionado automaticamente, esvaziando a outbox pendente para o Supabase.
