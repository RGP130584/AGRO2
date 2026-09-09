import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pesagem_com_gmd.dart';
import '../services/pesagem_service.dart';

final historicoPesagemProvider = StreamProvider.family<List<PesagemComGMD>, String>((ref, animalId) {
  final pesagemService = ref.watch(pesagemServiceProvider);
  return pesagemService.watchHistoricoComGMD(animalId);
});

class HistoricoPesagemList extends ConsumerWidget {
  final String animalId;
  const HistoricoPesagemList({super.key, required this.animalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historicoAsync = ref.watch(historicoPesagemProvider(animalId));

    return historicoAsync.when(
      data: (historico) {
        if (historico.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('Nenhuma pesagem registrada para este animal.'),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: historico.length,
          itemBuilder: (context, index) {
            final item = historico[index];
            final data = item.pesagem.dataPesagem;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.monitor_weight_outlined),
                ),
                title: Text('${item.pesagem.peso.toStringAsFixed(1)} kg'),
                subtitle: Text('${data.day}/${data.month}/${data.year}'),
                trailing: item.gmd != null
                    ? _GmdChip(gmd: item.gmd!)
                    : null,
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Erro ao carregar histórico: $e')),
    );
  }
}

class _GmdChip extends StatelessWidget {
  final double gmd;
  const _GmdChip({required this.gmd});

  @override
  Widget build(BuildContext context) {
    final isPositive = gmd >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Chip(
      avatar: Icon(icon, color: color, size: 16),
      label: Text(
        '${gmd.toStringAsFixed(3)} kg/dia',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide.none,
    );
  }
}