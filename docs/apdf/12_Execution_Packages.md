# FASE 12 — Execution Packages

Este documento representa o *Handoff* empacotado para o executor (seja um Agente de Inteligência Artificial ou um time de desenvolvimento). Ele contém escopo delimitado, critérios de sucesso e restrições para cada onda (Wave) do projeto App Pecuária V1.

## 1. Wave Specifications & Packages

### 📦 PACKAGE 01: Infraestrutura e Fundação Local
- **Escopo:** Criação do repositório Flutter, configuração inicial do Riverpod e modelagem completa do banco de dados local com Drift. Inclusão das telas básicas de cadastro (Fazenda, Piquete, Lote, Animal).
- **Critério de Aceite (Quality Gate):** O aplicativo deve inicializar offline num emulador limpo, criar o schema do SQLite sem erros, e permitir o cadastro aninhado (Fazenda > Piquete > Lote > Animal).
- **Restrição de Governança:** O desenvolvedor não deve criar nenhuma tabela de negócio sem incluir os 6 campos obrigatórios da Universal Sync Schema (id, server_id, created_at, updated_at, deleted_at, sync_status). 
- **Débito Técnico Permitido:** A marcação de piquete no mapa pode ser substituída temporariamente por *stub* (inserção manual de texto/coordenadas) para não bloquear a entrega.

### 📦 PACKAGE 02: Core de Negócio (Saúde e Nutrição)
- **Escopo:** Implementação das telas e lógicas locais de registro sanitário (aplicação de vacina/remédio e carência) e registro nutricional (formulação e fornecimento de dieta). Inclui o controle de estoque subjacente.
- **Critério de Aceite (Quality Gate):** Uma aplicação de vacina lançada no aplicativo **deve**, de forma síncrona e local, alterar o saldo do medicamento no estoque e definir visualmente um selo de carência para o lote/animal envolvido.
- **Restrição de Governança:** É proibido atrelar a ação de "Salvar" a requisições de rede ou *loaders* prolongados. 

### 📦 PACKAGE 03: Apoio e Relatórios
- **Escopo:** Módulos periféricos para dar suporte ao dia a dia (Pesagens mensais, financeiro básico de contas, e geração visual de relatórios locais).
- **Critério de Aceite (Quality Gate):** A inserção do peso de um animal deve gerar cálculo automático de GMD (comparado ao peso anterior). Os relatórios devem ler as tabelas locais (ex: rastreabilidade).
- **Restrição de Governança:** Reutilizar ao máximo componentes de UI padronizados construídos nos *Packages* 1 e 2.

### 📦 PACKAGE 04: Resiliência de Dados (Sincronização)
- **Escopo:** Criação do `SyncService` no app para esvaziar a *outbox*, tela de resolução de conflitos para o gerente, e criação do backend mínimo Node.js/Express.
- **Critério de Aceite (Quality Gate):** Criar 3 animais em *modo avião*, religar a internet, confirmar que subiram para o servidor sem duplicar os registros no banco da API. Se forjar uma colisão, o App deve sinalizar e permitir a escolha da versão.
- **Restrição de Governança:** Testes automatizados robustos na rotina de envio do lote e proteção contra duplicação via UUID.

### 📦 PACKAGE 05: UX e Polimento 
- **Escopo:** Revisão final com foco exclusivo no usuário final (peão / veterinário) em condições agressivas de uso.
- **Critério de Aceite (Quality Gate):** Os formulários críticos devem ser preenchidos em no máximo 4 toques usando seleções e não digitação. Navegação fácil de ler em ambientes ensolarados.

---

## 2. Engineering Handoff Checklist
*(Para o executor preencher ao receber a demanda)*

- [ ] A arquitetura base (ADRs) foi lida e compreendida?
- [ ] As regras rígidas de *Soft Delete* e modelo Universal do banco estão entendidas?
- [ ] O fluxo assíncrono (Outbox Pattern) está claro?
- [ ] A restrição de **NÃO bloquear a UI com loaders de rede** está internalizada?
- [ ] O débito técnico planejado sobre o mapa está aceito?
