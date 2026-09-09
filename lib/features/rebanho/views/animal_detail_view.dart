import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'historico_pesagem_list.dart';
import 'registro_pesagem_view.dart';
/// Tela para exibir os detalhes completos de um animal.
///
/// No futuro, esta tela conterá o histórico sanitário, reprodutivo,
/// de pesagem e outras informações detalhadas.
class AnimalDetailView extends ConsumerWidget {
  final String animalId;
  final String animalBrinco;

  const AnimalDetailView({
    super.key,
    required this.animalId,
    required this.animalBrinco,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes: ${animalBrinco}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Histórico de Pesagem (Em Breve)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          HistoricoPesagemList(animalId: animalId),
          // TODO: Adicionar outros históricos aqui (sanitário, reprodutivo, etc.)
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => RegistroPesagemView(
            animalId: animalId,
            animalBrinco: animalBrinco,
          )));
        },
        icon: const Icon(Icons.add),
        label: const Text('NOVA PESAGEM'),
      ),
    );
  }
}