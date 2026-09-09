import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import 'fazenda_form_view.dart';
import 'animal_form_view.dart';
import 'fazenda_detail_view.dart';

final fazendasProvider = StreamProvider<List<Fazenda>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.fazendas)
        ..where((f) => f.deletedAt.isNull()))
      .watch();
});

class FazendaListView extends ConsumerWidget {
  const FazendaListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fazendasAsync = ref.watch(fazendasProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Minhas Fazendas'),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: fazendasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (fazendas) {
          if (fazendas.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.landscape_outlined, size: 80, color: Theme.of(context).colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text('Nenhuma fazenda cadastrada', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('Toque no botão + para começar'),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: fazendas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final f = fazendas[i];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.landscape, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(f.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text(
                    [
                      if (f.responsavel != null) f.responsavel!,
                      if (f.cidade != null && f.estado != null) '${f.cidade} - ${f.estado}',
                      if (f.cpfCnpj != null) 'CPF/CNPJ: ${f.cpfCnpj}',
                    ].join('\n'),
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FazendaDetailView(
                          fazendaId: f.id,
                          nomeFazenda: f.nome,
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'fab_animal',
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const AnimalFormView()));
            },
            backgroundColor: Colors.brown[700],
            child: const Icon(Icons.pets, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'fab_fazenda',
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const FazendaFormView()));
            },
            icon: const Icon(Icons.add),
            label: const Text('NOVA FAZENDA'),
          ),
        ],
      ),
    );
  }
}
