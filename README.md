# AGRO — Sistema de Gestão Pecuária Inteligente (Offline-First)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?logo=node.js)](https://nodejs.org)
[![Express](https://img.shields.io/badge/Express-4.x-000000?logo=express)](https://expressjs.com)
[![SQLite](https://img.shields.io/badge/SQLite-3-003B57?logo=sqlite)](https://sqlite.org)
[![Riverpod](https://img.shields.io/badge/State-Riverpod-blue)](https://riverpod.dev)

Sistema completo de gestão pecuária projetado com arquitetura **Offline-First**, permitindo que produtores rurais e operadores de campo realizem todas as operações diárias sem necessidade de conexão com a internet. Os dados são sincronizados de forma segura e resiliente assim que o dispositivo detecta rede.

---

## 📁 Estrutura do Monorepo

```
AGRO/
├── app_pecuaria/          # Aplicativo Mobile/Desktop em Flutter (Dart)
│   ├── lib/
│   │   ├── data/          # Drift (SQLite local), Tabelas e Repositories
│   │   ├── features/      # Módulos: auth, rebanho, saude, nutricao, estoque, sync, home
│   │   └── providers/     # Providers globais Riverpod e Device ID
│   └── test/              # Testes unitários e de integração
│
├── backend_pecuaria/      # Servidor API REST em Node.js/Express
│   ├── app.js             # API de Autenticação, Sync e Middleware
│   ├── tests/             # Testes automatizados Jest + Supertest
│   └── .env.example       # Modelo de variáveis de ambiente
│
└── docs/                  # Documentação Completa (APDF)
    └── apdf/              # 12 Fases de Discovery, Arquitetura e Governança
```

---

## 🚀 Principais Funcionalidades

- 🐮 **Gestão de Rebanho**: Cadastro e rastreamento de animais, lotes, pesagens com cálculo automático de Ganho de Peso Diário (GMD) e piquetes.
- 💉 **Saúde Animal**: Registro de aplicações sanitárias (vacinas, medicamentos) com cálculo automático de carência e baixa em estoque.
- 🌾 **Nutrição e Dietas**: Formulação de dietas por lote, fornecimento diário e alerta de divergências.
- 📦 **Controle de Estoque Atômico**: Baixa automática de insumos vinculada a manejos sanitários e nutricionais.
- 🔐 **Autenticação Segura & Offline**: Login local resiliente, cadastro de usuários com e-mail/CPF, recuperação de senha, hashing Bcrypt e JWT seguro via `flutter_secure_storage`.
- 🔄 **Sincronização Resiliente (Outbox Pattern)**: Enfileiramento local atômico com envio em lote, resolução de conflitos e proteção estrita contra SQL Injection via whitelist.

---

## 🛠️ Tecnologias e Arquitetura

| Camada | Tecnologia | Detalhes |
|---|---|---|
| **App Mobile** | Flutter (Dart) | Multiplataforma (Android, iOS, Windows, Web) |
| **Estado** | `flutter_riverpod` | Injeção de dependência e reatividade limpa |
| **Banco Local** | `drift` (SQLite) | Single Source of Truth local, type-safe e reativo |
| **Segurança App** | `flutter_secure_storage` | Armazenamento de JWT em Keystore/Keychain nativo |
| **Identificação** | `device_info_plus` + `uuid` | Device ID único e persistente para auditoria |
| **Backend API** | Node.js + Express | Hub de sincronização REST e autenticação |
| **Segurança Backend** | `bcrypt`, `jsonwebtoken`, `zod`, `express-rate-limit`, `cors` | Criptografia com salt, validação de payload e proteção contra brute-force |
| **Testes** | `Jest` + `Supertest` | Testes automatizados de endpoints de auth e sync |

---

## ⚡ Como Iniciar

### 1. Pré-requisitos
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versão 3.x+)
- [Node.js](https://nodejs.org/) (versão 18+)
- Git

### 2. Backend (Node.js/Express)
```bash
cd backend_pecuaria

# Instalar dependências
npm install

# Configurar variáveis de ambiente
cp .env.example .env
# Edite o arquivo .env com seu JWT_SECRET e CORS_ORIGINS

# Rodar testes
npm test

# Iniciar servidor (porta 3000 por padrão)
npm start
```

### 3. Frontend (App Flutter)
```bash
cd app_pecuaria

# Instalar dependências
flutter pub get

# Gerar tabelas e código do Drift (se necessário)
dart run build_runner build --delete-conflicting-outputs

# Executar a aplicação
flutter run
```

---

## 📖 Documentação do Projeto

A documentação detalhada de arquitetura, domínio e governança está em [`docs/apdf/`](file:///e:/documentos/projetos/AGRO/docs/apdf/):

- [`01_Product_Discovery.md`](file:///e:/documentos/projetos/AGRO/docs/apdf/01_Product_Discovery.md) — Visão do Produto
- [`02_Domain_Discovery.md`](file:///e:/documentos/projetos/AGRO/docs/apdf/02_Domain_Discovery.md) — Domínio e Regras de Negócio
- [`06_Current_State.md`](file:///e:/documentos/projetos/AGRO/docs/apdf/06_Current_State.md) — Estado Atual da Implementação
- [`08_Target_Architecture.md`](file:///e:/documentos/projetos/AGRO/docs/apdf/08_Target_Architecture.md) — Arquitetura Alvo & Segurança
- [`09_Architecture_Freeze.md`](file:///e:/documentos/projetos/AGRO/docs/apdf/09_Architecture_Freeze.md) — Decisões Arquiteturais (ADRs) e Governança

---

## 🔒 Segurança e Governança

- **Zero Hard Deletes**: Todas as tabelas implementam *Soft Delete* (`deleted_at`).
- **Audit Trail Completo**: Todas as entidades possuem `id` (UUID v4), `device_id`, `created_at`, `updated_at`, `sync_status` e `server_id`.
- **Proteção de Segredos**: Nenhuma chave ou segredo JWT é versionado no Git; todas as configurações sensíveis residem em arquivos `.env`.
