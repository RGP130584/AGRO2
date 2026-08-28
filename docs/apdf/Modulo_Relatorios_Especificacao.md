# Módulo de Relatórios — Especificação Completa

> Este documento especifica o módulo de Relatórios citado no Passo 6 do documento anterior
> (`Analise_Funcionalidades_Modulos_Negocio.md`), agora detalhado relatório a relatório. Cada
> relatório foi desenhado em cima das tabelas **reais** do Drift (`app_pecuaria/lib/data/local/tables/`),
> não de um modelo hipotético. Onde o relatório depende de um dado que ainda não existe (ex.:
> Financeiro), isso está marcado explicitamente como dependência.

---

## 0. Decisões de arquitetura antes de implementar

0.1. **Sem dependência do backend.** Todos os relatórios abaixo devem ler exclusivamente do banco
   local (Drift/SQLite) — é a mesma filosofia offline-first do resto do app. Um produtor no meio do
   pasto sem sinal precisa conseguir ver o relatório de rebanho hoje.

0.2. **Um `ReportsService` por domínio, não um service gigante.** Sugestão de organização:
   ```
   app_pecuaria/lib/features/relatorios/
     services/
       relatorio_rebanho_service.dart
       relatorio_saude_service.dart
       relatorio_nutricao_service.dart
       relatorio_estoque_service.dart
       relatorio_financeiro_service.dart   (após o módulo Financeiro existir)
     views/
       relatorios_hub_view.dart            (tela com categorias/abas)
       relatorio_efetivo_view.dart
       relatorio_gmd_view.dart
       ... (uma view por relatório, ou uma view genérica parametrizável por tipo)
   ```

0.3. **Dependências novas de pacote a avaliar:**
   - Gráficos: nenhuma lib de chart está no `pubspec.yaml` hoje. Adicionar `fl_chart` (leve, offline,
     sem dependência de internet) para os relatórios com curva/série temporal.
   - Exportação (PDF/CSV): não existe hoje. Se for prioridade nesta fase, `pdf` + `printing` (para
     PDF) e/ou `csv` (para planilha) são as opções mais usadas no ecossistema Flutter. Sugestão: só
     entrar nesta fase se os relatórios em tela já estiverem validados com o usuário — exportação é
     fácil de adicionar depois, sem redesenhar as queries.

0.4. **Filtro global de contexto:** praticamente todo relatório abaixo precisa do filtro
   Fazenda → (opcional) Lote/Piquete → (opcional) período de datas. Vale construir esse seletor uma
   vez como widget reutilizável (`RelatorioFiltroBar`) em vez de repetir em cada tela.

---

## 1. Relatórios de Rebanho

### 1.1. Efetivo do Rebanho (headcount atual) — P0
- **Objetivo:** "quantos animais eu tenho, e onde estão", a pergunta mais básica de gestão.
- **Fonte:** `Animais` (contagem, `deletedAt IS NULL`) agrupado por `loteId` → `Lotes.nome`,
  `Lotes.categoria`, e por `Piquetes.nome` via `Lotes.piqueteId`.
- **Visualização:** tabela/cards agrupados por piquete e por lote, com total geral no topo.
- **Filtros:** Fazenda (obrigatório), categoria do animal, sexo.

### 1.2. Composição do Rebanho (categoria, raça, sexo) — P0
- **Objetivo:** distribuição do rebanho por categoria (bezerro, novilha, boi, etc.), raça e sexo —
  usado para planejamento de venda e de manejo.
- **Fonte:** `Animais.categoria`, `Animais.raca`, `Animais.sexo` (agregações `GROUP BY`).
- **Visualização:** gráfico de pizza/barras (categoria x quantidade) + tabela detalhada.

### 1.3. Ficha/Rastreabilidade Individual do Animal — P0
- **Objetivo:** histórico completo de um animal específico (busca por `brinco`) — é o relatório mais
  citado no domínio (`Ubiquitous Language`: *"Brinco é a principal chave de busca no campo"*), e é
  pré-requisito de rastreabilidade sanitária citado em `10_Execution_Planning.md`.
- **Fonte:** `Animais` (dados cadastrais) + `Pesagens` (linha do tempo de peso/GMD) +
  `AplicacoesSanitarias` (linha do tempo sanitária, incluindo carência) + (após o Passo 3 do
  documento de funcionalidades) `OcorrenciasSanitarias`.
- **Visualização:** uma tela única tipo "timeline" combinando pesagens e aplicações em ordem
  cronológica, com destaque em vermelho se o animal estiver em carência hoje.
- **Observação:** este já é essencialmente o que `animal_detail_view.dart` mostra hoje — vale
  reaproveitar a tela existente e só adicionar a exportação/impressão se for necessário formalmente
  para fiscalização (rastreabilidade costuma ser exigida em auditorias do setor).

### 1.4. Reprodução — Partos Previstos e Realizados — P1
- **Objetivo:** a tabela `Animais` já guarda `prenha`, `dataCobertura`, `dataPartoPrevisto`,
  `dataParto`, `qtdFilhotes`, `qtdFilhotesVivos` — dado coletado hoje só pela tela de cadastro do
  animal (`animal_form_view.dart`), sem nenhum relatório consolidado. Isso é uma "funcionalidade
  órfã" no mesmo espírito do que aconteceu com Nutrição.
- **Fonte:** `Animais` filtrando `sexo = 'F'`.
- **Visualização:**
  - Lista de fêmeas com `dataPartoPrevisto` nos próximos N dias (configurável, ex.: 30 dias) —
    "agenda de partos".
  - Indicador de taxa de sobrevivência de filhotes: `SUM(qtdFilhotesVivos) / SUM(qtdFilhotes)` no
    período.
- **Pronto quando:** dá para ver, sem abrir animal por animal, quais fêmeas devem parir no próximo
  mês.

### 1.5. Movimentação entre Lotes/Piquetes — P2
- **Objetivo:** histórico de quando um animal mudou de lote (hoje o dado atual é sobrescrito — não
  existe histórico de mudança de `loteId`). Requer decisão de produto: vale a pena guardar histórico
  de movimentação, ou o Ubiquitous Language trata isso como evento não-crítico? Marcado como P2
  porque, ao contrário dos outros, **exige mudança de schema** (uma tabela `HistoricoMovimentacao`)
  antes de existir dado para reportar.

---

## 2. Relatórios de Evolução Zootécnica

### 2.1. GMD Consolidado por Lote — P0
- **Objetivo:** hoje o GMD só existe por animal individual (`pesagem_service.dart`,
  `watchHistoricoComGMD`). Não existe uma visão agregada por lote, que é como o gestor realmente
  decide (ex.: "o lote X está engordando bem, o lote Y não").
- **Fonte:** `Pesagens` join `Animais` (por `loteId`), calculando GMD médio do lote no período.
- **Visualização:** gráfico de linha (eixo X = data, eixo Y = peso médio do lote) + tabela com GMD
  médio por lote no período selecionado, ordenável (para achar rápido o lote com pior desempenho).

### 2.2. Curva de Crescimento Individual — P1
- **Objetivo:** gráfico de peso ao longo do tempo de um animal específico — complementa o item 1.3.
- **Fonte:** `Pesagens` de um `animalId`.
- **Visualização:** gráfico de linha simples, reaproveitando o widget de gráfico do item 2.1.

---

## 3. Relatórios de Saúde Animal

### 3.1. Animais em Período de Carência (hoje) — P0
- **Objetivo:** é o relatório operacional mais crítico do domínio Core (`02_Domain_Discovery.md`
  chama Sanidade de "core domain") — evita vender/abater animal fora de conformidade.
- **Fonte:** `AplicacoesSanitarias` onde `carenciaFimCalculada > now()`, join `Animais`/`Lotes` para
  mostrar brinco e localização.
- **Visualização:** lista simples, ordenada por data de liberação (quem libera primeiro aparece no
  topo), com contagem total em destaque na tela inicial (ex.: badge "12 animais em carência" —
  reaproveitando o padrão visual já usado para "conflitos de sincronização" no `home_view.dart`).
- **Observação:** este relatório também resolve o gap "bloquear/alertar visualmente" citado no Passo
  3 do documento de funcionalidades — pode, inclusive, ser a mesma fonte de dados usada para o
  alerta pontual na hora de pesar/vender um animal.

### 3.2. Histórico Sanitário por Produto — P1
- **Objetivo:** "quanto e onde eu apliquei de cada produto" — importante para auditoria e para
  detectar uso fora do padrão (ex.: mesmo produto aplicado duas vezes no mesmo animal em intervalo
  muito curto).
- **Fonte:** `AplicacoesSanitarias` agrupado por `produtoId` (join `Produtos.nome`).
- **Visualização:** tabela com total de doses aplicadas por produto no período, e lista expansível
  com os animais/lotes que receberam.

### 3.3. Ocorrências Sanitárias (mortalidade e doenças) — P1 *(depende do Passo 3 do doc anterior)*
- **Objetivo:** taxa de mortalidade e doenças mais frequentes — indicador de saúde geral do rebanho.
- **Fonte:** `OcorrenciasSanitarias` (tabela ainda a ser criada — ver Passo 3 de
  `Analise_Funcionalidades_Modulos_Negocio.md`).
- **Visualização:** taxa de mortalidade no período (`óbitos / efetivo médio`) + ranking de tipos de
  ocorrência mais registrados.
- **Dependência:** só pode ser construído depois que a tabela de ocorrências existir — hoje esse
  dado simplesmente não é coletado em lugar nenhum.

---

## 4. Relatórios de Nutrição

### 4.1. Consumo de Ração/Dieta por Lote — P0
- **Objetivo:** total consumido por lote no período — insumo básico para custo de produção.
- **Fonte:** `FornecimentosDieta` agrupado por `loteId`, join `Dietas.produtoId` → `Produtos.nome`.
- **Visualização:** tabela (lote x produto x quantidade total no período).

### 4.2. Divergência Planejado vs. Fornecido — P0 *(depende do Passo 2 do doc anterior)*
- **Objetivo:** exatamente o que o `03_Capability_Discovery.md` pede: alerta de divergência >15%.
- **Fonte:** o mesmo cálculo do Passo 2 (planejado = `quantidadePorCabecaDia × cabeças do lote`),
  consolidado por período em vez de por lançamento individual.
- **Visualização:** lista de dias/lotes com divergência acima do limite, ordenada da pior para a
  melhor.
- **Dependência:** o cálculo de divergência (Passo 2 do doc de funcionalidades) precisa existir
  antes — este relatório é, na prática, a consolidação histórica daquele alerta pontual.

---

## 5. Relatórios de Estoque

### 5.1. Saldo Atual Consolidado — P0
- **Objetivo:** visão geral de tudo que tem em estoque, sem precisar abrir produto por produto.
- **Fonte:** reaproveita `EstoqueService._calcularSaldo` já existente, mas exibindo todos os
  produtos numa única tela/exportação em vez da lista paginada atual.
- **Visualização:** tabela (produto, saldo atual, estoque mínimo, situação — ok/baixo).

### 5.2. Movimentação de Estoque (Kardex) — P0
- **Objetivo:** rastrear entradas e saídas de um produto específico ao longo do tempo — pergunta
  clássica de auditoria: "por que meu estoque de vacina X está baixo?".
- **Fonte:** `EstoqueMovimentos` de um `produtoId`, ordenado por `dataMovimento`, mostrando `origem`
  (compra, aplicação, fornecimento_dieta) para explicar cada saída.
- **Visualização:** tabela cronológica com saldo corrente calculado linha a linha (estilo extrato
  bancário).

### 5.3. Consumo por Origem (Saúde x Nutrição) — P1
- **Objetivo:** "quanto do meu estoque foi consumido por vacina vs. por ração" — ajuda a entender
  custo por módulo.
- **Fonte:** `EstoqueMovimentos.origem` agregado (`aplicacao` vs `fornecimento_dieta` vs `compra`).
- **Visualização:** gráfico de pizza simples.

### 5.4. Produtos Próximos ao Vencimento — P1 *(depende do Passo 4 do doc anterior)*
- **Objetivo:** mesmo dado do alerta pontual do Passo 4, mas como lista consolidada revisável
  periodicamente (ex.: toda segunda-feira o gestor olha esse relatório).
- **Dependência:** precisa do campo `dataValidade` em `EstoqueMovimentos`, que ainda não existe.

---

## 6. Relatórios Financeiros *(dependem do módulo Financeiro — Passo 5 do doc anterior)*

### 6.1. Fluxo de Caixa Simplificado — P0 (assim que o módulo existir)
- **Fonte:** `LancamentosFinanceiros` (tabela a criar), agrupado por mês, `tipo` (pagar/receber) e
  `status`.
- **Visualização:** total a pagar, total a receber, e saldo projetado do período.

### 6.2. Contas em Atraso — P0 (assim que o módulo existir)
- **Fonte:** `LancamentosFinanceiros` onde `dataVencimento < hoje` e `status != 'pago'`.
- **Visualização:** lista simples, ordenada pelas mais antigas primeiro.

> Nenhum dos dois relatórios desta seção pode ser construído antes do Passo 5 do documento anterior
> (criação do módulo Financeiro) — estão aqui apenas para já deixar a especificação pronta, evitando
> retrabalho de design quando a base existir.

---

## 7. Relatório Operacional (Sync)

### 7.1. Status de Sincronização — P1
- **Objetivo:** já existe uma tela de conflitos (`sync_conflict_view.dart`), mas não uma visão
  simples de "quantos registros estão pendentes de envio, há quanto tempo, e quando foi a última
  sincronização bem-sucedida" — útil para o operador de campo confiar que o app está funcionando.
- **Fonte:** `SyncQueueItems` (contagem por status/tempo de espera) + `lastSyncAt` já salvo em
  `SharedPreferences` pelo `SyncService`.
- **Visualização:** um pequeno painel (não precisa ser uma tela cheia) com "Última sincronização:
  há 2h", "8 itens pendentes de envio".

---

## 8. Priorização consolidada (para o Antigravity executar em ondas)

```
🟢 Onda 1 — dados já existem hoje, zero dependência de outros módulos:
  1.1 Efetivo do Rebanho
  1.2 Composição do Rebanho
  1.3 Ficha/Rastreabilidade Individual (reaproveita animal_detail_view)
  2.1 GMD Consolidado por Lote
  3.1 Animais em Período de Carência        ← maior valor de negócio da Onda 1
  4.1 Consumo de Ração/Dieta por Lote
  5.1 Saldo Atual Consolidado
  5.2 Movimentação de Estoque (Kardex)
  7.1 Status de Sincronização

🟡 Onda 2 — dado já existe, mas coletado/exibido de forma nova:
  1.4 Partos Previstos e Realizados (dado órfão, igual ao caso da Nutrição)
  2.2 Curva de Crescimento Individual
  3.2 Histórico Sanitário por Produto
  5.3 Consumo por Origem

🔴 Onda 3 — depende de gaps do documento anterior serem fechados primeiro:
  3.3 Ocorrências Sanitárias        → depende do Passo 3 (tabela OcorrenciasSanitarias)
  4.2 Divergência Planejado x Fornecido → depende do Passo 2 (cálculo de divergência)
  5.4 Produtos Próximos ao Vencimento   → depende do Passo 4 (campo dataValidade)
  6.1 / 6.2 Financeiro                  → depende do Passo 5 (módulo Financeiro inteiro)
```

> Sugestão de entrega: construir a `relatorios_hub_view.dart` já na Onda 1, com abas/categorias
> (Rebanho, Saúde, Nutrição, Estoque, Sync) e ir plugando os relatórios das ondas seguintes nas
> mesmas abas — assim o usuário já ganha uma tela nova utilizável desde o primeiro incremento, em
> vez de esperar o módulo inteiro para ver qualquer resultado.
