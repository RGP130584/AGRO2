import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../services/vet_dashboard_service.dart';
import '../services/alertas_inteligente_service.dart';
import 'alertas_view.dart';

final _vetDashboardProvider = FutureProvider.autoDispose<VetDashboardData>((ref) {
  final service = ref.watch(vetDashboardServiceProvider);
  return service.carregarDashboard();
});

final _vetAgendaProvider = FutureProvider.autoDispose<List<VetAgendaItem>>((ref) {
  final service = ref.watch(vetDashboardServiceProvider);
  return service.carregarAgenda();
});

class PortalVeterinarioView extends ConsumerStatefulWidget {
  const PortalVeterinarioView({super.key});

  @override
  ConsumerState<PortalVeterinarioView> createState() => _PortalVeterinarioViewState();
}

class _PortalVeterinarioViewState extends ConsumerState<PortalVeterinarioView> with SingleTickerProviderStateMixin {
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

  void _atualizarTudo() {
    ref.invalidate(_vetDashboardProvider);
    ref.invalidate(_vetAgendaProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal Veterinário & Consultoria'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _atualizarTudo,
            tooltip: 'Atualizar Painel',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.tealAccent,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'Fazendas Conectadas'),
            Tab(icon: Icon(Icons.calendar_month_outlined), text: 'Agenda & Visitas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildAgendaTab(),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    final dashboardAsync = ref.watch(_vetDashboardProvider);

    return dashboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text('Erro ao carregar painel: $err', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: _atualizarTudo,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
      data: (data) {
        final overview = data.overview;
        final fazendas = data.fazendas;

        if (fazendas.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'Você ainda não possui compartilhamentos ativos com produtores.\n\nQuando um produtor convidar seu CRMV/e-mail, as fazendas aparecerão consolidadas aqui.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Onda 10: Banner de Alertas de Inteligência ───────────────
            _buildAlertasBanner(),
            const SizedBox(height: 16),
            // Overview KPI Grid
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    title: 'Fazendas',
                    value: '${overview.totalFazendasConectadas}',
                    icon: Icons.landscape,
                    color: Colors.teal.shade800,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKpiCard(
                    title: 'Total Animais',
                    value: '${overview.totalAnimais}',
                    icon: Icons.pets,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    title: 'Em Carência',
                    value: '${overview.totalAlertasCarencia}',
                    icon: Icons.warning_amber_rounded,
                    color: overview.totalAlertasCarencia > 0 ? Colors.red.shade900 : Colors.green.shade800,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKpiCard(
                    title: 'Ocorrências Abertas',
                    value: '${overview.totalOcorrenciasAbertas}',
                    icon: Icons.healing,
                    color: overview.totalOcorrenciasAbertas > 0 ? Colors.orange.shade900 : Colors.teal.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Visão por Fazenda',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...fazendas.map((f) => _buildFazendaCard(f)),
          ],
        );
      },
    );
  }
  /// ── Onda 10: Banner de Alertas de Inteligência ──────────────────────────
  Widget _buildAlertasBanner() {
    final service = ref.read(vetDashboardServiceProvider);
    // Busca sumário de alertas de forma não-bloqueante
    return FutureBuilder<Map<String, dynamic>>(
      future: AlertasInteligenteService(service.authService).getAlertas(),
      builder: (context, snap) {
        final loading = snap.connectionState == ConnectionState.waiting;
        final total = snap.data?['totalAlertas'] as int? ?? 0;
        final critico = snap.data?['sumario']?['critico'] as int? ?? 0;
        final hasError = snap.hasError;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => AlertasView(
                  onLoadAlertas: () => null,
                  fetchAlertas: ({tenantContaId}) =>
                      AlertasInteligenteService(service.authService)
                          .getAlertas(tenantContaId: tenantContaId),
                ),
              ));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: critico > 0
                      ? [const Color(0xFF7F1D1D), const Color(0xFF1E293B)]
                      : [const Color(0xFF312E81), const Color(0xFF1E293B)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: critico > 0
                      ? const Color(0xFFEF4444).withOpacity(0.5)
                      : const Color(0xFF818CF8).withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    critico > 0 ? Icons.crisis_alert_rounded : Icons.psychology_outlined,
                    color: critico > 0 ? const Color(0xFFEF4444) : const Color(0xFF818CF8),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alertas de Inteligência',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loading
                              ? 'Analisando fazendas...'
                              : hasError
                                  ? 'Não foi possível carregar alertas'
                                  : total == 0
                                      ? 'Nenhum alerta ativo — tudo dentro do esperado'
                                      : '$total alerta${total != 1 ? 's' : ''} detectado${total != 1 ? 's' : ''}'
                                      '${critico > 0 ? ' — $critico crítico${critico != 1 ? 's' : ''}!' : ''}',
                          style: TextStyle(
                            color: critico > 0 ? const Color(0xFFFCA5A5) : Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (loading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF818CF8),
                      ),
                    )
                  else
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {

    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white70, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFazendaCard(VetFazendaCardData fazenda) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.teal.shade50,
                  radius: 22,
                  child: Icon(Icons.agriculture, color: Colors.teal.shade900),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fazenda.fazendaNome,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Produtor: ${fazenda.produtorNome}${fazenda.cidade != null ? " • ${fazenda.cidade}/${fazenda.estado ?? ''}" : ""}',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (fazenda.diasParaExpirar != null)
                  Chip(
                    label: Text(
                      '${fazenda.diasParaExpirar}d restantes',
                      style: TextStyle(
                        fontSize: 11,
                        color: fazenda.diasParaExpirar! <= 7 ? Colors.red.shade900 : Colors.blueGrey.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: fazenda.diasParaExpirar! <= 7 ? Colors.red.shade50 : Colors.blueGrey.shade50,
                    side: BorderSide.none,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const Divider(height: 24),
            // Indicadores da Fazenda
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniIndicator(
                  label: 'Rebanho',
                  value: '${fazenda.animais} cab.',
                  icon: Icons.pets,
                  color: Colors.blueGrey,
                ),
                _buildMiniIndicator(
                  label: 'Carências',
                  value: '${fazenda.carenciasAtivas}',
                  icon: Icons.sanitizer,
                  color: fazenda.carenciasAtivas > 0 ? Colors.red : Colors.green,
                ),
                _buildMiniIndicator(
                  label: 'Ocorrências',
                  value: '${fazenda.ocorrenciasAbertas}',
                  icon: Icons.healing,
                  color: fazenda.ocorrenciasAbertas > 0 ? Colors.orange : Colors.grey,
                ),
                _buildMiniIndicator(
                  label: 'Estoque Baixo',
                  value: '${fazenda.alertasEstoque}',
                  icon: Icons.inventory_2,
                  color: fazenda.alertasEstoque > 0 ? Colors.amber.shade800 : Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniIndicator({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAgendaTab() {
    final agendaAsync = ref.watch(_vetAgendaProvider);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return agendaAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Erro ao carregar agenda: $err')),
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'Nenhuma visita ou retorno agendado.\n\nUse a agenda para planejar seus atendimentos nas fazendas.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final item = items[i];
            final isDone = item.status == 'realizado';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isDone ? Colors.green.shade100 : Colors.teal.shade100,
                  child: Icon(
                    isDone ? Icons.check_circle : Icons.event,
                    color: isDone ? Colors.green.shade900 : Colors.teal.shade900,
                  ),
                ),
                title: Text(item.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${item.produtorNome} • ${dateFormat.format(item.dataHora)}'
                  '${item.descricao != null ? "\n${item.descricao}" : ""}',
                ),
                isThreeLine: item.descricao != null,
                trailing: Chip(
                  label: Text(item.status.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  backgroundColor: isDone ? Colors.green.shade50 : Colors.teal.shade50,
                  side: BorderSide.none,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
