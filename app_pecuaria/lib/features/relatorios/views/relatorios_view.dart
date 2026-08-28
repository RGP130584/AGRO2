import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../rebanho/views/fazenda_list_view.dart';
import 'relatorio_rebanho_view.dart';
import 'relatorio_gmd_view.dart';
import 'relatorio_saude_view.dart';
import 'relatorio_nutricao_view.dart';
import 'relatorio_estoque_view.dart';
import 'relatorio_financeiro_view.dart';
import 'sync_status_view.dart';
import '../services/relatorio_rebanho_service.dart';

class RelatoriosView extends ConsumerWidget {
  const RelatoriosView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fazendasAsync = ref.watch(fazendasProvider);
    final carenciaCountAsync = ref.watch(_carenciaCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios Gerenciais'),
        centerTitle: true,
      ),
      body: fazendasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (fazendas) {
          final fazendaId = fazendas.isNotEmpty ? fazendas.first.id : null;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Badge de carência no topo
              carenciaCountAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (count) => count > 0
                    ? _buildAlertBanner(
                        context,
                        '🚨 $count animal${count > 1 ? 'is' : ''} em período de carência',
                        Colors.red.shade800,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RelatorioSaudeView(fazendaId: fazendaId)),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              Text('Rebanho e Desempenho', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildCategoryCard(
                      context,
                      icon: Icons.groups_outlined,
                      label: 'Efetivo e\nComposição',
                      color: Colors.brown.shade700,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RelatorioRebanhoView(fazendaId: fazendaId))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCategoryCard(
                      context,
                      icon: Icons.show_chart,
                      label: 'GMD e\nCrescimento',
                      color: Colors.teal.shade700,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RelatorioGmdView(fazendaId: fazendaId))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text('Saúde e Nutrição', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildCategoryCard(
                      context,
                      icon: Icons.health_and_safety_outlined,
                      label: 'Saúde\nAnimal',
                      color: Colors.red.shade700,
                      badge: carenciaCountAsync.valueOrNull,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RelatorioSaudeView(fazendaId: fazendaId))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCategoryCard(
                      context,
                      icon: Icons.restaurant_menu_outlined,
                      label: 'Nutrição\ne Dietas',
                      color: Colors.orange.shade700,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RelatorioNutricaoView(fazendaId: fazendaId))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text('Estoque e Financeiro', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildCategoryCard(
                      context,
                      icon: Icons.inventory_2_outlined,
                      label: 'Estoque\ne Kardex',
                      color: Colors.blueGrey.shade700,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RelatorioEstoqueView(fazendaId: fazendaId))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCategoryCard(
                      context,
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Financeiro',
                      color: Colors.indigo.shade700,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RelatorioFinanceiroView(fazendaId: fazendaId))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text('Sistema', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildCategoryCard(
                context,
                icon: Icons.sync_outlined,
                label: 'Status de Sincronização',
                color: Colors.purple.shade700,
                fullWidth: true,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SyncStatusView())),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAlertBanner(BuildContext context, String text, Color color, VoidCallback onTap) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    int? badge,
    bool fullWidth = false,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: fullWidth
              ? Row(
                  children: [
                    Icon(icon, size: 36, color: Colors.white),
                    const SizedBox(width: 16),
                    Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                  ],
                )
              : Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 36, color: Colors.white),
                        const SizedBox(height: 8),
                        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    if (badge != null && badge > 0)
                      Positioned(
                        top: -8,
                        right: -8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.yellow, shape: BoxShape.circle),
                          child: Text(
                            '$badge',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

// Provider para contador de carência
final _carenciaCountProvider = StreamProvider<int>((ref) {
  final service = ref.watch(relatorioRebanhoServiceProvider);
  return service.watchContadorCarencia();
});
