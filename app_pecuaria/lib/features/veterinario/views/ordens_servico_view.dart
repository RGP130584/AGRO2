import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../services/vet_operacao_service.dart';

final _ordensServicoProvider = FutureProvider.autoDispose<List<VetOrdemServicoItem>>((ref) {
  final service = ref.watch(vetOperacaoServiceProvider);
  return service.listarOrdensServico();
});

class OrdensServicoView extends ConsumerStatefulWidget {
  const OrdensServicoView({super.key});

  @override
  ConsumerState<OrdensServicoView> createState() => _OrdensServicoViewState();
}

class _OrdensServicoViewState extends ConsumerState<OrdensServicoView> {
  void _recarregar() {
    ref.invalidate(_ordensServicoProvider);
  }

  Future<void> _marcarComoPaga(VetOrdemServicoItem os) async {
    try {
      await ref.read(vetOperacaoServiceProvider).atualizarStatusPagamentoOS(os.id, 'paga');
      _recarregar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ordem de serviço marcada como PAGA!'), backgroundColor: Colors.green),
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

  @override
  Widget build(BuildContext context) {
    final osAsync = ref.watch(_ordensServicoProvider);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordens de Serviço & Cobrança'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _recarregar,
            tooltip: 'Atualizar Lista',
          ),
        ],
      ),
      body: osAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text('Erro ao carregar ordens de serviço: $err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: _recarregar,
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
        data: (lista) {
          if (lista.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Nenhuma ordem de serviço registrada.\n\nQuando você gerar faturamentos de visitas ou procedimentos, elas aparecerão listadas aqui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            itemBuilder: (ctx, i) {
              final os = lista[i];
              final isPaga = os.status == 'paga';
              final isAberta = os.status == 'aberta';

              Color statusColor = Colors.orange;
              String statusLabel = 'Aberta';
              if (isPaga) {
                statusColor = Colors.green;
                statusLabel = 'Paga';
              } else if (os.status == 'cancelada') {
                statusColor = Colors.red;
                statusLabel = 'Cancelada';
              }

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
                                  os.descricao,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Cliente: ${os.produtorNome}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
                            backgroundColor: statusColor.withOpacity(0.1),
                            side: BorderSide.none,
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      // Itens da OS
                      ...os.itens.map((item) {
                        final serv = item['servico'] ?? 'Serviço';
                        final qtd = item['quantidade'] ?? 1;
                        final sub = (item['subtotal'] ?? 0).toDouble();

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('$qtd x $serv', style: const TextStyle(fontSize: 13)),
                              Text(currencyFormat.format(sub), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data: ${dateFormat.format(os.createdAt)}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              if (os.dataPagamento != null)
                                Text(
                                  'Pago em: ${os.dataPagamento}',
                                  style: const TextStyle(fontSize: 11, color: Colors.green),
                                ),
                            ],
                          ),
                          Text(
                            currencyFormat.format(os.valorTotal),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                          ),
                        ],
                      ),
                      if (isAberta) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonalIcon(
                            icon: const Icon(Icons.check_circle_outline, size: 18),
                            label: const Text('Dar Baixa / Marcar como Paga'),
                            onPressed: () => _marcarComoPaga(os),
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
