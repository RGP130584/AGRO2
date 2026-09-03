import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/widgets/install_pwa_modal.dart';
import 'features/auth/views/splash_view.dart';

/// Navegador raiz do app. Fica válido durante toda a vida do app e é usado
/// para exibir o diálogo de instalação do PWA sobre a tela final
/// (Login/Home), sem competir com a navegação de abertura do Splash.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

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
      navigatorKey: appNavigatorKey,
      navigatorObservers: [InstallPromptObserver()],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SplashView(),
    );
  }
}

/// Observa a navegação e exibe o diálogo de instalação do PWA uma única vez,
/// após a primeira navegação real (Splash -> Login/Home) já ter ocorrido.
/// Assim o diálogo não é aberto e imediatamente removido pela troca de rota.
class InstallPromptObserver extends NavigatorObserver {
  bool _fired = false;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Dispara apenas na 1ª navegação não-diálogo (Splash para Login/Home).
    final isDialog = route is DialogRoute || route is PopupRoute;
    if (_fired || isDialog) return;
    final nav = navigator;
    if (nav == null) return;
    _fired = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = appNavigatorKey.currentContext;
      if (context == null) return;
      InstallPwaModal.show(context);
    });
  }
}
