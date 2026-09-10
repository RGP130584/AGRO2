# AGRO2 — CORREÇÃO: REMOVER SELETOR DE FAZENDA DA INTERFACE

## Objetivo

Simplificar a experiência atual do AGRO2.

Neste momento, o sistema deve trabalhar com **uma fazenda operacional**, cadastrada no início da utilização.

A fazenda deve ser assumida automaticamente pelo sistema como contexto dos registros.

**NÃO implementar neste momento um seletor/trocador de fazenda na interface.**

A arquitetura deve continuar preparada para uma futura evolução para múltiplas fazendas, mas essa funcionalidade não deve aparecer ou interferir na experiência atual.

---

# 1. Regra de negócio atual

O fluxo atual deve ser:

```text
Primeiro acesso
     ↓
Cadastro da Fazenda
     ↓
Fazenda operacional definida
     ↓
Sistema assume automaticamente a fazenda
     ↓
Cadastros e operações
```

O usuário não deve precisar selecionar a fazenda em cada operação.

Exemplo:

```text
Fazenda: Fazenda São José
```

Ao cadastrar um animal:

```text
Brinco: 001
Raça: Nelore
Sexo: Macho
Peso: 420 kg
```

o sistema deve automaticamente gravar:

```text
fazenda_id = ID da Fazenda São José
```

---

# 2. Remover o seletor de Fazenda do Header

A implementação anterior adicionou um seletor de Fazenda no Header.

**REMOVER esse componente da interface.**

Não deixar:

- select de Fazenda;
- botão de troca de Fazenda;
- barra de contexto de Fazenda;
- dropdown de Fazenda;
- ícone de Fazenda associado a um seletor;
- qualquer outro controle para alternar fazendas.

O Header deve voltar a utilizar o espaço para sua finalidade original.

---

# 3. Não criar uma barra de Fazenda neste momento

A proposta anterior de colocar uma barra:

```text
┌─────────────────────────────┐
│ 🏠 Fazenda Teste A       ˅  │
└─────────────────────────────┘
```

também deve ser descartada por enquanto.

**Não criar `FarmContextBar` ou componente equivalente.**

A experiência atual deve permanecer simples.

---

# 4. Fazenda automática

O mecanismo já implementado em:

```text
src/utils/fazendaHelper.js
```

deve continuar existindo.

Preservar:

```js
getActiveFazendaId()
```

e:

```js
requireActiveFazendaId()
```

A função deve continuar permitindo que os módulos obtenham automaticamente a fazenda operacional.

---

# 5. Cadastro inicial da Fazenda

Quando não existir nenhuma fazenda cadastrada:

```text
fazendas = 0
```

o sistema deve impedir cadastros operacionais que dependem de fazenda.

Mensagem:

> **Nenhuma fazenda cadastrada. Cadastre uma fazenda para iniciar a operação.**

Não criar:

```text
fazenda_id = null
```

Não criar registro órfão.

Não criar item de outbox para registro inválido.

---

# 6. Após cadastrar a primeira Fazenda

Depois que a primeira fazenda for cadastrada:

1. a fazenda deve ser persistida normalmente;
2. deve ser sincronizada pelo fluxo atual;
3. deve ser reconhecida automaticamente pelo `fazendaHelper`;
4. os módulos operacionais devem utilizá-la automaticamente.

O usuário não deve precisar configurar novamente a fazenda.

---

# 7. Registros que devem herdar automaticamente a Fazenda

Manter o comportamento automático para:

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
- Financeiro;
- demais entidades que possuam `fazenda_id`.

---

# 8. Não colocar Fazenda nos formulários

NÃO adicionar campo de Fazenda em:

- cadastro de animal;
- cadastro de lote;
- cadastro de piquete;
- cadastro de produto;
- financeiro;
- pesagem;
- estoque;
- sanidade;
- nutrição;
- demais formulários operacionais.

A fazenda deve vir do contexto interno automaticamente.

---

# 9. Proteção do Sync

Manter a barreira implementada anteriormente em:

```text
pushSyncToSupabase()
```

Para entidades operacionais:

```text
fazenda_id obrigatório
```

Se um payload chegar sem `fazenda_id`:

```text
[SYNC FARM VALIDATION]
```

deve rejeitar a operação antes de enviá-la ao Supabase.

Exceções atuais:

- `fazendas`;
- `usuarios`.

Não alterar essa regra.

---

# 10. Não alterar a arquitetura

Preservar:

- React;
- Dexie;
- IndexedDB;
- Supabase;
- Supabase Realtime;
- SyncContext;
- sync_queue;
- Outbox;
- sincronização atual;
- `fazendaHelper.js`.

Não criar:

- novo banco;
- novo contexto paralelo;
- novo mecanismo de sincronização;
- nova API;
- outra plataforma.

---

# 11. Multi-fazenda — somente preparação

A arquitetura pode continuar preparada para uma futura evolução para:

```text
Produtor
   ├── Fazenda A
   ├── Fazenda B
   └── Fazenda C
```

Porém:

**NÃO implementar agora:**

- seletor de fazenda;
- troca de fazenda;
- tela de múltiplas fazendas;
- barra de fazenda;
- transferência de rebanho;
- workflow de mudança de propriedade.

Esses recursos serão tratados em uma etapa futura específica.

---

# 12. Transferência de rebanho — futuro

A futura transferência deverá ser uma operação formal:

```text
Fazenda A
   ↓
Transferência
   ↓
Fazenda B
```

mantendo histórico.

Não implementar agora.

Não alterar `fazenda_id` diretamente como solução de transferência.

---

# 13. Corrigir o Header

Remover do `Header.jsx` tudo que foi adicionado especificamente para o seletor de Fazenda:

- import de `Home`, caso só seja utilizado pelo seletor;
- estado `fazendas`;
- estado `activeFazendaIdState`;
- `carregarFazendas()`, caso tenha sido criado apenas para o seletor;
- listener `agro2_fazenda_changed`, caso seja usado apenas pelo Header;
- listener relacionado à atualização do seletor;
- `handleSelectFazenda()`;
- JSX do `<select>`;
- container visual do seletor.

**Cuidado:** remover somente código relacionado ao seletor.

Não remover funcionalidades originais do Header.

---

# 14. Eventos

O evento:

```text
agro2_fazenda_changed
```

não precisa ser usado pela interface atual se não houver troca de fazenda.

Não criar novo mecanismo de eventos apenas para manter o seletor removido.

Se o evento já existir no helper por preparação futura, ele pode permanecer, desde que não cause efeitos colaterais.

---

# 15. Dashboard

O Dashboard deve continuar funcionando considerando a fazenda operacional automaticamente.

Não deve exibir seletor.

Não deve exigir interação do usuário para escolher Fazenda.

O Dashboard deve consultar os registros associados ao contexto da fazenda.

Exemplo:

```text
Fazenda operacional
       ↓
Dashboard
       ↓
Animais dessa fazenda
Lotes dessa fazenda
Estoque dessa fazenda
Indicadores dessa fazenda
```

Não misturar dados de outras propriedades.

---

# 16. Teste funcional

Executar somente os testes desta correção.

## TESTE 01 — Interface

Abrir o sistema no celular.

Verificar:

- [ ] não existe seletor de Fazenda no Header;
- [ ] não existe barra de Fazenda abaixo do Header;
- [ ] Header não ficou com espaço vazio estranho;
- [ ] Header mantém aparência original limpa;
- [ ] interface mobile continua adequada.

---

## TESTE 02 — Fazenda

Com uma fazenda cadastrada:

- abrir Dashboard;
- verificar que os dados pertencem à fazenda existente.

Não deve ser necessário selecionar a fazenda.

---

## TESTE 03 — Animal

Cadastrar animal sem informar Fazenda.

Resultado:

```text
animal.fazenda_id = Fazenda existente
```

---

## TESTE 04 — Financeiro

Cadastrar uma despesa sem informar Fazenda.

Resultado:

```text
financeiro.fazenda_id = Fazenda existente
```

---

## TESTE 05 — Bloqueio

Se não houver fazenda cadastrada:

tentar criar animal.

Resultado:

```text
BLOQUEADO
```

Nenhum:

- registro local;
- registro Supabase;
- item de outbox.

---

# 17. Critérios de aceite

A correção está concluída quando:

- [ ] seletor de Fazenda removido do Header;
- [ ] barra de Fazenda não existe;
- [ ] Header está visualmente limpo no mobile;
- [ ] usuário não precisa selecionar Fazenda;
- [ ] fazenda é assumida automaticamente;
- [ ] formulários não possuem campo Fazenda;
- [ ] `requireActiveFazendaId()` continua funcionando;
- [ ] registros operacionais recebem automaticamente `fazenda_id`;
- [ ] registros sem fazenda são bloqueados;
- [ ] Sync continua rejeitando payload sem `fazenda_id`;
- [ ] Dashboard não mistura dados de outras fazendas;
- [ ] arquitetura existente permanece intacta;
- [ ] Supabase schema não foi alterado;
- [ ] RLS não foi alterado;
- [ ] build passa.

---

# 18. Commit

Usar:

```text
fix: simplify farm context and remove farm selector
```

---

# 19. Regra definitiva desta etapa

A regra da versão atual do AGRO2 é:

> **A fazenda é cadastrada no início e assumida automaticamente pelo sistema.**

O usuário trabalha normalmente sem precisar escolher a fazenda.

A funcionalidade de múltiplas fazendas será desenvolvida posteriormente, em uma etapa específica, quando houver necessidade real de administrar propriedades diferentes e transferências de rebanho.
