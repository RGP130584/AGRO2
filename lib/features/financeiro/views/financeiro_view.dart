import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/local/database.dart';
import '../../rebanho/views/fazenda_list_view.dart';
import '../services/financeiro_service.dart';
import 'lancamento_form_view.dart';

final selectedFazendaFinanceiroProvider = StateProvider<String?>((ref) => null);
final statusFiltroFinanceiroProvider = StateProvider<String>((ref) => 'todos');

class FinanceiroView extends ConsumerWidget {
  const FinanceiroView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fazendasAsync = ref.watch(fazendasProvider);
    final selectedFazendaId = ref.watch(selectedFazendaFinanceiroProvider);
    final statusFiltro = ref.watch(statusFiltroFinanceiroProvider);
    final financeiroService = ref.watch(financeiroServiceProvider);

    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return fazendasAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erro: $e'))),
      data: (fazendas) {
        if (fazendas.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Financeiro')),
            body: const Center(child: Text('Cadastre uma fazenda primeiro.')),
          );
        }

        final activeFazendaId = selectedFazendaId ?? fazendas.first.id;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Gestão Financeira'),
            actions: [
              if (fazendas.length > 1)
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: activeFazendaId,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      items: fazendas.map((f) => DropdownMenuItem(value: f.id, child: Text(f.nome))).toList(),
                      onChanged: (v) {
                        if (v != null) ref.read(selectedFazendaFinanceiroProvider.notifier).state = v;
                      },
                    ),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              // Dashboard de Totais
              StreamBuilder<List<LancamentoFinanceiro>>(
                stream: financeiroService.watchLancamentos(activeFazendaId),
                builder: (context, snapshot) {
                  final list = snapshot.data ?? [];
                  double aPagar = 0;
                  double aReceber = 0;
                  final now = DateTime.now();

                  for (final l in list) {
                    if (l.status == 'pendente' || (l.status == 'atrasado') || (l.status == 'pendente' && l.dataVencimento.isBefore(now))) {
                      if (l.tipo == 'pagar') aPagar += l.valor;
                      if (l.tipo == 'receber') aReceber += l.valor;
                    }
                  }

                  return Container(
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTotalCard(
                            title: 'A Pagar (Pendente)',
                            valor: currencyFormat.format(aPagar),
                            color: Colors.red.shade800,
                            icon: Icons.arrow_downward,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTotalCard(
                            title: 'A Receber (Pendente)',
                            valor: currencyFormat.format(aReceber),
                            color: Colors.green.shade800,
                            icon: Icons.arrow_upward,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Filtros
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildFilterChip(ref, 'todos', 'Todos', statusFiltro),
                    const SizedBox(width: 8),
                    _buildFilterChip(ref, 'pendente', 'Pendentes', statusFiltro),
                    const SizedBox(width: 8),
                    _buildFilterChip(ref, 'pago', 'Pagos / Quitados', statusFiltro),
                  ],
                ),
              ),

              // Lista de Lançamentos
              Expanded(
                child: StreamBuilder<List<LancamentoFinanceiro>>(
                  stream: financeiroService.watchLancamentos(activeFazendaId, statusFiltro: statusFiltro),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final lancamentos = snapshot.data ?? [];
                    if (lancamentos.isEmpty) {
                      return const Center(child: Text('Nenhum lançamento encontrado nesta fazenda.'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: lancamentos.length,
                      itemBuilder: (context, index) {
                        final item = lancamentos[index];
                        final isPagar = item.tipo == 'pagar';
                        final isPago = item.status == 'pago';

                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isPagar ? Colors.red.shade100 : Colors.green.shade100,
                              child: Icon(
                                isPagar ? Icons.arrow_downward : Icons.arrow_upward,
                                color: isPagar ? Colors.red.shade800 : Colors.green.shade800,
                              ),
                            ),
                            title: Text(
                              item.descricao,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  '${currencyFormat.format(item.valor)} • ${item.categoria.toUpperCase()}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isPagar ? Colors.red.shade900 : Colors.green.shade900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text('Vencimento: ${dateFormat.format(item.dataVencimento)}'),
                              ],
                            ),
                            trailing: isPago
                                ? const Chip(
                                    label: Text('PAGO', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                                    backgroundColor: Colors.green,
                                  )
                                : OutlinedButton(
                                    onPressed: () async {
                                      await financeiroService.darBaixaLancamento(item.id);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Lançamento liquidado!'), backgroundColor: Colors.green),
                                        );
                                      }
                                    },
                                    child: const Text('QUITAR'),
                                  ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LancamentoFormView(fazendaId: activeFazendaId)),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('NOVO LANÇAMENTO'),
          ),
        );
      },
    );
  }

  Widget _buildTotalCard({required String title, required String valor, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(child: Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 6),
          Text(valor, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(WidgetRef ref, String value, String label, String selectedValue) {
    final isSelected = value == selectedValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) ref.read(statusFiltroFinanceiroProvider.notifier).state = value;
      },
    );
  }
}
