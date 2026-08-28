# FASE 06 — Current State Discovery

## Estado Atual do Projeto (Atualizado em 2026-08-28)

*O projeto não é mais greenfield. As Waves 1-4 do Guia de Execução estão substancialmente implementadas. O estado abaixo reflete o código em produção.*

### 1. Repository Analysis
- **Monorepo:** `AGRO/` contendo dois subprojetos:
  - `app_pecuaria/` — Flutter (Dart), com Drift/SQLite local, Riverpod, e arquitetura Feature-Driven.
  - `backend_pecuaria/` — Node.js/Express, com SQLite (via `sqlite3`) como banco do servidor.
- **Versionamento:** Git + GitHub (`RGP130584/agro`). Branch principal: `main`.
- **Higiene:** `.gitignore` configurado na raiz e no backend. Histórico limpo (remoção de `node_modules` e `backend.db` via `git filter-repo`).

### 2. Architecture Analysis
- **Frontend (Flutter/Dart):**
  - Gerenciamento de estado via **Riverpod** (Providers, StateProviders, FutureProviders, ChangeNotifiers).
  - Banco local via **Drift** (SQLite), com migrations versionadas (v1 → v2).
  - Feature modules: `auth`, `rebanho`, `saude`, `nutricao`, `estoque`, `sync`, `home`.
- **Backend (Node.js/Express):**
  - API REST versionada (`/v1/auth/*`, `/v1/sync`).
  - Autenticação JWT (`jsonwebtoken`) + hashing de senhas (`bcrypt`).
  - Validação de entrada com `zod`.
  - Rate limiting (`express-rate-limit`) e CORS configurado.
- **Sincronização:** Outbox Pattern implementado. `SyncService` envia lotes com JWT no header e recebe delta de alterações do servidor.

### 3. Database Analysis
- **Local (Drift/SQLite):**
  - Tabelas de negócio: `Fazendas`, `Piquetes`, `Lotes`, `Animais`, `Pesagens`, `Produtos`, `EstoqueMovimentos`, `AplicacoesSanitarias`, `Dietas`, `FornecimentosDieta`.
  - Tabelas de infraestrutura: `Usuarios` (com email, telefone, emailVerificado), `SyncQueueItems`.
  - Todas as tabelas seguem o schema obrigatório: `id` (UUID), `server_id`, `sync_status`, `device_id`, `created_at`, `updated_at`, `deleted_at`.
- **Servidor (SQLite via `sqlite3`):**
  - Tabela genérica `entities` para armazenar payloads sincronizados.
  - Tabela `usuarios` com campos de autenticação (`senha_hash`, `reset_token`, `reset_token_expires`).

### 4. Security Analysis
- **Autenticação:** JWT com expiração configurável (`JWT_EXPIRES_IN`). Segredo armazenado em variável de ambiente (`JWT_SECRET`).
- **Senhas:** Hash com bcrypt (salt rounds: 10) no backend. Hash SHA-256 no cliente para fallback offline.
- **Armazenamento Seguro:** Token JWT persistido via `flutter_secure_storage` (Keystore/Keychain nativo).
- **Device ID:** UUID persistente gerado por instalação, enriquecido com informação de `device_info_plus`.
- **Rate Limiting:** 20 req / 15min nos endpoints de autenticação.
- **Anti SQL Injection:** Whitelist estrita de tabelas e colunas no `SyncService` do Flutter.
- **Recuperação de Senha:** Fluxo com token temporário (8 chars, 15min expiração). E-mail simulado no servidor (TODO: integrar provedor real).

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
