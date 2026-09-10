# AGRO2 INDEXEDDB SCHEMA

**Database Name:** `Agro2DB`  
**ORM / Wrapper:** Dexie.js v4  
**Versão:** 1  

## Definição de Stores (Dexie)

```javascript
db.version(1).stores({
  fazendas: 'id, nome, proprietario_nome, sync_status, created_at',
  piquetes: 'id, fazenda_id, nome, sync_status, created_at',
  lotes: 'id, fazenda_id, piquete_id, nome, categoria, sync_status, created_at',
  animais: 'id, lote_id, fazenda_id, brinco, rfid, raca, categoria, sexo, carencia_fim, status, sync_status, created_at',
  produtos: 'id, nome, tipo, carencia_dias, saldo_atual, validade, sync_status, created_at',
  aplicacoes_sanitarias: 'id, animal_id, lote_id, fazenda_id, produto_id, data_aplicacao, carencia_fim, sync_status, created_at',
  ocorrencias_sanitarias: 'id, animal_id, lote_id, fazenda_id, tipo, data, resolvido, sync_status, created_at',
  dietas: 'id, fazenda_id, lote_id, categoria, ativa, sync_status, created_at',
  fornecimentos_dieta: 'id, fazenda_id, lote_id, dieta_id, produto_id, data, sync_status, created_at',
  pesagens: 'id, animal_id, lote_id, fazenda_id, data, sync_status, created_at',
  estoque_movimentos: 'id, fazenda_id, produto_id, tipo, data, sync_status, created_at',
  financeiro_lancamentos: 'id, fazenda_id, tipo, categoria, vencimento, status, sync_status, created_at',
  usuarios: 'id, email, nome, perfil, ativo, created_at',
  sync_queue: 'id, entidade, entidade_id, acao, status, created_at'
});
```
