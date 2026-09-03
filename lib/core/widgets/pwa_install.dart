/// Fachada para as funções de instalação do PWA.
///
/// Em web usa a implementação real baseada em `dart:js_interop`; nas demais
/// plataformas usa um stub neutro, evitando erro de compilação do
/// `dart:js_interop` em builds nativos (Windows, Android, iOS, etc.).
export 'pwa_install_stub.dart'
    if (dart.library.js_interop) 'pwa_install_web.dart';
