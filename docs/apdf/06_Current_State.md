# FASE 06 — Current State Discovery

## Estado Atual do Projeto (Atualizado em 2026-08-31)

*O projeto não é mais greenfield. As Waves 1-3 foram concluídas. O estado abaixo reflete o código em produção no branch `main`.*

### 1. Repository Analysis
- **Monorepo:** `AGRO/` contendo dois subprojetos:
  - `app_pecuaria/` — Flutter (Dart), com Drift/SQLite local, Riverpod, e arquitetura Feature-Driven.
  - `backend_pecuaria/` — Node.js/Express, com SQLite (via `sqlite3`) como banco do servidor.
- **Versionamento:** Git + GitHub (`RGP130584/agro`). Branch principal: `main`.
- **Higiene:** `.gitignore` configurado na raiz e no backend. `node_modules` e `backend.db` desrastreados do repositório Git. Banco de teste isolado em memória (`:memory:`).

### 2. Architecture Analysis
- **Frontend (Flutter/Dart):**
  - Gerenciamento de estado via **Riverpod** (Providers, StateProviders, FutureProviders, ChangeNotifiers).
  - Banco local via **Drift** (SQLite), com migrations versionadas (v1 → v2).
  - Configuração de API centralizada em `ApiConstants` com suporte a `--dart-define`.
  - Feature modules: `auth`, `rebanho`, `saude`, `nutricao`, `estoque`, `financeiro`, `relatorios`, `equipe`, `sync`, `home`.
- **Backend (Node.js/Express):**
  - API REST versionada (`/v1/auth/*`, `/v1/sync`, `/v1/users`, `/v1/users/invite`).
  - Autenticação JWT (`jsonwebtoken`) + hashing de senhas (`bcrypt`) com controle de papéis (`perfil`).
  - **Tenancy por `conta_id`:** cada usuário pertence a uma conta; funcionários convidados compartilham o `conta_id` do proprietário. JWT e `/v1/sync` usam `conta_id` como `owner_id`, permitindo trabalho colaborativo na mesma fazenda.
  - Suporte a revogação de sessão via `token_version` (invalidando JWTs após troca de senha).
  - Validação de entrada com `zod` (`e.issues`).
  - Rate limiting (`express-rate-limit`) e CORS configurado.
- **Sincronização:** Outbox Pattern com **Multi-Tenancy** por `conta_id`: tabela `entities` particionada por `owner_id`, impedindo vazamento de dados entre fazendas distintas e permitindo colaboração dentro da mesma conta.

### 3. Database Analysis
- **Local (Drift/SQLite):**
  - Tabelas de negócio: `Fazendas`, `Piquetes`, `Lotes`, `Animais`, `Pesagens`, `Produtos`, `EstoqueMovimentos`, `AplicacoesSanitarias`, `OcorrenciasSanitarias`, `Dietas`, `FornecimentosDieta`, `LancamentosFinanceiros`.
  - Tabelas de infraestrutura: `Usuarios` (com `perfil` para RBAC), `SyncQueueItems`.
  - Todas as tabelas seguem o schema obrigatório: `id` (UUID), `server_id`, `sync_status`, `device_id`, `created_at`, `updated_at`, `deleted_at`.
- **Servidor (SQLite via `sqlite3`):**
  - Tabela `entities` com `owner_id` (= `conta_id`) para segregação multi-tenant por fazenda.
  - Tabela `usuarios` com `conta_id`, `perfil`, `token_version`, `senha_hash` e hash seguro de reset (`reset_token_hash`).

### 4. Security Analysis
- **Multi-Tenancy por `conta_id`:** Isolamento estrito de dados por fazenda (conta) no `/v1/sync`. Funcionários da mesma fazenda compartilham o `conta_id` do proprietário que os convidou.
- **RBAC:** Middleware `requireRole('proprietario')` protege `/v1/users` e `/v1/users/invite`. Badge de perfil visível no HomeView do app; resolução de conflitos de sync restrita a proprietários.
- **Autenticação:** JWT com expiração configurável (`JWT_EXPIRES_IN`) e revogação via `token_version`. `conta_id` embutido no JWT.
- **Senhas (Backend):** Hash com bcrypt (salt rounds: 10). 
- **Senhas (Local):** PBKDF2 com HMAC-SHA256, 10.000 iterações e salt derivado do CPF/CNPJ.
- **Armazenamento Seguro:** Token JWT persistido via `flutter_secure_storage` (Keystore/Keychain nativo).
- **Device ID:** UUID persistente gerado por instalação, enriquecido com informação de `device_info_plus`.
- **Rate Limiting:** 20 req / 15min nos endpoints de autenticação.
- **Anti SQL Injection:** Whitelist estrita de tabelas e colunas no `SyncService` do Flutter.
- **Recuperação de Senha:** Token de 8 caracteres armazenado como hash SHA-256 no banco com expiração em 15 minutos. Invalidação de todas as sessões anteriores pós-reset.

### 5. Dependency Stack

| Camada | Tecnologia | Versão |
|--------|-----------|--------|
| Mobile Framework | Flutter | 3.x |
| State Management | Riverpod | 2.x |
| Local DB | Drift (SQLite) | 2.31+ |
| Secure Storage | flutter_secure_storage | latest |
| Device Info | device_info_plus | latest |
| Connectivity | connectivity_plus | 5.x |
| HTTP Client | http (dart) | latest |
| Backend Runtime | Node.js | 18+ |
| Backend Framework | Express | 4.x |
| Auth (Backend) | jsonwebtoken + bcrypt | latest |
| Validation | zod | latest |
| Rate Limiting | express-rate-limit | latest |
| Testing | Jest + Supertest | latest |
