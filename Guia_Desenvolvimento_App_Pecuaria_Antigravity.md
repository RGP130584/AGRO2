# Guia de Desenvolvimento — App Mobile de Gestão Pecuária (V1)
### Passo a passo para execução no Antigravity

> Base: `Manual_Escopo_Requisitos_App_Pecuaria_V1.docx` (escopo, RF e RNF já aprovados).
> Este guia traduz o manual em **tarefas sequenciais e executáveis**, para que o agente
> implemente o app em etapas curtas, verificáveis e sem perda de contexto.

---

## 0. Como usar este guia

- Siga os **Passos na ordem**. Cada passo tem: objetivo, entregável e critério de "pronto".
- Não avance para o próximo passo sem o critério de "pronto" satisfeito.
- Sempre que o passo envolver dados, **teste em modo avião** antes de marcar como concluído
  (é um app offline-first — se não funciona sem internet, não está pronto).
- Prompts sugeridos para o Antigravity estão em blocos `> Prompt:`.

---

## [x] Passo 1 — Configuração do projeto base

**Objetivo:** criar o esqueleto do app multiplataforma.

1.1. Criar projeto PWA em React 19 + Vite + Dexie.js (`agro2`) para operação offline-first multiplataforma (Web, Android, iOS, Windows).
1.2. Estrutura de pastas da aplicação `agro2`:

```
agro2/
  src/
    components/     # UI, modais, layout, onboarding, badge de carência
    contexts/       # AuthContext e SyncContext (sincronização offline)
    db/             # Schema Dexie (Agro2DB - IndexedDB local) e seed
    pages/          # Módulos (Rebanho, Saúde, Nutrição, Pesagem, Estoque, Financeiro, Relatórios, Sync)
    utils/          # Helpers de carência, GMD, datas e imagem
  public/           # sw.js (Service Worker), manifest.webmanifest e favicons
```

1.3. Dependências base: `dexie`, `react`, `react-dom`, `@vitejs/plugin-react`, `lucide-react`, `canvas-confetti`.

> Prompt: "Crie a aplicação PWA em React 19 com Vite e Dexie.js como banco local IndexedDB. Estruture a pasta agro2 com a arquitetura offline-first."

**Pronto quando:** a aplicação PWA compila, roda no navegador e permite instalação offline.

---

## [x] Passo 2 — Modelagem do banco local (offline-first)

**Objetivo:** definir o schema local que sustenta TODOS os módulos da V1 sem depender de rede.

2.1. Criar tabelas locais (todas com os campos técnicos de sincronização abaixo, em **todas** as tabelas de negócio):

```
id (uuid local)
server_id (nullable até sincronizar)
created_at
updated_at
deleted_at (soft delete)
device_id
sync_status (pending | synced | conflict)
```

2.2. Tabelas de domínio (V1 — pecuária):

- `fazendas`
- `piquetes` (fazenda_id, nome, lat, lng nullable)
- `lotes` (fazenda_id, piquete_id, categoria, quantidade)
- `animais` (lote_id, brinco, categoria, raca, data_nascimento)
- `produtos` (tipo: medicamento | vacina | racao | suplemento, nome, carencia_dias_padrao, unidade)
- `aplicacoes_sanitarias` (animal_id ou lote_id, produto_id, data, dose, via, motivo, responsavel_id, carencia_fim_calculada)
- `dietas` (lote_id ou categoria, produto_id, quantidade_por_cabeca_dia)
- `fornecimentos_dieta` (lote_id, dieta_id, data, quantidade_fornecida, responsavel_id)
- `pesagens` (animal_id ou lote_id, data, peso, responsavel_id)
- `estoque_movimentos` (produto_id, tipo: entrada|saida, quantidade, data, origem: manual|aplicacao|dieta)
- `financeiro_lancamentos` (tipo: pagar|receber, descricao, valor, vencimento, data_pagamento nullable)
- `usuarios` (nome, perfil: proprietario|gerente|colaborador)
- `log_auditoria` (usuario_id, entidade, entidade_id, acao, data, device_id)

2.3. Criar índices para busca rápida por `brinco` (animal) e por `lote_id` (uso mais frequente em campo).

> Prompt: "Implemente o schema acima usando drift, incluindo os campos de sincronização em todas as tabelas de negócio e os índices de busca por brinco e lote_id. Gere as migrations iniciais."

**Pronto quando:** banco local é criado no primeiro boot do app, sem internet, e aceita inserts/reads via testes unitários simples para cada tabela.

---

## [x] Passo 3 — Módulo de Cadastro do Rebanho (RF-010 a RF-016)

**Objetivo:** primeira tela funcional real, que já valida o padrão de CRUD offline usado em todos os módulos seguintes.

3.1. Tela de listagem de Fazendas → Piquetes → Lotes → Animais (navegação em drill-down).
3.2. Formulário de cadastro de Animal: brinco, categoria, raça, data de nascimento, lote (seleção, não digitação livre).
3.3. Formulário de cadastro de Lote: categoria, piquete, quantidade estimada.
3.4. Marcação de piquete no mapa por ponto (pin), com cache do mapa para uso offline (RF-015). Se o mapa não estiver disponível offline nesta fase, implementar como **stub** (campo de coordenadas manual) e marcar como débito técnico — não travar o passo por causa disso.
3.5. Toda gravação passa a marcar `sync_status = pending` e entra na fila de sincronização (ver Passo 8).

> Prompt: "Implemente as telas de Cadastro do Rebanho (fazendas, piquetes, lotes, animais) com formulários curtos (RF-010 a RF-014), seguindo os princípios de UX do Passo 7: botões grandes, seleção em vez de digitação livre, poucos campos por tela."

**Pronto quando:** é possível cadastrar fazenda → piquete → lote → animal em modo avião, fechar o app, reabrir e os dados continuam lá.

---

## [x] Passo 4 — Módulo de Saúde Animal (RF-020 a RF-028) — prioridade máxima

**Objetivo:** núcleo de valor da V1. Implementar com o máximo de rigor de UX e de regra de carência.

4.1. Tela "Registrar Aplicação": selecionar animal (busca por brinco) OU lote inteiro → selecionar produto (vacina/medicamento) → dose → data (padrão: hoje) → responsável (usuário logado, editável) → salvar.
4.2. Ao salvar, calcular automaticamente `carencia_fim = data_aplicacao + produto.carencia_dias_padrao` (RF-023).
4.3. Selo visual de carência ativa em qualquer tela que liste o animal/lote (vermelho = carência ativa, cinza = sem carência) — RF-024. Este selo deve funcionar 100% offline, calculado localmente.
4.4. Tela de histórico sanitário do animal/lote (linha do tempo simples, mais recente primeiro) — RF-028.
4.5. Registro de ocorrência sanitária (doença, óbito, descarte) como tipo separado de lançamento, vinculado ao animal — RF-026.
4.6. Anexo de foto (câmera do dispositivo) salva localmente (path do arquivo), sincronizada depois — RF-027.
4.7. Alerta de reaplicação programada (ex.: segunda dose) — RF-025: campo opcional no produto/protocolo `intervalo_reaplicacao_dias`; se preenchido, gerar um lembrete local.

> Prompt: "Implemente o módulo de Saúde Animal completo (RF-020 a RF-028): registrar aplicação de vacina/medicamento em animal ou lote, cálculo automático de carência, selo visual de carência ativa em todas as listagens, histórico sanitário e anexo de foto. Priorize que tudo funcione 100% offline."

**Pronto quando:**
- Registrar uma vacina em um lote inteiro offline gera um lançamento por animal do lote (ou um lançamento coletivo, a decidir na implementação, mas sempre rastreável por animal).
- O selo de carência aparece corretamente sem internet.
- Fechar e reabrir o app mantém tudo.

---

## [x] Passo 5 — Módulo de Nutrição e Dieta (RF-030 a RF-034)

**Objetivo:** segundo módulo de maior valor da V1.

5.1. Cadastro de Dieta: vincular a um lote ou categoria, produto (ração/suplemento), quantidade por cabeça/dia.
5.2. Tela "Registrar Fornecimento do Dia": selecionar lote → dieta pré-carregada (se existir) → confirmar ou ajustar quantidade fornecida → salvar.
5.3. Baixa automática no estoque a partir do fornecimento registrado (RF-031) — integrar com o Passo 6.
5.4. Indicador simples (ok / atenção) quando o fornecido divergir do planejado (RF-033) — regra inicial sugerida: variação > 15% do planejado dispara "atenção".
5.5. Histórico de dietas por lote (RF-034).

> Prompt: "Implemente o módulo de Nutrição e Dieta (RF-030 a RF-034), incluindo a baixa automática no estoque ao registrar fornecimento e o indicador de divergência entre planejado e fornecido."

**Pronto quando:** registrar o fornecimento diário de um lote, offline, reduz corretamente o saldo de estoque do produto correspondente após a gravação local (sem precisar sincronizar).

---

## [x] Passo 6 — Módulo de Estoque (RF-050 a RF-054)

**Objetivo:** sustentar as baixas automáticas dos Passos 4 e 5 e permitir lançamentos manuais.

6.1. Tela de estoque por produto: saldo atual, mínimo definido, validade.
6.2. Registro manual de entrada (compra) e saída (ajuste manual).
6.3. Baixa automática vinda de `aplicacoes_sanitarias` e `fornecimentos_dieta` (via triggers/regra de aplicação no repositório, não na UI).
6.4. Alertas: estoque abaixo do mínimo (RF-053) e validade próxima (RF-054), calculados localmente.

> Prompt: "Implemente o módulo de Estoque (RF-050 a RF-054) garantindo que as baixas automáticas dos módulos de Saúde Animal e Dieta sejam feitas na camada de repositório, não duplicadas na UI, e que os alertas de mínimo e validade funcionem offline."

**Pronto quando:** o saldo de estoque reflete corretamente entradas manuais + baixas automáticas, mesmo com o app inteiro operando offline por vários dias.

---

## [x] Passo 7 — Módulo de Pesagem, Financeiro básico, Relatórios e Configurações

**Objetivo:** completar os módulos de apoio da V1 (menor complexidade relativa).

7.1. **Pesagem** (RF-040 a RF-043): registro de peso por animal/lote, cálculo de GMD entre duas pesagens, lista/gráfico simples de evolução.
7.2. **Financeiro básico** (RF-060 a RF-063): contas a pagar/receber, marcação de pago/recebido, alerta de vencimento.
7.3. **Relatórios** (RF-070 a RF-075): rastreabilidade sanitária por animal/lote, histórico de dietas, desempenho de peso, custo simples por lote. Exportação em PDF/Excel apenas quando online; geração do relatório em si sempre a partir dos dados locais.
7.4. **Configurações** (RF-080 a RF-083): usuários e perfis (proprietário/veterinário, gerente, colaborador), preferências de sincronização (Wi-Fi apenas ou também dados móveis), log de auditoria.

> Prompt: "Implemente os módulos de Pesagem, Financeiro básico, Relatórios e Configurações conforme RF-040 a RF-083, reaproveitando os componentes de lista/formulário já criados nos módulos anteriores para manter consistência visual."

**Pronto quando:** todos os RF listados no manual para estes módulos têm uma tela correspondente navegável a partir do menu principal.

---

## [x] Passo 8 — Motor de Sincronização Offline (RF-090 a RF-096) — passo crítico

**Objetivo:** implementar a "fila outbox" e as regras de conflito que protegem os dados de campo.

8.1. Toda escrita de negócio (Passos 3 a 7) grava localmente **e** insere um evento na tabela `fila_sincronizacao` (entidade, entidade_id, ação: create/update/delete, payload, criado_em).
8.2. Serviço de sincronização (`SyncService`):
   - Detecta conectividade (RF-090).
   - Envia eventos pendentes em lotes pequenos, na ordem de criação (RF-091).
   - Ao confirmar recebimento do servidor, atualiza `sync_status = synced` e grava o `server_id` retornado; só então remove o evento da fila.
   - Busca alterações remotas desde o último `last_sync_at` e aplica localmente (RF-092).
8.3. Regra de conflito (RF-093): se um registro local `pending` colide com uma versão remota mais nova do mesmo `server_id`, **não sobrescrever**: manter as duas versões visíveis (ex.: registro local marcado `conflict`) até o usuário responsável (gerente/proprietário) decidir qual prevalece.
8.4. Botão "Sincronizar agora" manual (RF-094), além do gatilho automático.
8.5. Tela de histórico de sincronização (RF-095): lista de execuções com contagem de enviados/recebidos/erros.
8.6. Idempotência: reenviar um evento já processado pelo servidor (em caso de queda no meio do processo) não pode duplicar o registro — usar uma chave de idempotência (o próprio `id` local funciona como chave, desde que o backend a respeite) (RF-096).

> Prompt: "Implemente o SyncService completo conforme RF-090 a RF-096: fila outbox, sincronização incremental por lotes, resolução de conflitos preservando ambas as versões, sincronização manual e histórico de execuções. Escreva testes simulando queda de conexão no meio do processo."

**Pronto quando (testes obrigatórios):**
- Modo avião → cadastrar 1 lote, 3 animais, 2 aplicações sanitárias, 1 dieta → religar internet → tudo aparece no backend sem duplicidade.
- Dois dispositivos alteram o mesmo animal offline → ao sincronizar ambos, nenhum dado se perde; conflito é sinalizado.
- Derrubar a conexão no meio de uma sincronização e tentar novamente não duplica nem corrompe registros.

---

## [x] Passo 9 — Backend mínimo de apoio

**Objetivo:** existir um servidor simples o suficiente para validar a sincronização de ponta a ponta.

9.1. API REST com um endpoint por entidade de negócio, todos aceitando `updated_at`, `deleted_at`, `device_id` no payload.
9.2. Endpoint de sincronização em lote: recebe array de eventos, processa em ordem, retorna `server_id` de cada um + lista de alterações remotas desde `last_sync_at` enviado pelo cliente.
9.3. Autenticação simples via token (RNF-13), com tempo de expiração longo o suficiente para permitir uso offline prolongado.
9.4. Banco de dados do servidor com os mesmos campos técnicos de sincronização das tabelas locais.

> Prompt: "Implemente uma API REST mínima (Node/Express ou similar) com endpoints de sincronização em lote para as entidades do Passo 2, autenticação por token e persistência em banco relacional."

**Pronto quando:** o app consegue sincronizar de ponta a ponta com este backend em ambiente de teste/homologação.

---

## [x] Passo 10 — UX para público de baixa familiaridade digital (transversal)

**Objetivo:** aplicar, em todas as telas já construídas, os princípios de usabilidade do manual — não é uma tela nova, é uma revisão.

10.1. Revisar cada tela criada nos Passos 3 a 7 contra a checklist:
- [ ] No máximo 3–4 toques para a ação mais comum da tela.
- [ ] Botões grandes, ícones + texto curto.
- [ ] Seleção (chips, dropdown) em vez de digitação livre sempre que possível.
- [ ] Cores com significado consistente (vermelho = atenção/carência, amarelo = alerta, verde = ok).
- [ ] Confirmação visual (e, se possível, sonora) ao salvar.
- [ ] Legibilidade a pleno sol (contraste alto) testada manualmente.
10.2. Implementar onboarding visual (poucos slides, sem texto longo) na primeira abertura do app.

> Prompt: "Revise todas as telas implementadas até aqui contra a checklist de UX do Passo 10 e ajuste o que não estiver conforme. Implemente o onboarding inicial."

**Pronto quando:** um usuário sem experiência prévia consegue, sem ajuda, registrar uma aplicação sanitária e um fornecimento de dieta usando apenas o onboarding do app.

---

## [ ] Passo 11 — Testes finais e critérios de aceite do manual

Executar, em sequência, os critérios de aceite definidos no manual de escopo:

- [ ] Vacina em lote inteiro offline → sincroniza corretamente, carência calculada certa.
- [ ] Conflito de dois usuários no mesmo lote/dia → nenhum dado perdido, conflito sinalizado.
- [ ] Usuário leigo registra medicação sem treinamento formal.
- [ ] App funcional após 30 dias sem internet.
- [ ] Animal em carência é sinalizado antes de qualquer nova operação, mesmo sem sincronizar.
- [ ] Nenhuma perda de dado em bateria fraca / fechamento abrupto / queda de conexão durante sync.

**Pronto quando:** todos os itens acima passam manualmente em pelo menos um Android e um iPhone físico.

---

## Ordem recomendada de execução (resumo)

```
1. Setup do projeto
2. Banco local (schema completo)
3. Cadastro do Rebanho
4. Saúde Animal        ← maior prioridade de negócio
5. Nutrição e Dieta     ← maior prioridade de negócio
6. Estoque
7. Pesagem + Financeiro + Relatórios + Configurações
8. Motor de Sincronização ← maior prioridade técnica/risco
9. Backend mínimo
10. Revisão de UX
11. Testes finais de aceite
```

> Observação: os Passos 4, 5 e 8 são os mais críticos do MVP (valor de negócio + risco técnico) e merecem revisão dupla antes de avançar.
