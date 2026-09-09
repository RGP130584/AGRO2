import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/animal_list_item.dart';
import 'animal_form_view.dart';
import 'animal_detail_view.dart';
import '../services/rebanho_service.dart';

final animalListProvider = StreamProvider<List<AnimalListItem>>((ref) {
  final rebanhoService = ref.watch(rebanhoServiceProvider);
  return rebanhoService.watchAnimaisParaListagem();
});

class AnimalListView extends ConsumerWidget {
  const AnimalListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animaisAsync = ref.watch(animalListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Rebanho'),
      ),
      body: animaisAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
        data: (animais) {
          if (animais.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum animal cadastrado ainda.\nClique no botão + para começar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: animais.length,
            itemBuilder: (context, index) {
              final item = animais[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: const Icon(Icons.pets),
                  ),
                  title: Text(
                    'Brinco: ${item.animal.brinco}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text('Lote: ${item.lote.nome}'),
                  trailing: _buildCarenciaChip(item),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnimalDetailView(
                          animalId: item.animal.id,
                          animalBrinco: item.animal.brinco,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AnimalFormView()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('NOVO ANIMAL'),
      ),
    );
  }

  Widget _buildCarenciaChip(AnimalListItem item) {
    if (!item.emCarencia) {
      return const Chip(
        avatar: Icon(Icons.check_circle, color: Colors.green, size: 18),
        label: Text('Liberado'),
        backgroundColor: Color.fromARGB(255, 227, 240, 227),
        visualDensity: VisualDensity.compact,
      );
    }

    final formattedDate = item.carenciaFim != null
        ? DateFormat('dd/MM/yy').format(item.carenciaFim!)
        : '';

    return Tooltip(
      message: 'Em carência até $formattedDate',
      child: Chip(
        avatar: const Icon(Icons.warning, color: Colors.white, size: 18),
        label: const Text('CARÊNCIA'),
        labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        backgroundColor: Colors.redAccent,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}