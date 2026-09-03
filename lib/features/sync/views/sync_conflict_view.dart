import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';

final conflictsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final db = ref.watch(databaseProvider);
  
  final tables = [
    'animais', 'lotes', 'piquetes', 'fazendas', 
    'aplicacoes_sanitarias', 'dietas', 'fornecimentos_dieta', 
    'produtos', 'estoque_movimentos', 'pesagens'
  ];
  
  List<Map<String, dynamic>> conflicts = [];
  
  for (final table in tables) {
    try {
      final rs = await db.customSelect('SELECT * FROM $table WHERE sync_status = ?', variables: [Variable.withString('conflict')]).get();
      for (final row in rs) {
        conflicts.add({
          'entityType': table,
          'data': row.data,
        });
      }
    } catch (e) {
      // Ignora se a tabela não existir exatamente com esse nome minúsculo
    }
  }
  
  return conflicts;
});

class SyncConflictView extends ConsumerWidget {
  const SyncConflictView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conflictsAsync = ref.watch(conflictsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resolução de Conflitos'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
      ),
      body: conflictsAsync.when(
        data: (conflicts) {
          if (conflicts.isEmpty) {
            return const Center(child: Text('Nenhum conflito pendente! 🎉', style: TextStyle(fontSize: 18)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: conflicts.length,
            itemBuilder: (context, index) {
              final conflict = conflicts[index];
              final entityType = conflict['entityType'];
              final data = conflict['data'] as Map<String, dynamic>;
              
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'Conflito em: ${entityType.toUpperCase()}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('ID Local: ${data['id']}'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.grey[200],
                        child: Text(
                          'Dados Atuais: \n${data.toString()}',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.cloud_download),
                            label: const Text('Aceitar Servidor'),
                            onPressed: () => _resolveConflict(context, ref, entityType, data['id'], 'server'),
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          ),
                          FilledButton.icon(
                            icon: const Icon(Icons.upload),
                            label: const Text('Manter Local'),
                            onPressed: () => _resolveConflict(context, ref, entityType, data['id'], 'local'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro ao carregar conflitos: $err')),
      ),
    );
  }

  Future<void> _resolveConflict(BuildContext context, WidgetRef ref, String entityType, String id, String resolution) async {
    final db = ref.read(databaseProvider);
    
    if (resolution == 'local') {
      // Manter local significa colocar o status de volta pra pending para que re-sincronize forçado (sobrescrevendo o servidor)
      await db.customStatement('UPDATE $entityType SET sync_status = ?, updated_at = ? WHERE id = ?', [
        'pending', 
        DateTime.now().toIso8601String(), 
        id
      ]);
      
      // Re-enfileirar no outbox
      await db.customStatement(
        'INSERT INTO sync_queue_items (entity_type, entity_id, action, payload, status, device_id) VALUES (?, ?, ?, ?, ?, ?)',
        [entityType, id, 'update', '{}', 'pending', 'resolucao_manual'] 
      );
    } else {
      // Aceitar servidor significa descartar e pedir sync denovo?
      // Neste MVP, marcar como pending mas com a data antiga, ou forçar o download.
      // O ideal aqui é apenas deletar da outbox e fazer fetch novamente.
      // Vamos simular resetando para synced e esperando o próximo pull
      await db.customStatement('UPDATE $entityType SET sync_status = ? WHERE id = ?', ['synced', id]);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conflito resolvido!')));
    ref.invalidate(conflictsProvider);
  }
}
