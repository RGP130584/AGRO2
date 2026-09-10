# AGRO2 DATA MODEL CODE

Este documento define o modelo de dados mapeado diretamente do código-fonte do AGRO2.

## Entidades Principais e Mapeamento

### 1. `animais`
- **Nome:** Animais do Rebanho Multiespécie
- **IndexedDB Store:** `animais`
- **Supabase Table:** `animais`
- **Campos Principais:**
  - `id` (String / PK)
  - `fazenda_id` (String / FK fazendas)
  - `lote_id` (String / FK lotes, nullable)
  - `brinco` (String)
  - `rfid` (String, nullable)
  - `especie` (String: Bovino, Ovino, Equino, Búfalo, Caprino, Outro)
  - `raca` (String)
  - `categoria` (String)
  - `sexo` (String: Macho, Fêmea)
  - `data_nascimento` (String, nullable)
  - `peso_atual` (Number)
  - `gmd_recente` (Number)
  - `carencia_fim` (String YYYY-MM-DD, nullable)
  - `ultima_aplicacao_nome` (String, nullable)
  - `foto` (String / Base64, nullable)
  - `status` (String: ativo, inativo, vendido, obito)
  - `sync_status` (String: pending, synced, error)
  - `created_at` (String ISO)
  - `updated_at` (String ISO)

### 2. `aplicacoes_sanitarias`
- **Nome:** Aplicações Sanitárias (Medicamentos / Vacinas)
- **IndexedDB Store:** `aplicacoes_sanitarias`
- **Supabase Table:** `aplicacoes_sanitarias`
- **Campos Principais:**
  - `id` (String / PK)
  - `animal_id` (String / FK animais)
  - `lote_id` (String / FK lotes, nullable)
  - `fazenda_id` (String / FK fazendas)
  - `produto_id` (String / FK produtos)
  - `produto_nome` (String)
  - `data_aplicacao` (String YYYY-MM-DD)
  - `carencia_fim` (String YYYY-MM-DD, nullable)
  - `dose` (String)
  - `via` (String)
  - `motivo` (String)
  - `responsavel` (String)
  - `foto` (String, nullable)
  - `sync_status` (String: pending, synced, error)
  - `created_at` (String ISO)

### 3. `pesagens`
- **Nome:** Registros de Pesagem
- **IndexedDB Store:** `pesagens`
- **Supabase Table:** `pesagens`
- **Campos Principais:**
  - `id` (String / PK)
  - `animal_id` (String / FK animais)
  - `lote_id` (String / FK lotes, nullable)
  - `fazenda_id` (String / FK fazendas)
  - `data` (String YYYY-MM-DD)
  - `peso` (Number)
  - `peso_anterior` (Number)
  - `dias_decorridos` (Number)
  - `gmd` (Number)
  - `responsavel` (String)
  - `sync_status` (String: pending, synced, error)
  - `created_at` (String ISO)

### 4. `fazendas`
- **Nome:** Fazendas / Propriedades
- **IndexedDB Store:** `fazendas`
- **Supabase Table:** `fazendas`
- **Campos:** `id`, `nome`, `proprietario_nome`, `sync_status`, `created_at`

### 5. `lotes`
- **Nome:** Lotes de Animais
- **IndexedDB Store:** `lotes`
- **Supabase Table:** `lotes`
- **Campos:** `id`, `fazenda_id`, `piquete_id`, `nome`, `categoria`, `especie`, `sync_status`, `created_at`

### 6. `usuarios`
- **Nome:** Usuários do Sistema
- **IndexedDB Store:** `usuarios`
- **Supabase Table:** `usuarios`
- **Campos:** `id`, `email`, `nome`, `senha`, `perfil`, `ativo`, `created_at`
