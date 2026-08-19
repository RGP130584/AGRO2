# FASE 09 — Architecture Freeze

## 1. ADR Registry (Architecture Decision Records)
*As decisões abaixo formam o baseline oficial do projeto e não podem ser alteradas sem passar por uma nova rodada do comitê de arquitetura.*

### ADR 001: Mobile Client Stack
- **Decisão:** Utilizar Flutter como framework principal e Riverpod como gerenciador de estado.
- **Justificativa:** Necessidade de aplicativo multiplataforma (Android/iOS) com alta performance em listas pesadas e base de código unificada para agilizar o MVP.

### ADR 002: Offline-First Database
- **Decisão:** Utilizar Drift (SQLite) como banco de dados local embarcado no dispositivo.
- **Justificativa:** É a única forma de garantir que o aplicativo continue operando no campo sem conexão por múltiplos dias. O Drift provê tipagem forte no Dart e gerenciamento seguro de *migrations*.

### ADR 003: Integração Assíncrona (Outbox Pattern)
- **Decisão:** O aplicativo não fará chamadas HTTP diretamente a partir de ações na Interface de Usuário. Toda gravação irá para o SQLite e, concomitantemente, para uma tabela `fila_sincronizacao`. Um `SyncService` em *background* despachará a fila.
- **Justificativa:** Garantir o conceito de *"Caderneta Digital Infalível"*. Se a internet oscilar no exato segundo em que o usuário aperta "Salvar", ele não será bloqueado.

### ADR 004: Chaves Primárias Locais (UUID V4)
- **Decisão:** Todas as entidades de negócio utilizarão UUID V4 gerados no próprio celular como `id` (chave primária).
- **Justificativa:** Evita colisão de IDs inteiros (auto increment) quando dois dispositivos criam o mesmo tipo de registro offline ao mesmo tempo.

## 2. Governance Rules
*Estas regras são invioláveis e deverão ser checadas em ferramentas de análise estática e code review (ou tpm validate).*

1. **Universal Sync Schema:** É proibido criar tabelas de negócio no banco local sem incluir a tríade de sincronização: `id` (UUID local gen), `server_id` (recebido pós-sync) e `sync_status` (pending, synced, conflict).
2. **Audit Trail Completo:** É proibido criar tabelas de negócio sem os campos `device_id`, `created_at`, `updated_at` e `deleted_at`.
3. **No Hard Deletes:** A execução de um comando físico de `DELETE` em tabelas de negócio é vetada. Exclusões devem ser lógicas (`deleted_at = DATETIME('now')`).
4. **UI Non-Blocking:** É expressamente proibido atrelar a navegação ou o *feedback* de sucesso de uma tela de formulário (ex: Salvar Vacina) a uma resposta de rede (API).

## 3. Architecture Baseline Init
*(TPM INIT: Este documento consolida a linha de base arquitetural para validações do sistema e do agente de inteligência artificial durante o ciclo de engenharia).*
