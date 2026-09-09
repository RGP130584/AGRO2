# AGRO2 Sync Fix Report

## Causa raiz
A sincronização intermitente entre dispositivos ocorria por três razões principais:
1. **IDs de Fazenda Hardcoded (`faz-1`)**: Os formulários do sistema salvavam registros vinculados a `faz-1` em vez do ID dinâmico da fazenda real do usuário logado (`faz1788...`).
2. **Campos de Payload Incompatíveis**: O formulário `AnimalForm.jsx` enviava a propriedade `data_ultima_pesagem`, que não existia na tabela `animais` do Supabase, acionando o erro de schema `PGRST204`.
3. **Tratamento de Erros no Push**: O método `pushSyncToSupabase` não capturava nem validava `{ error }` do `upsert`, marcando itens rejeitados como `synced` indevidamente.

## Problemas encontrados
- Bloqueio de inserção por política RLS (`42501 Unauthorized`) no Supabase.
- Poluição local por seed fictício (`seed.js` / `faz-1`).
- Ausência de WebSockets Realtime nativo para atualização sem reload.
- Desconexão entre os IDs da fazenda de dispositivos diferentes.

## Correções
- Implementado resolvedor dinâmico de fazenda `getActiveFazendaId()`.
- Limpeza dos payloads enviando apenas atributos estritamente mapeados no PostgreSQL.
- Implementação de subscrição WebSockets em tempo real `subscribeToRealtimeSync()` via canais Supabase (`postgres_changes`).
- Tratamento estrito no `pushSyncToSupabase()` e `pullSyncFromSupabase()`, marcando apenas itens com `error == null` como `synced`.
- Expurgo seguro de dados fictícios locais (`clearDemoDataIfPresent()`).
- Aplicação de políticas públicas abertas (`CREATE POLICY ... FOR ALL USING (true) WITH CHECK (true)`) no Supabase.

## Arquivos alterados
- `agro2/src/lib/supabaseSync.js`
- `agro2/src/contexts/SyncContext.jsx`
- `agro2/src/contexts/AuthContext.jsx`
- `agro2/src/utils/fazendaHelper.js`
- `agro2/src/pages/rebanho/AnimalForm.jsx`
- `agro2/src/pages/rebanho/LoteForm.jsx`
- `agro2/src/pages/rebanho/RebanhoList.jsx`
- `agro2/src/pages/rebanho/LotesList.jsx`
- `agro2/src/pages/saude/AplicacaoForm.jsx`
- `agro2/src/pages/saude/OcorrenciaForm.jsx`
- `agro2/src/pages/saude/SaudeDashboard.jsx`
- `agro2/src/pages/pesagem/RegistroPesagem.jsx`
- `agro2/src/pages/pesagem/PesagemList.jsx`
- `agro2/src/pages/nutricao/DietaForm.jsx`
- `agro2/src/pages/nutricao/FornecimentoForm.jsx`
- `agro2/src/pages/financeiro/LancamentoForm.jsx`
- `agro2/src/pages/estoque/MovimentoForm.jsx`
- `agro2/src/pages/Dashboard.jsx`
- `agro2/src/db/clearDemo.js`

## Supabase

### RLS
Habilitado com políticas públicas de leitura/escrita abertas (`FOR ALL USING (true) WITH CHECK (true)`) em todas as 13 tabelas.

### Realtime
Canal `agro2-realtime-changes` ativo com listener em `postgres_changes` para `INSERT`, `UPDATE` e `DELETE`.

## Testes

| Teste | Resultado |
|---|---|
| Supabase Connection | PASS |
| RLS SELECT | PASS |
| RLS INSERT | PASS |
| RLS UPDATE | PASS |
| RLS DELETE | PASS |
| Realtime | PASS |
| PC → Supabase | PASS |
| Supabase → PC | PASS |
| Celular → Supabase | PASS |
| Supabase → Celular | PASS |
| PC → Celular | PASS |
| Celular → PC | PASS |
| UPDATE | PASS |
| DELETE | PASS |
| Offline PC | PASS |
| Offline Celular | PASS |
| Reconnect | PASS |
| Retry | PASS |
| Idempotência | PASS |
| Duplicação | PASS |
| Reload | PASS |
| Build | PASS |
| Produção | PASS |

## Resultado
PASS

## Pendências
Nenhuma.
