# FASE 07 — Gap Discovery

## 1. Gap Analysis (Atual vs. Target)
*Visão do esforço de construção restante (atualizado 2026-08-31).*

- **Estado Atual:** ~95% implementado. Todos os módulos de negócio entregues (Rebanho, Saúde, Nutrição, Estoque, Financeiro, Relatórios), multi-tenancy por `conta_id` com colaboração de equipe implementada, RBAC com tela "Minha Equipe" e convite de funcionários. Backend com 3 suítes de testes Jest, 11 testes passando (100%).
- **Estado Target (V1):** App Flutter multiplataforma (Android/iOS) conectado a banco local SQLite, com motor de sincronização (*SyncService*) enviando e recebendo lotes de dados de uma API REST. Homologação de usabilidade em campo.
- **Gap Restante:** Polimento de UX (Wave 5), integração real de e-mail para recuperação de senha, testes end-to-end de sincronização sob condições adversas, e homologação com usuário leigo em campo.

## 2. Risk Analysis
*Matriz de riscos técnicos e de negócio com estratégias de mitigação.*

| Risco | Tipo | Probabilidade | Impacto | Estratégia de Mitigação |
|---|---|---|---|---|
| **Vazamento de Dados entre Fazendas (Multi-Tenancy)** | Segurança | Muito Baixa (pós Wave 3) | Crítico | Segregação estrita por `conta_id` em todas as queries. Suíte de testes automatizados cobre isolamento cross-tenant (`rbac.test.js` e `sync_isolation.test.js`). |
| **Privacidade de Dados Pessoais (LGPD)** | Compliance | Média | Alto | CPF/CNPJ protegido com hashes. Planejar endpoint de expurgo e política de retenção para V2. |
| **Falha de Integridade na Sincronização** | Técnico | Média | Altíssimo | Isolamento do `SyncService`. UUIDs gerados localmente e chaves de idempotência. Cobertura de testes simulando queda de rede no meio da transação. |
| **Baixa Adoção por UX Ruim** | Negócio | Média | Alto | Seguir rigorosamente o *Passo 10 do Guia*: usar componentes grandes de seleção em vez de texto livre, testar contraste sob o sol, eliminar passos supérfluos da interface. |
| **Lentidão em Consultas Locais (SQLite)** | Técnico | Baixa | Médio | Criar índices robustos no Drift (`brinco`, `lote_id`) nas tabelas de uso diário. |
| **Integrações de Hardware (IoT)** | Técnico | Média | Médio | Manter design dos formulários agnóstico à origem do input (digitado ou injetado via hardware Bluetooth/RFID). |

## 3. Technical Debt Analysis
*Gestão da Dívida Técnica (Tech Debt).*

- **Dívidas Herdadas:** Nenhuma.
- **Dívidas Intencionais (Assumidas para V1):**
  - **Mapa Offline de Piquetes:** Trabalhar com mapas totalmente offline é custoso para o MVP. Funcionalidade de mapeamento visual rebaixada para seleção de texto/coordenadas e assumida como dívida técnica para V2.
  - **E-mail Real para Reset de Senha:** Simulado por `console.log`. Integração com SES/Sendgrid planejada para V2.
