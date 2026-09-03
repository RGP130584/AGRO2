import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pwa_install.dart'
    show getUserAgent, triggerInstallPrompt, waitBeforeInstallPrompt;

/// Modal de instalação do app (PWA).
///
/// Baseado no manifesto da pasta `web` (nome, cores e ícones), mostra um
/// diálogo ao abrir o app com as instruções de instalação adequadas para:
/// - Web em desktop (Windows/Linux): Chrome/Edge com `beforeinstallprompt`
/// - Android
/// - iOS
class InstallPwaModal extends StatefulWidget {
  const InstallPwaModal({super.key});

  static const String _dismissedKey = 'install_modal_dismissed';

  /// Mostra o modal de forma segura. Em apps nativos (android/ios) ele é
  /// ignorado, pois a instalação já ocorreu pela loja.
  static Future<void> show(BuildContext context) async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_dismissedKey) ?? false) return;

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

enum _InstallTarget { chromeDesktop, linux, android, ios, other }

class _InstallPwaModalState extends State<InstallPwaModal> {
  _InstallTarget _target = _InstallTarget.other;
  bool _canInstall = false;

  @override
  void initState() {
    super.initState();
    _detectPlatform();
  }

  Future<void> _detectPlatform() async {
    if (!kIsWeb) {
      _target = _nativePlatform();
    } else {
      await _initWebInstallPrompt();
      _target = _webTarget();
    }
    if (mounted) setState(() {});
  }

  _InstallTarget _nativePlatform() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _InstallTarget.android;
      case TargetPlatform.iOS:
        return _InstallTarget.ios;
      case TargetPlatform.linux:
        return _InstallTarget.linux;
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
        return _InstallTarget.chromeDesktop;
      default:
        return _InstallTarget.other;
    }
  }

  _InstallTarget _webTarget() {
    final ua = getUserAgent();
    if (ua == null) return _InstallTarget.chromeDesktop;
    final lower = ua.toLowerCase();
    if (lower.contains('android')) return _InstallTarget.android;
    if (lower.contains('iphone') ||
        lower.contains('ipad') ||
        lower.contains('ipod')) {
      return _InstallTarget.ios;
    }
    if (lower.contains('linux')) return _InstallTarget.linux;
    return _InstallTarget.chromeDesktop;
  }

  Future<void> _initWebInstallPrompt() async {
    _canInstall = await waitBeforeInstallPrompt();
  }

  Future<void> _dismiss([bool markSeen = false]) async {
    final prefs = await SharedPreferences.getInstance();
    if (markSeen) await prefs.setBool(InstallPwaModal._dismissedKey, true);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (title, message) = _contentFor(_target, _canInstall);

    return AlertDialog(
      icon: const Icon(
        Icons.download_for_offline,
        size: 56,
        color: Colors.green,
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => _dismiss(true),
          child: const Text('Agora não'),
        ),
        FilledButton(
          onPressed: _canInstall ? _install : () => _dismiss(true),
          child: Text(_canInstall ? 'Instalar' : 'Entendi'),
        ),
      ],
    );
  }

  (String, String) _contentFor(_InstallTarget target, bool canInstall) {
    switch (target) {
      case _InstallTarget.chromeDesktop:
        if (canInstall) {
          return (
            'Instalar o BovControl Pro',
            'Instale o app para usá-lo offline e com acesso rápido pela '
            'área de trabalho ou menu iniciar.',
          );
        }
        return (
          'Instalar o BovControl Pro',
          'Para instalar no navegador, use o ícone de instalação (⤓) na '
          'barra de endereço ou o menu em "Instalar aplicativo".',
        );
      case _InstallTarget.android:
        return (
          'Instalar o BovControl Pro',
          'Para instalar no Android, use o menu do navegador (⋮) e toque em '
          '"Adicionar à tela inicial" ou "Instalar aplicativo".',
        );
      case _InstallTarget.ios:
        return (
          'Instalar o BovControl Pro',
          'No iPhone/iPad, toque no botão Compartilhar (⇪) e selecione '
          '"Adicionar à Tela de Início".',
        );
      case _InstallTarget.linux:
        return (
          'Instalar o BovControl Pro',
          'No Linux, use o menu do navegador e selecione '
          '"Instalar BovControl Pro" para criar um atalho no ambiente gráfico.',
        );
      case _InstallTarget.other:
        return (
          'Instalar o BovControl Pro',
          'Use a opção de instalação do seu navegador para adicionar o app '
          'à tela inicial ou área de trabalho.',
        );
    }
  }

  Future<void> _install() async {
    final accepted = triggerInstallPrompt();
    if (mounted) {
      if (accepted) {
        await _dismiss(true);
      } else {
        setState(() => _canInstall = false);
      }
    }
  }
}

