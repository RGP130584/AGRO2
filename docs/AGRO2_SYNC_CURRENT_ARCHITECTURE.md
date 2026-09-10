# AGRO2 SYNC CURRENT ARCHITECTURE

## Arquitetura de Sincronização Unificada (V1)

```text
+-----------------------------------------------------------------+
|                       SUPABASE NUVEM (PostgreSQL)               |
|            Realtime Channel: agro2-realtime-changes             |
+-----------------------------------------------------------------+
               ▲                                   │
               │ pushSyncToSupabase()              │ Realtime / Pull
               │ (Reconciliado)                    ▼
+-----------------------------------------------------------------+
|                         CLIENTE LOCAL                           |
|  +---------------------+        +----------------------------+  |
|  |   IndexedDB / Dexie |        |     SyncContext Engine     |  |
|  |  - animais          |◄───────┤  - Intervalo 8s            |  |
|  |  - aplicacoes...    |        |  - Online Event Handler    |  |
|  |  - sync_queue       |────────►  - Outbox Processor       |  |
|  +---------------------+        +----------------------------+  |
|             ▲                                                   |
|             │ Local Mutations                                   |
|  +---------------------+                                        |
|  |   UI (AnimalForm,   |                                        |
|  |   AplicacaoForm,    |                                        |
|  |   RebanhoList)      |                                        |
|  +---------------------+                                        |
+-----------------------------------------------------------------+
```

## Fluxos Operacionais

### 1. Inserção / Edição Local (CREATE / UPDATE)
1. Interface do usuário executa a alteração.
2. Salva localmente em `db[entidade]`.
3. Adiciona o evento correspondente na fila `db.sync_queue` com `status = 'pending'`.
4. Dispara `syncNow()` de forma assíncrona.
5. `pushSyncToSupabase()` envia os payloads para o Supabase via `upsert()`.
6. Após confirmação HTTP sem erros, atualiza a outbox e a entidade local para `status = 'synced'`.

### 2. Propagação Instantânea (REALTIME)
1. Supabase dispara evento WebSocket `postgres_changes`.
2. O ouvinte em `supabaseSync.js` recebe o payload.
3. Se o evento for de tabela monitorada em `TABLES_TO_SYNC`, salva/atualiza no IndexedDB local.
4. Se for aplicação sanitária ou pesagem, executa atualização em cascata no cadastro do animal.
5. Dispara evento `agro2_sync_updated` para forçar o re-render das telas abertas sem necessitar de reload (F5).

### 3. Reconciliação Retroativa e Tolerância a Falhas
1. `pushSyncToSupabase()` varre o IndexedDB local em busca de dados marcados como não sincronizados ou ausentes no Supabase.
2. `pullSyncFromSupabase()` alinha fazendas legadas e resgata registros antigos do Supabase mantendo o estado 100% consistente.
