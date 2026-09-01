# AGRO — Evolução Futura: Módulo Veterinário SaaS

**Status:** proposta arquitetural futura  
**Data:** 31/08/2026

## 1. Visão

O AGRO continua tendo o **produtor/fazenda como núcleo operacional**. O Módulo Veterinário será um produto complementar, comercializado como plano SaaS separado, mas construído sobre o mesmo SaaS Core.

A ideia central é transformar o relacionamento entre produtor e veterinário em uma relação **autorizada, auditável, revogável e colaborativa**.

### Fluxo

```text
PRODUTOR
   │
   ├── seleciona veterinário
   ├── envia convite
   ├── define permissões
   └── pode revogar
          │
          ▼
      VETERINÁRIO
          │
          ├── acompanha rebanho
          ├── consulta histórico
          ├── avalia saúde
          ├── recomenda nutrição
          ├── registra tratamentos
          └── acompanha evolução
```

## 2. Princípio fundamental

O veterinário **não deve receber simplesmente acesso ao banco da fazenda**.

Deve existir uma entidade de relacionamento:

```text
SharingGrant
```

Ela define:

- quem concede;
- para quem;
- qual fazenda;
- qual lote/animal;
- quais módulos;
- quais permissões;
- quando começa;
- quando expira;
- quando foi revogada;
- qual histórico foi produzido.

## 3. Níveis de acesso

### Consulta

- Dashboard do rebanho
- Animais
- Lotes
- Histórico sanitário
- Relatórios
- Indicadores

### Técnico

Além da consulta:

- avaliações;
- recomendações;
- protocolos;
- observações;
- planos de acompanhamento.

### Intervenção

Além do técnico:

- tratamentos;
- protocolos de medicação;
- vacinação;
- recomendações nutricionais;
- acompanhamento de evolução.

### Administrativo

- agenda;
- visitas;
- documentos;
- relatórios;
- ordens de serviço;
- relacionamento com clientes.

## 4. Não editar diretamente o histórico

Intervenções veterinárias devem ser registradas como **eventos/protocolos versionados**, e não simplesmente sobrescrever os dados do produtor.

Exemplo:

```text
Animal 1234
   │
   ├── Avaliação 01
   ├── Tratamento A
   ├── Retorno
   ├── Tratamento B
   └── Encerramento
```

Isso permite saber:

- quem tomou a decisão;
- quando;
- qual era a situação;
- qual tratamento foi indicado;
- qual tratamento foi executado;
- qual foi o resultado.

## 5. Módulos futuros

```text
Veterinary
├── Clientes/Fazendas
├── Rebanho
├── Saúde
├── Prontuário
├── Vacinação
├── Medicamentos
├── Tratamentos
├── Controle de carência
├── Nutrição
├── Visitas
├── Agenda
├── Protocolos
├── Laudos
├── Relatórios
├── Alertas
└── Auditoria
```

## 6. SaaS

O plano veterinário deve utilizar o SaaS Core existente:

```text
Tenant
User
Subscription
Plan
Entitlement
Usage
Device
Audit
SharingGrant
```

Novos entitlements possíveis:

```text
VET_PORTAL
VET_CLIENTS
VET_HEALTH
VET_MEDICATION
VET_NUTRITION
VET_PROTOCOLS
VET_REPORTS
VET_API
VET_TEAM
```

## 7. Modelo de dados conceitual

```text
Veterinarian
    │
    ├── ProfessionalProfile
    ├── Subscription
    └── SharingGrants
             │
             ▼
          Farm/Tenant
             │
       ┌─────┼─────┐
       ▼     ▼     ▼
    Animals Lots Health
                    │
              Interventions
                    │
           ┌────────┼────────┐
           ▼        ▼        ▼
       Treatment Nutrition Vaccination
```

## 8. Revogação

A revogação é requisito de primeira classe.

Quando o produtor revogar:

1. o acesso deve ser bloqueado;
2. novas sincronizações daquele vínculo devem ser rejeitadas;
3. sessões relacionadas podem ser invalidadas;
4. o veterinário deixa de visualizar os dados atuais;
5. registros históricos já produzidos permanecem auditáveis;
6. a fazenda pode convidar outro veterinário sem perder histórico.

## 9. Offline-First

O módulo veterinário deve reutilizar o Offline-First do AGRO.

```text
Veterinário
    ↓
SQLite/Drift
    ↓
Outbox
    ↓
Sync Engine
    ↓
API
    ↓
PostgreSQL
```

O conjunto de dados disponível offline deve ser limitado ao **escopo autorizado**.

## 10. Segurança

Obrigatório:

- isolamento por tenant;
- least privilege;
- permission-based authorization;
- auditoria;
- expiração de compartilhamento;
- revogação;
- controle de dispositivos;
- controle de sessões;
- versionamento de intervenções;
- proteção de dados sensíveis.

## 11. Pesquisa de mercado

Foram encontrados produtos próximos:

### Pastio

Atende produtores, veterinários e consultores. O veterinário pode acessar histórico do paciente, registrar tratamentos e recomendações, enquanto consultores podem acompanhar múltiplas fazendas.

**Referência:** https://www.pastio.com.br/

### Rebanho 360

Apresenta tratamentos, protocolos, histórico sanitário, relatórios técnicos para veterinários e um módulo separado chamado **Vet360 Consultório**, com agenda, prontuário, ordens de serviço, cobrança, estoque e contratos.

**Referência:** https://www.rebanho360.com.br/

### Bovipec

Posiciona o sistema para pecuaristas e veterinários, com acompanhamento de peso, sanidade, reprodução e custos.

**Referência:** https://bovipec.com.br/

### Gestor Pecuário

Possui permissões por função, incluindo proprietários, administradores, técnicos e usuários de consulta, além de módulos de sanidade e bem-estar.

**Referência:** https://gestorpecuario.com.br/

### Congado

Declara suporte para proprietário, gerente, capataz e técnicos como veterinários, zootecnistas e agrônomos.

**Referência:** https://congado.com.br/

## 12. Diferencial pretendido do AGRO

A oportunidade não é simplesmente criar mais um sistema veterinário.

O diferencial deve ser:

> **uma rede de colaboração profissional entre produtor e veterinário, governada pelo produtor e integrada ao histórico operacional do rebanho.**

Isso cria um modelo interessante:

```text
              AGRO
                │
        ┌───────┴────────┐
        │                │
     PRODUTOR        VETERINÁRIO
        │                │
        └──── vínculo ───┘
                 │
          Sharing Grant
                 │
        Dados + Permissões
                 │
        Intervenções Técnicas
                 │
             Auditoria
```

## 13. Roadmap recomendado

### Fase 1 — Compartilhamento

- convite;
- aceite;
- consulta;
- relatórios;
- WhatsApp/e-mail;
- revogação.

### Fase 2 — Portal Veterinário

- carteira de fazendas;
- dashboard;
- alertas;
- agenda;
- histórico.

### Fase 3 — Saúde Animal

- prontuário;
- avaliação;
- vacinação;
- tratamentos;
- medicamentos;
- protocolos;
- carência.

### Fase 4 — Nutrição

- recomendações;
- planos nutricionais;
- acompanhamento;
- comparação de resultados.

### Fase 5 — Operação profissional

- visitas;
- ordens de serviço;
- laudos;
- documentos;
- contratos;
- cobrança.

### Fase 6 — Inteligência

- alertas preditivos;
- análise de tendências;
- recomendações;
- apoio à decisão.

A IA deve apoiar o veterinário, **não substituir a responsabilidade técnica**.

## 14. Decisão arquitetural

Não criar um segundo sistema independente.

Criar:

```text
AGRO SaaS Core
      │
      ├── Producer
      │
      └── Veterinary
```

O plano comercial pode ser separado, mas os seguintes componentes devem ser compartilhados:

- identidade;
- tenancy;
- subscription;
- entitlements;
- sharing;
- auditoria;
- dispositivos;
- sincronização.

## 15. Próximas melhorias no AGRO Core

Antes da implementação completa do módulo veterinário, o AGRO deve evoluir para:

1. PostgreSQL no backend;
2. modularização do backend;
3. Sharing/Delegated Access;
4. Permissions em vez de apenas roles;
5. Device Management;
6. Audit Trail;
7. Sync Engine 2.0;
8. Entitlements;
9. Subscription;
10. Observability.

Essas melhorias não são desperdício: são justamente a infraestrutura necessária para suportar o módulo veterinário com segurança.

## 16. Conclusão

A ideia deve ser preservada como uma evolução estratégica do AGRO.

O produto atual resolve:

> **"Como o produtor administra o rebanho?"**

O módulo veterinário passa a resolver:

> **"Como produtor e veterinário trabalham juntos sobre o mesmo rebanho, com controle, responsabilidade e histórico?"**

Essa segunda pergunta cria uma oportunidade SaaS muito maior do que simplesmente adicionar uma tela de veterinário.
