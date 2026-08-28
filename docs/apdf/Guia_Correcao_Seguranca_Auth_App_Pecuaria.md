# Guia de Correção — Autenticação, Segurança e Higiene de Repositório (App Pecuária)

> Base: Auditoria técnica realizada sobre o repositório `agro` (código real, não apenas os docs de `apdf/`).
> Este guia segue o mesmo formato do `Guia_Desenvolvimento_App_Pecuaria_Antigravity.md` e deve ser
> executado **depois** dele, como uma onda de correção (hardening) antes de qualquer release real.
> Cada passo tem: objetivo, entregável e critério de "pronto". Não avance sem o critério satisfeito.

---

## 0. Como usar este guia

- Execute os passos **na ordem**. Os Passos 1 a 4 são bloqueantes de produção (não lance o app
  com eles pendentes). Os Passos 5 a 8 são de qualidade/robustez e podem ser feitos em paralelo
  entre si, mas depois dos 4 primeiros.
- Todo passo que altera o schema local (Drift) exige gerar uma nova *migration* — nunca alterar uma
  tabela existente sem versionar a migração corretamente.
- Prompts sugeridos para o Antigravity estão em blocos `> Prompt:`.

---

## [ ] Passo 1 — Adicionar canal de contato e permitir recuperação de senha

**Objetivo:** hoje é estruturalmente impossível recuperar senha porque a tabela `usuarios` só tem
`nome`, `cpfCnpj` e `senhaHash` — não existe e-mail nem telefone. Isso precisa ser corrigido no
schema antes de qualquer fluxo de recuperação.

1.1. Adicionar à tabela `Usuarios` (`app_pecuaria/lib/data/local/tables/auth_tables.dart`):
   - `email` (`TextColumn`, nullable no cadastro mas obrigatório antes de permitir recuperação de senha)
   - `telefone` (`TextColumn`, nullable, opcional para 2º canal via SMS/WhatsApp no futuro)
   - `emailVerificado` (`BoolColumn`, default `false`)
1.2. Gerar migration do Drift (`database.g.dart` é gerado — não editar manualmente, rodar
    `dart run build_runner build`).
1.3. Atualizar `cadastro_view.dart` para exigir e-mail no cadastro.
1.4. Criar endpoint no backend `POST /v1/auth/password-reset/request` (recebe e-mail ou cpfCnpj,
    gera um token de reset com expiração curta — 15 a 30 min — e dispara e-mail com link/código).
1.5. Criar endpoint `POST /v1/auth/password-reset/confirm` (recebe token + nova senha, valida
    expiração e uso único do token, grava o novo hash).
1.6. Adicionar link "Esqueci minha senha" na `login_view.dart`, com tela de fluxo de 2 etapas
    (solicitar → confirmar código/token → nova senha).
1.7. Definir e documentar o provedor de envio de e-mail (ex.: SendGrid, SES, Resend) e mover a
    chave de API para variável de ambiente (ver Passo 6).

> Prompt: "Adicione os campos email, telefone e emailVerificado à tabela Usuarios no Drift, gere a
> migration, e implemente o fluxo completo de recuperação de senha: tela 'Esqueci minha senha' no
> app, e os endpoints /v1/auth/password-reset/request e /v1/auth/password-reset/confirm no backend,
> com token de expiração curta e uso único."

**Pronto quando:** um usuário cadastrado consegue, sem ajuda de suporte, resetar a própria senha
usando apenas o e-mail cadastrado, e o token de reset não pode ser reutilizado nem usado após expirar.

---

## [ ] Passo 2 — Autenticação real no backend (login server-side + JWT) — passo crítico

**Objetivo:** hoje o login é 100% local (consulta só o SQLite do próprio aparelho) e o backend não
tem nenhuma rota de autenticação nem middleware de proteção. Isso impede multi-dispositivo de
verdade e deixa `/v1/sync` público para qualquer pessoa.

2.1. Criar tabela `usuarios` no backend (mesmo banco do `backend.db` ou um banco dedicado), com
   `id, nome, cpf_cnpj, email, senha_hash, criado_em`.
2.2. Instalar `bcrypt` (ou `argon2`) e `jsonwebtoken` no `backend_pecuaria`.
2.3. Criar `POST /v1/auth/register` — recebe cadastro, salva a senha **sempre com hash** (nunca em
   texto puro), retorna JWT.
2.4. Criar `POST /v1/auth/login` — valida credenciais contra o hash (`bcrypt.compare`), retorna
   JWT com expiração longa (ex.: 30 dias, conforme já decidido no `08_Target_Architecture.md`) e um
   *refresh token* separado.
2.5. Criar middleware `authenticate` que valida o header `Authorization: Bearer <token>` em
   **toda** rota de negócio, incluindo `/v1/sync`. Rejeitar com `401` se ausente/inválido/expirado.
2.6. Atualizar `auth_service.dart` (Flutter) para: no cadastro/login, chamar o backend quando houver
   conexão, salvar o JWT recebido de forma segura (usar `flutter_secure_storage`, não
   `SharedPreferences`, que não é criptografado) e continuar permitindo login **local** (offline)
   como fallback quando não há rede — mas sempre sincronizando o hash de senha real quando a
   conexão voltar, nunca a senha em texto puro.
2.7. Atualizar `sync_service.dart` para enviar o JWT real (`Authorization: Bearer $token`) em vez do
   placeholder `'SEU_TOKEN_JWT'`, e tratar `401` disparando reautenticação/logout.
2.8. **Nunca** armazenar ou sincronizar senha em texto puro. `senhaHash` no cliente deve armazenar
   um hash local (ex.: derivado com `bcrypt`/`argon2` disponível em Dart) — nunca o valor digitado.

> Prompt: "Implemente autenticação real no backend (register, login, middleware JWT protegendo
> todas as rotas incluindo /v1/sync) usando bcrypt para hash de senha. No app Flutter, ajuste o
> AuthService para autenticar contra o backend quando houver rede, armazenar o token com
> flutter_secure_storage, e nunca persistir ou sincronizar a senha em texto puro."

**Pronto quando:**
- Uma requisição a `/v1/sync` sem token válido retorna `401`.
- Inspecionando o banco (local e do backend), a senha nunca aparece em texto puro em lugar nenhum.
- Login funciona offline (fallback local) e volta a sincronizar corretamente quando a rede retorna.

---

## [ ] Passo 3 — Corrigir geração de `device_id` (quebra a resolução de conflito)

**Objetivo:** o `device_id` está hardcoded como `'device_local_01'` em todas as instalações do app,
o que anula a lógica de detecção de conflito descrita no RF-093 (o backend só detecta conflito se
os `device_id` forem diferentes entre dispositivos).

3.1. Gerar um `device_id` único e persistente por instalação usando pacote apropriado (ex.:
   `device_info_plus` combinado com um UUID gerado na primeira execução e salvo localmente).
3.2. Substituir todas as ocorrências hardcoded de `'device_local_01'` (`auth_service.dart` e
   quaisquer outros pontos) pelo provider `device_info_provider.dart` já existente no projeto.
3.3. Escrever teste simulando dois "dispositivos" (dois `device_id` diferentes) editando o mesmo
   registro offline, confirmando que o backend sinaliza `conflict` corretamente.

> Prompt: "Substitua o device_id hardcoded 'device_local_01' por um identificador único gerado na
> primeira execução do app e persistido localmente, usando o device_info_provider já existente.
> Adicione um teste de integração simulando conflito entre dois device_id diferentes."

**Pronto quando:** dois emuladores/dispositivos distintos editando o mesmo registro offline geram
um conflito sinalizado corretamente ao sincronizar (não um dos dois simplesmente sobrescreve o outro
silenciosamente).

---

## [ ] Passo 4 — Eliminar SQL dinâmico não whitelisted no cliente

**Objetivo:** `sync_service.dart` monta comandos SQL usando `entityType` e nomes de coluna vindos
diretamente da resposta do servidor (`UPDATE $entityType SET ...`), sem validação. Se o backend for
comprometido ou houver um ataque man-in-the-middle, isso permite injeção de SQL no banco local do
usuário.

4.1. Criar uma lista explícita (`const Set<String> allowedEntityTypes`) com todas as tabelas de
   negócio válidas (`fazendas`, `piquetes`, `lotes`, `animais`, ... `usuarios`).
4.2. Em `_applyRemoteChange` e `_updateEntitySyncStatus`, validar `entityType` contra essa lista
   **antes** de montar qualquer SQL; rejeitar e logar (sem quebrar o app) qualquer valor fora da lista.
4.3. Da mesma forma, validar que as chaves de `payload` batem com as colunas conhecidas de cada
   tabela (não aceitar chaves arbitrárias vindas do servidor).
4.4. Preferir, onde possível, usar os métodos tipados do Drift (`into(table).insertOnConflictUpdate`)
   em vez de `customStatement` com concatenação de string.

> Prompt: "No SyncService, crie uma whitelist de entityTypes e colunas válidas por tabela e valide
> tudo que vem do servidor antes de montar SQL dinâmico. Rejeite e logue qualquer entityType ou
> coluna fora da whitelist, sem derrubar o app."

**Pronto quando:** um payload de teste com `entityType` ou coluna inválida/maliciosa é rejeitado
silenciosamente (com log) e não gera nenhuma alteração no banco local.

---

## [ ] Passo 5 — Higiene do repositório Git

**Objetivo:** `node_modules/` e o arquivo real `backend.db` (banco SQLite com dados) estão
versionados no Git porque não existe `.gitignore` em `backend_pecuaria/` nem na raiz do monorepo.

5.1. Criar `.gitignore` na raiz do repositório cobrindo, no mínimo: `node_modules/`, `*.db`,
   `*.sqlite`, `.env`, `.env.*`, `build/`, `.dart_tool/`.
5.2. Criar `.gitignore` específico em `backend_pecuaria/` (`node_modules/`, `*.db`, `.env`).
5.3. Remover `node_modules/` e `backend.db` do histórico do Git (não apenas do próximo commit —
   usar `git filter-repo` ou BFG Repo-Cleaner, já que `backend.db` pode ter contido dados reais em
   algum momento e não deve permanecer recuperável no histórico).
5.4. Adicionar `backend_pecuaria/.env.example` documentando as variáveis necessárias (porta, URL do
   banco, segredo do JWT, chave do provedor de e-mail) sem valores reais.

> Prompt: "Crie os arquivos .gitignore na raiz e em backend_pecuaria cobrindo node_modules, arquivos
> de banco (*.db, *.sqlite) e .env. Remova node_modules e backend.db do histórico do git usando
> git filter-repo, e crie um .env.example documentando as variáveis necessárias."

**Pronto quando:** `git status` após `npm install` não mostra `node_modules` como rastreado, o
arquivo `backend.db` não existe mais em nenhum commit do histórico (`git log --all --full-history --
backend_pecuaria/backend.db` não retorna nada), e existe um `.env.example` atualizado.

---

## [ ] Passo 6 — Configuração via variáveis de ambiente

**Objetivo:** a URL da API está hardcoded (`http://10.0.2.2:3000/v1`, específica do emulador
Android) e não existe nenhuma configuração de ambiente no backend.

6.1. No Flutter, introduzir `--dart-define` ou um pacote de config (ex.: `flutter_dotenv`) para a
   URL base da API, com valores distintos para dev/homologação/produção.
6.2. No backend, usar `dotenv` para: porta, segredo do JWT, tempo de expiração do token, chave do
   provedor de e-mail, origem(ns) permitidas de CORS (ver Passo 7).
6.3. Documentar no `README.md` de cada projeto como configurar o ambiente local.

> Prompt: "Substitua a URL hardcoded do SyncService por uma configuração via --dart-define com
> valores diferentes por ambiente, e mova as configurações sensíveis do backend (porta, JWT_SECRET,
> chave de e-mail, CORS_ORIGIN) para variáveis de ambiente via dotenv."

**Pronto quando:** nenhuma URL, porta, segredo ou chave aparece hardcoded no código-fonte; trocar de
ambiente (dev → produção) não exige alterar código, apenas variáveis.

---

## [ ] Passo 7 — Endurecer o backend Express

**Objetivo:** `/v1/sync` hoje aceita qualquer origem (CORS liberado), corpo de até 50 MB, e não tem
nenhuma limitação de taxa de requisições.

7.1. Restringir CORS a uma lista explícita de origens permitidas (variável de ambiente).
7.2. Reduzir o limite de body para um valor realista para o payload de sincronização (ex.: 5–10 MB)
   e avaliar paginação/lotes menores se o app puder gerar filas grandes.
7.3. Adicionar rate limiting (ex.: `express-rate-limit`) nas rotas de autenticação, para mitigar
   força bruta em login.
7.4. Adicionar validação de payload (ex.: `zod` ou `joi`) em todas as rotas antes de tocar no banco.
7.5. Adicionar logging estruturado de erros (sem vazar detalhes internos na resposta ao cliente).

> Prompt: "Endureça o app.js: restrinja CORS a origens explícitas via env, reduza o limite do body,
> adicione rate limiting nas rotas de auth, e valide todo payload de entrada com zod antes de
> qualquer operação no banco."

**Pronto quando:** requisições de origens não autorizadas são bloqueadas, tentativas repetidas de
login são limitadas, e payloads malformados retornam erro de validação claro em vez de exception
não tratada.

---

## [ ] Passo 8 — Cobertura de testes mínima (conforme a própria governança do projeto)

**Objetivo:** o `11_Governance_Model.md` exige testes de idempotência e resiliência do
`SyncService`, mas hoje existe apenas um arquivo de teste em todo o projeto.

8.1. Testes unitários para `AuthService`: cadastro duplicado, login com credenciais inválidas,
   fluxo de recuperação de senha (token expirado, token já usado).
8.2. Teste de integração do `SyncService`: reenvio de evento já processado não duplica registro
   (idempotência — RF-096).
8.3. Teste simulando queda de conexão no meio de uma sincronização e novo envio.
8.4. Teste de conflito real (dois `device_id` distintos, ver Passo 3).
8.5. Testes de backend para os novos endpoints de auth e para o middleware `authenticate` (rejeição
   sem token, token expirado, token válido).

> Prompt: "Escreva os testes descritos no Passo 8: AuthService (cadastro duplicado, login inválido,
> recuperação de senha), SyncService (idempotência, reconexão após queda), e testes de backend para
> os endpoints de autenticação e o middleware JWT."

**Pronto quando:** os cenários acima têm teste automatizado passando e failing corretamente quando
a regra é violada de propósito (teste de mutação manual).

---

## Ordem recomendada de execução (resumo)

```
1. Schema de usuário (email/telefone) + recuperação de senha
2. Autenticação real (backend + JWT) — CRÍTICO
3. Corrigir device_id
4. Whitelist de SQL dinâmico no cliente
5. Higiene do Git (node_modules, backend.db, .gitignore)
6. Variáveis de ambiente
7. Hardening do Express (CORS, rate limit, validação)
8. Testes mínimos de governança
```

> Observação: os Passos 1, 2 e 4 tratam de dados de acesso e segurança de usuários reais — não
> lance a V1 em produção, nem com usuários reais fazendo cadastro, enquanto eles não estiverem
> concluídos. Os Passos 5 e 6 devem ser feitos o quanto antes, independente dos demais, porque
> envolvem dados já vazados no histórico do Git.
