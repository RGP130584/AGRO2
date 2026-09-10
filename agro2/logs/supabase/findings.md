# Supabase Findings

## Required Actions (Supabase Schema Findings)

### Tabela
`financeiro_lancamentos`

### Campo
`comprovante`, `updated_at`

### Problema
Atributos de auditoria de atualização e upload de comprovante fiscal/recibo são gerados no frontend mas não possuem coluna na tabela relacional `financeiro_lancamentos`.

### Motivo
Permitir a persistência remota de recibos e rastreabilidade de atualizações temporais.

### SQL sugerido
```sql
ALTER TABLE public.financeiro_lancamentos ADD COLUMN IF NOT EXISTS comprovante text;
ALTER TABLE public.financeiro_lancamentos ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();
```

### Impacto
Atualmente a sanitização `sanitizePayload()` remove estes campos antes do push para evitar erro `PGRST204`. A adição das colunas permitirá sincronizar comprovantes completos.

---

### Tabela
`aplicacoes_sanitarias`

### Campo
`produto_nome`, `dose`, `via`, `motivo`, `responsavel`, `foto`

### Problema
Metadados descritivos da aplicação sanitária não possuem colunas na tabela relacional PostgreSQL.

### Motivo
Registrar os detalhes da vacinação/medicação diretamente na tabela de histórico clínico do Supabase.

### SQL sugerido
```sql
ALTER TABLE public.aplicacoes_sanitarias ADD COLUMN IF NOT EXISTS produto_nome text;
ALTER TABLE public.aplicacoes_sanitarias ADD COLUMN IF NOT EXISTS dose text;
ALTER TABLE public.aplicacoes_sanitarias ADD COLUMN IF NOT EXISTS via text;
ALTER TABLE public.aplicacoes_sanitarias ADD COLUMN IF NOT EXISTS motivo text;
ALTER TABLE public.aplicacoes_sanitarias ADD COLUMN IF NOT EXISTS responsavel text;
ALTER TABLE public.aplicacoes_sanitarias ADD COLUMN IF NOT EXISTS foto text;
```

### Impacto
O frontend salva a aplicação e a `carencia_fim` (que possui coluna real no banco). A inclusão destas colunas preservará a fotografia e os detalhes da dose no banco remoto.

---

### Tabela
`pesagens`

### Campo
`peso_anterior`, `dias_decorridos`, `gmd`, `responsavel`

### Problema
Campos de cálculo de ganho de peso diário e operador da pesagem ausentes no PostgreSQL.

### Motivo
Atualmente `dias_decorridos` e `gmd` são métricas calculadas em tempo de execução pela UI. Caso seja desejado consultar relatórios de GMD via SQL direto no Supabase, a criação das colunas permitirá a persistência.

### SQL sugerido
```sql
ALTER TABLE public.pesagens ADD COLUMN IF NOT EXISTS peso_anterior numeric;
ALTER TABLE public.pesagens ADD COLUMN IF NOT EXISTS dias_decorridos numeric;
ALTER TABLE public.pesagens ADD COLUMN IF NOT EXISTS gmd numeric;
ALTER TABLE public.pesagens ADD COLUMN IF NOT EXISTS responsavel text;
```

### Impacto
O peso atual do animal é atualizado em `animais.peso_atual` e `animais.gmd_recente` (que possuem colunas relativas no banco). A inclusão manterá o histórico granular na tabela de pesagens.

---

### Tabela
`produtos`

### Campo
`fazenda_id`, `unidade`, `updated_at`

### Problema
Identificador de fazenda e unidade de medida ausentes no PostgreSQL.

### SQL sugerido
```sql
ALTER TABLE public.produtos ADD COLUMN IF NOT EXISTS fazenda_id text;
ALTER TABLE public.produtos ADD COLUMN IF NOT EXISTS unidade text;
ALTER TABLE public.produtos ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();
```
