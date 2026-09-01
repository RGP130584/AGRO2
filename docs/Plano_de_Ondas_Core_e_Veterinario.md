# Plano de Ondas — Próximos Passos do AGRO (Core + Módulo Veterinário)

> Consolida: (1) o que ainda resta do backlog Core validado nas rodadas anteriores, e (2) a proposta
> de `AGRO_Modulo_Veterinario_Analise.docx` / `AGRO_Modulo_Veterinario_Roadmap.md`, resequenciada com
> o pré-requisito técnico identificado na análise desses documentos: **o backend hoje não tem schema
> de domínio, só um blob genérico de sincronização** — isso precisa ser resolvido antes de qualquer
> consulta cross-fazenda para o veterinário funcionar.

---

## 🟢 Onda 0 — Fechar o Core (o que ainda não foi confirmado como concluído)

Antes de abrir a frente Veterinário, vale checar se isto já não foi feito nas últimas atualizações
(parte pode já estar pronta — confirmar contra o código antes de iniciar):

| # | Item | Origem |
|---|---|---|
| 0.1 | Atualizar `06_Current_State.md`/`07_Gap_Discovery.md` para refletir Financeiro/Relatórios/Equipe | Wave 3 |
| 0.2 | Garantir que `/v1/users` e o fluxo de convite estão 100% cobertos por teste de regressão de isolamento (já existe `rbac.test.js` — só manter atualizado a cada mudança de schema) | Wave 3 |

Se ambos já estiverem confirmados, pular direto para a Onda 1.

---

## 🔴 Onda 1 — Pré-requisito técnico: Schema de Domínio no Backend

**Este é o passo que os documentos do Módulo Veterinário não detalham, mas que bloqueia tudo o
que vem depois.** Hoje `/v1/sync` só grava um blob opaco:

```sql
entities (server_id, owner_id, entity_id, entity_type, payload TEXT, device_id, ...)
```

O servidor nunca sabe o que tem dentro do `payload`. Isso é suficiente para sincronizar um app móvel
sozinho, mas é **insuficiente** para qualquer consulta cross-fazenda (ex.: veterinário vendo
"animais em carência" de 12 clientes ao mesmo tempo).

1.1. Escolher a estratégia: (a) **projeção/materialização** — ao receber cada `entity` no `/v1/sync`,
   além de gravar o blob (mantém compatibilidade com o app atual), gravar também os campos
   relevantes em tabelas reais (`animais`, `saude_aplicacoes`, `saude_ocorrencias`, `pesagens`,
   `nutricao_fornecimentos`, `financeiro_lancamentos`) — ou (b) migrar de vez o backend para ser a
   fonte de verdade relacional e o app passa a sincronizar contra essas tabelas diretamente. **(a) é
   mais seguro e incremental — recomendado como primeiro passo.**
1.2. Migrar o backend de SQLite para PostgreSQL (citado na seção 15 do roadmap) — SQLite não tem os
   recursos de indexação/JSON/particionamento necessários para consultas agregadas entre múltiplos
   tenants em produção.
1.3. Criar um mapa explícito de `entityType → tabela/colunas de projeção` (evita SQL dinâmico não
   whitelisted, seguindo o mesmo cuidado já aplicado no `SyncService` do app).
1.4. Escrever um endpoint interno de consistência (`/v1/admin/reconcile`) que reprocessa o histórico
   de `entities` e reconstrói as projeções — útil tanto para migração inicial quanto para recuperação
   de bugs futuros de projeção.

**Pronto quando:** existe uma tabela `animais` real no Postgres, populada a partir da sincronização
normal do app, sem exigir nenhuma mudança no app Flutter existente.

---

## 🟠 Onda 2 — Modularização do Backend

**Objetivo:** o `app.js` de hoje é um arquivo único (~350 linhas, tudo inline). Adicionar 15+ novos
domínios do Veterinary (Prontuário, Protocolos, Visitas, Laudos, etc.) sobre esse arquivo o tornaria
insustentável.

2.1. Separar em módulos: `routes/auth.js`, `routes/sync.js`, `routes/users.js`,
   `middlewares/authenticate.js`, `middlewares/requireRole.js`, `db/schema.js`,
   `services/*.js` — sem mudar comportamento, só reorganizar (refactor puro, coberto pelos testes
   já existentes).
2.2. Introduzir uma camada de acesso a dados (repository pattern simples) para isolar SQL cru dos
   handlers de rota — facilita a Onda 1 (projeções) e a Onda 4 (Sharing Grant) não colidirem.

**Pronto quando:** a suíte de testes atual (`npm test`) continua passando 100% após a reorganização,
sem nenhuma mudança de comportamento.

---

## 🟠 Onda 3 — Observability e Audit Trail

**Objetivo:** pré-requisito de segurança tanto para o Core quanto para o Veterinário (seção 11 do
`.docx`: "audit trail" é item obrigatório).

3.1. Criar tabela `audit_events` (`id, actor_user_id, actor_conta_id, action, entity_type,
   entity_id, metadata JSON, created_at`) — registra login, convite/revogação de equipe, alteração
   de perfil, e (mais à frente) toda intervenção veterinária.
3.2. Logar automaticamente os eventos já existentes (login, invite, password-reset) nesta tabela.
3.3. Adicionar logging estruturado básico (nível de request/erro) — não existe hoje além do
   `console.log`.

**Pronto quando:** é possível responder "quem convidou este funcionário, e quando" consultando uma
tabela, não vasculhando logs manualmente.

---

## 🟡 Onda 4 — Entitlements e Subscription (mínimo viável)

**Objetivo:** pré-requisito comercial para vender o módulo Veterinário como plano separado (seção 6
do `.docx`).

4.1. Criar tabelas `plans` (nome, entitlements inclusos) e `subscriptions` (conta_id, plan_id,
   status, vigência) — sem gateway de pagamento ainda, só o suficiente para gatear funcionalidade.
4.2. Criar tabela `entitlements` simples por conta (`VET_PORTAL`, `VET_CLIENTS`, etc., conforme
   seção 6 do roadmap) e um middleware `requireEntitlement(nome)` no mesmo padrão do `requireRole`
   já existente.
4.3. Deixar todo o resto do sistema (Rebanho, Saúde, Nutrição, Estoque, Financeiro atuais) marcado
   como entitlement `CORE` — sempre ativo — para não quebrar nada hoje.

**Pronto quando:** é possível marcar uma conta como "sem `VET_PORTAL`" e o backend nega acesso às
rotas do Veterinário para ela, sem afetar o uso normal do app.

---

## 🔴 Onda 5 — Fase 1 do Roadmap Veterinário: Sharing Grant (núcleo do produto novo)

**Objetivo:** a entidade central de todo o módulo — construir sobre o `conta_id` já validado nas
waves anteriores, generalizando o padrão "convite" (`/v1/users/invite`) que já existe para equipe.

5.1. Criar tabela `veterinarians` (identidade profissional própria — nome, CRMV, contato — distinta
   de `usuarios`, já que um veterinário pode atender várias contas/fazendas, diferente do modelo
   atual de `funcionario`, que pertence a uma única `conta_id`).
5.2. Criar tabela `sharing_grants`:
   ```sql
   sharing_grants (
     id, tenant_conta_id, veterinarian_id, scope_type, scope_id,
     permissions TEXT, -- JSON: ['consulta','tecnico','intervencao','administrativo']
     granted_by, created_at, expires_at, revoked_at, status, audit_reference
   )
   ```
   `scope_type`/`scope_id` cobrem fazenda, lote ou animal — não usar `conta_id` fixo como no modelo
   de equipe atual.
5.3. Fluxo de convite: produtor busca/convida veterinário (por CPF/CRMV ou e-mail) →
   `POST /v1/vet/grants` (cria grant `status: pending`) → veterinário aceita
   (`POST /v1/vet/grants/:id/accept`) → grant vira `status: active`.
5.4. **Consentimento LGPD explícito no aceite** — o veterinário, ao aceitar, concorda com termos de
   tratamento de dados de terceiro (registrar isso no `audit_events` da Onda 3, com versão do termo
   aceito).
5.5. Endpoint de revogação (`DELETE /v1/vet/grants/:id`), aplicando as regras da seção 9 do `.docx`:
   bloquear novas sincronizações daquele vínculo imediatamente; invalidar sessões do veterinário
   ligadas a esse grant (reaproveitar o `token_version` já existente, mas por grant, não só por
   usuário); manter histórico produzido, intacto e consultável em modo somente-leitura.
5.6. Middleware `authorizeGrant(scopeType, permissionMinima)` que verifica, para requisições do
   veterinário, se existe um `sharing_grant` ativo e não expirado cobrindo o escopo solicitado.
5.7. `/v1/sync` do veterinário usa a mesma lógica de `owner_id` já existente, mas resolvida via
   grants ativos em vez de `conta_id` fixo — um veterinário pode ter `owner_id` efetivo variável por
   requisição, conforme a fazenda que está acessando no momento.

**Pronto quando:** um veterinário convidado consegue ver os dados de uma fazenda específica só
enquanto o grant estiver ativo, e perde o acesso imediatamente após a revogação — validado com o
mesmo padrão de teste usado em `sync_isolation.test.js`/`rbac.test.js` (Fazenda A convida, Fazenda B
não deveria aparecer nunca para o mesmo veterinário sem grant próprio).

---

## 🟡 Onda 6 — Fase 2 do Roadmap: Portal Veterinário (consumidor das Ondas 1 e 5)

6.1. Definir se o portal é um novo cliente (web) ou uma variação de perfil dentro do mesmo app
   Flutter — decisão de produto que impacta esforço; um portal web é o mais alinhado ao caso de uso
   ("veterinário no escritório vendo 12 fazendas"), mas exige um front-end novo.
6.2. Dashboard consolidado: usa as tabelas projetadas da Onda 1 para listar, entre todas as fazendas
   com grant ativo, animais em carência, divergências nutricionais e alertas de estoque — os mesmos
   relatórios já construídos no Core (`Modulo_Relatorios_Especificacao.md`), agora agregados
   cross-tenant.
6.3. Agenda/alertas básicos (visitas futuras, retornos pendentes).

**Pronto quando:** o veterinário loga uma vez e vê um resumo de todas as fazendas sob grant ativo,
sem precisar entrar fazenda por fazenda.

---

## 🟡 Onda 7 — Fase 3 do Roadmap: Saúde Avançada (Prontuário e Protocolos)

7.1. Modelar intervenções como eventos versionados (seção 8 do `.docx`) — nova tabela
   `intervencoes_veterinarias` (append-only, nunca update): `animal_id, veterinario_id, grant_id,
   tipo (avaliacao/prescricao/aplicacao/retorno), payload, created_at` — reaproveita o padrão de
   soft-delete/append já usado em `AplicacoesSanitarias`/`OcorrenciasSanitarias`, mas sem permitir
   edição retroativa.
7.2. Vincular ao módulo de Saúde já existente no Core — uma intervenção veterinária pode gerar uma
   `AplicacoesSanitarias` normal (o produtor continua vendo no seu app como sempre viu), mas com
   `autor = veterinario_id` e link para a intervenção de origem.
7.3. Regra de conflito entre profissionais (gap de requisito identificado na análise): decidir e
   documentar o que acontece quando dois veterinários com grant ativo registram intervenções
   conflitantes no mesmo animal — sugestão mínima: ambas ficam registradas (é histórico, não dado
   mutável), e o app avisa visualmente quando há mais de um profissional ativo no mesmo animal.

---

## 🔵 Onda 8 — Fase 4 do Roadmap: Nutrição Avançada

8.1. Recomendação nutricional do veterinário como registro vinculado à `Dieta` já existente no Core
   (mesma lógica de autoria da Onda 7), com comparação de resultado ao longo do tempo.

## 🔵 Onda 9 — Fase 5 do Roadmap: Operação Profissional

9.1. Visitas, ordens de serviço, laudos, documentos, cobrança — módulo mais próximo de um ERP
   veterinário do que do domínio atual do AGRO; tratar como sub-produto dentro do bounded context
   Veterinary, sem tocar nas tabelas do Core.

## 🔵 Onda 10 — Fase 6 do Roadmap: Inteligência

10.1. Alertas preditivos e apoio à decisão — só depois de Ondas 1, 5 e 7 estarem maduras e com
   volume de dados real; IA aqui deve consumir as tabelas relacionais da Onda 1, não os blobs JSON.

---

## Ordem de execução e dependências

```
Onda 0 (confirmar Core)
   │
   ▼
Onda 1 (schema de domínio no backend) ──┐
   │                                     │
   ▼                                     │
Onda 2 (modularizar backend)             │
   │                                     │
   ▼                                     │
Onda 3 (audit trail) ────────────────────┤
   │                                     │
   ▼                                     ▼
Onda 4 (entitlements/subscription)   Onda 5 (Sharing Grant) ──┐
                                          │                    │
                                          ▼                    │
                                     Onda 6 (Portal Vet)        │
                                          │                    │
                                          ▼                    │
                                     Onda 7 (Saúde Avançada) ◄─┘
                                          │
                                          ▼
                                     Onda 8 (Nutrição Avançada)
                                          │
                                          ▼
                                     Onda 9 (Operação Profissional)
                                          │
                                          ▼
                                     Onda 10 (Inteligência)
```

**Ondas 1, 2 e 3 podem ser feitas em paralelo entre si** (nenhuma bloqueia a outra tecnicamente),
mas todas devem terminar antes da Onda 5, porque o Sharing Grant precisa de auditoria (3) e de dados
projetados no backend (1) para valer a pena. A Onda 4 (comercial) pode esperar até logo antes do
lançamento da Fase 1 para o mercado — não bloqueia o desenvolvimento técnico das ondas seguintes.

> Recomendação de foco imediato: **Onda 0 → Onda 1**. É o maior risco técnico não mencionado nos
> documentos originais, e quanto antes for resolvido, menos retrabalho as ondas seguintes vão exigir.
