import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'registro_aplicacao_view.dart';

/// Tela principal para o módulo de Saúde Animal.
class SaudeView extends ConsumerWidget {
  const SaudeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Módulo de Saúde (em desenvolvimento)'),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.vaccines),
              label: const Text('Registrar Nova Aplicação'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistroAplicacaoView())),
            )
          ],
        ),
      ),
    );
  }
}