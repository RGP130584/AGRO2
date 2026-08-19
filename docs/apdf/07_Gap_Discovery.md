# FASE 07 — Gap Discovery

## 1. Gap Analysis (Atual vs. Target)
*Visão do esforço total de construção, visto que o projeto não possui legado (greenfield).*

- **Estado Atual:** 0% de código. Documentação e arquitetura aprovadas.
- **Estado Target (V1):** App Flutter multiplataforma (Android/iOS) conectado a um banco local SQLite, com motor de sincronização (*SyncService*) enviando e recebendo lotes de dados de uma API REST base.
- **Gap de Esforço:** Implementação integral dos 10 passos técnicos definidos no Guia de Desenvolvimento, começando do esqueleto do projeto até a homologação da usabilidade de campo.

## 2. Risk Analysis
*Matriz de riscos técnicos e de negócio com estratégias de mitigação.*

| Risco | Tipo | Probabilidade | Impacto | Estratégia de Mitigação |
|-------|------|---------------|---------|-------------------------|
| **Falha de Integridade na Sincronização** | Técnico | Média | Altíssimo | Isolamento do `SyncService`. Implementação de UUIDs gerados localmente e chaves de idempotência. Cobertura de testes simulando queda de rede no meio da transação. |
| **Baixa Adoção por UX Ruim** | Negócio | Média | Alto | Seguir rigorosamente o *Passo 10 do Guia*: usar componentes grandes de seleção em vez de texto livre, testar contraste sob o sol, eliminar passos supérfluos da interface. |
| **Lentidão em Consultas Locais (SQLite)** | Técnico | Baixa | Médio | Criar índices robustos no Drift (`brinco`, `lote_id`) nas tabelas de uso diário (Animais e Ocorrências) desde a primeira *migration*. |
| **Integrações de Hardware (IoT)** | Técnico | Média | Médio | Antecipar que balanças e leitores de brinco (RFID/Bluetooth) poderão ser integrados no futuro; manter o design dos formulários agnóstico à origem do input (se foi digitado ou injetado via hardware). |

## 3. Technical Debt Analysis
*Gestão da Dívida Técnica (Tech Debt).*

- **Dívidas Herdadas:** Nenhuma.
- **Dívidas Intencionais (Assumidas para V1):**
  - **Mapa Offline de Piquetes:** Trabalhar com mapas (Google Maps/Mapbox) totalmente offline é custoso para o MVP. Se o cache de *tiles* atrasar o cronograma, a funcionalidade de mapeamento visual será rebaixada para um *stub* (seleção de texto/coordenadas) e assumida como dívida técnica para a V2.
