import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../services/relatorio_estoque_service.dart';

class RelatorioEstoqueView extends ConsumerStatefulWidget {
  final String? fazendaId;
  const RelatorioEstoqueView({super.key, this.fazendaId});

  @override
  ConsumerState<RelatorioEstoqueView> createState() => _RelatorioEstoqueViewState();
}

class _RelatorioEstoqueViewState extends ConsumerState<RelatorioEstoqueView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _produtoSelecionadoId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estoque'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Saldo'),
            Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Kardex'),
            Tab(icon: Icon(Icons.event_busy_outlined), text: 'Vencimentos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSaldoTab(),
          _buildKardexTab(),
          _buildVencimentosTab(),
        ],
      ),
    );
  }

  Widget _buildSaldoTab() {
    final service = ref.watch(relatorioEstoqueServiceProvider);

    return StreamBuilder<List<SaldoProduto>>(
      stream: service.watchSaldoConsolidado(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data!;
        if (items.isEmpty) return const Center(child: Text('Nenhum produto no estoque.'));

        final baixos = items.where((i) => i.saldo <= i.produto.estoqueMinimo && i.produto.estoqueMinimo > 0).length;
        final aVencer = items.where((i) => i.proximoVencimento != null).length;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Resumo
            Row(
              children: [
                Expanded(child: _buildSummaryCard('${items.length}', 'Produtos', Colors.blueGrey.shade700, Icons.inventory_2)),
                const SizedBox(width: 10),
                Expanded(child: _buildSummaryCard('$baixos', 'Estoque Baixo', Colors.red.shade700, Icons.warning_amber)),
                const SizedBox(width: 10),
                Expanded(child: _buildSummaryCard('$aVencer', 'A Vencer', Colors.orange.shade700, Icons.event_busy)),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) {
              final estaBaixo = item.saldo <= item.produto.estoqueMinimo && item.produto.estoqueMinimo > 0;
              final aVencer = item.proximoVencimento != null;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 8),
                color: estaBaixo ? Colors.red.shade50 : (aVencer ? Colors.orange.shade50 : null),
                child: ListTile(
                  title: Text(item.produto.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item.saldo.toStringAsFixed(1)} ${item.produto.unidade}', style: TextStyle(fontWeight: FontWeight.bold, color: estaBaixo ? Colors.red.shade800 : Colors.green.shade800)),
                      if (aVencer) Text('⚠️ Vence: ${DateFormat('dd/MM/yyyy').format(item.proximoVencimento!)}', style: TextStyle(color: Colors.orange.shade900, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  trailing: estaBaixo
                      ? const Chip(label: Text('CRÍTICO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)), backgroundColor: Colors.red)
                      : const Chip(label: Text('OK', style: TextStyle(color: Colors.white, fontSize: 10)), backgroundColor: Colors.green),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildKardexTab() {
    final service = ref.watch(relatorioEstoqueServiceProvider);
    final db = ref.watch(databaseProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      children: [
        // Seletor de produto
        Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<List<Produto>>(
            stream: db.select(db.produtos).watch(),
            builder: (context, snapshot) {
              final produtos = snapshot.data ?? [];
              return DropdownButtonFormField<String>(
                value: _produtoSelecionadoId,
                decoration: InputDecoration(
                  labelText: 'Selecione o Produto',
                  prefixIcon: const Icon(Icons.inventory_2_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: produtos.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nome))).toList(),
                onChanged: (v) => setState(() => _produtoSelecionadoId = v),
              );
            },
          ),
        ),
        if (_produtoSelecionadoId == null)
          const Expanded(child: Center(child: Text('Selecione um produto para ver o Kardex.')))
        else
          Expanded(
            child: StreamBuilder<List<KardexItem>>(
              stream: service.watchKardex(_produtoSelecionadoId!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final items = snapshot.data!;
                if (items.isEmpty) return const Center(child: Text('Nenhuma movimentação registrada para este produto.'));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    final isEntrada = item.movimento.tipo == 'entrada';

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        leading: Icon(
                          isEntrada ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isEntrada ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                        title: Text(
                          '${isEntrada ? "+" : "-"}${item.movimento.quantidade.toStringAsFixed(1)}  •  ${item.movimento.origem}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: isEntrada ? Colors.green.shade800 : Colors.red.shade800),
                        ),
                        subtitle: Text(dateFormat.format(item.movimento.createdAt)),
                        trailing: Text(
                          'Saldo: ${item.saldoAcumulado.toStringAsFixed(1)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildVencimentosTab() {
    final service = ref.watch(relatorioEstoqueServiceProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return FutureBuilder<List<({Produto produto, DateTime dataValidade, double quantidade})>>(
      future: service.getProdutosAVencer(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data!;

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, size: 72, color: Colors.green.shade400),
                const SizedBox(height: 12),
                const Text('Nenhum produto com vencimento nos próximos 30 dias!'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            final diasRestantes = item.dataValidade.difference(DateTime.now()).inDays;

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 10),
              color: diasRestantes <= 7 ? Colors.red.shade50 : Colors.orange.shade50,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: diasRestantes <= 7 ? Colors.red.shade200 : Colors.orange.shade200,
                  child: Icon(Icons.event_busy, color: diasRestantes <= 7 ? Colors.red.shade900 : Colors.orange.shade900),
                ),
                title: Text(item.produto.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Qtd: ${item.quantidade.toStringAsFixed(1)} ${item.produto.unidade}\nVence: ${dateFormat.format(item.dataValidade)}'),
                trailing: Chip(
                  label: Text(
                    '$diasRestantes dias',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: diasRestantes <= 7 ? Colors.red : Colors.orange,
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
