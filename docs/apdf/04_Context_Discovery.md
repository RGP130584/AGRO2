# FASE 04 — Context Discovery

## 1. Context Map
*Mapa de fronteiras (Bounded Contexts) que guiará a organização das pastas e módulos do aplicativo.*

```mermaid
graph TD
    Sync[Sync Context\n(Motor Offline)] 
    
    Rebanho[Rebanho Context\n(Core Cadastro)]
    Saude[Saúde Context\n(Core Sanidade)]
    Nutricao[Nutrição Context\n(Core Alimentação)]
    Estoque[Estoque Context\n(Suporte)]
    
    Saude -- Consulta Lote/Animal --> Rebanho
    Nutricao -- Consulta Lote --> Rebanho
    
    Saude -- Evento: Baixa Vacina --> Estoque
    Nutricao -- Evento: Baixa Ração --> Estoque
    
    Rebanho -. Grava Offline .-> Sync
    Saude -. Grava Offline .-> Sync
    Nutricao -. Grava Offline .-> Sync
    Estoque -. Grava Offline .-> Sync
```

## 2. Bounded Contexts e Data Ownership
*Definição estrita de quem é dono de qual tabela/entidade.*

### 2.1. Rebanho Context
- **Responsabilidade:** Manter a topologia da fazenda e a árvore genealógica/agrupamento de animais.
- **Entidades (Owner):** Fazenda, Piquete, Lote, Animal.
- **Regra Externa:** Outros contextos podem ler, mas nunca criar ou alterar um animal diretamente (devem pedir ao contexto de Rebanho).

### 2.2. Saúde Context
- **Responsabilidade:** Garantir o status sanitário do rebanho e o cálculo de carência.
- **Entidades (Owner):** Aplicação Sanitária, Histórico Médico.
- **Regra Externa:** Consome dados de Rebanho (para saber quem vacinar) e de Estoque (catálogo de vacinas/remédios).

### 2.3. Nutrição Context
- **Responsabilidade:** Gerir a conversão de planos alimentares em fornecimento físico no cocho.
- **Entidades (Owner):** Dieta, Registro de Fornecimento.
- **Regra Externa:** Consome dados de Rebanho (lote) e Estoque (catálogo de rações/suplementos).

### 2.4. Estoque Context
- **Responsabilidade:** Proteger a integridade do saldo físico de insumos na propriedade.
- **Entidades (Owner):** Produto, Movimentação de Estoque.
- **Regra Externa:** Age reativamente, processando baixas sempre que os contextos de Saúde ou Nutrição operam.

### 2.5. Sync Context
- **Responsabilidade:** Abstrair a complexidade de rede e garantir que nenhum dado gravado no campo seja perdido.
- **Entidades (Owner):** Fila de Sincronização (Outbox), Log de Erros de Rede, Tabela de Idempotência.

## 3. Event Map
*Como os contextos trocam informações de forma assíncrona para não travar a usabilidade do aplicativo.*

| Evento | Origem | Destino | Efeito Gerado |
|--------|--------|---------|---------------|
| `AplicacaoSanitariaRegistrada` | Saúde | Estoque | Gera lançamento automático de saída de medicamento. |
| `FornecimentoDietaRegistrado` | Nutrição | Estoque | Gera lançamento automático de saída de ração. |
| `DadoPersistidoOffline` | Qualquer Contexto | Sync | Envelopa a operação local numa *task* pendente para envio ao servidor. |
