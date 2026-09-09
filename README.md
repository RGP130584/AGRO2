# AGRO 2 — Sistema PWA de Gestão Pecuária Inteligente (Offline-First Multi-Espécie)

[![React](https://img.shields.io/badge/React-19.x-61DAFB?logo=react)](https://react.dev)
[![Vite](https://img.shields.io/badge/Vite-6.x-646CFF?logo=vite)](https://vitejs.dev)
[![Dexie.js](https://img.shields.io/badge/Dexie.js-IndexedDB-339933)](https://dexie.org)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?logo=node.js)](https://nodejs.org)
[![PWA](https://img.shields.io/badge/PWA-Offline--First-5A0FC8?logo=pwa)](https://web.dev/progressive-web-apps/)

Sistema completo de gestão pecuária multi-espécie projetado com arquitetura **PWA Offline-First** 100% responsiva para dispositivos móveis, utilizando **React 19, Vite, Dexie IndexedDB, Lucide Icons, Node.js e Express**.

---

## 🚀 Principais Funcionalidades

- 📱 **Interface 100% Mobile-First Responsiva**: Visualização em cards otimizados para smartphones sem rolagem horizontal.
- 🐄 **Isolamento por Espécies**: Separação rigorosa de Bovinos, Ovinos, Equinos, Búfalos, Caprinos e Outros em lotes e cadastros.
- ⚖️ **Módulo de Pesagem & GMD**: Exibição da última pesagem por animal, registro com teclado numérico automático (`inputMode="decimal"`) e cálculo em tempo real de Ganho Médio Diário (kg/dia e @).
- 💉 **Saúde Animal & Carência Sanitária**: Bloqueio de novas aplicações em animais sob carência ativa, cálculo automático de retenção para abate e baixa no estoque.
- 🌾 **Nutrição e Dietas**: Formulação de tratos por lote e fornecimento diário com baixa atômica no estoque.
- 📦 **Controle de Estoque Atômico**: Baixa automática de insumos e medicamentos vinculada às operações do campo.
- 💰 **Financeiro**: Lançamentos de despesas/receitas, projeção de saldo e liquidação.
- 📄 **Relatórios & Rastreabilidade (GTA)**: Emissão de laudos de conformidade sanitária formatados para impressão.
- 🔐 **Gestão de Equipe & Matriz de Permissões**: Perfis editáveis (Proprietário, Veterinário, Campeiro) com CRMV.
- 🔄 **Sincronização Offline-First (Dexie.js IndexedDB)**: Fila Outbox de transações locais com espelhamento para API REST Express.

---

## 📁 Estrutura do Projeto

```
AGRO/
├── agro2/                 # Aplicação Frontend PWA (React 19 + Vite + Dexie.js)
│   ├── src/
│   │   ├── components/    # Layout, Header, InstallPrompt, BadgeCarencia, CameraCapture
│   │   ├── contexts/      # Contextos de Autenticação e Sync
│   │   ├── db/            # Schema Dexie IndexedDB e Seed de dados
│   │   ├── pages/         # Módulos: Dashboard, Rebanho, Saúde, Nutrição, Pesagem, Estoque, Financeiro, Relatórios, Equipe, Sync
│   │   └── utils/         # Helpers de cálculo de GMD, carência sanitária e permissões
│   └── public/            # Service Worker (sw.js), Manifest (manifest.webmanifest) e Ícones
│
└── backend_pecuaria/      # Servidor Backend API REST em Node.js / Express
    ├── app.js             # Endpoints REST, Autenticação JWT, Sincronização e SQLite
    ├── tests/             # Testes unitários e de integração com Jest + Supertest (100% Passing)
    └── .env.example       # Modelo de configuração de ambiente
```

---

## ⚡ Como Executar Localmente

### 1. Backend (Node.js / Express)
```bash
cd backend_pecuaria
npm install
npm test
npm start
```

### 2. Frontend PWA (React 19 + Vite)
```bash
cd agro2
npm install
npm run dev
```

Acesse no navegador: `http://localhost:3001` (ou `http://localhost:5173`).

Para gerar o build de produção PWA:
```bash
cd agro2
npm run build
```
