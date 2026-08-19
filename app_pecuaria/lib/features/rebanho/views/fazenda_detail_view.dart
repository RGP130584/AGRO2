import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import 'piquete_form_view.dart';
import 'lote_form_view.dart';
import 'animal_list_view.dart';

final piquetesProvider = StreamProvider.family<List<Piquete>, String>((ref, fazendaId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.piquetes)..where((p) => p.fazendaId.equals(fazendaId))).watch();
});

final lotesProvider = StreamProvider.family<List<Lote>, String>((ref, fazendaId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.lotes)..where((l) => l.fazendaId.equals(fazendaId))).watch();
});

class FazendaDetailView extends ConsumerWidget {
  final String fazendaId;
  final String nomeFazenda;

  const FazendaDetailView({
    super.key,
    required this.fazendaId,
    required this.nomeFazenda,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final piquetesAsync = ref.watch(piquetesProvider(fazendaId));
    final lotesAsync = ref.watch(lotesProvider(fazendaId));

    return Scaffold(
      appBar: AppBar(title: Text(nomeFazenda)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Piquetes', style: Theme.of(context).textTheme.titleLarge),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PiqueteFormView(fazendaId: fazendaId)));
                },
                icon: const Icon(Icons.add),
                label: const Text('NOVO'),
              ),
            ],
          ),
          piquetesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Erro: $e'),
            data: (piquetes) {
              if (piquetes.isEmpty) return const Text('Nenhum piquete cadastrado.');
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: piquetes.map((p) => Chip(
                  avatar: const Icon(Icons.fence, size: 16),
                  label: Text('${p.nome} (${p.areaHectares ?? '?'} ha)'),
                )).toList(),
              );
            },
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Lotes', style: Theme.of(context).textTheme.titleLarge),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => LoteFormView(fazendaId: fazendaId)));
                },
                icon: const Icon(Icons.add),
                label: const Text('NOVO'),
              ),
            ],
          ),
          lotesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Erro: $e'),
            data: (lotes) {
              if (lotes.isEmpty) return const Text('Nenhum lote cadastrado.');
              return Column(
                children: lotes.map((l) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.group_work)),
                  title: Text(l.nome),
                  subtitle: Text('Categoria: ${l.categoria}'),
                )).toList(),
              );
            },
          ),
          const Divider(height: 32),
          FilledButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AnimalListView()));
            },
            icon: const Icon(Icons.pets),
            label: const Text('VER TODOS OS ANIMAIS'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
