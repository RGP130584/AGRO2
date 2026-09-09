import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AlertasView extends StatefulWidget {
  final Map<String, dynamic>? Function() onLoadAlertas;
  final Future<Map<String, dynamic>> Function({String? tenantContaId}) fetchAlertas;

  const AlertasView({
    super.key,
    required this.onLoadAlertas,
    required this.fetchAlertas,
  });

  @override
  State<AlertasView> createState() => _AlertasViewState();
}

class _AlertasViewState extends State<AlertasView> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final d = await widget.fetchAlertas();
      setState(() { _data = d; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Color _corNivel(String nivel) {
    switch (nivel) {
      case 'critico': return const Color(0xFFEF4444);
      case 'atencao': return const Color(0xFFF59E0B);
      default: return const Color(0xFF6366F1);
    }
  }

  IconData _iconeNivel(String nivel) {
    switch (nivel) {
      case 'critico': return Icons.crisis_alert_rounded;
      case 'atencao': return Icons.warning_amber_rounded;
      default: return Icons.info_outline_rounded;
    }
  }

  IconData _iconeCodigo(String codigo) {
    switch (codigo) {
      case 'A1': return Icons.trending_down_rounded;
      case 'A2': return Icons.coronavirus_rounded;
      case 'A3': return Icons.timer_outlined;
      case 'A4': return Icons.monitor_weight_outlined;
      case 'A5': return Icons.receipt_long_outlined;
      default: return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Row(
          children: [
            Icon(Icons.psychology_outlined, color: Color(0xFF818CF8), size: 22),
            SizedBox(width: 8),
            Text(
              'Alertas de Inteligência',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF818CF8)),
            onPressed: _load,
            tooltip: 'Atualizar alertas',
          ),
        ],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF818CF8)))
          : _error != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 48),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final total = _data!['totalAlertas'] as int? ?? 0;
    final sumario = _data!['sumario'] as Map<String, dynamic>? ?? {};
    final alertas = (_data!['alertas'] as List? ?? []).cast<Map<String, dynamic>>();
    final geradoEm = _data!['geradoEm'] as String?;

    return RefreshIndicator(
      onRefresh: _load,
      color: const Color(0xFF818CF8),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Header com sumário ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF312E81), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF818CF8).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.analytics_rounded, color: Color(0xFF818CF8), size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Análise Baseada em Regras',
                        style: TextStyle(color: Color(0xFF818CF8), fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const Spacer(),
                      if (geradoEm != null)
                        Text(
                          DateFormat('HH:mm').format(DateTime.parse(geradoEm).toLocal()),
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$total Alerta${total != 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _sumarioChip('Crítico', sumario['critico'] ?? 0, const Color(0xFFEF4444)),
                      const SizedBox(width: 8),
                      _sumarioChip('Atenção', sumario['atencao'] ?? 0, const Color(0xFFF59E0B)),
                      const SizedBox(width: 8),
                      _sumarioChip('Info', sumario['informativo'] ?? 0, const Color(0xFF6366F1)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Nota de transparência ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFF59E0B), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cada alerta tem justificativa clara — sem IA de caixa-preta. Toque no alerta para ver o motivo.',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── Lista de alertas ───────────────────────────────────────────
          if (alertas.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: Colors.green.shade400, size: 56),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhum alerta ativo',
                      style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Todos os indicadores estão dentro do esperado',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final alerta = alertas[i];
                    return _buildAlertCard(alerta);
                  },
                  childCount: alertas.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _sumarioChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('$count $label', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alerta) {
    final nivel = alerta['nivel'] as String? ?? 'informativo';
    final codigo = alerta['codigo'] as String? ?? '';
    final cor = _corNivel(nivel);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cor.withOpacity(0.4)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: cor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_iconeCodigo(codigo), color: cor, size: 22),
          ),
          title: Text(
            alerta['titulo'] ?? '',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: cor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    nivel.toUpperCase(),
                    style: TextStyle(color: cor, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(width: 6),
                Text(codigo, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          trailing: Icon(_iconeNivel(nivel), color: cor, size: 20),
          children: [
            Text(alerta['descricao'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF818CF8), size: 15),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alerta['justificativa'] ?? '',
                      style: const TextStyle(color: Color(0xFF818CF8), fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
