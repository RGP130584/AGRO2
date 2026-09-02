import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../../rebanho/views/fazenda_list_view.dart';
import '../services/nutricao_service.dart';
import 'dieta_form_view.dart';
import 'fornecimento_form_view.dart';
import 'recomendacoes_nutricionais_view.dart';

final selectedFazendaNutricaoProvider = StateProvider<String?>((ref) => null);

class NutricaoView extends ConsumerStatefulWidget {
  const NutricaoView({super.key});

  @override
  ConsumerState<NutricaoView> createState() => _NutricaoViewState();
}

class _NutricaoViewState extends ConsumerState<NutricaoView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final fazendasAsync = ref.watch(fazendasProvider);
    final selectedFazendaId = ref.watch(selectedFazendaNutricaoProvider);

    return fazendasAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erro ao carregar fazendas: $e'))),
      data: (fazendas) {
        if (fazendas.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Nutrição e Dietas')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text('Cadastre uma fazenda antes de gerenciar a nutrição.'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('VOLTAR'),
                  ),
                ],
              ),
            ),
          );
        }

        final activeFazendaId = selectedFazendaId ?? fazendas.first.id;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Nutrição e Dietas'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.restaurant_menu), text: 'Dietas'),
                Tab(icon: Icon(Icons.history), text: 'Fornecimentos'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.recommend_outlined),
                tooltip: 'Recomendações Nutricionais',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RecomendacoesNutricionaisView()),
                  );
                },
              ),
              if (fazendas.length > 1)
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: activeFazendaId,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      items: fazendas.map((f) {
                        return DropdownMenuItem(
                          value: f.id,
                          child: Text(f.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) ref.read(selectedFazendaNutricaoProvider.notifier).state = v;
                      },
                    ),
                  ),
                ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildDietasTab(activeFazendaId),
              _buildFornecimentosTab(activeFazendaId),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              if (_tabController.index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DietaFormView(fazendaId: activeFazendaId)),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FornecimentoFormView(fazendaId: activeFazendaId)),
                );
              }
            },
            icon: const Icon(Icons.add),
            label: Text(_tabController.index == 0 ? 'NOVA DIETA' : 'NOVO FORNECIMENTO'),
          ),
        );
      },
    );
  }

  Widget _buildDietasTab(String fazendaId) {
    final nutricaoService = ref.watch(nutricaoServiceProvider);

    return StreamBuilder<List<drift.TypedResult>>(
      stream: nutricaoService.watchDietasDetalhadas(fazendaId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final rows = snapshot.data ?? [];
        if (rows.isEmpty) {
          return const Center(
            child: Text('Nenhuma dieta cadastrada nesta fazenda.\nToque no botão + para cadastrar.'),
          );
        }

        final db = ref.watch(databaseProvider);
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rows.length,
          itemBuilder: (context, index) {
            final row = rows[index];
            final dieta = row.readTable(db.dietas);
            final produto = row.readTable(db.produtos);
            final lote = row.readTableOrNull(db.lotes);

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  child: Icon(Icons.grass, color: Colors.orange.shade800),
                ),
                title: Text(
                  '${produto.nome} (${dieta.quantidadePorCabecaDia} ${produto.unidade}/cab/dia)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  lote != null ? 'Lote: ${lote.nome}' : 'Categoria: ${dieta.categoria ?? "Geral"}',
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFornecimentosTab(String fazendaId) {
    final nutricaoService = ref.watch(nutricaoServiceProvider);

    return StreamBuilder<List<drift.TypedResult>>(
      stream: nutricaoService.watchFornecimentosDetalhados(fazendaId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final rows = snapshot.data ?? [];
        if (rows.isEmpty) {
          return const Center(
            child: Text('Nenhum fornecimento registrado hoje.\nToque em NOVO FORNECIMENTO.'),
          );
        }

        final db = ref.watch(databaseProvider);
        final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rows.length,
          itemBuilder: (context, index) {
            final row = rows[index];
            final fornecimento = row.readTable(db.fornecimentosDieta);
            final dieta = row.readTable(db.dietas);
            final produto = row.readTable(db.produtos);
            final lote = row.readTable(db.lotes);

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lote: ${lote.nome}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          dateFormat.format(fornecimento.dataFornecimento),
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Insumo: ${produto.nome}'),
                    const SizedBox(height: 4),
                    Text(
                      'Fornecido: ${fornecimento.quantidadeFornecida} ${produto.unidade}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
