import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../rebanho/views/fazenda_list_view.dart';
import '../../estoque/views/estoque_view.dart';
import '../../saude/views/saude_view.dart';
import '../../nutricao/views/nutricao_view.dart';
import '../../financeiro/views/financeiro_view.dart';
import '../../relatorios/views/relatorios_view.dart';
import '../../sync/views/sync_conflict_view.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conflictsAsync = ref.watch(conflictsProvider);
    final hasConflicts = conflictsAsync.valueOrNull?.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AGRO Pecuária'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (hasConflicts)
              Material(
                color: Colors.red[800],
                child: InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SyncConflictView()));
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Conflitos pendentes. Toque para resolver.',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(20),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildMenuCard(
                    context: context,
                    icon: Icons.group_work_outlined,
                    label: 'Rebanho',
                    color: Colors.brown.shade700,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FazendaListView())),
                  ),
                  _buildMenuCard(
                    context: context,
                    icon: Icons.inventory_2_outlined,
                    label: 'Estoque',
                    color: Colors.blueGrey.shade700,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EstoqueView())),
                  ),
                  _buildMenuCard(
                    context: context,
                    icon: Icons.health_and_safety_outlined,
                    label: 'Saúde Animal',
                    color: Colors.teal.shade700,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SaudeView())),
                  ),
                  _buildMenuCard(
                    context: context,
                    icon: Icons.restaurant_menu_outlined,
                    label: 'Nutrição',
                    color: Colors.orange.shade800,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NutricaoView())),
                  ),
                  _buildMenuCard(
                    context: context,
                    icon: Icons.attach_money_outlined,
                    label: 'Financeiro',
                    color: Colors.indigo.shade700,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceiroView())),
                  ),
                  _buildMenuCard(
                    context: context,
                    icon: Icons.bar_chart_outlined,
                    label: 'Relatórios',
                    color: Colors.deepPurple.shade700,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RelatoriosView())),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 42, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}