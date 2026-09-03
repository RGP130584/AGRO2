import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'pwa_install.dart'
    show getUserAgent, isStandalone, triggerInstallPrompt;

/// Diálogo automático de instalação do PWA.
///
/// Chamado no [LoginView] e no [HomeView]. Aparece sempre que o app
/// não está instalado como PWA ([isStandalone] == false).
/// Não usa persistência — se o app não estiver instalado, o diálogo
/// volta a aparecer no próximo acesso.
class InstallPwaModal extends StatefulWidget {
  const InstallPwaModal({super.key});

  static Future<void> show(BuildContext context) async {
    if (!kIsWeb) return;
    if (isStandalone()) return;

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const InstallPwaModal(),
    );
  }

  @override
  State<InstallPwaModal> createState() => _InstallPwaModalState();
}

enum _PlatformKind { desktop, android, ios }

class _InstallPwaModalState extends State<InstallPwaModal> {
  _PlatformKind _platform = _PlatformKind.desktop;
  bool _detecting = true;

  @override
  void initState() {
    super.initState();
    _detect();
  }

  Future<void> _detect() async {
    final ua = getUserAgent();
    _platform = _detectPlatform(ua);
    if (!mounted) return;

    setState(() => _detecting = false);
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

  bool get _isIos => _platform == _PlatformKind.ios;

  // Só no iOS a instalação é manual (Adicionar à Tela de Início) —
  // Android e desktop usam o prompt nativo do PWA.
  bool get _manualOnly => _isIos;

  void _close() {
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirm() async {
    // Sempre tenta disparar o prompt nativo — ele pode ter chegado
    // depois da janela de detecção de 2 s. Se não existir, é no-op.
    triggerInstallPrompt();
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_detecting) {
      return AlertDialog(
        icon: const SizedBox(
          width: 56,
          height: 56,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        title: const Text('Preparando instalação...', textAlign: TextAlign.center),
        content: const Text(
          'Verificando compatibilidade do navegador.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: _close,
            child: const Text('Agora não'),
          ),
        ],
      );
    }

    if (_manualOnly) {
      final (title, desc) = _manualGuide();
      return AlertDialog(
        icon: const Icon(Icons.add_to_home_screen, size: 56, color: Colors.green),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(desc, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: _close,
            child: const Text('Agora não'),
          ),
          FilledButton(
            onPressed: _confirm,
            child: const Text('Entendi'),
          ),
        ],
      );
    }

    return AlertDialog(
      icon: const Icon(Icons.download_for_offline, size: 56, color: Colors.green),
      title: Text(
        'Instalar o BovControl Pro',
        textAlign: TextAlign.center,
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'Toque em Instalar para adicionar o app ao seu dispositivo.',
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: _close,
          child: const Text('Agora não'),
        ),
        FilledButton.icon(
          onPressed: _confirm,
          icon: const Icon(Icons.download, size: 18),
          label: const Text('Instalar'),
        ),
      ],
    );
  }

  (String, String) _manualGuide() {
    return (
      'Adicionar ao iPhone / iPad',
      'No Safari, toque em Compartilhar, escolha '
      '"Adicionar à Tela de Início" e confirme em Adicionar.',
    );
  }
}
