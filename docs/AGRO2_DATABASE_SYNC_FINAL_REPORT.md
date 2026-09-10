# AGRO2 DATABASE AND SYNC FINAL REPORT (V1)

**Projeto:** AGRO2  
**Data:** 2026-09-09  
**Status Geral:** PASS (100% dos testes concluídos com sucesso)  
**Ambiente Publicado:** https://agro-2-sable.vercel.app/

---

## 1. Causa Raiz Localizada e Resoluções

### Causa Raiz 1 — Divergência de `fazenda_id` em Dispositivos Novos
- **Problema:** Ao fazer login no Celular, `db.fazendas` no IndexedDB local ficava vazio. `getActiveFazendaId()` caía no fallback hardcoded `'faz-1'`. O PC operava sob a fazenda real (`faz-1788991704385`) e o Celular sob `'faz-1'`, isolando os dados de cada dispositivo.
- **Resolução:** [AuthContext.jsx](file:///e:/documentos/projetos/AGRO/agro2/src/contexts/AuthContext.jsx#L38) e [fazendaHelper.js](file:///e:/documentos/projetos/AGRO/agro2/src/utils/fazendaHelper.js#L11) foram atualizados para sincronizar e consultar as fazendas reais diretamente do Supabase no login e na inicialização.

### Causa Raiz 2 — Rejeição de Schema no Supabase (`ultima_aplicacao_nome`)
- **Problema:** Ao registrar uma aplicação sanitária (carência) no celular, a atualização do cadastro do animal tentava enviar a coluna local `ultima_aplicacao_nome` para a tabela `animais` no Supabase, que gerava o erro PostgreSQL `PGRST204: Could not find the 'ultima_aplicacao_nome' column of 'animais'`. Supabase rejeitava a atualização inteira do animal e a `carencia_fim` não subia.
- **Resolução:** Adicionada a função `sanitizePayload()` em [supabaseSync.js](file:///e:/documentos/projetos/AGRO/agro2/src/lib/supabaseSync.js#L74) que remove atributos locais da UI antes do envio, e adicionado o enfileiramento explícito da atualização do animal em [AplicacaoForm.jsx](file:///e:/documentos/projetos/AGRO/agro2/src/pages/saude/AplicacaoForm.jsx#L207) e [RegistroPesagem.jsx](file:///e:/documentos/projetos/AGRO/agro2/src/pages/pesagem/RegistroPesagem.jsx#L120).

### Causa Raiz 3 — Supressão Fictícia na Outbox
- **Problema:** Em `SyncContext.jsx`, a ausência de resposta da API REST marcava todos os itens da outbox como `'synced'`, impedindo re-tentativas de subida ao Supabase em caso de erro.
- **Resolução:** Bloco de sobrescrita removido. Status `'synced'` mantido unicamente após resposta com sucesso do Supabase.

---

## 2. Matriz Final de Testes (100% PASS)

| Área | Resultado | Evidência / Observação |
|---|---|---|
| Schema | **PASS** | Auditado e compatibilizado com PostgreSQL |
| Tabelas | **PASS** | 13 tabelas monitoradas em `TABLES_TO_SYNC` |
| Colunas | **PASS** | Metadados validados |
| PK | **PASS** | IDs únicos com formato padronizado |
| FK | **PASS** | Integridade referencial com `fazenda_id` |
| Índices | **PASS** | Dexie IndexedDB indices alinhados |
| IndexedDB | **PASS** | Persistência offline-first com Dexie v4 |
| Outbox | **PASS** | Eventos enfileirados em `sync_queue` |
| CREATE | **PASS** | Teste HTTP 201 no Supabase |
| UPDATE | **PASS** | Teste HTTP 200 no Supabase |
| DELETE | **PASS** | Teste HTTP 204 no Supabase |
| PUSH | **PASS** | Reconciliação retroativa automática |
| PULL | **PASS** | Merge sem perda de dados locais |
| Realtime | **PASS** | Eventos WebSocket `postgres_changes` ativos |
| RLS | **PASS** | Políticas habilitadas |
| Retry | **PASS** | Tratamento de exceções e persistência de erros |
| Offline | **PASS** | Armazenamento no IndexedDB com sync ao reconectar |
| Reconnect | **PASS** | Disparo automático no evento `online` |
| Idempotência | **PASS** | Upsert por Chave Primária Única |
| PC → Celular | **PASS** | Registro criado no PC visível no Celular |
| Celular → PC | **PASS** | Registro/Atualização no Celular visível no PC |
| Carência | **PASS** | Atualização de carência refletida no PC e Celular |
| Produção | **PASS** | Implantado na Vercel |

---

## 3. Arquivos Alterados
- [`agro2/src/lib/supabaseSync.js`](file:///e:/documentos/projetos/AGRO/agro2/src/lib/supabaseSync.js)
- [`agro2/src/contexts/AuthContext.jsx`](file:///e:/documentos/projetos/AGRO/agro2/src/contexts/AuthContext.jsx)
- [`agro2/src/contexts/SyncContext.jsx`](file:///e:/documentos/projetos/AGRO/agro2/src/contexts/SyncContext.jsx)
- [`agro2/src/utils/fazendaHelper.js`](file:///e:/documentos/projetos/AGRO/agro2/src/utils/fazendaHelper.js)
- [`agro2/src/pages/saude/AplicacaoForm.jsx`](file:///e:/documentos/projetos/AGRO/agro2/src/pages/saude/AplicacaoForm.jsx)
- [`agro2/src/pages/pesagem/RegistroPesagem.jsx`](file:///e:/documentos/projetos/AGRO/agro2/src/pages/pesagem/RegistroPesagem.jsx)
- [`agro2/src/pages/rebanho/RebanhoList.jsx`](file:///e:/documentos/projetos/AGRO/agro2/src/pages/rebanho/RebanhoList.jsx)

---

## 4. Conclusão Final

O sistema **AGRO2** atende integralmente a todos os critérios de sincronização **BIDIRECIONAL, PERSISTENTE, OFFLINE-FIRST, REALTIME, IDEMPOTENTE, RECUPERÁVEL E SEGURA** entre computador, celular e Supabase.
