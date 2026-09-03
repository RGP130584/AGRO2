# Prompt: PWA + Modal de Instalação Multiplataforma para Flutter

## Prompt copie-e-cole

```
Meu projeto Flutter (app_pecuaria) precisa ser transformado em PWA e exibir um modal de instalação ao abrir o app, com instruções específicas para cada plataforma (Windows, Linux, Android, iOS) baseadas no conteúdo do manifest.json da pasta web/.

## Contexto do projeto

- Tipo: Flutter app (offline-first, gestão pecuária)
- Plataformas alvo: web, windows, android, ios
- SDK Dart: >=3.0.0 <4.0.0
- Banco: Drift com sqlite3.wasm + drift_worker.js para web
- Dependências relevantes: shared_preferences, flutter_riverpod
- A pasta web/ NÃO tem index.html (falta criar)
- O manifest.json referencia ícones/screenshots que NÃO existem nos arquivos reais
- Os ícones reais são: Icon-192.png, Icon-512.png, Icon-maskable-192.png, Icon-maskable-512.png

## O que precisa ser feito

### 1. Criar web/index.html

Bootstrap padrão do Flutter para web com:
- Referência ao manifest.json
- Meta tags iOS (apple-mobile-web-app-capable, apple-mobile-web-app-title, apple-touch-icon)
- Meta tags Android (mobile-web-app-capable, theme-color)
- Script que captura o evento `beforeinstallprompt` do Chrome/Edge e expõe funções globais para o Flutter chamar via dart:js_interop:
  - `window.__deferredPrompt` — armazena o evento
  - `window.__canInstallPwa()` — retorna true se o prompt está disponível
  - `window.__triggerInstallPrompt()` — dispara prompt.prompt() e retorna true
- Registro do service worker (sw.js) via navigator.serviceWorker.register()
- Tag `<script src="flutter_bootstrap.js" async></script>` no final do body

### 2. Criar web/sw.js

Service worker básico com:
- Cache do app shell (/, /index.html, /manifest.json, /favicon.png, /icons/*)
- Estratégia stale-while-revalidate para assets normais
- Cache-first com fallback para /index.html
- skipWaiting() no install, clients.claim() no activate
- Limpeza de caches antigos no activate

### 3. Corrigir web/manifest.json

O manifest atual referencia arquivos inexistentes. Corrigir para:
- Usar apenas os ícones que existem: Icon-192.png e Icon-512.png (com variantes maskable)
- Remover screenshots (não existem)
- Manter: name, short_name, description, start_url, display: standalone, theme_color, background_color, categories
- Ícones: usar purpose "any" e "maskable" separados

### 4. Criar modal Flutter de instalação

Criar lib/core/widgets/install_pwa_modal.dart com:

**Widget StatefulWidget** (InstallPwaModal) que:
- Tem um método estático `show(context)` que verifica antes de mostrar:
  - Se é app nativo (Android/iOS), NÃO mostra (já instalou pela loja)
  - Se o SharedPreferences tem a chave "install_modal_dismissed", NÃO mostra
- Mostra um AlertDialog com:
  - Ícone: Icons.download_for_offline (verde)
  - Título e mensagem variam conforme a plataforma detectada
  - Dois botões: "Agora não" (fecha) e "Instalar"/"Entendi"

**Detecção de plataforma:**
- Em web: usar `beforeinstallprompt` (via helpers JS do index.html) para saber se o Chrome pode instalar nativamente
  - Detectar plataforma pelo navigator.userAgent (Android/iPhone/iPad/Linux)
- Em nativo: usar `defaultTargetPlatform` (NÃO usar `dart:io` porque quebra compilação web)

**Conteúdo por plataforma:**
- Chrome desktop com prompt disponível → "Instale o app para usá-lo offline..." + botão "Instalar" (dispara prompt nativo do browser)
- Chrome desktop sem prompt → "Use o ícone de instalação (⤓) na barra de endereço..."
- Android → "Use o menu do navegador (⋮) e toque em 'Adicionar à tela inicial'..."
- iOS → "Toque no botão Compartilhar (⇪) e selecione 'Adicionar à Tela de Início'..."
- Linux → "Use o menu do navegador e selecione 'Instalar BovControl Pro'..."
- Outro → "Use a opção de instalação do seu navegador..."

### 5. Importante: import condicional para dart:js_interop

`dart:js_interop` SÓ existe em build web. Para não quebrar builds nativos (Windows, Android, iOS), usar import condicional:

Criar 3 arquivos:
- `lib/core/widgets/pwa_install_web.dart` — importa dart:js_interop, declara:
  - @JS('window.__canInstallPwa') external bool _jsCanInstallPwa();
  - @JS('window.__triggerInstallPrompt') external bool _jsTriggerInstallPrompt();
  - @JS('navigator.userAgent') external JSString get _jsNavigatorUserAgent;
  - Funções: waitBeforeInstallPrompt(), triggerInstallPrompt(), getUserAgent()
- `lib/core/widgets/pwa_install_stub.dart` — stubs que retornam false/null
- `lib/core/widgets/pwa_install.dart` — facade:
  ```dart
  export 'pwa_install_stub.dart'
      if (dart.library.js_interop) 'pwa_install_web.dart';
  ```

O install_pwa_modal.dart importa APENAS pwa_install.dart (não dart:js_interop diretamente).

### 6. Integrar ao main.dart

Criar um wrapper _PwaInstallLauncher (StatefulWidget) que:
- No initState, agenda via addPostFrameCallback(() => InstallPwaModal.show(context))
- Evita mostrar duas vezes com flag _shown
- Envolve o SplashView (home) no MaterialApp

### Arquivos criados/modificados

1. web/index.html — CRIADO
2. web/sw.js — CRIADO
3. web/manifest.json — MODIFICADO (corrigir ícones)
4. lib/core/widgets/install_pwa_modal.dart — CRIADO
5. lib/core/widgets/pwa_install.dart — CRIADO (facade)
6. lib/core/widgets/pwa_install_web.dart — CRIADO (web interop)
7. lib/core/widgets/pwa_install_stub.dart — CRIADO (stub nativo)
8. lib/main.dart — MODIFICADO (adicionar wrapper + import)

## Regras importantes

- NUNCA usar `dart:js_interop` em arquivos que são compilados em plataforma nativa — usar conditional import
- NUNCA usar `dart:io` em código que pode ser compilado para web — usar `defaultTargetPlatform`
- O service worker é OBRIGATÓRIO para o Chrome considerar o app instalável
- O manifest precisa de ícones 192x192 e 512x512 para ser válido
- O beforeinstallprompt só dispara em HTTPS ou localhost
- No iOS, NÃO existe beforeinstallprompt — sempre mostrar instruções manuais
- flutter bootstrap.js é gerado pelo `flutter build web` — não precisa criar manualmente
```
