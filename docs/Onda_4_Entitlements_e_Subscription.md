# Onda 4 — Entitlements e Subscription (mínimo viável)

> Pré-requisito comercial para vender o Módulo Veterinário como plano separado (seção 6 do
> `AGRO_Modulo_Veterinario_Analise.docx`). Objetivo desta onda: **gatear funcionalidade por plano**,
> sem ainda integrar nenhum gateway de pagamento — isso fica para uma fase comercial posterior.

---

## [ ] Passo 1 — Tabelas de Plano e Assinatura

1.1. Adicionar ao `db/schema.js`:
   ```sql
   CREATE TABLE IF NOT EXISTS plans (
     id TEXT PRIMARY KEY,
     nome TEXT NOT NULL,
     entitlements TEXT NOT NULL, -- JSON array: ['CORE', 'VET_PORTAL', ...]
     created_at TEXT NOT NULL
   );

   CREATE TABLE IF NOT EXISTS subscriptions (
     id TEXT PRIMARY KEY,
     conta_id TEXT NOT NULL,
     plan_id TEXT NOT NULL,
     status TEXT NOT NULL DEFAULT 'active', -- active | canceled | expired
     starts_at TEXT NOT NULL,
     ends_at TEXT, -- null = sem vencimento definido
     created_at TEXT NOT NULL
   );
   CREATE INDEX IF NOT EXISTS idx_subscriptions_conta ON subscriptions (conta_id, status);
   ```
1.2. Popular um plano `CORE` padrão (`entitlements: ["CORE"]`) na inicialização do schema, e migrar
   toda `conta_id` existente para uma `subscription` `CORE` ativa sem data de expiração — garante que
   nenhuma conta atual perde acesso ao lançar esta onda.

> Prompt: "Crie as tabelas plans e subscriptions no schema.js. Adicione um plano CORE padrão e migre
> todas as contas existentes para uma subscription CORE ativa e sem expiração, para não quebrar
> nenhum usuário atual."

**Pronto quando:** toda conta que já existia antes desta onda continua com acesso total ao app, sem
nenhuma ação manual.

---

## [ ] Passo 2 — Middleware `requireEntitlement`

2.1. Criar `middlewares/requireEntitlement.js`, seguindo o mesmo padrão de `requireRole.js`:
   ```js
   const requireEntitlement = (...entitlementsNecessarios) => async (req, res, next) => {
     const sub = await getAsync(
       `SELECT p.entitlements FROM subscriptions s
        JOIN plans p ON p.id = s.plan_id
        WHERE s.conta_id = ? AND s.status = 'active'
        AND (s.ends_at IS NULL OR s.ends_at > ?)`,
       [req.user.contaId, new Date().toISOString()]
     );
     const entitlements = sub ? JSON.parse(sub.entitlements) : [];
     const temAcesso = entitlementsNecessarios.every(e => entitlements.includes(e));
     if (!temAcesso) {
       return res.status(403).json({ error: 'Plano atual não inclui este recurso' });
     }
     next();
   };
   ```
2.2. Aplicar `requireEntitlement('CORE')` nas rotas de negócio já existentes (`/v1/sync`,
   `/v1/users`) — não deve mudar nada na prática hoje, já que toda conta tem `CORE`, mas prepara o
   terreno para quando existirem planos sem `CORE` completo (ex.: um plano só-veterinário).

> Prompt: "Crie o middleware requireEntitlement no mesmo padrão do requireRole já existente, e
> aplique requireEntitlement('CORE') nas rotas /v1/sync e /v1/users. Isso não deve mudar o
> comportamento atual, já que toda conta existente tem o plano CORE."

**Pronto quando:** os testes existentes (`npm test`) continuam passando 100% após aplicar o
middleware — prova de que o comportamento atual não mudou.

---

## [ ] Passo 3 — Endpoint de consulta do plano atual

3.1. Criar `GET /v1/subscription` (autenticado) retornando o plano e os entitlements ativos da
   conta do usuário logado — necessário para o app decidir o que mostrar/esconder na UI mais tarde
   (ex.: esconder o menu "Veterinário" se a conta não tiver `VET_PORTAL`).

> Prompt: "Crie o endpoint GET /v1/subscription retornando o plano ativo e a lista de entitlements
> da conta autenticada."

**Pronto quando:** o app consegue perguntar "quais recursos esta conta tem direito a usar" com uma
única chamada.

---

**Pronto quando (onda inteira):** é possível criar uma conta de teste sem o entitlement `VET_PORTAL`
e confirmar que uma rota protegida por `requireEntitlement('VET_PORTAL')` retorna `403` para ela —
sem afetar nenhuma conta `CORE` existente.
