# SYNC_ENTITIES.md — Mapeamento das 13 Entidades do AGRO2

```
[ IndexedDB Local ] → [ Sync Queue Outbox ] → [ Supabase REST API ] → [ WebSockets Realtime ]
```

| # | Entidade | Tabela IndexedDB | Tabela Supabase | Chave Primária | Status RLS | Realtime Ativo |
|---|---|---|---|---|---|---|
| 1 | Usuários | `usuarios` | `usuarios` | `id` | Habilitado + Política Pública | SIM |
| 2 | Fazendas | `fazendas` | `fazendas` | `id` | Habilitado + Política Pública | SIM |
| 3 | Piquetes | `piquetes` | `piquetes` | `id` | Habilitado + Política Pública | SIM |
| 4 | Lotes | `lotes` | `lotes` | `id` | Habilitado + Política Pública | SIM |
| 5 | Animais | `animais` | `animais` | `id` | Habilitado + Política Pública | SIM |
| 6 | Produtos (Farmácia/Ração) | `produtos` | `produtos` | `id` | Habilitado + Política Pública | SIM |
| 7 | Aplicações Sanitárias | `aplicacoes_sanitarias` | `aplicacoes_sanitarias` | `id` | Habilitado + Política Pública | SIM |
| 8 | Ocorrências Sanitárias | `ocorrencias_sanitarias` | `ocorrencias_sanitarias` | `id` | Habilitado + Política Pública | SIM |
| 9 | Dietas | `dietas` | `dietas` | `id` | Habilitado + Política Pública | SIM |
| 10 | Fornecimentos de Dieta | `fornecimentos_dieta` | `fornecimentos_dieta` | `id` | Habilitado + Política Pública | SIM |
| 11 | Pesagens / GMD | `pesagens` | `pesagens` | `id` | Habilitado + Política Pública | SIM |
| 12 | Movimentos de Estoque | `estoque_movimentos` | `estoque_movimentos` | `id` | Habilitado + Política Pública | SIM |
| 13 | Lançamentos Financeiros | `financeiro_lancamentos` | `financeiro_lancamentos` | `id` | Habilitado + Política Pública | SIM |
