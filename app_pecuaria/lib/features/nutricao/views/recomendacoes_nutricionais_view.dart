import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../services/nutricao_recomendacao_service.dart';

final _recomendacoesProvider = FutureProvider.autoDispose<List<RecomendacaoNutricional>>((ref) {
  final service = ref.watch(nutricaoRecomendacaoServiceProvider);
  return service.listarRecomendacoes();
});

class RecomendacoesNutricionaisView extends ConsumerStatefulWidget {
  const RecomendacoesNutricionaisView({super.key});

  @override
  ConsumerState<RecomendacoesNutricionaisView> createState() => _RecomendacoesNutricionaisViewState();
}

class _RecomendacoesNutricionaisViewState extends ConsumerState<RecomendacoesNutricionaisView> {
  void _recarregar() {
    ref.invalidate(_recomendacoesProvider);
  }

  Future<void> _aplicar(RecomendacaoNutricional rec) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aplicar Dieta Recomendada?'),
        content: Text(
          'Deseja ativar a "${rec.dietaSugerida['nome'] ?? 'Dieta'}" para o ${rec.loteNome ?? 'lote selecionado'}?\n\n'
          'Isso criará uma nova Dieta ativa no seu plano nutricional de campo.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Aplicar Dieta'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await ref.read(nutricaoRecomendacaoServiceProvider).aplicarRecomendacao(rec.id);
        _recarregar();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dieta aplicada e ativada com sucesso no lote!'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recomendacoesAsync = ref.watch(_recomendacoesProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recomendações Nutricionais'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _recarregar,
            tooltip: 'Atualizar Lista',
          ),
        ],
      ),
      body: recomendacoesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text('Erro ao carregar recomendações: $err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: _recarregar,
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
        data: (recomendacoes) {
          if (recomendacoes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Nenhuma recomendação nutricional pendente.\n\nQuando um veterinário ou zootecnista enviar uma formulação de dieta para seus lotes, ela aparecerá aqui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recomendacoes.length,
            itemBuilder: (ctx, i) {
              final rec = recomendacoes[i];
              final isPendente = rec.status == 'pendente';
              final isAceita = rec.status == 'aceita';

              Color statusColor = Colors.orange;
              String statusText = 'Pendente';
              if (isAceita) {
                statusColor = Colors.green;
                statusText = 'Aplicada';
              } else if (rec.status == 'rejeitada') {
                statusColor = Colors.red;
                statusText = 'Rejeitada';
              }

              final nomeDieta = rec.dietaSugerida['nome'] ?? 'Dieta Recomendada';
              final descDieta = rec.dietaSugerida['descricao'] ?? '';

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nomeDieta,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Lote: ${rec.loteNome ?? "Lote Geral"} • Autor: Dr(a). ${rec.veterinarianNome ?? "Especialista"}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
                            backgroundColor: statusColor.withOpacity(0.1),
                            side: BorderSide.none,
                          ),
                        ],
                      ),
                      if (descDieta.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Text(
                            descDieta,
                            style: TextStyle(color: Colors.brown.shade900, fontSize: 13),
                          ),
                        ),
                      ],
                      if (rec.justificativa != null && rec.justificativa!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Justificativa técnica: ${rec.justificativa}',
                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black87),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Enviado em: ${dateFormat.format(rec.createdAt)}'
                        '${rec.decidedAt != null ? " • Decidido em: ${dateFormat.format(rec.decidedAt!)}" : ""}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      if (isPendente) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(backgroundColor: Colors.teal.shade800),
                            onPressed: () => _aplicar(rec),
                            icon: const Icon(Icons.check_circle_outline, size: 18),
                            label: const Text('Aplicar e Ativar Dieta no Lote'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
