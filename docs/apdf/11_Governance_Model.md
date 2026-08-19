# FASE 11 — Governance Model

## 1. Validation Rules (Regras de Validação por Artefato)
- **Código Frontend (Flutter):** Zero *warnings* e *errors* no `flutter analyze`. 
- **Separação de Preocupações:** Views (`.dart`) estão estritamente proibidas de conter regras de cálculo de negócio (ex: lógica de carência). Tudo deve ser injetado via Riverpod Providers.
- **Banco de Dados Local (Drift):** Toda entidade de negócio nova no *schema* exige uma validação estática de que contém os 6 campos obrigatórios de sincronização (UUID, server_id, sync_status, created_at, updated_at, deleted_at).

## 2. Scoring e Compliance Model
O projeto não buscará métricas cegas de cobertura de testes de UI para a V1, mas exigirá conformidade total com a **Arquitetura de Sobrevivência**:
- **Compliance Score 1 (Fail):** Uma tela tenta fazer um POST direto na API ao salvar um dado ou existe uso de `DELETE` SQL físico. O Pull Request / Feature deve ser rejeitado.
- **Compliance Score 10 (Pass):** A tela salva localmente, despacha o evento para a *outbox* e retorna controle ao usuário instantaneamente. 

## 3. Quality Gates (Critérios de Aprovação por Wave)

| Wave | Quality Gate Exigido | Método de Validação |
|------|----------------------|---------------------|
| **1. Fundação** | Inserções locais sobrevivem ao encerramento abrupto do app. | Teste de emulador: Inserir dado, "matar" o app, reabrir. O dado deve existir. |
| **2. Core Business** | Regras de cálculo funcionam 100% sem rede e baixas automáticas cruzam domínios. | Teste unitário e de integração na camada do Repositório (com internet desligada). |
| **3. Apoio** | Consistência visual e reuso de componentes já criados nas Waves 1 e 2. | Revisão de código / Visual. |
| **4. Conectividade** | Integridade transacional e idempotência em envios de lote. | Teste automatizado no `SyncService`: Derrubar a conexão *durante* a resposta da API e reenviar o payload. Não deve haver duplicação. |
| **5. Polimento (Handoff)** | Homologação de usabilidade em campo. | Teste com usuário leigo. Uso do app no modo avião por 2 dias. Legibilidade sob o sol testada em aparelho físico. |
