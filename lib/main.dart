import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/widgets/install_pwa_modal.dart';
import 'features/auth/views/splash_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: AppPecuaria(),
    ),
  );
}

class AppPecuaria extends StatelessWidget {
  const AppPecuaria({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Pecuária',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const _PwaInstallLauncher(
        child: SplashView(),
      ),
    );
  }
}

/// Mostra o modal de instalação (PWA) logo na abertura do app.
class _PwaInstallLauncher extends StatefulWidget {
  const _PwaInstallLauncher({required this.child});

  final Widget child;

  @override
  State<_PwaInstallLauncher> createState() => _PwaInstallLauncherState();
}

class _PwaInstallLauncherState extends State<_PwaInstallLauncher> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_shown || !mounted) return;
      _shown = true;
      InstallPwaModal.show(context);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
