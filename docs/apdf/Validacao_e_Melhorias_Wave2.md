# Validação da Wave 1 de Correção + Melhorias (Wave 2)

> Este documento foi gerado auditando o código real do repositório após os commits:
> `48f9298`, `d7401d1`, `6c97806`, `09ddedc`, `b6191da`.
> Objetivo: confirmar o que do `Guia_Correcao_Seguranca_Auth_App_Pecuaria.md` foi **de fato**
> implementado (não só documentado), e mapear o que ainda falta por módulo.

---

## Parte 1 — Validação do que foi corrigido (Wave 1)

| # | Item do guia anterior | Status | Evidência |
|---|---|---|---|
| 1 | Campos `email`/`telefone` no usuário | ✅ Feito | `auth_tables.dart`: `email`, `telefone`, `emailVerificado` adicionados |
| 1 | Fluxo de recuperação de senha (ponta a ponta) | ✅ Feito | `POST /v1/auth/password-reset/request` e `/confirm` no backend + `forgot_password_view.dart` no app, token de 8 chars com expiração de 15 min e uso único |
| 2 | Login/registro reais no backend com hash de senha | ✅ Feito | `bcrypt` (salt rounds 10) em `/v1/auth/register` e `/v1/auth/login` |
| 2 | JWT protegendo rotas | ✅ Feito | Middleware `authenticate` aplicado em `/v1/sync`; retorna `401` sem token válido |
| 2 | Token salvo com `flutter_secure_storage` | ✅ Feito | `auth_service.dart` e `sync_service.dart` usam `FlutterSecureStorage` para o JWT |
| 3 | `device_id` único por instalação | ✅ Feito | `device_info_provider.dart` gera UUID + info do dispositivo, persistido via `SharedPreferences` |
| 4 | Whitelist de `entityType`/colunas no `SyncService` | ✅ Feito | `_whitelist` em `sync_service.dart` valida tabela e cada coluna do payload antes de montar SQL |
| 5 | `.gitignore` (raiz e backend) | ✅ Feito | Ambos criados, cobrindo `node_modules`, `*.db`, `.env` |
| 5 | Remover `node_modules` do controle de versão | ✅ Feito | `git ls-files` confirma 0 arquivos de `node_modules` rastreados hoje |
| 5 | Remover `backend.db` do **histórico** do Git | ❌ **Não feito** (mas documentado como feito) | Ver Parte 2, item 2.1 — o arquivo continua rastreado hoje |
| 6 | Variáveis de ambiente no backend | ✅ Feito | `dotenv` + `.env.example` com `PORT`, `JWT_SECRET`, `CORS_ORIGINS`, etc. |
| 6 | Variáveis de ambiente no **app Flutter** | ❌ Não feito | `_apiBaseUrl` continua hardcoded (`http://10.0.2.2:3000`) em `auth_service.dart` **e** `sync_service.dart`, ambos com `// TODO: extract to env` |
| 7 | CORS restrito | ✅ Feito | Lista de origens via `CORS_ORIGINS` |
| 7 | Rate limiting no login/registro | ✅ Feito | `express-rate-limit`, 20 req/15min |
| 7 | Validação de payload | ✅ Feito | `zod` em todas as rotas de auth |
| 8 | Testes automatizados | 🟡 Parcial | `backend_pecuaria/tests/auth.test.js` cobre só os 3 caminhos felizes; `package.json` → `"test"` **continua sendo o placeholder padrão** (`exit 1`), ou seja `npm test` não roda os testes de verdade |

**Resumo:** 11 de 14 itens da Wave 1 foram implementados corretamente. Isso é um trabalho sólido —
mas os 3 pendentes (histórico do Git, config do app Flutter, script de teste) precisam ser fechados
antes de considerar a Wave 1 "concluída", porque um deles (`backend.db` no histórico) está
documentado como resolvido sem estar.

---

## Parte 2 — O que falta por módulo (Wave 2)

### 2.1 Módulo Git/Repositório — 🔴 Crítico (divergência doc x realidade)

O `06_Current_State.md` afirma: *"Histórico limpo (remoção de `node_modules` e `backend.db` via
`git filter-repo`)"*. Isso **não é verdade** — validado tecnicamente:

```
git ls-files backend_pecuaria/backend.db   →  ainda retorna o arquivo (está rastreado)
```

O `node_modules` foi removido corretamente (commit único de `git rm`), mas o `backend.db` — que é
o banco SQLite real do backend, contendo hashes de senha, e-mails e tokens de reset — **continua
sendo commitado a cada alteração**, porque `*.db` só foi para o `.gitignore` depois que o arquivo já
estava rastreado (adicionar ao `.gitignore` não desfaz o rastreamento de um arquivo já commitado).

**Correção:**
```bash
git rm --cached backend_pecuaria/backend.db
git commit -m "chore: parar de versionar backend.db"
# depois, se quiser realmente limpar o histórico anterior:
git filter-repo --path backend_pecuaria/backend.db --invert-paths
git filter-repo --path-glob 'backend_pecuaria/node_modules/*' --invert-paths
```
E corrigir a afirmação em `06_Current_State.md` para refletir o estado real até a limpeza ser feita.

**Pronto quando:** `git ls-files backend_pecuaria/backend.db` não retorna nada, e um novo `npm start`
ou `npx jest` local não aparece como alteração pendente em `git status`.

---

### 2.2 Módulo Sync — 🔴 Crítico: sem isolamento entre usuários/contas (multi-tenancy)

Este é o gap mais sério encontrado nesta rodada, **novo em relação à Wave 1** (só apareceu porque
agora existe autenticação de verdade para expor o problema).

A tabela `entities` no backend não tem nenhuma coluna de dono (`user_id`/`tenant_id`):

```sql
CREATE TABLE entities (
    server_id TEXT PRIMARY KEY,
    entity_id TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    payload TEXT,
    device_id TEXT NOT NULL,
    ...
)
```

E o pull de mudanças em `/v1/sync` busca **tudo**, de qualquer usuário:
```js
const changesRows = await allAsync(`SELECT * FROM entities WHERE updated_at > ?`, [lastSyncAt]);
```

Ou seja: hoje, **qualquer usuário autenticado (com um JWT válido, mesmo que da própria conta dele)
recebe o rebanho, estoque, dados de saúde e fazendas de todos os outros usuários do sistema** — não
existe segregação de dados por conta. Isso é mais grave que a ausência de autenticação da Wave 0,
porque agora existe uma falsa sensação de segurança ("tem login, tem JWT") escondendo que o dado
em si nunca foi isolado por dono.

**Correção:**
- Adicionar `owner_id` (ou `conta_id`, se o modelo for "conta com múltiplos usuários/funcionários")
  à tabela `entities`, preenchido a partir de `req.user.id` extraído do JWT no middleware.
- Toda gravação (`INSERT`) e leitura (`SELECT ... WHERE updated_at > ?`) do `/v1/sync` deve filtrar
  por `owner_id = req.user.id` (ou pelo `conta_id` da fazenda, se o `perfil` de "funcionário" puder
  acessar a mesma conta do "proprietário" — ver item 2.3).
- Adicionar teste de integração garantindo que o Usuário A nunca recebe registros do Usuário B.

**Pronto quando:** dois usuários distintos, cada um sincronizando seus próprios dados, jamais veem
registros um do outro — mesmo compartilhando o mesmo banco de dados no backend.

---

### 2.3 Módulo Autenticação/Perfil — 🟠 Alto: campo `perfil` sem nenhuma autorização

A tabela `Usuarios` tem um campo `perfil` (`proprietario` por padrão), sugerindo que o domínio
previa múltiplos papéis (ex.: proprietário vs. funcionário de campo — coerente com o
`02_Domain_Discovery.md`). Hoje esse campo **existe mas não é usado em lugar nenhum**: não há
checagem de `perfil` no backend, nem controle de tela/ação por papel no app.

**Correção:**
- Definir explicitamente nos docs de domínio quais ações cada `perfil` pode fazer (ex.: funcionário
  registra pesagem/aplicação, só o proprietário edita cadastro de fazenda/exclui animais).
- Incluir o `perfil` no payload do JWT (`jwt.sign({ id, cpfCnpj, perfil }, ...)`).
- Criar um middleware `requireRole(...perfis)` reaproveitável no backend.
- No app, esconder/desabilitar ações não permitidas para o perfil logado.

**Pronto quando:** existe pelo menos um endpoint ou ação de tela que se comporta diferente para
`proprietario` vs. outro perfil, e isso está coberto por teste.

---

### 2.4 Módulo Autenticação — 🟡 Médio: hash local fraco e sem revogação de token

- `auth_service.dart` usa `sha256` **sem salt** para o hash local usado no fallback offline
  (`_hashSenha`). SHA-256 puro é rápido de forçar por dicionário/rainbow table caso o SQLite local
  seja extraído de um aparelho comprometido/rooteado. Não é tão grave quanto o problema original
  (texto puro), mas não é o padrão recomendado para senha — o ideal é PBKDF2/Argon2 com salt (ex.:
  derivar o salt do próprio `id` do usuário, que já é um UUID).
- O JWT tem validade de 30 dias e **não existe refresh token nem lista de revogação**: um token
  roubado continua válido até expirar, mesmo que o usuário faça logout ou troque a senha.
  `logout()` hoje só apaga o token do dispositivo local — o token em si continua aceito pelo
  backend se alguém já tiver capturado uma cópia.

**Correção sugerida (nesta ordem de custo/benefício):**
1. Ao trocar a senha (reset), invalidar sessões antigas — ex.: incluir um campo `token_version` no
   usuário, embutir no JWT, e verificar no middleware; incrementar `token_version` no reset invalida
   tudo que foi emitido antes.
2. Trocar o hash local de SHA-256 puro por uma derivação com salt (ex.: `PBKDF2` disponível via
   pacote `cryptography` ou `pointycastle` em Dart).

**Pronto quando:** trocar a senha invalida qualquer token JWT emitido antes da troca.

---

### 2.5 Módulo Backend/Qualidade — 🟠 Alto: `npm test` não executa nada

O `package.json` do backend continua com o script padrão:
```json
"scripts": { "test": "echo \"Error: no test specified\" && exit 1", "start": "node app.js" }
```
Apesar de `jest`/`supertest` terem sido instalados e de existir `tests/auth.test.js`, **ninguém que
rodar `npm test` (como o próprio README raiz instrui) vai executar esse teste** — só quem souber
rodar `npx jest` diretamente. Isso é inconsistente com o próprio `README.md` da raiz, que documenta
`npm test` como o comando oficial.

**Correção:**
```json
"scripts": {
  "start": "node app.js",
  "test": "jest --runInBand"
}
```
(`--runInBand` evita rodar os testes em paralelo contra o mesmo arquivo `backend.db`, ver item 2.6.)

**Pronto quando:** `npm test` roda os 3 testes existentes e falha o processo (exit code ≠ 0) se
algum quebrar — condição necessária para uso futuro em CI.

---

### 2.6 Módulo Backend/Testes — 🟡 Médio: testes escrevem no banco de produção local

`app.js` sempre conecta em `./backend.db` (não há distinção de ambiente de teste):
```js
const db = new sqlite3.Database('./backend.db', ...)
```
Isso significa que rodar `npx jest` cria usuários de teste reais dentro do mesmo arquivo que seria
usado por `npm start` — poluindo dados e sendo uma das razões pelas quais esse arquivo não deveria
estar em git em primeiro lugar (item 2.1).

**Correção:** usar um banco separado para teste, ex.:
```js
const dbFile = process.env.NODE_ENV === 'test' ? ':memory:' : (process.env.DB_PATH || './backend.db');
```
e setar `NODE_ENV=test` no script de teste do `package.json`.

**Pronto quando:** rodar a suíte de testes não deixa nenhum registro novo em `backend.db`.

---

### 2.7 Módulo Backend/Segurança — 🟡 Médio: token de reset em texto puro + `.errors` do Zod

- O `reset_token` é salvo em texto puro na coluna `reset_token`. Como tem vida curta (15 min) e uso
  único, o risco é baixo, mas o padrão recomendado é armazenar um hash do token (igual se faz com
  senha) e comparar o hash recebido — assim, mesmo um dump do banco não expõe tokens ativos.
- O código usa `e.errors` ao capturar `ZodError` (`res.status(400).json({ ..., details: e.errors })`).
  A partir de certas versões do Zod 4, essa propriedade foi **removida** (o nome correto passou a
  ser `e.issues`). Como o `package.json` fixa `"zod": "^4.5.1"` (aceita atualizações de minor/patch),
  uma atualização de dependência pode fazer `details` silenciosamente virar `undefined` sem quebrar
  a rota — vale fixar a versão exata ou trocar para `e.issues` desde já.

**Pronto quando:** o token de reset armazenado no banco não é o mesmo valor enviado por e-mail, e
`e.issues` é usado no lugar de `e.errors`.

---

### 2.8 Módulo Governança/Documentação — 🟡 Médio: matriz de risco não reflete a realidade

O `07_Gap_Discovery.md` foi atualizado, mas a matriz de risco **ainda não lista** nenhum risco de
segurança/privacidade — nem mesmo depois de toda a Wave 1 de hardening. Itens como "vazamento de
dados entre contas" (item 2.2 deste documento) e "dados pessoais de CPF/CNPJ sob LGPD" continuam
fora do radar formal de riscos do projeto, o que indica que a descoberta de requisitos ainda não
tem um dono para o tema segurança/compliance — só reage a auditorias externas como esta.

**Correção:** adicionar à tabela de riscos do `07_Gap_Discovery.md` pelo menos:
- Vazamento de dados entre contas (ver 2.2) — Probabilidade Alta hoje, Impacto Altíssimo.
- Ausência de política de retenção/exclusão de dados pessoais (LGPD) — nenhum endpoint de exclusão
  de conta/dados existe hoje.

**Pronto quando:** a matriz de risco do `07_Gap_Discovery.md` inclui esses itens com estratégia de
mitigação, não apenas riscos técnicos de sincronização/UX.

---

## Parte 3 — Ordem de execução recomendada (Wave 2)

```
🔴 Crítico — resolver antes de qualquer usuário real usar contas separadas:
  1. Isolamento de dados por usuário/conta no /v1/sync (2.2)
  2. Remover backend.db do controle de versão e do histórico (2.1)

🟠 Alto — resolver antes do próximo ciclo de release:
  3. Autorização por perfil (proprietário x funcionário) (2.3)
  4. Consertar "npm test" para rodar de fato o Jest (2.5)

🟡 Médio — pode entrar no mesmo ciclo ou no seguinte:
  5. Variáveis de ambiente no app Flutter (Passo 6 da Wave 1, ainda pendente)
  6. Banco de teste isolado (2.6)
  7. Hash do token de reset + troca de e.errors por e.issues (2.7)
  8. Revogação de sessão ao trocar senha + hash local com salt (2.4)
  9. Atualizar matriz de risco com segurança/LGPD (2.8)
```

> Observação para quem for revisar isto com o Antigravity: o item 2.2 (isolamento de dados) deve
> ser tratado como bloqueante de produto — sem ele, o sistema hoje **não suporta múltiplos clientes
> reais com privacidade entre si**, que é a premissa básica de qualquer SaaS multiusuário.
