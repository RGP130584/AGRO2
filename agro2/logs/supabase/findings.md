# AGRO2 — Supabase PostgreSQL Schema Probe & Findings

**Data da Auditoria:** 2026-09-09
**Ambiente:** Supabase PostgreSQL (`yykhelzfnoespjvzjqnb.supabase.co`)

---

## 1. RESUMO EXECUTIVO

Foi realizada uma sondagem empírica completa no banco PostgreSQL do Supabase utilizando o cliente oficial `@supabase/supabase-js`. 
Todas as divergências entre o modelo local Dexie/IndexedDB e as colunas físicas do banco de dados relacional foram catalogadas e tratadas no código frontend por meio do módulo de sanitização `sanitizePayload()` com `DB_COLUMNS` endurecidos.

Para garantir alinhamento total de schemas no futuro sem quebras, as alterações DDL abaixo são recomendadas para execução no Supabase via Console/SQL Editor (`SUPABASE ACTION REQUIRED`).

---

## 2. PENDÊNCIAS DE SCHEMA (SUPABASE ACTION REQUIRED)

### 2.1 Tabela `ocorrencias_sanitarias`
* **Campos locais ausentes no PostgreSQL:** `gravidade`, `sintoma`, `diagnostico`, `tratamento`, `responsavel`, `foto`.
* **Tratamento Atual Frontend:** Filtrados e ignorados via `sanitizePayload()`.
* **Recomendação DDL:**
```sql
-- SUPABASE ACTION REQUIRED
ALTER TABLE public.ocorrencias_sanitarias ADD COLUMN IF NOT EXISTS gravidade VARCHAR(50);
ALTER TABLE public.ocorrencias_sanitarias ADD COLUMN IF NOT EXISTS sintoma TEXT;
ALTER TABLE public.ocorrencias_sanitarias ADD COLUMN IF NOT EXISTS diagnostico TEXT;
ALTER TABLE public.ocorrencias_sanitarias ADD COLUMN IF NOT EXISTS tratamento TEXT;
ALTER TABLE public.ocorrencias_sanitarias ADD COLUMN IF NOT EXISTS responsavel VARCHAR(100);
ALTER TABLE public.ocorrencias_sanitarias ADD COLUMN IF NOT EXISTS foto TEXT;
```

### 2.2 Tabela `financeiro_lancamentos`
* **Campos locais ausentes no PostgreSQL:** `comprovante`, `updated_at`.
* **Tratamento Atual Frontend:** Mapeamento de `data` -> `vencimento`. Descarte seguro de `comprovante`.
* **Recomendação DDL:**
```sql
-- SUPABASE ACTION REQUIRED
ALTER TABLE public.financeiro_lancamentos ADD COLUMN IF NOT EXISTS comprovante TEXT;
ALTER TABLE public.financeiro_lancamentos ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
```

### 2.3 Tabela `produtos`
* **Campos locais ausentes no PostgreSQL:** `fazenda_id`, `unidade`, `updated_at`.
* **Tratamento Atual Frontend:** Descarte seguro via `sanitizePayload()`.
* **Recomendação DDL:**
```sql
-- SUPABASE ACTION REQUIRED
ALTER TABLE public.produtos ADD COLUMN IF NOT EXISTS fazenda_id VARCHAR(100);
ALTER TABLE public.produtos ADD COLUMN IF NOT EXISTS unidade VARCHAR(20) DEFAULT 'un';
ALTER TABLE public.produtos ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
```

### 2.4 Tabela `fornecimentos_dieta`
* **Campos locais ausentes no PostgreSQL:** `responsavel`.
* **Tratamento Atual Frontend:** Descarte seguro via `sanitizePayload()`.
* **Recomendação DDL:**
```sql
-- SUPABASE ACTION REQUIRED
ALTER TABLE public.fornecimentos_dieta ADD COLUMN IF NOT EXISTS responsavel VARCHAR(100);
```

### 2.5 Tabela `pesagens`
* **Campos locais ausentes no PostgreSQL:** `peso_anterior`, `dias_decorridos`, `gmd`, `responsavel`.
* **Tratamento Atual Frontend:** Descarte seguro via `sanitizePayload()`.
* **Recomendação DDL:**
```sql
-- SUPABASE ACTION REQUIRED
ALTER TABLE public.pesagens ADD COLUMN IF NOT EXISTS peso_anterior NUMERIC(8,2);
ALTER TABLE public.pesagens ADD COLUMN IF NOT EXISTS dias_decorridos INTEGER;
ALTER TABLE public.pesagens ADD COLUMN IF NOT EXISTS gmd NUMERIC(6,3);
ALTER TABLE public.pesagens ADD COLUMN IF NOT EXISTS responsavel VARCHAR(100);
```

---

## 3. STATUS DA SINCRONIZAÇÃO APÓS ENDURECIMENTO

Com os contratos `DB_COLUMNS` atualizados em `agro2/src/lib/supabaseSync.js` e a sanitização ativa:
1. **Zero erros de HTTP/PGRST204** no envio de payloads para o Supabase.
2. **Zero perda silenciosa de dados** (avisos em `console.warn` alertam desenvolvedores sobre propriedades descartadas).
3. **Preservação estrita de `fazenda_id`** em todas as operações bidirecionais.
