# AGRO2 — P0.2
# CORREÇÃO FINAL P0 DE SINCRONIZAÇÃO + LOGS DE EVIDÊNCIA

**Projeto:** AGRO2  
**Repositório:** `RGP130584/AGRO2`  
**Diretório:** `/agro2`  
**Objetivo:** corrigir os pontos restantes identificados na auditoria independente do commit `616c092`.

---

# 1. CONTEXTO

A primeira rodada de correção P0 melhorou significativamente a sincronização, porém a auditoria independente identificou pendências.

Este trabalho é uma **segunda rodada cirúrgica**.

Não refazer a arquitetura.

Não criar nova arquitetura.

Não substituir Supabase.

Não substituir IndexedDB.

Não criar novo backend.

Não alterar módulos que não tenham relação direta com os problemas listados neste documento.

---

# 2. RESULTADO DA AUDITORIA INDEPENDENTE

Foram identificados os seguintes pontos:

## P0.2.1 — Contrato Financeiro incompleto

O Supabase possui atualmente:

```text
financeiro_lancamentos
├── id
├── fazenda_id
├── tipo
├── categoria
├── vencimento
├── status
├── sync_status
├── created_at
├── valor
├── descricao
├── data_pagamento
└── fornecedor_cliente
```

Porém o `DB_COLUMNS` atual do código não permite:

```text
data_pagamento
fornecedor_cliente
```

Resultado:

Esses dados são descartados antes do envio ao Supabase.

---

# 3. P0.2.2 — Aplicações Sanitárias

O Supabase possui:

```text
produto_nome
dose
via
motivo
responsavel
foto
```

Porém o `DB_COLUMNS` atual do código não permite esses campos.

Resultado:

Os dados podem ser registrados localmente, mas são descartados antes do push.

Corrigir o contrato para preservar os campos que realmente existem no PostgreSQL.

---

# 4. P0.2.3 — Pesagens

O relatório anterior solicitou:

```text
peso_anterior
dias_decorridos
gmd
responsavel
```

Esses campos NÃO existem atualmente no Supabase.

Portanto:

## NÃO criar essas colunas automaticamente.

Antes, verificar:

1. como `pesagens` é criado no frontend;
2. se esses valores são efetivamente persistidos localmente;
3. se são apenas valores calculados para apresentação;
4. se existe necessidade funcional real de persistência.

Se o frontend realmente depender desses campos para sincronização, registrar:

```text
SUPABASE ACTION REQUIRED
```

no log:

```text
/agro2/logs/supabase/findings.md
```

Não executar DDL.

---

# 5. P0.2.4 — Fazenda

Foi identificado risco na implementação anterior.

É PROIBIDO utilizar `fazenda_id` para reescrever silenciosamente registros.

Não fazer:

```javascript
clean.fazenda_id = activeFazendaId;
```

simplesmente porque o dispositivo está operando em determinada fazenda.

A regra correta é:

```text
fazenda_id identifica o proprietário/contexto original do registro.
```

O dispositivo ativo pode ser utilizado para:

- filtrar;
- validar;
- selecionar;
- impedir operação inválida.

Mas NÃO para alterar silenciosamente a propriedade de um registro.

---

# 6. P0.2.5 — Fornecimentos de Dieta

Verificar o contrato atual.

O código pode possuir:

```text
responsavel
```

enquanto o Supabase atualmente não possui esse campo.

Não adicionar coluna automaticamente.

Se o campo for realmente necessário para persistência remota:

```text
SUPABASE ACTION REQUIRED
```

Registrar em:

```text
/agro2/logs/supabase/findings.md
```

---

# 7. P0.2.6 — Ocorrências Sanitárias

Comparar rigorosamente:

```text
DB_COLUMNS.ocorrencias_sanitarias
```

contra o schema real conhecido pelo projeto.

Não permitir que o sistema simplesmente descarte silenciosamente informações clínicas relevantes.

Se houver campos locais que não existem no banco:

1. identificar;
2. determinar se são calculados/UI;
3. se forem dados persistentes necessários, registrar pendência Supabase;
4. não criar coluna automaticamente.

---

# 8. PRINCÍPIO FUNDAMENTAL

O contrato deve seguir:

```text
FRONTEND
   │
   │ dados necessários
   ↓
SANITIZAÇÃO
   │
   │ somente colunas existentes
   ↓
SUPABASE
```

Nunca:

```text
FRONTEND
   ↓
descarta silenciosamente informação importante
   ↓
Supabase
```

Se uma informação necessária ao processo não possui coluna no banco:

```text
SUPABASE ACTION REQUIRED
```

---

# 9. CRIAR ESTRUTURA DE LOGS

Criar:

```text
/agro2/logs/
```

com:

```text
logs/
├── README.md
│
├── sync/
│   ├── push.log
│   ├── pull.log
│   ├── realtime.log
│   ├── outbox.log
│   └── errors.log
│
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
│
├── supabase/
│   └── findings.md
│
└── audits/
    └── P0_SYNC_STATUS.md
```

---

# 10. README DOS LOGS

Criar:

```text
/agro2/logs/README.md
```

explicando:

- finalidade dos logs;
- formato;
- origem;
- data/hora;
- teste executado;
- resultado;
- evidência;
- limitações.

---

# 11. REGRA DOS LOGS

É proibido gerar log artificial.

Exemplo PROIBIDO:

```text
PUSH: PASS
PULL: PASS
REALTIME: PASS
```

sem execução real.

Todo PASS deve possuir evidência.

---

# 12. FORMATO PADRÃO

Usar:

```text
==================================================
TESTE: <nome>
DATA: <ISO-8601>
AMBIENTE: <dev/preview/prod>
==================================================

PRÉ-CONDIÇÃO:
...

AÇÃO:
...

RESULTADO ESPERADO:
...

RESULTADO OBTIDO:
...

EVIDÊNCIA:
...

STATUS:
PASS / FAIL / NOT TESTED / BLOCKED
```

---

# 13. LOG DE ERROS

Criar:

```text
/agro2/logs/sync/errors.log
```

Somente registrar erros reais.

Formato:

```text
[2026-09-09T...]

TABLE:
...

ACTION:
...

ERROR:
...

POSTGREST CODE:
...

PAYLOAD SANITIZADO:
...

RESULT:
...
```

Nunca registrar senhas, tokens ou chaves secretas.

---

# 14. DB_COLUMNS — CORREÇÃO

Revisar completamente:

```text
src/lib/supabaseSync.js
```

A definição:

```javascript
DB_COLUMNS
```

deve representar o schema real do Supabase.

Para cada tabela:

```text
frontend field
        ↓
DB_COLUMNS
        ↓
PostgreSQL column
```

Se não houver coluna correspondente:

```text
não inventar
não criar automaticamente
registrar SUPABASE ACTION REQUIRED
```

---

# 15. FINANCEIRO

Atualizar o contrato para permitir:

```text
data_pagamento
fornecedor_cliente
```

pois essas colunas existem no Supabase.

Também verificar se:

```text
comprovante
```

é realmente utilizado pelo frontend.

Se for utilizado e não existir no Supabase:

```text
SUPABASE ACTION REQUIRED
```

Não adicionar diretamente.

---

# 16. APLICAÇÃO SANITÁRIA

Atualizar `DB_COLUMNS.aplicacoes_sanitarias` para os campos existentes no Supabase:

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
dosagem
observacoes
produto_nome
dose
via
motivo
responsavel
foto
```

Não enviar campos inexistentes.

---

# 17. PESAGENS

Não adicionar automaticamente:

```text
peso_anterior
dias_decorridos
gmd
responsavel
```

ao banco.

Primeiro verificar o código.

Se forem dados calculados/local-only:

```text
não sincronizar
```

Se forem dados persistentes necessários:

```text
SUPABASE ACTION REQUIRED
```

---

# 18. ESTOQUE

Verificar contrato:

```text
estoque_movimentos
```

deve preservar os campos existentes no banco:

```text
id
fazenda_id
produto_id
tipo
quantidade
motivo
data
sync_status
created_at
referencia_id
responsavel
```

Não descartar `referencia_id` ou `responsavel`.

---

# 19. FORNECIMENTOS DE DIETA

Verificar:

```text
DB_COLUMNS.fornecimentos_dieta
```

contra o schema real.

Se:

```text
responsavel
```

não existir no banco:

```text
SUPABASE ACTION REQUIRED
```

Não criar coluna.

---

# 20. OCORRÊNCIAS SANITÁRIAS

Verificar divergências entre frontend e banco.

Especial atenção para:

```text
descricao
sintoma
diagnostico
tratamento
gravidade
responsavel
foto
```

Não descartar silenciosamente informação clínica necessária.

---

# 21. FAZENDA_ID — REGRA DEFINITIVA

Remover qualquer comportamento equivalente a:

```javascript
clean.fazenda_id = activeFazendaId;
```

quando o objetivo for simplesmente sincronizar.

O payload deve preservar:

```text
payload.fazenda_id
```

original.

Exemplo:

```javascript
if (clean.fazenda_id && activeFazendaId) {
  // validar, NÃO substituir
}
```

Se houver divergência:

```text
registro.fazenda_id !== activeFazendaId
```

não alterar o registro.

Definir comportamento seguro usando a lógica existente do sistema.

Preferencialmente:

```text
bloquear operação
registrar erro
```

quando for uma operação local que exige a fazenda ativa.

---

# 22. PULL — FAZENDA_ID

No:

```text
pullSyncFromSupabase()
```

não fazer:

```javascript
targetFazendaId = activeFazendaId;
```

para registros remotos.

Preservar:

```text
item.fazenda_id
```

do Supabase.

O registro remoto deve permanecer associado à sua fazenda original.

---

# 23. PULL — PENDÊNCIAS LOCAIS

Manter a regra:

```text
pending
error
```

não devem ser sobrescritos silenciosamente.

Verificar também se registros:

```text
synced
```

podem ser atualizados normalmente.

---

# 24. OUTBOX

Garantir:

```text
pending
   ↓
push
   ↓
sucesso
   ↓
synced
```

ou:

```text
pending
   ↓
push
   ↓
erro
   ↓
error/pending
```

Nunca:

```text
erro
 ↓
synced
```

---

# 25. RECONCILIAÇÃO

Auditar o bloco de reconciliação.

Ele não deve:

- gerar duplicação;
- criar loop;
- sobrescrever alterações pendentes;
- marcar como synced sem confirmação;
- alterar `fazenda_id`.

---

# 26. REALTIME

Preservar:

```text
agro2-realtime-changes
```

Verificar:

```text
SUBSCRIBED
CHANNEL_ERROR
TIMED_OUT
CLOSED
```

Registrar resultados em:

```text
logs/sync/realtime.log
```

Não considerar WebSocket conectado como prova de sincronização completa.

---

# 27. FINANCEIRO — TESTE

Executar teste real:

```text
Criar lançamento
↓
IndexedDB
↓
sync_queue
↓
Supabase
```

Depois:

```text
Alterar para pago
↓
IndexedDB
↓
sync_queue
↓
Supabase
```

Depois:

```text
alterar no outro dispositivo
↓
Realtime/Pull
↓
FinanceiroList
```

Registrar tudo em:

```text
logs/tests/finance.log
```

---

# 28. ANIMAL — TESTE

Testar:

```text
criação
alteração
carencia_fim
```

Registrar em:

```text
logs/tests/animal.log
```

---

# 29. APLICAÇÃO SANITÁRIA — TESTE

Testar:

```text
aplicação
produto_nome
dose
via
motivo
responsavel
foto
carencia_fim
```

Não precisa usar foto real se o ambiente de teste não permitir.

Nesse caso:

```text
NOT TESTED
```

para a parte específica.

Registrar em:

```text
logs/tests/sanitary.log
```

---

# 30. ESTOQUE — TESTE

Testar:

```text
movimento
quantidade
produto
referencia_id
responsavel
```

Registrar:

```text
logs/tests/stock.log
```

---

# 31. OFFLINE

Testar:

```text
offline
↓
criação
↓
IndexedDB
↓
sync_queue pending
```

Depois:

```text
online
↓
push
↓
Supabase
↓
synced
```

Registrar:

```text
logs/tests/offline.log
```

---

# 32. RETRY

Forçar uma condição controlada de erro, se possível.

Verificar:

```text
erro
↓
não synced
↓
retry
↓
sucesso
```

Registrar:

```text
logs/tests/retry.log
```

Se não for possível executar com segurança:

```text
NOT TESTED
```

Não declarar PASS.

---

# 33. PC → MOBILE

Executar teste real sempre que o ambiente permitir:

```text
PC
 ↓
Supabase
 ↓
Realtime/Pull
 ↓
Mobile
```

Registrar:

```text
logs/tests/pc-to-mobile.log
```

---

# 34. MOBILE → PC

Executar:

```text
Mobile
 ↓
Supabase
 ↓
Realtime/Pull
 ↓
PC
```

Registrar:

```text
logs/tests/mobile-to-pc.log
```

---

# 35. BUILD

Executar somente comandos existentes no `package.json`.

No mínimo verificar:

```text
npm run build
```

Registrar:

```text
logs/tests/build.log
```

---

# 36. SUPABASE FINDINGS

Criar:

```text
logs/supabase/findings.md
```

Formato:

```markdown
# Supabase Findings

## Required

### Tabela
...

### Campo
...

### Problema
...

### Motivo
...

### SQL sugerido
...

### Impacto
...
```

Não executar o SQL.

---

# 37. AUDITORIA FINAL

Criar:

```text
logs/audits/P0_SYNC_STATUS.md
```

Formato:

```markdown
# AGRO2 P0 Sync Status

## Código

- [ ] DB_COLUMNS alinhado
- [ ] Financeiro alinhado
- [ ] Aplicações alinhadas
- [ ] Estoque alinhado
- [ ] Pesagens analisadas
- [ ] Fornecimentos analisados
- [ ] Ocorrências analisadas
- [ ] fazenda_id preservado
- [ ] pull seguro
- [ ] outbox seguro
- [ ] realtime tratado
- [ ] offline preservado
- [ ] retry preservado

## Testes

- [ ] Build
- [ ] Push
- [ ] Pull
- [ ] Realtime
- [ ] Offline
- [ ] Retry
- [ ] Financeiro
- [ ] Animal
- [ ] Sanitário
- [ ] Estoque
- [ ] PC → Mobile
- [ ] Mobile → PC

## Supabase

- [ ] Nenhuma alteração executada pelo Antigravity
- [ ] Pendências documentadas
```

---

# 38. PROIBIÇÃO DE FALSO PASS

Não utilizar:

```javascript
testResults["PUSH"] = "PASS";
```

ou equivalente sem execução.

Não usar:

```text
PASS
```

porque:

- o arquivo existe;
- a função existe;
- o build passou;
- o código parece correto.

Isso não comprova funcionamento.

---

# 39. STATUS VÁLIDOS

Utilizar somente:

```text
PASS
FAIL
NOT TESTED
BLOCKED
```

### PASS

Existe evidência real.

### FAIL

O teste foi executado e falhou.

### NOT TESTED

O teste não foi executado.

### BLOCKED

Existe dependência externa impedindo o teste.

---

# 40. NÃO ALTERAR SUPABASE

O Antigravity NÃO deve:

```text
ALTER TABLE
CREATE TABLE
DROP TABLE
CREATE COLUMN
DROP COLUMN
CREATE POLICY
ALTER POLICY
ALTER PUBLICATION
```

nem executar qualquer alteração no banco.

Se identificar necessidade:

```text
SUPABASE ACTION REQUIRED
```

---

# 41. NÃO ALTERAR RLS

Não modificar políticas RLS nesta rodada.

Essa será uma etapa separada.

---

# 42. NÃO CRIAR MIGRATION DE BANCO COMO SE ESTIVESSE APLICADA

Pode documentar SQL sugerido em:

```text
logs/supabase/findings.md
```

mas não considerar o banco alterado.

---

# 43. GIT

Antes:

```text
git status
```

Depois:

```text
git diff
```

Verificar todos os arquivos alterados.

Não alterar arquivos não relacionados.

---

# 44. COMMIT

Ao concluir, criar commit somente se essa for a rotina normal do projeto.

Mensagem sugerida:

```text
fix: harden p0 sync contracts and evidence logging
```

---

# 45. RELATÓRIO FINAL

Ao terminar, informar:

## Arquivos alterados

Lista completa.

## Arquivos criados

Lista completa.

## Correções

Lista objetiva.

## Pendências Supabase

Lista objetiva.

## Testes

Tabela:

| Teste | Status | Log |
|---|---|---|
| Build | PASS/FAIL | arquivo |
| Push | PASS/FAIL | arquivo |
| Pull | PASS/FAIL | arquivo |
| Realtime | PASS/FAIL | arquivo |
| Offline | PASS/FAIL | arquivo |
| Retry | PASS/FAIL | arquivo |
| Financeiro | PASS/FAIL | arquivo |
| Animal | PASS/FAIL | arquivo |
| Sanitário | PASS/FAIL | arquivo |
| Estoque | PASS/FAIL | arquivo |
| PC → Mobile | PASS/FAIL | arquivo |
| Mobile → PC | PASS/FAIL | arquivo |

---

# 46. CRITÉRIO DE CONCLUSÃO

Não é necessário atingir 100% PASS.

O objetivo é:

```text
100% TRANSPARÊNCIA
```

Se algo não puder ser testado:

```text
NOT TESTED
```

Se depender do Supabase:

```text
BLOCKED — SUPABASE ACTION REQUIRED
```

Se falhar:

```text
FAIL
```

Nunca mascarar.

---

# 47. OBJETIVO FINAL

Ao concluir:

```text
                AGRO2
                  │
          ┌───────┴────────┐
          │                │
       CÓDIGO           SUPABASE
          │                │
          ↓                ↓
       LOGS            BANCO REAL
          │                │
          └───────┬────────┘
                  ↓
          AUDITORIA CRUZADA
                  ↓
          TESTE PC ↔ MOBILE
                  ↓
             APROVAÇÃO P0
```

O Antigravity corrige e documenta o código.

O Supabase será validado separadamente.

A aprovação final somente acontecerá após a auditoria cruzada.