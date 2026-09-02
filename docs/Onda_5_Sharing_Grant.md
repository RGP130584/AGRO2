# Onda 5 — Sharing Grant (Núcleo do Módulo Veterinário)

> Fase 1 do roadmap original ("Compartilhamento: convite, aceite, consulta, revogação"). Depende das
> Ondas 1 (schema de domínio), 3 (audit trail) e 4 (entitlements) já estarem prontas. Reaproveita
> diretamente o padrão de convite/`conta_id` já validado no fluxo de "Minha Equipe".

---

## [ ] Passo 1 — Identidade do Veterinário

1.1. Criar tabela `veterinarians`:
   ```sql
   CREATE TABLE IF NOT EXISTS veterinarians (
     id TEXT PRIMARY KEY,
     usuario_id TEXT NOT NULL, -- FK para usuarios.id (login compartilha auth, mas perfil próprio)
     nome TEXT NOT NULL,
     crmv TEXT UNIQUE,
     telefone TEXT,
     criado_em TEXT NOT NULL
   );
   ```
   Um veterinário é um `usuario` com `perfil = 'veterinario'` (novo valor do enum) **mais** um
   registro profissional em `veterinarians` — diferente de `funcionario`, que pertence a uma única
   `conta_id`, o veterinário não tem `conta_id` fixo: ele acumula acesso via grants a várias contas.
1.2. Ajustar `authenticate.js`/JWT para não embutir mais um `contaId` fixo no token do veterinário —
   o `owner_id` efetivo passa a ser resolvido por requisição, conforme o Passo 4.

> Prompt: "Crie a tabela veterinarians e o perfil 'veterinario' no enum de perfil de usuarios. Um
> veterinário não deve ter conta_id fixo no JWT — o acesso a cada fazenda vem de sharing_grants,
> resolvido por requisição."

---

## [ ] Passo 2 — Tabela `sharing_grants`

2.1. Criar a tabela central do módulo:
   ```sql
   CREATE TABLE IF NOT EXISTS sharing_grants (
     id TEXT PRIMARY KEY,
     tenant_conta_id TEXT NOT NULL,   -- a fazenda/conta que concede
     veterinarian_id TEXT NOT NULL,   -- quem recebe
     scope_type TEXT NOT NULL,        -- 'fazenda' | 'lote' | 'animal'
     scope_id TEXT,                   -- null quando scope_type = 'fazenda' (acesso total à conta)
     permissions TEXT NOT NULL,       -- JSON: ['consulta','tecnico','intervencao','administrativo']
     granted_by TEXT NOT NULL,        -- usuario_id de quem concedeu
     status TEXT NOT NULL DEFAULT 'pending', -- pending | active | revoked | expired
     created_at TEXT NOT NULL,
     accepted_at TEXT,
     expires_at TEXT,
     revoked_at TEXT
   );
   CREATE INDEX IF NOT EXISTS idx_grants_tenant ON sharing_grants (tenant_conta_id, status);
   CREATE INDEX IF NOT EXISTS idx_grants_vet ON sharing_grants (veterinarian_id, status);
   ```

> Prompt: "Crie a tabela sharing_grants conforme especificado, com índices por tenant e por
> veterinário."

**Pronto quando:** existe schema suficiente para representar "Fazenda X concedeu nível Técnico ao
Veterinário Y, válido até tal data".

---

## [ ] Passo 3 — Fluxo de Convite, Aceite e Consentimento LGPD

3.1. `POST /v1/vet/grants` (autenticado como `proprietario`) — busca veterinário por CRMV/e-mail,
   cria grant com `status: pending`.
3.2. `POST /v1/vet/grants/:id/accept` (autenticado como o veterinário destinatário) — muda para
   `status: active`, seta `accepted_at`.
3.3. **Consentimento explícito no aceite:** o corpo da requisição de aceite deve incluir
   `termsVersion` (versão do termo de tratamento de dados de terceiro que o veterinário está
   aceitando). Registrar isso via `logEvent` (Onda 3) com `action: 'grant_accepted'` e
   `metadata: { termsVersion }` — é o requisito de LGPD identificado na análise dos documentos
   originais (o veterinário passa a ser "operador" de dados de terceiro).
3.4. `GET /v1/vet/grants` — lista os grants do veterinário logado (todas as fazendas com acesso
   ativo) e, para o proprietário, lista os grants que ele concedeu.

> Prompt: "Implemente os endpoints de convite (/v1/vet/grants), aceite
> (/v1/vet/grants/:id/accept, exigindo termsVersion e logando o consentimento) e listagem
> (GET /v1/vet/grants para ambos os lados). Toda transição de status deve gerar um audit_event."

**Pronto quando:** um veterinário só ganha acesso a uma fazenda depois de aceitar explicitamente um
termo versionado, e isso fica registrado de forma auditável.

---

## [ ] Passo 4 — Middleware de Autorização por Grant

4.1. Criar `middlewares/authorizeGrant.js`:
   ```js
   const authorizeGrant = (permissaoMinima) => async (req, res, next) => {
     const { fazendaId } = req.params; // ou de onde vier o escopo da requisição
     const grant = await getAsync(
       `SELECT * FROM sharing_grants
        WHERE veterinarian_id = ? AND tenant_conta_id = ? AND status = 'active'
        AND (expires_at IS NULL OR expires_at > ?)`,
       [req.user.veterinarianId, fazendaId, new Date().toISOString()]
     );
     if (!grant) return res.status(403).json({ error: 'Sem acesso ativo a esta fazenda' });
     const permissoes = JSON.parse(grant.permissions);
     const ordem = ['consulta', 'tecnico', 'intervencao', 'administrativo'];
     if (ordem.indexOf(permissaoMinima) > Math.max(...permissoes.map(p => ordem.indexOf(p)))) {
       return res.status(403).json({ error: 'Nível de permissão insuficiente' });
     }
     req.grant = grant;
     next();
   };
   ```
4.2. Ajustar `/v1/sync` para veterinários: em vez de usar `req.user.contaId` fixo, resolver o
   `ownerId` efetivo a partir do `tenant_conta_id` do grant ativo correspondente à requisição —
   um veterinário pode sincronizar/consultar dados de fazendas diferentes em chamadas diferentes.

> Prompt: "Crie o middleware authorizeGrant que valida se existe um sharing_grant ativo e não
> expirado cobrindo o nível de permissão exigido. Ajuste as rotas que o veterinário usa para
> resolver o owner_id efetivo a partir do grant, não de um conta_id fixo no token."

**Pronto quando:** um veterinário com grant "consulta" recebe `403` ao tentar registrar um
tratamento (que exige "intervenção"), mesmo tendo acesso de leitura àquela fazenda.

---

## [ ] Passo 5 — Revogação

5.1. `DELETE /v1/vet/grants/:id` (autenticado como `proprietario` dono do grant) — seta
   `status: revoked`, `revoked_at: now()`.
5.2. Ao revogar: nenhuma nova sincronização daquele grant deve ser aceita a partir daquele momento
   (o `authorizeGrant` já resolve isso, já que a query só busca `status = 'active'`).
5.3. Registrar `logEvent` com `action: 'grant_revoked'`.
5.4. Histórico já produzido (intervenções, avaliações feitas enquanto o grant estava ativo)
   **permanece intacto e consultável pelo proprietário** — a revogação não apaga nada, só impede
   acesso futuro.

> Prompt: "Implemente a revogação de grant (DELETE /v1/vet/grants/:id), garantindo que nenhuma nova
> sincronização seja aceita após a revogação, mas que o histórico já produzido permaneça intacto."

**Pronto quando:** um teste de integração (no mesmo padrão de `sync_isolation.test.js`) confirma:
Fazenda A convida Veterinário V → V sincroniza normalmente → Fazenda A revoga → V tenta sincronizar
de novo e recebe `403` → o histórico já gravado continua visível para o proprietário da Fazenda A.

---

## [ ] Passo 6 — App Flutter: tela de convite/gestão de grants (lado produtor)

6.1. Nova tela `MeusVeterinariosView` (mesmo padrão de `EquipeView` já existente) — listar grants
   concedidos, convidar novo veterinário, revogar.
6.2. Reaproveitar o componente de badge de perfil já usado no Home para indicar quando a conta tem
   um veterinário com acesso ativo.

> Prompt: "Crie a tela MeusVeterinariosView no app Flutter, seguindo o padrão visual da EquipeView
> já existente, para o proprietário convidar, listar e revogar veterinários."

**Pronto quando:** o produtor consegue convidar e revogar um veterinário inteiramente pelo app, sem
precisar chamar a API manualmente.

---

**Pronto quando (onda inteira):** todo o ciclo — convite, aceite com consentimento, uso com
permissão correta, revogação com corte imediato e preservação de histórico — funciona de ponta a
ponta e está coberto por teste automatizado equivalente ao `sync_isolation.test.js`.
