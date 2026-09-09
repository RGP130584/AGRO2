import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'install_pwa_modal.dart';
import 'pwa_install.dart' show canInstallPwa, getUserAgent, isStandalone;

/// Botão de instalação do PWA para a AppBar.
///
/// Verifica se o app pode ser instalado e mostra um ícone de download.
/// Ao tocar abre o diálogo de instalação que dispara o prompt nativo do PWA.
class PwaInstallButton extends StatefulWidget {
  const PwaInstallButton({super.key});

  @override
  State<PwaInstallButton> createState() => _PwaInstallButtonState();
}

class _PwaInstallButtonState extends State<PwaInstallButton> {
  bool _canInstall = false;
  _PlatformKind _platform = _PlatformKind.other;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<void> _check() async {
    if (isStandalone()) return;

    if (kIsWeb) {
      for (var i = 0; i < 20; i++) {
        if (canInstallPwa()) break;
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }

    if (!mounted) return;

    final canInstall = canInstallPwa();
    final ua = getUserAgent();
    _platform = _detectPlatform(ua);

    setState(() => _canInstall = canInstall);
  }

  _PlatformKind _detectPlatform(String? ua) {
    if (ua == null) return _PlatformKind.desktop;
    final lower = ua.toLowerCase();
    if (lower.contains('android')) return _PlatformKind.android;
    if (lower.contains('iphone') ||
        lower.contains('ipad') ||
        lower.contains('ipod')) {
      return _PlatformKind.ios;
    }
    return _PlatformKind.desktop;
  }

  void _onTap() {
    InstallPwaModal.show(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || isStandalone()) return const SizedBox.shrink();

    final isIos = _platform == _PlatformKind.ios;
    final isAndroid = _platform == _PlatformKind.android;
    // No celular (iOS/Android) o botão sempre aparece: a instalação é feita
    // via "Adicionar à tela inicial" quando não há prompt nativo. No desktop
    // só aparece quando há prompt nativo disponível.
    if (!isIos && !isAndroid && !_canInstall) return const SizedBox.shrink();

    return IconButton(
      icon: Icon(isIos ? Icons.add_to_home_screen : Icons.download_outlined),
      tooltip: isIos ? 'Adicionar à Tela de Início' : 'Instalar app',
      onPressed: _onTap,
    );
  }
}

enum _PlatformKind { desktop, android, ios, other }
