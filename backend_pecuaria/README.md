# Backend Pecuária — API REST & Sync Hub

API REST e Hub de Sincronização em Node.js/Express para o ecossistema **AGRO**, responsável por autenticação segura, persistência em nuvem e sincronização bidirecional offline-first.

---

## 🛠️ Stack Tecnológica

- **Runtime**: Node.js (18+)
- **Framework Web**: Express 4.x
- **Banco de Dados**: SQLite3 (armazenamento persistente em `backend.db`)
- **Autenticação & Criptografia**: `jsonwebtoken` (JWT) + `bcrypt`
- **Validação de Schema**: `zod`
- **Segurança**: `express-rate-limit` + `cors`
- **Testes Automatizados**: `jest` + `supertest`

---

## 🔐 Endpoints da API

### 1. Autenticação (`/v1/auth`)

- `POST /v1/auth/register` — Cadastro de novo usuário (gera token JWT).
- `POST /v1/auth/login` — Login com validação de credenciais (Bcrypt) e retorno de JWT.
- `POST /v1/auth/password-reset/request` — Solicitação de código de recuperação de senha por e-mail.
- `POST /v1/auth/password-reset/confirm` — Confirmação de código de recuperação e redefinição de senha.

> *Nota: Os endpoints de autenticação contam com rate limiting ativo (20 req / 15min por IP).*

### 2. Sincronização (`/v1/sync`)

- `POST /v1/sync` *(Requer Header `Authorization: Bearer <TOKEN>`)*:
  - **Push**: Processa lote de mutações locais enviadas no array `outbox`.
  - **Pull**: Retorna lista de entidades alteradas no servidor após o timestamp `lastSyncAt`.
  - **Idempotência**: Gerenciamento de conflitos e identificadores UUID gerados no cliente.

---

## ⚙️ Configuração e Instalação

1. **Instalar dependências:**
   ```bash
   npm install
   ```

2. **Configurar variáveis de ambiente:**
   Copie o arquivo `.env.example` para `.env`:
   ```bash
   cp .env.example .env
   ```
   Ajuste os valores:
   ```ini
   PORT=3000
   NODE_ENV=development
   JWT_SECRET=seu_jwt_secret_super_seguro_e_longo
   JWT_EXPIRES_IN=30d
   CORS_ORIGINS=*
   ```

3. **Executar em modo de desenvolvimento:**
   ```bash
   npm start
   ```

4. **Executar testes automatizados:**
   ```bash
   npx jest
   ```
