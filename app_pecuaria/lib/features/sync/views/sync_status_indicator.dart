import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sync_status_provider.dart';

class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(syncStatusProvider);

    return statusAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => _buildChip(Icons.error, 'Erro', Colors.red),
      data: (status) {
        switch (status) {
          case SyncStatus.offline:
            return _buildChip(Icons.wifi_off, 'Offline', Colors.grey);
          case SyncStatus.syncing:
            return _buildChip(Icons.sync, 'Sincronizando...', Colors.blue, showSpinner: true);
          case SyncStatus.synced:
            return _buildChip(Icons.cloud_done, 'Sincronizado', Colors.green);
          case SyncStatus.pending:
            return _buildChip(Icons.cloud_upload, 'Pendente', Colors.orange);
          case SyncStatus.error:
            return _buildChip(Icons.error, 'Falha', Colors.red);
        }
      },
    );
  }

  Widget _buildChip(IconData icon, String label, Color color, {bool showSpinner = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        avatar: showSpinner
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Icon(icon, color: Colors.white, size: 16),
        label: Text(label),
        labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}