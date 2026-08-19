# FASE 02 — Domain Discovery

## 1. Core Domain
*Onde reside o maior valor de negócio e o principal diferencial competitivo da aplicação.*

- **Saúde Animal (Sanidade):** Gestão rigorosa de aplicações sanitárias (vacinas, medicamentos), registro de ocorrências de saúde e **cálculo automatizado de carência**, garantindo a conformidade do rebanho para comercialização.
- **Nutrição & Dietas:** Formulação de planos alimentares, registro diário de fornecimento por lote e verificação de aderência (planejado vs. executado) diretamente no curral.

*(Estes domínios dependem fortemente do pilar técnico de **Resiliência Offline** para existirem no contexto da fazenda).*

## 2. Supporting Domains
*Domínios essenciais para o funcionamento do Core, mas que não são o foco principal de inovação.*

- **Manejo de Rebanho:** Estruturação da propriedade (Fazendas, Piquetes) e agrupamento lógico dos animais (Lotes, Animais individuais) para facilitar as operações em massa.
- **Evolução Zootécnica:** Pesagem periódica e acompanhamento do Ganho Médio Diário (GMD).
- **Gestão de Estoque:** Controle de inventário de insumos (produtos veterinários e nutricionais) com baixa automática integrada aos módulos do Core.

## 3. Generic Domains
*Processos padronizados e rotineiros; devem ser implementados da forma mais simples possível.*

- **Financeiro Básico:** Registro simples de contas a pagar e receber, sem complexidade contábil.
- **Identidade e Acesso:** Gestão de usuários, papéis (Owner, Manager, Worker) e autenticação local/remota.
- **Auditoria e Logs:** Rastreabilidade técnica das ações tomadas no sistema.

## 4. Ubiquitous Language
*Glossário oficial do projeto. Estes termos devem ser usados consistentemente no código (classes, tabelas, variáveis) e nas conversas.*

| Termo | Definição |
|-------|-----------|
| **Brinco** | Identificador único (visual ou eletrônico) de um animal específico. É a principal chave de busca no campo. |
| **Lote** | Agrupamento de animais gerido como uma única unidade de manejo (ex: mesmo pasto, mesma dieta, mesmo protocolo sanitário). |
| **Piquete** | Subdivisão física (pasto) da fazenda onde um ou mais lotes são alocados. |
| **Carência** | Período regulatório de restrição de abate ou venda de produtos (leite/carne) após a aplicação de determinado produto veterinário num animal. |
| **Sync Pending** | Estado de um registro criado no campo que ainda não foi confirmado pelo servidor central. |
| **Sync Conflict** | Estado em que um dado local diverge criticamente de uma versão mais recente existente no servidor e requer resolução manual. |
