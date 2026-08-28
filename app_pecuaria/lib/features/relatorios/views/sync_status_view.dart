import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';

final _syncStatusProvider = FutureProvider<({String ultimaSync, int pendentes, int falhas})>((ref) async {
  final db = ref.watch(databaseProvider);
  final prefs = await SharedPreferences.getInstance();
  final ultimaSync = prefs.getString('lastSyncAt');

  final pendentes = await (db.select(db.syncQueueItems)..where((t) => t.status.equals('pending'))).get();
  final falhas = await (db.select(db.syncQueueItems)..where((t) => t.status.equals('failed'))).get();

  String ultimaSyncFormatada = 'Nunca';
  if (ultimaSync != null) {
    try {
      final dt = DateTime.parse(ultimaSync).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) {
        ultimaSyncFormatada = 'Há menos de 1 minuto';
      } else if (diff.inMinutes < 60) {
        ultimaSyncFormatada = 'Há ${diff.inMinutes} min';
      } else if (diff.inHours < 24) {
        ultimaSyncFormatada = 'Há ${diff.inHours}h';
      } else {
        ultimaSyncFormatada = DateFormat('dd/MM HH:mm').format(dt);
      }
    } catch (_) {}
  }

  return (
    ultimaSync: ultimaSyncFormatada,
    pendentes: pendentes.length,
    falhas: falhas.length,
  );
});

final _syncQueueStream = StreamProvider<List<SyncQueueItem>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.syncQueueItems)..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)])).watch();
});

class SyncStatusView extends ConsumerWidget {
  const SyncStatusView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(_syncStatusProvider);
    final queueAsync = ref.watch(_syncQueueStream);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status de Sincronização'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(_syncStatusProvider),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Painel de status
          statusAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Erro: $e'),
            data: (status) => Column(
              children: [
                _buildStatusCard(
                  context,
                  icon: Icons.access_time_filled,
                  label: 'Última Sincronização',
                  value: status.ultimaSync,
                  color: Colors.purple.shade700,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusCard(
                        context,
                        icon: Icons.upload_outlined,
                        label: 'Pendentes de Envio',
                        value: '${status.pendentes}',
                        color: status.pendentes > 0 ? Colors.orange.shade700 : Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatusCard(
                        context,
                        icon: Icons.error_outline,
                        label: 'Com Falha',
                        value: '${status.falhas}',
                        color: status.falhas > 0 ? Colors.red.shade700 : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Fila completa de sincronização
          Text('Fila de Sincronização', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          queueAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Erro: $e'),
            data: (items) {
              if (items.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 28),
                      const SizedBox(width: 12),
                      const Text('Fila vazia — todos os dados foram sincronizados!', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }

              return Column(
                children: items.take(30).map((item) {
                  final isPending = item.status == 'pending';
                  final isFailed = item.status == 'failed';

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        isPending ? Icons.hourglass_empty : isFailed ? Icons.error : Icons.check_circle,
                        color: isPending ? Colors.orange : isFailed ? Colors.red : Colors.green,
                        size: 22,
                      ),
                      title: Text(
                        '${item.entityType} → ${item.action}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: Text(
                        'Tentativas: ${item.retryCount} • ${DateFormat('dd/MM HH:mm').format(item.createdAt)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isPending ? Colors.orange.shade100 : isFailed ? Colors.red.shade100 : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isPending ? Colors.orange.shade900 : isFailed ? Colors.red.shade900 : Colors.green.shade900,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, {required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
