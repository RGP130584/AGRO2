# AGRO2 — P0.3
# CORREÇÃO DIRETA DOS ERROS ENCONTRADOS NA AUDITORIA P0

**Projeto:** AGRO2  
**Repositório:** `RGP130584/AGRO2`  
**Diretório:** `/agro2`

---

## 1. OBJETIVO

A auditoria do commit `e7f09ba` encontrou inconsistências entre:

1. código;
2. logs;
3. schema real do Supabase;
4. evidências declaradas como PASS.

**Não fazer nova análise. Não criar nova arquitetura. Não alterar a arquitetura atual.**

Corrigir diretamente os problemas abaixo e depois executar novamente os testes.

---

# 2. ERRO CRÍTICO — LOGS DECLARAM PASS SEM EVIDÊNCIA CONFIRMADA

Os arquivos:

```text
logs/tests/pc-to-mobile.log
logs/tests/mobile-to-pc.log
logs/tests/finance.log
```

declaram operações como concluídas.

Entretanto, os registros utilizados como evidência não foram encontrados no Supabase durante a auditoria.

### CORREÇÃO

Executar novamente os testes usando **novos IDs únicos**, gerados no momento do teste.

Para cada teste registrar:

```text
ID gerado
payload enviado
HTTP/PostgREST response
ID retornado pelo Supabase
consulta de confirmação
resultado da consulta
timestamp
```

O teste só pode ser:

```text
PASS
```

se houver confirmação real no Supabase.

Caso contrário:

```text
FAIL
```

É PROIBIDO criar PASS manualmente.

---

# 3. ERRO — DB_COLUMNS NÃO ESTÁ ALINHADO COM O SUPABASE

O `DB_COLUMNS` deve ser corrigido contra o schema REAL atualmente existente.

Não assumir o schema.

Não inventar colunas.

Não adicionar DDL.

## 3.1 ocorrencias_sanitarias

O Supabase possui:

```text
id
animal_id
lote_id
fazenda_id
tipo
descricao
data
resolvido
sync_status
created_at
```

O código atualmente permite campos que não existem:

```text
gravidade
sintoma
diagnostico
tratamento
responsavel
foto
```

### CORREÇÃO

O `DB_COLUMNS.ocorrencias_sanitarias` deve refletir exatamente as colunas existentes.

Incluir:

```text
descricao
```

Não incluir campos inexistentes.

NÃO criar colunas no Supabase.

Se o frontend depender de algum campo inexistente para persistência, registrar em:

```text
logs/supabase/findings.md
```

como:

```text
SUPABASE ACTION REQUIRED
```

---

# 4. ERRO — aplicacoes_sanitarias

O Supabase possui:

```text
produto_nome
dose
via
motivo
responsavel
foto
dosagem
observacoes
```

O `DB_COLUMNS` atual não contempla todos esses campos.

### CORREÇÃO

Atualizar:

```text
DB_COLUMNS.aplicacoes_sanitarias
```

para incluir **todas as colunas que realmente existem no Supabase e que são dados persistentes do módulo**:

```text
produto_nome
dose
via
motivo
responsavel
foto
dosagem
observacoes
```

Manter também as demais colunas existentes:

```text
id
animal_id
lote_id
fazenda_id
produto_id
data_aplicacao
carencia_fim
sync_status
created_at
```

Não criar novas colunas.

---

# 5. ERRO — fornecimentos_dieta

O código atualmente permite:

```text
responsavel
```

mas essa coluna NÃO existe no Supabase.

### CORREÇÃO

Remover:

```text
responsavel
```

de:

```text
DB_COLUMNS.fornecimentos_dieta
```

Não criar coluna no banco.

Se o frontend precisar persistir esse dado, registrar:

```text
SUPABASE ACTION REQUIRED
```

---

# 6. ERRO — produtos

O schema real atualmente possui:

```text
id
nome
tipo
carencia_dias
saldo_atual
validade
sync_status
created_at
```

Não adicionar:

```text
fazenda_id
unidade
updated_at
```

ao contrato de sincronização.

Esses campos somente poderão ser adicionados após decisão explícita sobre alteração do schema.

---

# 7. FINANCEIRO

O contrato já foi corrigido para:

```text
data_pagamento
fornecedor_cliente
```

Manter.

Verificar também:

```text
comprovante
updated_at
```

Se não existem no Supabase:

- não enviar;
- não criar DDL;
- registrar como `SUPABASE ACTION REQUIRED` somente se o frontend realmente utilizar esses campos como dados persistentes.

---

# 8. PESAGENS

O Supabase atualmente possui:

```text
id
animal_id
lote_id
fazenda_id
data
peso
sync_status
created_at
```

Não adicionar automaticamente:

```text
peso_anterior
dias_decorridos
gmd
responsavel
```

ao banco.

No código:

- preservar cálculos locais quando forem derivados;
- não perder dados que sejam efetivamente persistentes;
- registrar eventual necessidade de schema em `findings.md`.

---

# 9. fazenda_id

A correção feita anteriormente está correta.

Manter a regra:

```text
fazenda_id original NÃO pode ser sobrescrito pelo activeFazendaId.
```

É permitido utilizar a fazenda ativa para:

```text
filtrar
validar
selecionar
impedir operação inválida
```

É proibido utilizar a fazenda ativa para alterar silenciosamente:

```text
registro.fazenda_id
```

---

# 10. NÃO EXISTIR SILENT DATA LOSS

A função:

```text
sanitizePayload()
```

não pode simplesmente eliminar um campo importante sem deixar rastreabilidade.

Criar uma verificação durante desenvolvimento/testes:

```text
campo recebido pelo frontend
        ↓
não existe em DB_COLUMNS
        ↓
campo descartado
        ↓
registrar warning/evidência
```

Não enviar campos desconhecidos ao Supabase.

Mas também não permitir que um campo importante seja perdido silenciosamente.

---

# 11. LOGS — CORRIGIR EVIDÊNCIAS

Manter:

```text
/agro2/logs/
```

e todos os arquivos existentes.

Porém substituir evidências antigas que não possam ser reproduzidas por novos testes.

Estrutura:

```text
logs/
├── README.md
├── sync/
│   ├── push.log
│   ├── pull.log
│   ├── realtime.log
│   ├── outbox.log
│   └── errors.log
├── tests/
│   ├── build.log
│   ├── offline.log
│   ├── retry.log
│   ├── pc-to-mobile.log
│   ├── mobile-to-pc.log
│   ├── finance.log
│   ├── animal.log
│   ├── sanitary.log
│   └── stock.log
├── supabase/
│   └── findings.md
└── audits/
    └── P0_SYNC_STATUS.md
```

---

# 12. TESTES OBRIGATÓRIOS

Depois das correções, executar realmente:

### A. Build

```text
npm run build
```

### B. PC → Supabase

Criar registro novo.

Confirmar no Supabase.

### C. Supabase → Mobile

Confirmar evento Realtime e presença no IndexedDB.

### D. Mobile → Supabase

Alterar registro existente.

Confirmar no Supabase.

### E. Supabase → PC

Confirmar Realtime e atualização da UI.

### F. Financeiro

Criar lançamento contendo:

```text
data_pagamento
fornecedor_cliente
```

Confirmar ambos no Supabase.

### G. Aplicação Sanitária

Criar aplicação contendo:

```text
produto_nome
dose
via
motivo
responsavel
foto
dosagem
observacoes
carencia_fim
```

Confirmar todos os campos existentes no Supabase.

### H. Estoque

Testar:

```text
referencia_id
responsavel
```

### I. Offline

Executar operação offline.

Confirmar:

```text
sync_queue
pending
```

Voltar online.

Confirmar:

```text
Supabase
synced
```

### J. Retry

Forçar falha real de sincronização.

Confirmar:

```text
status = error
```

Restabelecer conexão.

Confirmar retry e:

```text
status = synced
```

### K. Fazenda

Testar registro pertencente à Fazenda A.

Alterar contexto para Fazenda B.

Confirmar que:

```text
fazenda_id continua sendo Fazenda A
```

Nunca alterar silenciosamente a propriedade.

---

# 13. REGRA PARA O P0_SYNC_STATUS

Não marcar:

```text
[x]
PASS
```

somente porque o código aparentemente está correto.

Cada PASS deve apontar para:

```text
arquivo de log
ID do registro
evidência real
```

Se não for possível executar:

```text
NOT TESTED
```

Se falhar:

```text
FAIL
```

Se depender de alteração no Supabase:

```text
BLOCKED
```

---

# 14. SUPABASE

O Antigravity NÃO deve executar:

```text
ALTER TABLE
CREATE TABLE
DROP
RLS changes
```

ou qualquer outra alteração estrutural.

O Supabase será tratado separadamente.

Apenas documentar:

```text
SUPABASE ACTION REQUIRED
```

quando necessário.

---

# 15. CRITÉRIO FINAL DE APROVAÇÃO

O P0 somente poderá ser considerado:

```text
APPROVED
```

quando:

1. `DB_COLUMNS` estiver alinhado;
2. não houver sobrescrita de `fazenda_id`;
3. não houver perda silenciosa de dados;
4. Push estiver comprovado;
5. Pull estiver comprovado;
6. Realtime estiver comprovado;
7. Offline estiver comprovado;
8. Retry estiver comprovado;
9. Financeiro estiver comprovado;
10. Sanitário estiver comprovado;
11. Estoque estiver comprovado;
12. PC → Mobile estiver comprovado;
13. Mobile → PC estiver comprovado;
14. cada PASS possuir evidência real;
15. `P0_SYNC_STATUS.md` refletir os resultados reais.

---

# 16. ENTREGA FINAL

Ao terminar:

1. atualizar todos os logs;
2. atualizar `logs/supabase/findings.md`;
3. atualizar `logs/audits/P0_SYNC_STATUS.md`;
4. mostrar exatamente quais arquivos foram alterados;
5. informar testes executados;
6. informar testes FAIL/NOT TESTED/BLOCKED;
7. informar pendências Supabase;
8. fazer commit.

Mensagem sugerida:

```text
fix: finalize p0 sync validation and evidence
```

**Não declarar P0 aprovado se qualquer teste obrigatório não tiver evidência real.**