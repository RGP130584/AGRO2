import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/local/database.dart';
import '../../rebanho/views/fazenda_list_view.dart';
import '../services/relatorio_rebanho_service.dart';

class RelatorioRebanhoView extends ConsumerStatefulWidget {
  final String? fazendaId;
  const RelatorioRebanhoView({super.key, this.fazendaId});

  @override
  ConsumerState<RelatorioRebanhoView> createState() => _RelatorioRebanhoViewState();
}

class _RelatorioRebanhoViewState extends ConsumerState<RelatorioRebanhoView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _activeFazendaId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('Rebanho'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.groups), text: 'Efetivo'),
            Tab(icon: Icon(Icons.pie_chart_outline), text: 'Composição'),
            Tab(icon: Icon(Icons.child_care), text: 'Partos'),
          ],
        ),
        actions: [
          fazendasAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (fazendas) => fazendas.length > 1
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _activeFazendaId ?? fazendas.first.id,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        items: fazendas.map((f) => DropdownMenuItem(value: f.id, child: Text(f.nome))).toList(),
                        onChanged: (v) => setState(() => _activeFazendaId = v),
                      ),
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
          if (fazendaId == null) return const Center(child: Text('Nenhuma fazenda cadastrada.'));

          return TabBarView(
            controller: _tabController,
            children: [
              _buildEfetivoTab(fazendaId),
              _buildComposicaoTab(fazendaId),
              _buildPartosTab(fazendaId),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEfetivoTab(String fazendaId) {
    final service = ref.watch(relatorioRebanhoServiceProvider);

    return FutureBuilder<List<EfetivoLote>>(
      future: service.getEfetivoRebanho(fazendaId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final itens = snapshot.data!;
        if (itens.isEmpty) return const Center(child: Text('Nenhum animal cadastrado nesta fazenda.'));

        final total = itens.fold(0, (sum, i) => sum + i.totalAnimais);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Card total geral
            Card(
              color: Colors.brown.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.groups, color: Colors.white, size: 48),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$total', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)),
                        const Text('animais no total', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...itens.map((item) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.brown.shade100,
                  child: Text('${item.totalAnimais}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown.shade900)),
                ),
                title: Text(item.loteNome, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${item.piqueteNome != null ? "Piquete: ${item.piqueteNome} • " : ""}${item.loteCategoria}\n♂ ${item.machos} machos  ♀ ${item.femeas} fêmeas',
                ),
                isThreeLine: true,
              ),
            )),
          ],
        );
      },
    );
  }

  Widget _buildComposicaoTab(String fazendaId) {
    final service = ref.watch(relatorioRebanhoServiceProvider);

    return FutureBuilder<Map<String, List<ComposicaoItem>>>(
      future: service.getComposicaoRebanho(fazendaId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildComposicaoSection('Por Categoria', data['categoria'] ?? [], Colors.brown),
            const SizedBox(height: 16),
            _buildComposicaoSection('Por Raça', data['raca'] ?? [], Colors.teal),
            const SizedBox(height: 16),
            _buildComposicaoSection('Por Sexo', data['sexo'] ?? [], Colors.orange),
          ],
        );
      },
    );
  }

  Widget _buildComposicaoSection(String titulo, List<ComposicaoItem> itens, MaterialColor color) {
    if (itens.isEmpty) return const SizedBox.shrink();
    final total = itens.fold(0, (sum, i) => sum + i.quantidade);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color.shade800)),
            const SizedBox(height: 12),
            ...itens.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.label, style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text('${item.quantidade} (${item.percentual.toStringAsFixed(1)}%)', style: TextStyle(color: color.shade700, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: total > 0 ? item.quantidade / total : 0,
                      backgroundColor: color.shade100,
                      valueColor: AlwaysStoppedAnimation(color.shade600),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPartosTab(String fazendaId) {
    final service = ref.watch(relatorioRebanhoServiceProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return StreamBuilder<List<Animal>>(
      stream: service.watchPartosPrevistos(fazendaId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final animais = snapshot.data ?? [];

        if (animais.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.child_care, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text('Nenhum parto previsto nos próximos 30 dias.', textAlign: TextAlign.center),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: animais.length,
          itemBuilder: (context, i) {
            final a = animais[i];
            final diasRestantes = a.dataPartoPrevisto != null ? a.dataPartoPrevisto!.difference(DateTime.now()).inDays : null;

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.pink.shade100,
                  child: Icon(Icons.child_care, color: Colors.pink.shade800),
                ),
                title: Text('Brinco: ${a.brinco} — ${a.raca}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  a.dataPartoPrevisto != null
                      ? 'Parto previsto: ${dateFormat.format(a.dataPartoPrevisto!)}'
                      : 'Data não informada',
                ),
                trailing: diasRestantes != null
                    ? Chip(
                        label: Text(
                          diasRestantes <= 0 ? 'HOJE' : 'em $diasRestantes dias',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        backgroundColor: diasRestantes <= 3 ? Colors.red : Colors.orange,
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
