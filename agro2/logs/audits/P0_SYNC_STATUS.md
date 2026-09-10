# AGRO2 — AUDITORIA P0.5: RESET LOCAL APÓS LIMPEZA DO SUPABASE

**Status Geral:** PASS  
**Data da Execução:** 2026-09-09  
**Responsável:** Antigravity AI Pair Programmer  

---

## 1. RESUMO DA OPERAÇÃO DE RESET E VERIFICAÇÃO

| Entidade / Tabela | Contagem Supabase Remoto | Ação no IndexedDB Local | Ação na Outbox (`sync_queue`) | Status Final |
| :--- | :--- | :--- | :--- | :--- |
| **`usuarios`** | **2 registros** | **PRESERVADA (Não Limpa)** | N/A | **PRESERVADO** |
| **`fazendas`** | 0 registros | Limpa / Resetada | Resetada | **PASS** |
| **`piquetes`** | 0 registros | Limpa / Resetada | Resetada | **PASS** |
| **`lotes`** | 0 registros | Limpa / Resetada | Resetada | **PASS** |
| **`animais`** | 0 registros | Limpa / Resetada | Resetada | **PASS** |
| **`produtos`** | 0 registros | Limpa / Resetada | Resetada | **PASS** |
| **`aplicacoes_sanitarias`** | 0 registros | Limpa / Resetada | Resetada | **PASS** |
| **`ocorrencias_sanitarias`** | 0 registros | Limpa / Resetada | Resetada | **PASS** |
| **`dietas`** | 0 registros | Limpa / Resetada | Resetada | **PASS** |
| **`fornecimentos_dieta`** | 0 registros | Limpa / Resetada | Resetada | **PASS** |
| **`pesagens`** | 0 registros | Limpa / Resetada | Resetada | **PASS** |
| **`estoque_movimentos`** | 0 registros | Limpa / Resetada | Resetada | **PASS** |
| **`financeiro_lancamentos`** | 0 registros | Limpa / Resetada | Resetada | **PASS** |
| **`sync_queue`** | N/A | `count = 0` (Totalmente ZERADA) | Resetada | **PASS** |

---

## 2. GARANTIAS TÉCNICAS DA IMPLEMENTAÇÃO P0.5

1. **`resetLocalOperationalDataIfServerIsEmpty()`**:
   - Executa uma verificação atômica de contagem (`count: 'exact', head: true`) nas 12 tabelas operacionais do Supabase.
   - SOMENTE se **TODAS as 12 tabelas operacionais estiverem zeradas**, executa o `clear()` local das 12 tabelas no IndexedDB e da `sync_queue`.
   - A tabela `usuarios` é preservada integralmente no banco local e na nuvem.

2. **Ordem Obrigatória de Sincronização**:
   - `resetLocalOperationalDataIfServerIsEmpty()` roda **ANTES** de `pullSyncFromSupabase()` e **ANTES** de `pushSyncToSupabase()`, impedindo que a outbox local envie registros antigos de volta para o Supabase.

3. **Propagação de Exclusões Remotas em `pullSyncFromSupabase()`**:
   - Quando o Supabase retorna um conjunto de dados para uma tabela (ex: array vazio `[]`), o pull local verifica os itens com `sync_status === 'synced'` e remove do IndexedDB aqueles que não existem mais no servidor.
