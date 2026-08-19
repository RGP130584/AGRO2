# FASE 10 — Execution Planning

## 1. Roadmap (Visão Macro)
A entrega de valor seguirá a estratégia *"Offline-First Foundation"*, garantindo que o sistema funcione isoladamente primeiro, e a complexidade de rede seja acoplada no final, evitando que gargalos de infraestrutura atrasem o desenvolvimento do Core Business.

## 2. Waves, Epics e Features

### Wave 1: Fundação Local
*Objetivo:* App compilando e banco de dados pronto para armazenar a estrutura da fazenda.
- **Epic 1.1 - Infraestrutura Base:**
  - `Feature:` Setup do projeto Flutter (Riverpod, rotas).
  - `Feature:` Criação do banco local (Drift/SQLite) com tabelas possuindo os campos de controle de sincronização (UUID, server_id, sync_status).
- **Epic 1.2 - Rebanho Context:**
  - `Feature:` Telas de cadastro em drill-down (Fazenda > Piquete > Lote > Animal).
  - `Feature:` Marcação stub/simples de coordenadas para o piquete.

### Wave 2: Core Business
*Objetivo:* Entregar o diferencial competitivo: manejo de gado offline.
- **Epic 2.1 - Saúde Animal (Sanidade):**
  - `Feature:` Lançamento de protocolo/medicamento por Lote ou Animal.
  - `Feature:` Motor local de cálculo de carência.
  - `Feature:` UI: Selo visual (vermelho/cinza) indicando carência ativa nas listagens.
  - `Feature:` Anexo de foto do animal/lote salva no *file system* local.
- **Epic 2.2 - Nutrição e Dieta:**
  - `Feature:` Tela de formulação de dieta (por Lote/Categoria).
  - `Feature:` Registro de fornecimento diário no cocho com indicador de divergência.
- **Epic 2.3 - Gestão de Estoque:**
  - `Feature:` Saldo por produto (ração, suplemento, vacina).
  - `Feature:` Integração: Baixa automática em background gerada pelas features 2.1 e 2.2.

### Wave 3: Módulos de Apoio
*Objetivo:* Completar o ecossistema de dados da propriedade.
- **Epic 3.1 - Evolução:**
  - `Feature:` Lançamento de pesagem e cálculo de GMD.
- **Epic 3.2 - Financeiro & Relatórios:**
  - `Feature:` Gestão de contas a pagar/receber (offline).
  - `Feature:` Rastreabilidade sanitária e histórico de dietas.
- **Epic 3.3 - Configurações:**
  - `Feature:` Telas de preferência, login local, log de auditoria.

### Wave 4: Conectividade e Resiliência
*Objetivo:* Dar vida ao conceito *Outbox* e enviar dados à nuvem.
- **Epic 4.1 - Motor de Sincronização (App):**
  - `Feature:` `SyncService` escutando conectividade.
  - `Feature:` Transmissão de Lote (Outbox) via HTTP.
  - `Feature:` Resolução manual de conflitos (Tela de *merge* para o Gerente).
- **Epic 4.2 - Backend Mínimo (API):**
  - `Feature:` Criação do Node/Express API.
  - `Feature:` Endpoint `/sync/batch` (Idempotente).

### Wave 5: Polimento e Lançamento
*Objetivo:* Refatoração focada exclusivamente no operador rural.
- **Epic 5.1 - UX Handoff:**
  - `Feature:` Revisão completa de contraste, botões grandes e fluxos de 3 toques.
  - `Feature:` Onboarding visual inicial.
- **Epic 5.2 - Testes de Aceite:**
  - `Feature:` Bateria de testes de uso agressivo sem internet.
