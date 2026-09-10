# AGRO2 SUPABASE SCHEMA (REAL)

**Database Provider:** Supabase PostgreSQL  
**Project Ref:** `yykhelzfnoespjvzjqnb`  
**Schema:** `public`

## Mapeamento de Tabelas Principais

### `animais`
Colunas:
- `id` (text, Primary Key)
- `fazenda_id` (text, Foreign Key fazendas.id)
- `lote_id` (text, Foreign Key lotes.id, nullable)
- `brinco` (text, NOT NULL)
- `rfid` (text, nullable)
- `especie` (text, NOT NULL, default 'Bovino')
- `raca` (text, NOT NULL)
- `categoria` (text, NOT NULL)
- `sexo` (text, NOT NULL)
- `data_nascimento` (date / text, nullable)
- `peso_atual` (numeric, default 0)
- `gmd_recente` (numeric, default 0)
- `carencia_fim` (text / date YYYY-MM-DD, nullable)
- `ultima_aplicacao_nome` (text, nullable)
- `foto` (text, nullable)
- `status` (text, default 'ativo')
- `sync_status` (text, default 'synced')
- `created_at` (timestamptz)
- `updated_at` (timestamptz)

### `aplicacoes_sanitarias`
Colunas:
- `id` (text, Primary Key)
- `animal_id` (text, Foreign Key animais.id)
- `lote_id` (text, Foreign Key lotes.id, nullable)
- `fazenda_id` (text, Foreign Key fazendas.id)
- `produto_id` (text, Foreign Key produtos.id)
- `produto_nome` (text)
- `data_aplicacao` (text)
- `carencia_fim` (text, nullable)
- `dose` (text)
- `via` (text)
- `motivo` (text)
- `responsavel` (text)
- `foto` (text, nullable)
- `sync_status` (text)
- `created_at` (timestamptz)

### `pesagens`
Colunas:
- `id` (text, Primary Key)
- `animal_id` (text)
- `lote_id` (text, nullable)
- `fazenda_id` (text)
- `data` (text)
- `peso` (numeric)
- `peso_anterior` (numeric)
- `dias_decorridos` (numeric)
- `gmd` (numeric)
- `responsavel` (text)
- `sync_status` (text)
- `created_at` (timestamptz)

### Policies & Realtime
- **Policies:** RLS Habilitado. Políticas públicas ativas para operações de sincronização multi-dispositivo.
- **Realtime:** Publicação `supabase_realtime` habilitada para escutar `postgres_changes` em todas as tabelas em `public`.
