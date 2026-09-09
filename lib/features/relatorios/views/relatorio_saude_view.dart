import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../services/relatorio_rebanho_service.dart';

class RelatorioSaudeView extends ConsumerStatefulWidget {
  final String? fazendaId;
  const RelatorioSaudeView({super.key, this.fazendaId});

  @override
  ConsumerState<RelatorioSaudeView> createState() => _RelatorioSaudeViewState();
}

class _RelatorioSaudeViewState extends ConsumerState<RelatorioSaudeView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        title: const Text('Saúde Animal'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.timer_off_outlined), text: 'Em Carência'),
            Tab(icon: Icon(Icons.vaccines), text: 'Por Produto'),
            Tab(icon: Icon(Icons.warning_amber), text: 'Ocorrências'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCarenciaTab(),
          _buildPorProdutoTab(),
          _buildOcorrenciasTab(),
        ],
      ),
    );
  }

  Widget _buildCarenciaTab() {
    final service = ref.watch(relatorioRebanhoServiceProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return FutureBuilder<List<AnimaisEmCarencia>>(
      future: service.getAnimaisEmCarencia(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;

        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, size: 72, color: Colors.green.shade400),
                const SizedBox(height: 16),
                const Text('Nenhum animal em período de carência!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Todos os animais estão aptos para venda/abate.'),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Banner de atenção
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade800, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${list.length} animal${list.length > 1 ? 'is' : ''} NÃO APTO${list.length > 1 ? 'S' : ''} para venda ou abate',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade900),
                    ),
                  ),
                ],
              ),
            ),
            ...list.map((item) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 10),
              color: item.diasRestantes <= 3 ? Colors.red.shade50 : null,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Brinco: ${item.animal.brinco}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Chip(
                          label: Text(
                            '${item.diasRestantes} dia${item.diasRestantes != 1 ? 's' : ''}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11),
                          ),
                          backgroundColor: item.diasRestantes <= 5 ? Colors.red : Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Produto: ${item.produtoNome}'),
                    Text('Liberação: ${dateFormat.format(item.carenciaFim)}', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            )),
          ],
        );
      },
    );
  }

  Widget _buildPorProdutoTab() {
    final db = ref.watch(databaseProvider);

    final query = db.select(db.aplicacoesSanitarias).join([
      drift.innerJoin(db.produtos, db.produtos.id.equalsExp(db.aplicacoesSanitarias.produtoId)),
    ])..orderBy([drift.OrderingTerm.asc(db.produtos.nome)]);

    return StreamBuilder<List<drift.TypedResult>>(
      stream: query.watch(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final rows = snapshot.data!;
        if (rows.isEmpty) return const Center(child: Text('Nenhuma aplicação sanitária registrada.'));

        // Agrupar por produto
        final byProduto = <String, ({String nome, String unidade, double totalDose, int totalAplicacoes})>{};
        for (final row in rows) {
          final app = row.readTable(db.aplicacoesSanitarias);
          final produto = row.readTable(db.produtos);
          final existing = byProduto[produto.id];
          byProduto[produto.id] = (
            nome: produto.nome,
            unidade: produto.unidade,
            totalDose: (existing?.totalDose ?? 0) + app.dose,
            totalAplicacoes: (existing?.totalAplicacoes ?? 0) + 1,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: byProduto.length,
          itemBuilder: (context, i) {
            final entry = byProduto.entries.elementAt(i);
            final item = entry.value;
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal.shade100,
                  child: Icon(Icons.vaccines, color: Colors.teal.shade800),
                ),
                title: Text(item.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${item.totalAplicacoes} aplicações'),
                trailing: Text(
                  '${item.totalDose.toStringAsFixed(1)} ${item.unidade}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade800),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOcorrenciasTab() {
    final db = ref.watch(databaseProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    final query = db.select(db.ocorrenciasSanitarias).join([
      drift.innerJoin(db.animais, db.animais.id.equalsExp(db.ocorrenciasSanitarias.animalId)),
    ])..orderBy([drift.OrderingTerm.desc(db.ocorrenciasSanitarias.dataOcorrencia)]);

    return StreamBuilder<List<drift.TypedResult>>(
      stream: query.watch(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final rows = snapshot.data!;
        if (rows.isEmpty) return const Center(child: Text('Nenhuma ocorrência sanitária registrada.'));

        // Calcular taxa de mortalidade
        final obitos = rows.where((r) => r.readTable(db.ocorrenciasSanitarias).tipo == 'obito').length;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (obitos > 0) ...[
              Card(
                color: Colors.red.shade800,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.heart_broken, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$obitos óbito${obitos > 1 ? 's' : ''} registrado${obitos > 1 ? 's' : ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const Text('Total de mortes no histórico', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            ...rows.map((row) {
              final ocorrencia = row.readTable(db.ocorrenciasSanitarias);
              final animal = row.readTable(db.animais);
              final isObito = ocorrencia.tipo == 'obito';
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isObito ? Colors.red.shade100 : Colors.orange.shade100,
                    child: Icon(isObito ? Icons.heart_broken : Icons.sick, color: isObito ? Colors.red.shade800 : Colors.orange.shade800),
                  ),
                  title: Text('Brinco: ${animal.brinco} — ${ocorrencia.tipo.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${ocorrencia.descricao}\n${dateFormat.format(ocorrencia.dataOcorrencia)}'),
                  isThreeLine: true,
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
