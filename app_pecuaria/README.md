# App Pecuária

Um aplicativo Flutter para gerenciamento de rebanho bovino, projetado com uma arquitetura **offline-first** para garantir operação contínua em ambientes rurais com conectividade limitada.

## Visão Geral

O **App Pecuária** é uma ferramenta para auxiliar produtores rurais no controle de seu rebanho. O aplicativo foi projetado para funcionar de forma confiável mesmo em ambientes com conectividade de internet limitada ou intermitente, garantindo que os dados possam ser inseridos a qualquer momento.

Todas as operações de escrita são salvas localmente primeiro e, em seguida, enfileiradas para sincronização com um servidor central, seguindo o padrão **Outbox Pattern**.

### Principais Capacidades

- **Gestão de Rebanho**: Cadastro e visualização de detalhes de animais, lotes e piquetes.
- **Saúde Animal**: Registro de aplicações sanitárias (vacinas, medicamentos) com cálculo automático de período de carência.
- **Nutrição e Dieta**: Cadastro de dietas por lote, registro de fornecimento diário e indicador de divergência entre planejado e executado.
- **Pesagem e Desempenho**: Registro de pesagens individuais e cálculo automático de Ganho de Peso Diário (GMD).
- **Controle de Estoque**: Gerenciamento de produtos com baixa automática de insumos a partir de lançamentos sanitários e de nutrição. As operações são atômicas para garantir a consistência dos dados.
- **Sincronização Resiliente**: Utiliza uma fila de eventos (`SyncQueue`) para garantir que nenhuma alteração seja perdida. O `SyncService` processa essa fila de forma assíncrona quando a conectividade é restaurada.

## Arquitetura e Decisões Técnicas

O projeto segue uma arquitetura limpa, separando as responsabilidades em camadas de **UI (Views)**, **Lógica de Negócio (Services)** e **Acesso a Dados (Database/Repositories)**.

- **Linguagem**: Dart
- **Framework**: Flutter
- **Gerenciamento de Estado (`flutter_riverpod`)**: Escolhido por sua capacidade de prover injeção de dependência, facilitando a criação de serviços desacoplados e testáveis, além de gerenciar o estado da UI de forma reativa e eficiente.

- **Banco de Dados Local (`drift`)**: Utilizado para criar um banco de dados SQLite local de forma type-safe e reativa.
  - **Type-Safety**: As queries são escritas em Dart e verificadas em tempo de compilação, evitando erros de SQL.
  - **Reatividade**: Permite que a UI "assista" a streams de queries e se reconstrua automaticamente quando os dados mudam.
  - **Transações**: Garante a atomicidade de operações complexas, como registrar uma aplicação sanitária e dar baixa no estoque simultaneamente (ex: `SaudeService`).

- **Sincronização Offline (Outbox Pattern)**: O coração da resiliência do app.
  1.  Toda operação de escrita (CUD - Create, Update, Delete) é executada dentro de uma transação no banco de dados local.
  2.  Junto com a alteração na tabela de negócio (ex: `animais`), um registro é inserido na tabela `sync_queue_items`. Este registro contém a entidade, a ação e o payload da alteração.
  3.  Um `SyncService` em background monitora a conectividade (`connectivity_plus`) e a fila.
  4.  Quando online, o serviço processa os itens da fila em ordem, enviando-os para a API do backend.
  5.  Em caso de sucesso, o item é removido da fila. Em caso de falha, o status é atualizado para `failed` com o motivo do erro, permitindo novas tentativas ou intervenção manual.

- **Geração de ID (`uuid`)**: IDs únicos universais são gerados no cliente no momento da criação. Isso permite que os registros sejam criados offline e referenciados entre si antes mesmo de serem sincronizados com o servidor, evitando conflitos de chave primária.

## Modelo de Dados

Todas as tabelas de negócio no banco de dados local (`drift`) compartilham um conjunto de campos para facilitar a sincronização e a auditoria:

- `id`: `TEXT` (PRIMARY KEY) - UUID v4 gerado no cliente.
- `server_id`: `INTEGER NULLABLE` - ID do registro no banco de dados do servidor (preenchido após a sincronização).
- `created_at`: `DATETIME` - Timestamp de criação local.
- `updated_at`: `DATETIME` - Timestamp da última modificação local.
- `deleted_at`: `DATETIME NULLABLE` - Implementa soft delete, essencial para propagar exclusões para outros dispositivos.
- `device_id`: `TEXT` - Identificador do dispositivo que originou o dado.
- `sync_status`: `TEXT` - Status do registro (ex: `pending`, `synced`). *Este campo pode ser adicionado futuramente para controle por registro.*

## Estrutura do Projeto

O código-fonte está organizado em módulos de funcionalidade dentro de `lib/features`:

```
lib/
├── data/
│   └── local/          # Configuração do banco de dados Drift (tabelas, DAOs)
├── features/
│   ├── estoque/        # Módulo de controle de estoque
│   ├── rebanho/        # Módulo de gerenciamento do rebanho
│   ├── saude/          # Módulo de saúde animal
│   └── nutricao/       # Módulo de nutrição e dieta
│   └── pesagem/        # Módulo de pesagem e GMD
│   └── sync/           # Lógica de sincronização offline
├── providers/          # Providers globais do Riverpod (banco de dados, deviceId)
└── main.dart           # Ponto de entrada da aplicação
```

## Como Executar o Projeto

1. **Instale as dependências:**
   ```bash
   flutter pub get
   ```
2. **Gere os arquivos do Drift:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
3. **Execute a aplicação:**
   ```bash
   flutter run
   ```

## Versão PWA (Web)

Este repositório também contém um script para gerar uma versão PWA (Progressive Web App) do aplicativo, permitindo o uso em navegadores web com as mesmas garantias de funcionamento offline.

O script `gerar-pwa-pecuaria.sh` cria um projeto web completo que espelha a arquitetura do aplicativo Flutter:

- **Stack**: React, TypeScript, Vite.
- **Banco de Dados Local**: `Dexie.js` (wrapper para IndexedDB) em vez de `Drift/SQLite`.
- **Gerenciamento de Estado**: `Zustand` em vez de `Riverpod`.
- **Sincronização**: O mesmo **Outbox Pattern** é implementado, usando uma tabela no IndexedDB e um `SyncService` que monitora a conectividade.

Para gerar e executar o projeto PWA:

```bash
chmod +x gerar-pwa-pecuaria.sh
./gerar-pwa-pecuaria.sh meu-pwa-pecuaria
cd meu-pwa-pecuaria
npm install && npm run dev
```
