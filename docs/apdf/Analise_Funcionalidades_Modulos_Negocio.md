# Análise de Funcionalidades — Módulos de Negócio (Rebanho, Saúde, Nutrição, Estoque, Financeiro)

> Enquanto as duas rodadas anteriores focaram em Autenticação/Segurança/Sync, este documento
> audita os módulos de **negócio** do app (o motivo de existir do produto) contra o que está
> prometido em `docs/apdf/02_Domain_Discovery.md` e `docs/apdf/03_Capability_Discovery.md`.
> Cada item foi confirmado lendo o código-fonte, não apenas a documentação.

---

## Resumo por módulo

| Módulo | Está no menu do app? | Nível de completude |
|---|---|---|
| Rebanho (Fazendas/Piquetes/Lotes/Animais) | ✅ Sim | 🟢 Alto |
| Evolução / Pesagem (GMD) | ✅ Sim (dentro de Animal) | 🟢 Alto |
| Saúde Animal | ✅ Sim | 🟡 Parcial — só aplicação, sem ocorrência/foto/bloqueio |
| Estoque | ✅ Sim | 🟡 Parcial — sem validade/vencimento |
| **Nutrição** | ❌ **Não** (código existe, mas está órfão) | 🔴 Inacessível |
| **Financeiro** | ❌ Não existe | 🔴 Não implementado (0%) |
| Relatórios | ❌ Não existe | 🔴 Não implementado (0%) |

---

## [ ] Passo 1 — Conectar o módulo de Nutrição ao app (🔴 crítico, baixo esforço)

**Objetivo:** `DietaFormView` e `FornecimentoFormView` (em `app_pecuaria/lib/features/nutricao/views/`)
estão completos — service, models e telas prontos — mas nenhuma tela do app navega até eles. Hoje
esse trabalho já feito está simplesmente invisível para quem usa o aplicativo.

1.1. Adicionar um botão "Nutrição" em `home_view.dart`, no mesmo padrão dos outros
   (`Icons.restaurant_menu` ou similar), levando a uma `NutricaoView` (a criar, como já existe
   `SaudeView`/`EstoqueView` como tela "hub" de cada módulo).
1.2. Criar `NutricaoView` listando dietas cadastradas por fazenda/lote, com atalho para
   `DietaFormView` (nova dieta) e `FornecimentoFormView` (registrar fornecimento do dia).
1.3. Validar a navegação: `fazendaId` é exigido pelos construtores das telas — garantir que o fluxo
   a partir do Home tenha acesso à fazenda ativa/selecionada (mesma lógica já usada por Estoque/Saúde).

> Prompt: "Crie uma NutricaoView (hub do módulo, seguindo o padrão de SaudeView) e adicione um botão
> 'Nutrição' no home_view.dart apontando para ela. Garanta que o fluxo de fazendaId chega
> corretamente até DietaFormView e FornecimentoFormView, que já existem e estão prontos."

**Pronto quando:** um usuário consegue, a partir da tela inicial, cadastrar uma dieta e registrar um
fornecimento diário sem precisar de nenhuma alteração de código.

---

## [ ] Passo 2 — Alerta de divergência Nutricional (planejado vs. fornecido)

**Objetivo:** o `03_Capability_Discovery.md` exige: *"Comparar a quantidade planejada vs. fornecida
e gerar alerta de divergência (ex: >15%)"*. Hoje `registrarFornecimento` só grava o valor informado —
não existe nenhum cálculo comparando com `dieta.quantidadePorCabecaDia` × nº de cabeças do lote.

2.1. No momento de registrar o fornecimento, calcular o total planejado do dia para o lote
   (`quantidadePorCabecaDia * quantidadeAnimaisNoLote`).
2.2. Comparar com `quantidadeFornecida` e, se a diferença for maior que 15% (configurável), marcar o
   registro com uma flag (`divergente: true`) e exibir alerta visual na `FornecimentoFormView` e/ou
   numa lista de "divergências do dia" na `NutricaoView`.
2.3. Adicionar teste unitário no `NutricaoService` cobrindo os casos "dentro da margem" e "acima da
   margem".

> Prompt: "No NutricaoService.registrarFornecimento, calcule o total planejado do lote com base na
> dieta e no número de animais, compare com a quantidade fornecida e marque como divergente
> qualquer registro que ultrapasse 15% de diferença. Exiba esse alerta na tela de fornecimento."

**Pronto quando:** registrar um fornecimento 20% abaixo do planejado gera um alerta visível na hora,
sem precisar abrir relatório separado.

---

## [ ] Passo 3 — Fechar os gaps de Saúde Animal

**Objetivo:** cobrir o restante da capacidade 1.2 do `03_Capability_Discovery.md`, hoje só parcialmente
atendida (aplicação sanitária e cálculo de carência já funcionam).

3.1. **Foto da aplicação:** o campo `fotoPath` já existe em `AplicacoesSanitarias`. Adicionar
   `image_picker` (câmera/galeria) na `registro_aplicacao_view.dart` e salvar o caminho do arquivo
   local nesse campo.
3.2. **Ocorrências sanitárias (doença/óbito):** criar uma nova tabela `OcorrenciasSanitarias`
   (`animalId`, `tipo` — doença/óbito/outro —, `descricao`, `dataOcorrencia`, `fotoPath`, campos de
   sync padrão) e a tela correspondente de registro, distinta da aplicação de produto.
3.3. **Bloqueio/alerta de carência:** ao abrir a tela de pesagem, venda ou qualquer ação de saída de
   um animal, consultar se existe `carenciaFimCalculada` futura para esse animal e exibir um aviso
   destacado (não necessariamente bloquear — o próprio guia usa "bloquear/alertar", decisão de
   produto a confirmar) antes de confirmar a ação.

> Prompt: "Implemente captura de foto (image_picker) na tela de registro de aplicação sanitária,
> salvando em fotoPath. Crie a tabela e a tela de OcorrenciasSanitarias (doença/óbito) como um
> registro separado de aplicação de produto. Adicione um alerta visual ao tentar pesar ou vender um
> animal que ainda está em período de carência."

**Pronto quando:** é possível anexar uma foto a uma aplicação, registrar um óbito/doença de um
animal específico, e o app avisa visivelmente quando uma ação é feita durante a carência.

---

## [ ] Passo 4 — Controle de validade no Estoque

**Objetivo:** a capacidade 1.4 pede notificação de "proximidade do vencimento", mas não existe campo
de data de validade em nenhuma tabela do estoque.

4.1. Adicionar `dataValidade` (nullable, pois nem todo insumo tem validade, ex: alguns
   suplementos minerais) à tabela `EstoqueMovimentos` (por lote de entrada) — não em `Produtos`,
   já que cada entrada/lote de compra pode ter uma validade diferente.
4.2. Calcular e exibir, na `produtos_list_view.dart`, um aviso quando alguma entrada em estoque
   estiver a X dias (configurável, ex: 30) do vencimento.
4.3. Se o produto for consumido via FEFO (First-Expire-First-Out) nas baixas automáticas (saúde e
   nutrição), considerar isso na lógica de `_calcularSaldo`/baixa — hoje a baixa não escolhe qual
   lote de entrada consumir, só soma/subtrai quantidade total.

> Prompt: "Adicione o campo dataValidade em EstoqueMovimentos (por lote de entrada), gere a
> migration, e exiba um alerta na tela de produtos quando houver um lote próximo do vencimento
> (configurável, padrão 30 dias)."

**Pronto quando:** cadastrar uma entrada de estoque com validade próxima gera um aviso visível na
lista de produtos, sem precisar abrir cada movimento manualmente.

---

## [ ] Passo 5 — Iniciar o módulo Financeiro (Epic 3.2 / Package 03 — nunca começado)

**Objetivo:** os docs de execução (`10_Execution_Planning.md`, `12_Execution_Packages.md`) definem
"Gestão de contas a pagar/receber (offline)" como parte do Package 03, mas não existe nenhum código
para isso hoje — nem tabela, nem service, nem tela.

5.1. Criar tabela `LancamentosFinanceiros` (`tipo`: pagar/receber, `descricao`, `valor`,
   `dataVencimento`, `dataPagamento` nullable, `status`: pendente/pago/atrasado, `fazendaId`, campos
   de sync padrão).
5.2. Criar `FinanceiroService` com `criarLancamento`, `darBaixa` (marcar como pago/recebido) e
   `watchLancamentosPendentes`.
5.3. Criar `FinanceiroView` (lista com filtro por status) + formulário de lançamento, seguindo o
   mesmo padrão visual dos demais módulos.
5.4. Adicionar o módulo ao menu do Home.
5.5. Atualizar `06_Current_State.md` e `07_Gap_Discovery.md` para deixar de omitir este módulo como
   pendência — hoje esses documentos passam a impressão de que só falta "polimento de UX".

> Prompt: "Implemente o módulo Financeiro básico (contas a pagar/receber): tabela
> LancamentosFinanceiros, FinanceiroService com criação e baixa de lançamentos, FinanceiroView com
> lista filtrável por status, e um botão no home_view. Sem integrações contábeis — é um controle
> simples offline-first, seguindo o mesmo padrão dos outros módulos."

**Pronto quando:** é possível lançar uma conta a pagar/receber, marcá-la como quitada e ver o total
pendente, tudo funcionando offline como os demais módulos.

---

## [ ] Passo 6 — Módulo de Relatórios (mínimo viável)

**Objetivo:** capacidade prevista no grafo de dependências do `03_Capability_Discovery.md`, mas sem
nenhuma implementação — hoje o usuário só vê dados um registro de cada vez.

6.1. Criar uma tela simples de relatórios com pelo menos: evolução de peso/GMD por lote (gráfico ou
   tabela), histórico de aplicações sanitárias por animal (rastreabilidade — já citado como
   requisito em `10_Execution_Planning.md`), e saldo consolidado de estoque.
6.2. Priorizar leitura das tabelas locais já existentes (Drift) — não depende do backend.
6.3. Deixar export (PDF/CSV) como incremento futuro; o essencial é consolidar a visão que hoje só
   existe fragmentada em cada módulo.

> Prompt: "Crie uma tela de Relatórios mínima que leia os dados locais (Drift) e mostre: evolução de
> peso/GMD por lote, histórico de aplicações sanitárias por animal, e saldo de estoque consolidado.
> Sem necessidade de exportação por enquanto, só visualização."

**Pronto quando:** existe uma tela única onde dá para ver a evolução de um lote e o histórico
sanitário de um animal sem precisar navegar módulo por módulo.

---

## Ordem recomendada

```
🔴 Crítico, baixo esforço — fazer primeiro:
  1. Conectar Nutrição ao menu (Passo 1) — trabalho já pronto, só falta expor

🔴 Crítico, esforço médio:
  2. Alerta de divergência nutricional (Passo 2)
  3. Fechar gaps de Saúde: foto, ocorrências, alerta de carência (Passo 3)

🟠 Alto, mas pode esperar a Wave de segurança (guia anterior) ser fechada:
  4. Controle de validade no Estoque (Passo 4)
  5. Módulo Financeiro do zero (Passo 5)
  6. Relatórios mínimos (Passo 6)
```

> Observação: o Passo 1 é o de maior retorno imediato — é trabalho que já foi feito e pago, só não
> está acessível. Vale a pena tratá-lo como prioridade máxima antes mesmo dos itens de segurança
> pendentes, já que é praticamente sem risco e devolve funcionalidade já pronta ao usuário.
