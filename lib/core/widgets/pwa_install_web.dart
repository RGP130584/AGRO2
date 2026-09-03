// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';

import 'package:flutter/foundation.dart' show kIsWeb;

/// Helper global definido em `web/index.html` que verifica se o evento
/// `beforeinstallprompt` está pendente (Chrome/Edge; Windows, Linux e Android).
@JS('window.__canInstallPwa')
external bool _jsCanInstallPwa();

/// Helper global definido em `web/index.html` que dispara a caixa de
/// instalação nativa do navegador. Retorna `true` se foi exibida.
@JS('window.__triggerInstallPrompt')
external bool _jsTriggerInstallPrompt();

@JS('navigator.userAgent')
external JSString get _jsNavigatorUserAgent;

/// Aguarda (até [timeout]) pela disponibilidade do evento
/// `beforeinstallprompt`. Retorna `true` se o PWA pode ser instalado.
Future<bool> waitBeforeInstallPrompt({
  Duration timeout = const Duration(seconds: 2),
}) async {
  if (!kIsWeb) return false;
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    try {
      if (_jsCanInstallPwa()) return true;
    } catch (_) {
      return false;
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  try {
    return _jsCanInstallPwa();
  } catch (_) {
    return false;
  }
}

/// Dispara a caixa de instalação nativa do navegador. Retorna `true` se foi
/// exibida com sucesso.
bool triggerInstallPrompt() {
  if (!kIsWeb) return false;
  try {
    return _jsTriggerInstallPrompt();
  } catch (_) {
    return false;
  }
}

/// Retorna o `userAgent` do navegador, ou `null` quando indisponível.
String? getUserAgent() {
  if (!kIsWeb) return null;
  try {
    return _jsNavigatorUserAgent.toDart;
  } catch (_) {
    return null;
  }
}
