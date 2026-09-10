# AGRO2 — CORREÇÃO: CONTEXTO DE FAZENDA ATIVA E MULTI-FAZENDA

## 1. Objetivo

Corrigir a regra de negócio do AGRO2 para que a **fazenda seja o contexto operacional ativo do sistema**.

O usuário NÃO deve informar a fazenda repetidamente em cada formulário.

Fluxo esperado:

**Usuário → Fazenda Ativa → Operações e Cadastros**

A primeira fazenda é cadastrada no início. Depois disso, o sistema assume automaticamente essa fazenda para os registros dependentes.

O sistema também deve ficar preparado para trabalhar com **múltiplas fazendas** e, posteriormente, permitir **transferência de rebanho entre fazendas**, preservando histórico.

---

# 2. Regra de negócio

Quando existir uma Fazenda Ativa, o sistema deve automaticamente utilizar seu `fazenda_id` em todos os registros que pertencem à propriedade.

Isso inclui, conforme os contratos atuais:

- Animais;
- Lotes;
- Piquetes;
- Produtos/estoque;
- Dietas;
- Fornecimentos de dieta;
- Aplicações sanitárias;
- Ocorrências sanitárias;
- Pesagens;
- Movimentos de estoque;
- Lançamentos financeiros;
- Demais entidades operacionais que possuam `fazenda_id`.

### Regra fundamental

O usuário NÃO deve precisar selecionar a fazenda dentro de cada formulário.

Exemplo:

> Fazenda ativa: Fazenda São José

Ao cadastrar um animal:

> Brinco: TOURO-001  
> Raça: Nelore  
> Sexo: Macho

O sistema automaticamente grava:

`fazenda_id = ID da Fazenda São José`

---

# 3. Primeira utilização do sistema

Quando o usuário entrar no sistema e ainda não existir nenhuma fazenda cadastrada:

1. O sistema deve identificar que não existe Fazenda Ativa.
2. Deve direcionar o usuário para o cadastro inicial da fazenda.
3. Após o cadastro, a nova fazenda deve se tornar a Fazenda Ativa.
4. A partir desse momento, os módulos operacionais podem ser utilizados.

Mensagem sugerida:

> **Cadastre sua primeira fazenda para iniciar a operação.**

---

# 4. Nunca permitir registros órfãos

Atualmente foi identificado que registros podem ser criados com:

`fazenda_id = NULL`

Isso NÃO deve mais acontecer para entidades operacionais.

Se não existir Fazenda Ativa:

- não salvar o registro local;
- não criar item na `sync_queue`;
- não enviar para Supabase;
- informar claramente o usuário sobre a necessidade de cadastrar uma fazenda.

Mensagem sugerida:

> **Nenhuma fazenda cadastrada. Cadastre uma fazenda para iniciar a operação.**

---

# 5. Contexto centralizado de Fazenda

Utilizar o mecanismo existente em:

`src/utils/fazendaHelper.js`

Manter:

`getActiveFazendaId()`

Adicionar uma função de domínio:

`requireActiveFazendaId()`

Comportamento:

1. Procurar a fazenda ativa no contexto/local.
2. Se necessário, consultar Supabase pelo mecanismo já existente.
3. Retornar o ID da fazenda ativa.
4. Caso não exista fazenda, lançar erro controlado.
5. Nunca retornar `null` para um fluxo de criação que exige fazenda.

Mensagem do erro:

`Nenhuma fazenda cadastrada. Cadastre uma fazenda para iniciar a operação.`

### Restrição

Não usar:

- ID fixo;
- `faz-1`;
- primeira fazenda de maneira espalhada pelo código;
- lógica diferente em cada formulário.

A resolução da fazenda deve permanecer centralizada.

---

# 6. Fazenda ativa

O sistema deve possuir o conceito de:

## Fazenda Ativa

A Fazenda Ativa representa o contexto operacional atual.

Exemplo:

### Fazenda A — ativa

Todos os novos registros pertencem à Fazenda A.

O usuário pode cadastrar:

- animais;
- lotes;
- piquetes;
- estoque;
- financeiro;
- sanidade;
- pesagens etc.

Todos recebem automaticamente:

`fazenda_id = Fazenda A`

---

# 7. Cadastro de uma nova fazenda

Deve existir uma operação explícita:

## Cadastrar Nova Fazenda

Ao cadastrar uma nova fazenda:

1. Criar a fazenda utilizando o fluxo atual.
2. Sincronizar normalmente com Supabase.
3. Após criação bem-sucedida, permitir torná-la a Fazenda Ativa.
4. A Fazenda anterior continua existente.
5. Os registros da Fazenda anterior NÃO são alterados.
6. Animais NÃO são duplicados.
7. Estoque NÃO é duplicado.
8. Financeiro NÃO é duplicado.
9. Histórico NÃO é apagado.

Exemplo:

Fazenda A
- 100 animais

Cadastrar Fazenda B.

Resultado:

Fazenda A
- 100 animais

Fazenda B
- 0 animais

Apenas depois de uma operação explícita de transferência um animal poderá mudar de propriedade.

---

# 8. Troca de Fazenda Ativa

O sistema deve permitir:

**Fazenda A → Fazenda B**

Quando o usuário trocar a Fazenda Ativa:

- as consultas operacionais passam a considerar a Fazenda B;
- novos registros passam automaticamente a usar Fazenda B;
- registros da Fazenda A permanecem associados à Fazenda A;
- não ocorre alteração automática dos registros existentes.

Depois:

**Fazenda B → Fazenda A**

O sistema volta a trabalhar com os dados da Fazenda A.

---

# 9. Isolamento por Fazenda

Os módulos operacionais devem respeitar o contexto da Fazenda Ativa.

Exemplo:

Se Fazenda A estiver ativa:

- listar animais da Fazenda A;
- listar lotes da Fazenda A;
- listar piquetes da Fazenda A;
- listar estoque da Fazenda A;
- listar financeiro da Fazenda A;
- listar informações sanitárias da Fazenda A.

Não misturar registros de propriedades diferentes.

---

# 10. Proteção no fluxo de sincronização

Além da proteção nos formulários, o Sync deve possuir uma segunda barreira.

Para as tabelas operacionais que possuem `fazenda_id`:

Se o payload chegar ao fluxo de sincronização sem `fazenda_id`, ou com:

`fazenda_id = null`

a operação deve ser rejeitada antes do envio ao Supabase.

Registrar erro de domínio/log.

Não criar registro remoto órfão.

### Exceções atuais

Não aplicar essa regra a:

- `fazendas`;
- `usuarios`;

porque essas entidades não possuem `fazenda_id` no contrato atual.

---

# 11. Não alterar o banco nesta etapa

NÃO criar `NOT NULL` no Supabase.

NÃO alterar schema.

NÃO alterar RLS.

A correção deve ocorrer na camada da aplicação e no fluxo de sincronização existente.

Motivo:

A arquitetura atual utiliza Dexie + outbox + Supabase e deve ser preservada.

---

# 12. Não alterar a arquitetura existente

Preservar integralmente:

- React;
- Dexie;
- IndexedDB;
- Supabase;
- Supabase Realtime;
- SyncContext;
- `sync_queue`;
- fluxo offline;
- outbox;
- sincronização atual;
- estrutura atual dos módulos.

Não criar:

- outro banco;
- outro mecanismo de sincronização;
- outro backend;
- outra plataforma;
- serviço paralelo.

---

# 13. Preparação para transferência de rebanho

Nesta correção, preparar o domínio para uma futura funcionalidade:

## Transferência de Rebanho

Exemplo:

**Fazenda A → Fazenda B**

A operação futura deverá registrar:

- Fazenda Origem;
- Fazenda Destino;
- Animal ou conjunto de animais;
- Lote de origem, quando aplicável;
- Lote de destino, quando aplicável;
- Data;
- Responsável;
- Motivo;
- Observação;
- Identificação da operação.

### Regra importante

NÃO simplesmente alterar:

`animal.fazenda_id`

sem registrar a operação.

A transferência deve preservar rastreabilidade.

### Nesta etapa

Não implementar tabela nova.

Não alterar schema.

Apenas preparar o ponto de extensão no domínio e documentar a regra.

---

# 14. Registros de teste inválidos

Durante o teste anterior foram criados quatro registros sem fazenda:

- `ani-1789006820724`
- `ani-1789006466081`
- `fin-1789006517402`
- `fin-1789006860517`

Esses registros são inválidos porque possuem:

`fazenda_id = NULL`

Após a correção:

1. remover esses quatro registros de teste;
2. limpar eventuais cópias locais;
3. NÃO apagar usuários;
4. NÃO apagar fazendas válidas que tenham sido cadastradas posteriormente.

---

# 15. Teste funcional da correção

Não repetir a bateria completa de P0.

Executar somente os testes desta correção.

## TESTE 01 — Sem fazenda

Estado:

- nenhuma fazenda cadastrada.

Tentar:

- cadastrar animal.

Resultado esperado:

**BLOQUEADO**

Nenhum:

- registro Dexie;
- item de outbox;
- registro Supabase.

---

## TESTE 02 — Primeira Fazenda

Cadastrar:

**Fazenda Teste A**

Resultado esperado:

- criada localmente;
- sincronizada;
- existente no Supabase;
- definida como Fazenda Ativa.

---

## TESTE 03 — Animal na Fazenda A

Cadastrar animal sem informar fazenda.

Resultado esperado:

- cadastro permitido;
- `fazenda_id` preenchido automaticamente;
- associado à Fazenda Teste A;
- sincronizado;
- exatamente um registro remoto.

---

## TESTE 04 — Segunda Fazenda

Cadastrar:

**Fazenda Teste B**

Resultado esperado:

- Fazenda B criada;
- Fazenda A continua existente;
- nenhum registro da Fazenda A alterado.

---

## TESTE 05 — Troca para Fazenda B

Definir:

**Fazenda Teste B = Fazenda Ativa**

Cadastrar novo animal sem selecionar fazenda.

Resultado esperado:

- novo animal associado automaticamente à Fazenda B;
- animal anterior continua associado à Fazenda A;
- nenhum duplicado.

---

## TESTE 06 — Financeiro

Com Fazenda B ativa:

Criar:

- uma despesa;
- uma receita.

Sem selecionar fazenda no formulário.

Resultado esperado:

- ambos recebem automaticamente `fazenda_id` da Fazenda B;
- sincronização correta;
- nenhum `fazenda_id = NULL`.

---

# 16. Critérios de aceite

A correção somente será considerada concluída quando:

- [ ] primeira fazenda pode ser cadastrada;
- [ ] primeira fazenda torna-se Fazenda Ativa;
- [ ] sistema bloqueia operação dependente quando não existe fazenda;
- [ ] usuário não precisa informar fazenda em cada formulário;
- [ ] novos registros herdam automaticamente a Fazenda Ativa;
- [ ] troca de Fazenda Ativa funciona;
- [ ] dados de fazendas diferentes não são misturados;
- [ ] registros antigos permanecem associados à fazenda original;
- [ ] Sync rejeita payload operacional sem `fazenda_id`;
- [ ] nenhum registro órfão é criado;
- [ ] quatro registros de teste inválidos são removidos;
- [ ] usuários permanecem intactos;
- [ ] schema Supabase não foi alterado;
- [ ] RLS não foi alterado;
- [ ] Dexie/Supabase/Realtime/Outbox permanecem na arquitetura atual;
- [ ] build passa;
- [ ] testes funcionais acima passam.

---

# 17. Logs esperados

Adicionar/usar logs claros quando necessário:

`[FAZENDA ACTIVE]`

`[FAZENDA REQUIRED]`

`[FAZENDA CREATED]`

`[FAZENDA SWITCH]`

`[FAZENDA CONTEXT]`

`[FAZENDA CONTEXT ERROR]`

`[SYNC FARM VALIDATION]`

Exemplo:

`[FAZENDA CONTEXT] Fazenda ativa: <id>`

Exemplo de erro:

`[FAZENDA CONTEXT ERROR] Nenhuma fazenda cadastrada.`

---

# 18. Restrições para o Antigravity

## NÃO fazer

- Não criar arquitetura nova.
- Não mudar banco.
- Não mudar RLS.
- Não criar outro banco.
- Não criar outro sistema de sincronização.
- Não colocar seletor de fazenda em todos os formulários.
- Não usar ID fixo.
- Não duplicar rebanho ao criar nova fazenda.
- Não alterar `fazenda_id` diretamente como transferência normal.
- Não apagar usuários.
- Não repetir toda a bateria P0.
- Não criar dados artificiais fora dos testes definidos.

## FAZER

- Corrigir o contexto de Fazenda Ativa.
- Centralizar a resolução da fazenda.
- Garantir herança automática de `fazenda_id`.
- Bloquear registros quando não houver fazenda.
- Criar proteção adicional no Sync.
- Preparar o domínio para múltiplas fazendas.
- Preparar o ponto de extensão para transferência de rebanho.
- Remover os quatro registros inválidos.
- Executar somente os testes desta correção.
- Fazer build.
- Registrar resultado.
- Commitar.

---

# 19. Commit

Mensagem sugerida:

`fix: enforce active farm context and prepare multi-farm`

---

# 20. Resultado esperado

Ao final, o comportamento do AGRO2 deve ser:

```text
ENTRADA NO SISTEMA
        │
        ▼
Existe Fazenda?
   │             │
  NÃO           SIM
   │             │
   ▼             ▼
Cadastrar      Fazenda
 Fazenda        Ativa
   │             │
   └──────┬──────┘
          ▼
   Operação normal
          │
          ▼
Todos os novos registros
herdam automaticamente
a Fazenda Ativa
```

E para múltiplas fazendas:

```text
Fazenda A
   │
   ├── Rebanho A
   ├── Estoque A
   ├── Financeiro A
   └── Histórico A

          ⇅
    Troca de contexto

          ⇅

Fazenda B
   │
   ├── Rebanho B
   ├── Estoque B
   ├── Financeiro B
   └── Histórico B
```

A transferência de animais entre A e B deverá futuramente ocorrer por uma **operação formal de transferência**, mantendo o histórico da movimentação.
