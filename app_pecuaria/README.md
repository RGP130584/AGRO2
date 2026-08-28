# App Pecuária

Aplicativo Flutter para gerenciamento de rebanho bovino, projetado com uma arquitetura **offline-first** e foco em segurança para garantir operação contínua e confiável em ambientes rurais com conectividade limitada.

---

## 📱 Visão Geral

O **App Pecuária** é uma ferramenta para auxiliar produtores rurais no controle total de sua propriedade e rebanho. O aplicativo funciona 100% offline, salvando dados localmente no SQLite e sincronizando de forma segura via Outbox Pattern assim que houver conexão.

### Principais Módulos

- 🔐 **Autenticação & Sessão**:
  - Login e cadastro (com validação de CPF/CNPJ, E-mail e Senha).
  - Fluxo de recuperação de senha ("Esqueci minha senha").
  - Suporte a login offline com fallback para credenciais locais (hash SHA-256).
  - Armazenamento seguro de tokens JWT via `flutter_secure_storage` (Keystore/Keychain).
- 🐮 **Gestão de Rebanho**: Cadastro e visualização de animais, lotes, pesagens e piquetes.
- 💉 **Saúde Animal**: Registro de aplicações sanitárias (vacinas, medicamentos) com cálculo automático de carência.
- 🌾 **Nutrição e Dieta**: Cadastro de dietas por lote, registro de fornecimento diário e indicador de divergência.
- ⚖️ **Pesagem e Desempenho**: Registro de pesagens individuais e cálculo automático de Ganho de Peso Diário (GMD).
- 📦 **Controle de Estoque**: Gerenciamento de produtos com baixa automática e atômica de insumos.
- 🔄 **Sincronização Segura**: `SyncService` com Outbox Pattern, JWT no header e proteção contra SQL Injection por whitelist estática.

---

## 🏗️ Arquitetura e Decisões Técnicas

- **Linguagem / Framework**: Dart & Flutter
- **Gerenciamento de Estado**: `flutter_riverpod` (Providers desacoplados e reativos)
- **Banco Local**: `drift` (SQLite type-safe com migrations versionadas)
- **Segurança**: `flutter_secure_storage` (armazenamento criptografado nativo)
- **Device ID**: `device_info_plus` + `uuid` persistente para rastreabilidade e auditoria
- **Sincronização**: Outbox Pattern em fila local (`sync_queue_items`)

---

## 📁 Estrutura de Pastas

```
lib/
├── data/
│   ├── local/          # Drift database, migrations e tabelas locais
│   └── repositories/   # Camada de acesso e persistência
├── features/
│   ├── auth/           # Login, Cadastro, Recuperação de Senha e AuthService
│   ├── estoque/        # Gestão de produtos e movimentação de estoque
│   ├── home/           # Dashboard e navegação principal
│   ├── nutricao/       # Dietas e fornecimentos
│   ├── rebanho/        # Fazendas, animais, lotes, piquetes e pesagens
│   ├── saude/          # Aplicações sanitárias e controle de carência
│   └── sync/           # SyncService, resolução de conflitos e Outbox
├── providers/          # Providers globais (databaseProvider, deviceIdProvider)
└── main.dart           # Entrada principal da aplicação
```

---

## 🚀 Como Executar

1. **Instale as dependências:**
   ```bash
   flutter pub get
   ```

2. **Gere o código das tabelas do Drift:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Execute o aplicativo:**
   ```bash
   flutter run
   ```

4. **Rodar testes:**
   ```bash
   flutter test
   ```
