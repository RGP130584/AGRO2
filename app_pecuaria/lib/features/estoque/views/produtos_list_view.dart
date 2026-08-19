import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../../estoque/views/produto_form_view.dart';

final produtosComSaldoProvider = StreamProvider<List<({Produto produto, double saldo})>>((ref) {
  final db = ref.watch(databaseProvider);

  return db.select(db.produtos).watch().asyncMap((produtos) async {
    final result = <({Produto produto, double saldo})>[];
    for (final p in produtos) {
      final movimentos = await (db.select(db.estoqueMovimentos)
            ..where((m) => m.produtoId.equals(p.id)))
          .get();

      double saldo = 0;
      for (final m in movimentos) {
        if (m.tipo == 'entrada') saldo += m.quantidade;
        if (m.tipo == 'saida') saldo -= m.quantidade;
      }
      result.add((produto: p, saldo: saldo));
    }
    return result;
  });
});

class ProdutosListView extends ConsumerWidget {
  const ProdutosListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final produtosAsync = ref.watch(produtosComSaldoProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Estoque de Insumos'),
        centerTitle: false,
        elevation: 0,
      ),
      body: produtosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: Theme.of(context).colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text('Nenhum produto cadastrado', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('Toque no botão + para adicionar vacinas, medicamentos ou rações'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final p = items[i].produto;
              final saldo = items[i].saldo;
              final estaBaixo = saldo < p.estoqueMinimo && p.estoqueMinimo > 0;

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                color: estaBaixo ? Colors.red[50] : null,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: estaBaixo ? Colors.red[100] : Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      _iconePorTipo(p.tipo),
                      color: estaBaixo ? Colors.red[700] : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(p.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      if (estaBaixo)
                        const Icon(Icons.warning_amber, color: Colors.red, size: 20),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Saldo: ${saldo.toStringAsFixed(1)} ${p.unidade}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: estaBaixo ? Colors.red[700] : Colors.green[700],
                        ),
                      ),
                      if (estaBaixo)
                        Text(
                          'Mínimo: ${p.estoqueMinimo.toStringAsFixed(0)} ${p.unidade}',
                          style: TextStyle(color: Colors.red[700], fontSize: 12),
                        ),
                      if (p.carenciaDiasPadrao > 0)
                        Text('Carência: ${p.carenciaDiasPadrao} dias', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: _badgeTipo(context, p.tipo),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_estoque',
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProdutoFormView()));
        },
        icon: const Icon(Icons.add),
        label: const Text('NOVO PRODUTO'),
      ),
    );
  }

  IconData _iconePorTipo(String tipo) {
    switch (tipo) {
      case 'vacina': return Icons.vaccines;
      case 'medicamento': return Icons.medication;
      case 'racao': return Icons.grass;
      case 'mineral': return Icons.diamond_outlined;
      default: return Icons.inventory;
    }
  }

  Widget _badgeTipo(BuildContext context, String tipo) {
    final labels = {'vacina': 'Vacina', 'medicamento': 'Remédio', 'racao': 'Ração', 'mineral': 'Mineral'};
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(labels[tipo] ?? tipo, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSecondaryContainer)),
    );
  }
}
