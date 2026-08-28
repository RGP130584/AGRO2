import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../../rebanho/views/fazenda_list_view.dart';
import '../../estoque/views/produtos_list_view.dart';

class RelatoriosView extends ConsumerStatefulWidget {
  const RelatoriosView({super.key});

  @override
  ConsumerState<RelatoriosView> createState() => _RelatoriosViewState();
}

class _RelatoriosViewState extends ConsumerState<RelatoriosView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _animalSelecionadoId;

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
    final fazendasAsync = ref.watch(fazendasProvider);

    return fazendasAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erro: $e'))),
      data: (fazendas) {
        if (fazendas.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Relatórios Gerenciais')),
            body: const Center(child: Text('Cadastre uma fazenda para visualizar relatórios.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Relatórios e Desempenho'),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(icon: Icon(Icons.show_chart), text: 'Desempenho (GMD)'),
                Tab(icon: Icon(Icons.health_and_safety_outlined), text: 'Rastreabilidade Sanitária'),
                Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Posição de Estoque'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildGmdReport(),
              _buildRastreabilidadeReport(),
              _buildEstoqueReport(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGmdReport() {
    final db = ref.watch(databaseProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    final query = db.select(db.pesagens).join([
      drift.innerJoin(db.animais, db.animais.id.equalsExp(db.pesagens.animalId)),
    ])..orderBy([drift.OrderingTerm.desc(db.pesagens.dataPesagem)]);

    return StreamBuilder<List<drift.TypedResult>>(
      stream: query.watch(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final rows = snapshot.data ?? [];
        if (rows.isEmpty) {
          return const Center(child: Text('Nenhum registro de pesagem cadastrado.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rows.length,
          itemBuilder: (context, index) {
            final row = rows[index];
            final p = row.readTable(db.pesagens);
            final a = row.readTable(db.animais);

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  child: Icon(Icons.scale, color: Colors.white),
                ),
                title: Text('Brinco ${a.brinco}: ${p.peso.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Data: ${dateFormat.format(p.dataPesagem)} • Raça: ${a.raca}'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRastreabilidadeReport() {
    final db = ref.watch(databaseProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return StreamBuilder<List<Animal>>(
      stream: (db.select(db.animais)..where((a) => a.deletedAt.isNull())).watch(),
      builder: (context, snapshot) {
        final animais = snapshot.data ?? [];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String>(
                value: _animalSelecionadoId,
                decoration: InputDecoration(
                  labelText: 'Selecione o Animal (Brinco)',
                  prefixIcon: const Icon(Icons.pets),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: animais.map((a) => DropdownMenuItem(value: a.id, child: Text('Brinco ${a.brinco} (${a.raca})'))).toList(),
                onChanged: (v) => setState(() => _animalSelecionadoId = v),
              ),
            ),
            if (_animalSelecionadoId == null)
              const Expanded(child: Center(child: Text('Selecione um animal para ver o histórico sanitário.')))
            else
              Expanded(
                child: StreamBuilder<List<AplicacaoSanitaria>>(
                  stream: (db.select(db.aplicacoesSanitarias)..where((a) => a.animalId.equals(_animalSelecionadoId!))).watch(),
                  builder: (context, snapApp) {
                    final aplicacoes = snapApp.data ?? [];
                    if (aplicacoes.isEmpty) {
                      return const Center(child: Text('Nenhuma aplicação sanitária registrada para este animal.'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: aplicacoes.length,
                      itemBuilder: (context, i) {
                        final item = aplicacoes[i];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: const Icon(Icons.vaccines, color: Colors.teal),
                            title: Text('Aplicação em ${dateFormat.format(item.dataAplicacao)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Dose: ${item.dose} • Via: ${item.via}\nMotivo: ${item.motivo}'),
                            isThreeLine: true,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEstoqueReport() {
    final produtosAsync = ref.watch(produtosComSaldoProvider);

    return produtosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e')),
      data: (items) {
        if (items.isEmpty) return const Center(child: Text('Nenhum produto cadastrado no estoque.'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final p = items[i].produto;
            final saldo = items[i].saldo;
            final estaCritico = saldo <= p.estoqueMinimo && p.estoqueMinimo > 0;

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 10),
              color: estaCritico ? Colors.red.shade50 : null,
              child: ListTile(
                title: Text(p.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Estoque Atual: ${saldo.toStringAsFixed(1)} ${p.unidade} | Mínimo: ${p.estoqueMinimo.toStringAsFixed(0)}'),
                trailing: estaCritico
                    ? const Chip(label: Text('CRÍTICO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)), backgroundColor: Colors.red)
                    : const Chip(label: Text('REGULAR', style: TextStyle(color: Colors.white, fontSize: 10)), backgroundColor: Colors.green),
              ),
            );
          },
        );
      },
    );
  }
}
