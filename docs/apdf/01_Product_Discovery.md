# FASE 01 — Product Discovery

## 1. Product Vision
Fornecer aos pecuaristas e suas equipes de campo uma ferramenta móvel robusta, intuitiva e *offline-first* que garanta o registro contínuo e confiável de todas as operações zootécnicas (saúde, nutrição, pesagem) diretamente no curral, eliminando retrabalhos, erros de papel e dependência de conexão com a internet.

## 2. Product Charter
- **Problema:** O registro de dados de campo na pecuária falha devido à falta de conectividade nas fazendas e à complexidade dos softwares tradicionais, resultando em dados atrasados, perdas de histórico sanitário e retrabalho.
- **Solução:** Um aplicativo mobile construído desde o primeiro dia para funcionar sem internet (offline-first), com interfaces simplificadas (botões grandes, seleção visual) focadas na operação em campo.
- **Diferencial:** Arquitetura de sincronização resiliente que resolve conflitos de dados de forma assíncrona, combinada com uma UX adaptada para usuários de baixíssima familiaridade digital (legibilidade ao sol, alertas visuais de carência).

## 3. Personas
### 3.1. O Peão / Colaborador de Campo (ex: "João")
- **Perfil:** Baixa familiaridade digital, mãos grossas/sujas durante o trabalho, opera sob luz do sol intensa.
- **Necessidade:** Registrar vacinas, dietas e pesagens de forma rápida (em poucos toques) sem precisar digitar textos ou esperar telas carregarem.
- **Frustração:** Telas complexas com muitos campos, letras pequenas e sistemas que travam quando a internet cai.

### 3.2. O Proprietário / Gerente (ex: "Carlos")
- **Perfil:** Tomador de decisão, foca em rentabilidade e gestão de estoque/financeiro.
- **Necessidade:** Ter a visão exata do inventário de animais, alertas de carência sanitária e controle de estoque de insumos.
- **Frustração:** Informações desencontradas entre o que foi feito no campo e o que está no escritório, e dados perdidos.

## 4. Market Positioning
Um "canivete suíço" digital para o manejo pecuário. Diferente de ERPs complexos de escritório, este é um aplicativo de operação de campo, utilitário, direto ao ponto e que prioriza a consistência dos dados (sync outbox) sobre funcionalidades infladas.

## 5. Problem Statement
"Como podemos garantir que 100% dos eventos sanitários e nutricionais de um rebanho sejam registrados no momento em que ocorrem, por operadores com pouca experiência tecnológica, em locais com zero cobertura de rede, garantindo que o escritório receba esses dados de forma íntegra assim que houver conexão?"
