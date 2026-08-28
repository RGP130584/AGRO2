import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../services/relatorio_rebanho_service.dart';

class RelatorioGmdView extends ConsumerStatefulWidget {
  final String? fazendaId;
  const RelatorioGmdView({super.key, this.fazendaId});

  @override
  ConsumerState<RelatorioGmdView> createState() => _RelatorioGmdViewState();
}

class _RelatorioGmdViewState extends ConsumerState<RelatorioGmdView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _animalSelecionadoId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('GMD e Crescimento'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart), text: 'GMD por Lote'),
            Tab(icon: Icon(Icons.trending_up), text: 'Curva Individual'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGmdLoteTab(),
          _buildCurvaIndividualTab(),
        ],
      ),
    );
  }

  Widget _buildGmdLoteTab() {
    final service = ref.watch(relatorioRebanhoServiceProvider);
    final fazendaId = widget.fazendaId;
    if (fazendaId == null) return const Center(child: Text('Selecione uma fazenda.'));

    return FutureBuilder<List<GmdLote>>(
      future: service.getGmdPorLote(fazendaId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final lotes = snapshot.data!;

        if (lotes.isEmpty) {
          return const Center(child: Text('Sem pesagens suficientes para calcular GMD por lote.'));
        }

        final maxGmd = lotes.map((l) => l.gmdMedio.abs()).reduce((a, b) => a > b ? a : b);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Gráfico de barras
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GMD Médio por Lote (kg/dia)', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxGmd * 1.3,
                          barGroups: lotes.asMap().entries.map((e) {
                            final isGood = e.value.gmdMedio >= 0;
                            return BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value.gmdMedio.abs(),
                                  color: isGood ? Colors.teal : Colors.red,
                                  width: 20,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                ),
                              ],
                            );
                          }).toList(),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1), style: const TextStyle(fontSize: 10)),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, _) {
                                  final idx = v.toInt();
                                  if (idx < 0 || idx >= lotes.length) return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      lotes[idx].loteNome.length > 6 ? '${lotes[idx].loteNome.substring(0, 6)}..' : lotes[idx].loteNome,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: const FlGridData(show: true),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tabela
            ...lotes.map((lote) {
              final isGood = lote.gmdMedio >= 0;
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isGood ? Colors.teal.shade100 : Colors.red.shade100,
                    child: Icon(isGood ? Icons.trending_up : Icons.trending_down, color: isGood ? Colors.teal.shade800 : Colors.red.shade800),
                  ),
                  title: Text(lote.loteNome, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Peso médio atual: ${lote.pesoMedioAtual.toStringAsFixed(1)} kg • ${lote.totalPesagens} pesagens'),
                  trailing: Text(
                    '${isGood ? "+" : ""}${lote.gmdMedio.toStringAsFixed(2)} kg/dia',
                    style: TextStyle(fontWeight: FontWeight.bold, color: isGood ? Colors.teal.shade800 : Colors.red.shade800),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildCurvaIndividualTab() {
    final db = ref.watch(databaseProvider);
    final service = ref.watch(relatorioRebanhoServiceProvider);
    final dateFormat = DateFormat('dd/MM');

    return StreamBuilder<List<Animal>>(
      stream: (db.select(db.animais)..where((a) => a.deletedAt.isNull())).watch(),
      builder: (context, snapshot) {
        final animais = snapshot.data ?? [];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<String>(
                value: _animalSelecionadoId,
                decoration: InputDecoration(
                  labelText: 'Selecione o Animal (Brinco)',
                  prefixIcon: const Icon(Icons.pets),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: animais.map((a) => DropdownMenuItem(value: a.id, child: Text('Brinco ${a.brinco} — ${a.raca}'))).toList(),
                onChanged: (v) => setState(() => _animalSelecionadoId = v),
              ),
            ),
            if (_animalSelecionadoId == null)
              const Expanded(child: Center(child: Text('Selecione um animal para ver a curva de crescimento.')))
            else
              Expanded(
                child: StreamBuilder<List<Pesagem>>(
                  stream: service.watchPesagensAnimal(_animalSelecionadoId!),
                  builder: (context, snapPes) {
                    final pesagens = snapPes.data ?? [];
                    if (pesagens.length < 2) {
                      return const Center(child: Text('São necessárias ao menos 2 pesagens para gerar o gráfico.'));
                    }

                    final spots = pesagens.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.peso)).toList();

                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Curva de Crescimento', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              Expanded(
                                child: LineChart(
                                  LineChartData(
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: spots,
                                        isCurved: true,
                                        color: Colors.teal,
                                        barWidth: 3,
                                        dotData: FlDotData(
                                          getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                                            radius: 5,
                                            color: Colors.teal,
                                            strokeWidth: 2,
                                            strokeColor: Colors.white,
                                          ),
                                        ),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: Colors.teal.withValues(alpha: 0.1),
                                        ),
                                      ),
                                    ],
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 45,
                                          getTitlesWidget: (v, _) => Text('${v.toStringAsFixed(0)}kg', style: const TextStyle(fontSize: 10)),
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (v, _) {
                                            final idx = v.toInt();
                                            if (idx < 0 || idx >= pesagens.length) return const SizedBox.shrink();
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 6),
                                              child: Text(dateFormat.format(pesagens[idx].dataPesagem), style: const TextStyle(fontSize: 9)),
                                            );
                                          },
                                        ),
                                      ),
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    gridData: const FlGridData(show: true),
                                    borderData: FlBorderData(show: false),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
