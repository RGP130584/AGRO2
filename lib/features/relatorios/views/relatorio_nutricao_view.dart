import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/database_provider.dart';
import '../../rebanho/views/fazenda_list_view.dart';

class RelatorioNutricaoView extends ConsumerStatefulWidget {
  final String? fazendaId;
  const RelatorioNutricaoView({super.key, this.fazendaId});

  @override
  ConsumerState<RelatorioNutricaoView> createState() => _RelatorioNutricaoViewState();
}

class _RelatorioNutricaoViewState extends ConsumerState<RelatorioNutricaoView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _activeFazendaId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _activeFazendaId = widget.fazendaId;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fazendasAsync = ref.watch(fazendasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrição e Dietas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.restaurant_menu), text: 'Consumo por Lote'),
            Tab(icon: Icon(Icons.compare_arrows), text: 'Divergências'),
          ],
        ),
        actions: [
          fazendasAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (fazendas) => fazendas.length > 1
                ? DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _activeFazendaId ?? fazendas.first.id,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      items: fazendas.map((f) => DropdownMenuItem(value: f.id, child: Text(f.nome))).toList(),
                      onChanged: (v) => setState(() => _activeFazendaId = v),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: fazendasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (fazendas) {
          final fazendaId = _activeFazendaId ?? (fazendas.isNotEmpty ? fazendas.first.id : null);
          if (fazendaId == null) return const Center(child: Text('Nenhuma fazenda.'));

          return TabBarView(
            controller: _tabController,
            children: [
              _buildConsumoTab(fazendaId),
              _buildDivergenciasTab(fazendaId),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConsumoTab(String fazendaId) {
    final db = ref.watch(databaseProvider);

    // Query: FornecimentosDieta → Dieta → Lote → Produto, filtrado por fazenda
    final query = db.select(db.fornecimentosDieta).join([
      drift.innerJoin(db.dietas, db.dietas.id.equalsExp(db.fornecimentosDieta.dietaId)),
      drift.innerJoin(db.lotes, db.lotes.id.equalsExp(db.fornecimentosDieta.loteId)),
      drift.innerJoin(db.produtos, db.produtos.id.equalsExp(db.dietas.produtoId)),
    ])..where(db.lotes.fazendaId.equals(fazendaId));

    return StreamBuilder<List<drift.TypedResult>>(
      stream: query.watch(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final rows = snapshot.data!;
        if (rows.isEmpty) return const Center(child: Text('Nenhum fornecimento registrado nesta fazenda.'));

        // Agrupar por lote → produto
        final byLote = <String, Map<String, ({String produtoNome, String unidade, double totalQtd})>>{};
        final loteNomes = <String, String>{};

        for (final row in rows) {
          final forn = row.readTable(db.fornecimentosDieta);
          final lote = row.readTable(db.lotes);
          final produto = row.readTable(db.produtos);

          loteNomes[lote.id] = lote.nome;
          byLote.putIfAbsent(lote.id, () => {});
          final existing = byLote[lote.id]![produto.id];
          byLote[lote.id]![produto.id] = (
            produtoNome: produto.nome,
            unidade: produto.unidade,
            totalQtd: (existing?.totalQtd ?? 0) + forn.quantidadeFornecida,
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: byLote.entries.map((loteEntry) {
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  child: Icon(Icons.grass, color: Colors.orange.shade800),
                ),
                title: Text(loteNomes[loteEntry.key] ?? loteEntry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${loteEntry.value.length} insumo${loteEntry.value.length > 1 ? 's' : ''}'),
                children: loteEntry.value.values.map((produto) {
                  return ListTile(
                    dense: true,
                    title: Text(produto.produtoNome),
                    trailing: Text(
                      '${produto.totalQtd.toStringAsFixed(1)} ${produto.unidade}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDivergenciasTab(String fazendaId) {
    final db = ref.watch(databaseProvider);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Query: todos os fornecimentos com dieta e lote, para calcular divergência
    final query = db.select(db.fornecimentosDieta).join([
      drift.innerJoin(db.dietas, db.dietas.id.equalsExp(db.fornecimentosDieta.dietaId)),
      drift.innerJoin(db.lotes, db.lotes.id.equalsExp(db.fornecimentosDieta.loteId)),
      drift.innerJoin(db.produtos, db.produtos.id.equalsExp(db.dietas.produtoId)),
    ])
      ..where(db.lotes.fazendaId.equals(fazendaId))
      ..orderBy([drift.OrderingTerm.desc(db.fornecimentosDieta.dataFornecimento)]);

    return StreamBuilder<List<drift.TypedResult>>(
      stream: query.watch(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final rows = snapshot.data!;

        // Calcular divergências
        final divergencias = <Map<String, dynamic>>[];
        for (final row in rows) {
          final forn = row.readTable(db.fornecimentosDieta);
          final dieta = row.readTable(db.dietas);
          final lote = row.readTable(db.lotes);
          final produto = row.readTable(db.produtos);

          final planejado = dieta.quantidadePorCabecaDia * lote.quantidade;
          if (planejado <= 0) continue;

          final divergencia = ((forn.quantidadeFornecida - planejado) / planejado * 100).abs();
          if (divergencia > 15) {
            divergencias.add({
              'data': forn.dataFornecimento,
              'loteNome': lote.nome,
              'produtoNome': produto.nome,
              'fornecido': forn.quantidadeFornecida,
              'planejado': planejado,
              'divergencia': divergencia,
              'acimaDoPlanejado': forn.quantidadeFornecida > planejado,
            });
          }
        }

        if (divergencias.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, size: 72, color: Colors.green.shade400),
                const SizedBox(height: 12),
                const Text('Nenhuma divergência acima de 15%!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                const Text('Todos os fornecimentos estão dentro do planejado.'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: divergencias.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Text(
                  '${divergencias.length} registro${divergencias.length > 1 ? 's' : ''} com divergência > 15%',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                ),
              );
            }
            final item = divergencias[i - 1];
            final acima = item['acimaDoPlanejado'] as bool;
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  child: Icon(acima ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.orange.shade800),
                ),
                title: Text('${item['loteNome']} — ${item['produtoNome']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Fornecido: ${(item['fornecido'] as double).toStringAsFixed(1)} | Planejado: ${(item['planejado'] as double).toStringAsFixed(1)}\n${dateFormat.format(item['data'] as DateTime)}',
                ),
                trailing: Text(
                  '${acima ? "+" : "-"}${(item['divergencia'] as double).toStringAsFixed(1)}%',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800, fontSize: 14),
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
