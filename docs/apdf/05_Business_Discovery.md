# FASE 05 — Business Discovery

## 1. Business Architecture
A arquitetura de negócio baseia-se num modelo de **Auditoria Assíncrona** suportado por ferramentas de alta usabilidade. O valor do negócio não está apenas no processamento dos dados, mas sim em **garantir que o dado seja coletado de forma indolor e confiável no momento e local em que a ação física acontece** (o curral), independentemente de infraestrutura de rede.

## 2. Value Streams
Os fluxos de valor representam a jornada do trabalho ponta a ponta:

### 2.1. Fluxo de Saúde e Conformidade
1. **Gatilho:** Planejamento sanitário (vacina de rotina) ou ocorrência clínica (doença).
2. **Execução:** Aplicação do produto no animal/lote registrada no app em campo (modo offline).
3. **Consequência Local:** O app projeta a carência e impõe um selo visual de bloqueio sobre o animal.
4. **Baixa Logística:** Sincronização em *background* debita o medicamento do estoque.
5. **Encerramento:** Liberação do animal para comercialização/abate após fim da carência calculada.

### 2.2. Fluxo de Nutrição
1. **Gatilho:** Zootecnista/Gerente formula uma dieta no escritório.
2. **Execução:** Tratorista/Peão faz o trato no cocho e informa no app a quantidade real fornecida (modo offline).
3. **Controle:** O sistema compara planejado vs. executado e avisa imediatamente em caso de desvio.
4. **Baixa Logística:** Sincronização em *background* debita o insumo do estoque.

## 3. Operating Model
Como a fazenda se organiza para alimentar o sistema:

- **Frontline (O Curral / Pasto):**
  - **Perfil:** Operadores de campo (Peões, Tratoristas, Veterinários).
  - **Restrições:** Sem internet, sob luz do sol, uso de luvas/mãos sujas.
  - **Ação no Sistema:** Inserção primária de dados. Precisam de fluxos que exijam no máximo 3 ou 4 toques, usando componentes de seleção (botões, listas) em vez de digitação livre.

- **Backoffice (O Escritório):**
  - **Perfil:** Gerente, Proprietário.
  - **Restrições:** Conectividade intermitente ou total.
  - **Ação no Sistema:** Cadastros estruturais (compra de estoque, criação de dietas), acompanhamento de relatórios e tomada de decisão sobre conflitos gerados por sincronizações simultâneas.

## 4. Service Model
- Para o **Operador de Campo**, o sistema presta o serviço de *"Caderneta Digital Infalível"*. Ele nunca diz "erro de conexão". O que for feito, está salvo e pronto.
- Para o **Gestor**, o sistema presta o serviço de *"Rastreabilidade Auditável"*. Ele sabe, ao sincronizar, exatamente as métricas de manejo, qual aparelho registrou e quais as distorções entre planejamento e realidade.
