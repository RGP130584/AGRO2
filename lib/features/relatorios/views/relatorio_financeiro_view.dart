import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/local/database.dart';
import '../../rebanho/views/fazenda_list_view.dart';
import '../../financeiro/services/financeiro_service.dart';
import '../services/relatorio_financeiro_service.dart';

class RelatorioFinanceiroView extends ConsumerStatefulWidget {
  final String? fazendaId;
  const RelatorioFinanceiroView({super.key, this.fazendaId});

  @override
  ConsumerState<RelatorioFinanceiroView> createState() => _RelatorioFinanceiroViewState();
}

class _RelatorioFinanceiroViewState extends ConsumerState<RelatorioFinanceiroView> with SingleTickerProviderStateMixin {
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
        title: const Text('Financeiro'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.account_balance_outlined), text: 'Fluxo de Caixa'),
            Tab(icon: Icon(Icons.warning_amber_outlined), text: 'Em Atraso'),
          ],
        ),
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
              _buildFluxoCaixaTab(fazendaId),
              _buildAtrasosTab(fazendaId),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFluxoCaixaTab(String fazendaId) {
    final service = ref.watch(relatorioFinanceiroServiceProvider);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final mesesNomes = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];

    return StreamBuilder<List<FluxoMensal>>(
      stream: service.watchFluxoCaixaMensal(fazendaId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final meses = snapshot.data!;

        if (meses.isEmpty) {
          return const Center(child: Text('Nenhum lançamento financeiro registrado.'));
        }

        // Saldo acumulado total
        final totalPagar = meses.fold(0.0, (sum, m) => sum + m.totalPagar);
        final totalReceber = meses.fold(0.0, (sum, m) => sum + m.totalReceber);
        final saldoTotal = totalReceber - totalPagar;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Cards de totais
            Row(
              children: [
                Expanded(
                  child: _buildTotalBox('A Pagar', currencyFormat.format(totalPagar), Colors.red.shade700, Icons.arrow_downward),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTotalBox('A Receber', currencyFormat.format(totalReceber), Colors.green.shade700, Icons.arrow_upward),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: saldoTotal >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: saldoTotal >= 0 ? Colors.green.shade300 : Colors.red.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Saldo Projetado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    currencyFormat.format(saldoTotal),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: saldoTotal >= 0 ? Colors.green.shade800 : Colors.red.shade800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Por mês', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Tabela por mês
            ...meses.map((mes) {
              final saldoMes = mes.saldoProjetado;
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${mesesNomes[mes.mes - 1]} / ${mes.ano}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('A pagar:', style: TextStyle(color: Colors.red.shade700)),
                          Text(currencyFormat.format(mes.totalPagar), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade800)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('A receber:', style: TextStyle(color: Colors.green.shade700)),
                          Text(currencyFormat.format(mes.totalReceber), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Saldo projetado:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            currencyFormat.format(saldoMes),
                            style: TextStyle(fontWeight: FontWeight.bold, color: saldoMes >= 0 ? Colors.green.shade800 : Colors.red.shade800),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildTotalBox(String label, String valor, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text(valor, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtrasosTab(String fazendaId) {
    final service = ref.watch(relatorioFinanceiroServiceProvider);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return StreamBuilder<List<LancamentoFinanceiro>>(
      stream: service.watchContasEmAtraso(fazendaId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;

        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, size: 72, color: Colors.green.shade400),
                const SizedBox(height: 12),
                const Text('Nenhuma conta em atraso!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          );
        }

        final totalAtraso = list.where((l) => l.tipo == 'pagar').fold(0.0, (s, l) => s + l.valor);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${list.length} conta${list.length > 1 ? 's' : ''} em atraso', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Total em atraso: ${currencyFormat.format(totalAtraso)}', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            ...list.map((item) {
              final diasAtraso = DateTime.now().difference(item.dataVencimento).inDays;
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 8),
                color: Colors.red.shade50,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.shade200,
                    child: const Icon(Icons.arrow_downward, color: Colors.white),
                  ),
                  title: Text(item.descricao, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${currencyFormat.format(item.valor)} • Venceu: ${dateFormat.format(item.dataVencimento)}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$diasAtraso dias', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade800, fontSize: 13)),
                      const Text('em atraso', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
