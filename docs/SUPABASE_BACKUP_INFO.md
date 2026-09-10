# SUPABASE BACKUP INFO — AGRO2

**Data:** 2026-09-09 21:10:00 -03:00  
**Projeto:** AGRO2 (Supabase: `yykhelzfnoespjvzjqnb.supabase.co`)  
**Schema:** `public`  
**Quantidade de Tabelas Auditadas:** 13  
**Método:** Exportação de Metadados e Snapshots via Supabase JS Client (Service/Anon Client API)

## Snapshot das Tabelas do Supabase
- `usuarios`: 2 registros
- `fazendas`: 2 registros
- `piquetes`: 0 registros
- `lotes`: 0 registros
- `animais`: 3 registros
- `produtos`: 0 registros
- `aplicacoes_sanitarias`: 0 registros
- `ocorrencias_sanitarias`: 0 registros
- `dietas`: 0 registros
- `fornecimentos_dieta`: 0 registros
- `pesagens`: 0 registros
- `estoque_movimentos`: 0 registros
- `financeiro_lancamentos`: 0 registros

## Amostra de Colunas Verificadas
- `animais`: `[id, lote_id, fazenda_id, brinco, rfid, raca, categoria, sexo, carencia_fim, status, sync_status, created_at, especie, data_nascimento, peso_atual, gmd_recente, foto, updated_at]`
- `fazendas`: `[id, nome, proprietario_nome, sync_status, created_at]`
- `usuarios`: `[id, nome, email, senha, perfil, ativo, created_at]`

Backup efetuado com sucesso antes da reconstrução e testes do banco.
