# FASE 08 — Target Architecture

## 1. Target Architecture (Visão Geral)
A solução será baseada em uma arquitetura de cliente pesado (*Thick Client*) operando no padrão **Offline-First**. 

- **Frontend:** Aplicativo Mobile em Flutter.
- **Armazenamento Primário:** Banco de dados relacional embarcado (Drift / SQLite) no dispositivo do usuário. É a *Single Source of Truth* momentânea.
- **Backend:** API REST minimalista (Node.js/Express) que atua exclusivamente como um *hub* de sincronização (recebe e entrega lotes de dados).
- **Armazenamento Secundário:** Banco de dados relacional em nuvem (ex: PostgreSQL) ligado à API.

## 2. Domain Architecture (Flutter)
Estruturação interna do aplicativo baseada em *Feature-Driven Architecture* para alinhar-se perfeitamente aos Bounded Contexts da Fase 04:

```text
lib/
  core/            # Configurações globais, tema, utilitários
  data/
    local/         # DAO e schema do Drift (SQLite)
    remote/        # API Client e DTOs
    repositories/  # Onde mora a regra: "Tente rede, senão grave local"
  domain/
    models/        # Entidades agnósticas (Animal, Dieta)
  features/
    rebanho/       # (UI + Providers específicos do contexto Rebanho)
    saude_animal/
    nutricao/
    estoque/
    sync/          # Lógica isolada da fila outbox
```
*Gerenciamento de Estado escolhido:* **Riverpod**, por oferecer uma injeção de dependência simplificada e robusta para MVPs.

## 3. Integration Architecture
O fluxo de integração entre cliente e servidor abandona o padrão "requisição direta por clique" em favor de uma topologia de **Sincronização Assíncrona e Idempotente**.

1. **Gravação Local:** O usuário salva uma vacina. O app grava na tabela `aplicacoes_sanitarias` e imediatamente insere um payload na tabela `fila_sincronizacao` (Outbox Pattern).
2. **Batch Sync:** Assim que o `connectivity_plus` detectar internet, o `SyncService` empacota eventos pendentes e envia em um único *array* (lote) para a API.
3. **Idempotência:** A API usa o `id` (UUID V4 gerado localmente no Flutter) como chave. Se a rede cair no meio do retorno e o app enviar os dados novamente, a API ignora a duplicata.
4. **Resolução de Conflitos:** Se dois gerentes alterarem o mesmo lote de animais offline e sincronizarem, a API aceita a primeira requisição. A segunda requisição recebe um *status code* de conflito (ex: 409). O app marca o registro local como `conflict` e a UI exibe ambas as versões para resolução humana.

## 4. Security Architecture (Segurança por Design)
- **Rastreabilidade (Auditoria Extrema):** Toda tabela de negócio possui os campos: `device_id` (UUID persistente por instalação, gerado via `device_info_plus` + `uuid`), `created_at`, `updated_at`, `deleted_at`.
- **Soft Delete:** A deleção física de registros (comando DELETE) é proibida no banco de dados. Qualquer deleção é lógica (`deleted_at`).
- **Autenticação:** Baseada em JWT (JSON Web Tokens) com tempo de expiração prolongado, permitindo que o aplicativo abra e libere funcionalidades localmente sem necessitar renovar a sessão todos os dias.
- **Hashing de Senhas:** Bcrypt com salt no backend. SHA-256 no cliente para fallback offline.
- **Armazenamento Seguro:** Token JWT armazenado via `flutter_secure_storage` (Keystore Android / Keychain iOS), nunca em SharedPreferences.
- **Proteção Anti-Brute Force:** Rate limiting (`express-rate-limit`) nos endpoints de autenticação (20 req / 15min por IP).
- **Validação de Input:** Schemas Zod validam corpo de requisição no backend antes de qualquer processamento.
- **Anti SQL Injection:** Whitelist estrita de tabelas e colunas no `SyncService` do Flutter para queries dinâmicas. Queries parametrizadas no backend.
- **CORS:** Whitelist de origens configurável via variável de ambiente.
- **Variáveis de Ambiente:** Segredos (`JWT_SECRET`, `CORS_ORIGINS`) nunca versionados; armazenados em `.env` ignorado pelo Git.
