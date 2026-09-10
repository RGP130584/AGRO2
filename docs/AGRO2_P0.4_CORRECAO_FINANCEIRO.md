# AGRO2 — P0.4 CORREÇÃO DEFINITIVA DO PUSH FINANCEIRO

## OBJETIVO

Corrigir definitivamente o fluxo:

**Financeiro → IndexedDB → sync_queue → Supabase**

O teste real mostrou:
- lançamento aparece no celular;
- cálculo financeiro funciona;
- receita chega ao Supabase;
- despesa de R$ 1.000.000 não chega ao Supabase.

### REGRAS
- NÃO repetir todos os testes.
- NÃO alterar arquitetura.
- NÃO alterar RLS.
- NÃO alterar schema do Supabase.
- Corrigir somente o fluxo necessário para garantir a entrega financeira.

---

## 1. CORRIGIR `queueSyncEvent()`

Arquivo:

`src/contexts/SyncContext.jsx`

Atualmente `queueSyncEvent` captura qualquer erro e apenas faz `console.error`.

Corrigir para que, se `db.sync_queue.add()` falhar:
1. o erro seja propagado;
2. o formulário não informe sucesso;
3. `syncError` seja atualizado;
4. o lançamento permaneça identificável como pendente localmente.

**NÃO engolir exceções.**

---

## 2. GARANTIR OUTBOX NO CADASTRO FINANCEIRO

Arquivo:

`src/pages/financeiro/LancamentoForm.jsx`

Fluxo obrigatório:
1. criar payload;
2. gravar em `financeiro_lancamentos`;
3. criar evento correspondente em `sync_queue`;
4. somente depois considerar o lançamento criado com sucesso;
5. disparar sincronização;
6. se Supabase falhar, manter:
   - `financeiro.sync_status = pending/error`
   - `sync_queue.status = pending/error`
7. nunca perder o evento.

O ID do lançamento e o `entidade_id` da outbox devem ser exatamente iguais.

---

## 3. NÃO DEPENDER SOMENTE DE `setTimeout()`

O `setTimeout(() => syncNow(), 100)` não pode ser o único mecanismo de disparo.

Manter:
- sincronização imediata;
- sincronização periódica;
- sincronização no evento `online`.

Se uma execução estiver em andamento, a próxima execução não deve simplesmente ser descartada.

Garantir nova execução assim que a execução atual terminar quando houver pendências.

---

## 4. GARANTIR RETRY DE ITENS `ERROR`

Itens `error` também precisam voltar automaticamente para o ciclo de retry.

Fluxo:

```text
pending → tentativa
sucesso → synced
falha → error
próximo ciclo → error → nova tentativa
```

**NUNCA apagar automaticamente um evento com erro.**

O retry deve ser seguro e não criar duplicidades.

---

## 5. GARANTIR CONFIRMAÇÃO DO SUPABASE

Para criação/atualização financeira, considerar sucesso somente quando:
- não houver erro;
- houver registro retornado;
- o ID retornado for o mesmo ID enviado.

Preferencialmente:

```js
const { data, error } =
  await supabase
    .from('financeiro_lancamentos')
    .upsert(cleanPayload)
    .select();
```

Considerar sucesso somente quando:

```text
error === null
data existe
data.length > 0
data[0].id === payload.id
```

Somente então:

```text
financeiro.sync_status = synced
sync_queue.status = synced
```

---

## 6. LOG OBRIGATÓRIO

Adicionar logs explícitos:

```text
[FINANCEIRO CREATE]
id:
fazenda_id:
tipo:
valor:

[OUTBOX CREATE]
id:
entidade:
entidade_id:
status:

[OUTBOX PUSH]
id:
resultado:
Supabase ID:

[OUTBOX ERROR]
id:
erro:

[OUTBOX RETRY]
id:
tentativa:

[OUTBOX CONFIRMED]
id:
Supabase confirmado:
```

Não inventar PASS.

Só registrar PASS quando houver confirmação real.

---

## 7. PRESERVAR CONTRATO DO SUPABASE

Não alterar `DB_COLUMNS.financeiro_lancamentos`.

Contrato atual:

```text
id
fazenda_id
tipo
categoria
descricao
valor
vencimento
status
data_pagamento
fornecedor_cliente
sync_status
created_at
```

Não adicionar colunas.

---

## 8. NORMALIZAÇÃO DO TIPO

O frontend utiliza:

```text
pagar = despesa
receber = receita
```

Preservar compatibilidade com os registros existentes.

Não alterar dados antigos.

Garantir que novos registros financeiros sejam persistidos de forma consistente com o contrato atual.

---

## 9. RECUPERAÇÃO DO LANÇAMENTO DE R$ 1.000.000

Não apagar o lançamento existente no IndexedDB.

Localizar o lançamento de R$ 1.000.000.

Verificar:

```text
financeiro_lancamentos
        ↓
sync_queue
        ↓
push
        ↓
Supabase
```

Se estiver em `pending` ou `error`, processar automaticamente.

**Não criar duplicidade.**

Se o ID já existir no Supabase, usar `upsert`.

---

## 10. TESTE TÉCNICO OBRIGATÓRIO

Depois da correção:
1. executar `npm run build`;
2. localizar o lançamento de R$ 1.000.000;
3. confirmar seu registro no IndexedDB;
4. confirmar o evento correspondente na `sync_queue`;
5. executar o push;
6. consultar o Supabase pelo MESMO ID;
7. confirmar valor;
8. confirmar `fazenda_id`;
9. confirmar status;
10. confirmar `sync_queue = synced`.

Depois criar **apenas um novo lançamento financeiro de teste com ID único** e repetir somente o fluxo financeiro acima.

Não repetir a bateria completa do P0.

---

## 11. NÃO ALTERAR OUTROS MÓDULOS

Não mexer em:
- arquitetura;
- schema do Supabase;
- RLS;
- Realtime;
- cadastro de animais;
- sanitário;
- estoque;
- pesagem;
- nutrição.

Somente corrigir o mecanismo necessário para garantir o ciclo financeiro.

---

## 12. ENTREGA

Após corrigir:
- executar build real;
- atualizar logs reais;
- informar o ID do lançamento de R$ 1.000.000;
- informar o ID da respectiva outbox;
- informar resultado real da consulta Supabase;
- informar o ID do novo lançamento de teste;
- informar o resultado real da consulta Supabase;
- commit no GitHub.

Não marcar PASS sem confirmação no banco.

### COMMIT

```text
fix: p0.4 guarantee financial outbox delivery
```
