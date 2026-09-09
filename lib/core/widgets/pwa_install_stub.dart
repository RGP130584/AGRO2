/// Stub para plataformas não-web (Windows, Android, iOS, Linux, macOS).
///
/// O `dart:js_interop` só existe em web, portanto estas funções retornam
/// valores neutros quando compiladas para plataformas nativas.
bool canInstallPwa() => false;

bool isStandalone() => false;

Future<bool> waitBeforeInstallPrompt({
  Duration timeout = const Duration(seconds: 2),
}) async {
  return false;
}

bool triggerInstallPrompt() => false;

String? getUserAgent() => null;
