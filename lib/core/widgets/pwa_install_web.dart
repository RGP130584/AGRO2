// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';

import 'package:flutter/foundation.dart' show kIsWeb;

@JS('window.__canInstallPwa')
external bool _jsCanInstallPwa();

@JS('window.__triggerInstallPrompt')
external bool _jsTriggerInstallPrompt();

@JS('window.__isStandalone')
external bool _jsIsStandalone();

@JS('navigator.userAgent')
external JSString get _jsNavigatorUserAgent;

bool canInstallPwa() {
  if (!kIsWeb) return false;
  try {
    return _jsCanInstallPwa();
  } catch (_) {
    return false;
  }
}

bool isStandalone() {
  if (!kIsWeb) return false;
  try {
    return _jsIsStandalone();
  } catch (_) {
    return false;
  }
}

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

bool triggerInstallPrompt() {
  if (!kIsWeb) return false;
  try {
    return _jsTriggerInstallPrompt();
  } catch (_) {
    return false;
  }
}

String? getUserAgent() {
  if (!kIsWeb) return null;
  try {
    return _jsNavigatorUserAgent.toDart;
  } catch (_) {
    return null;
  }
}
