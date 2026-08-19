import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../services/sync_service.dart';

enum SyncStatus { offline, syncing, synced, pending, error }

/// Provider que combina múltiplas fontes para determinar o status de sincronização.
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final controller = StreamController<SyncStatus>();
  final db = ref.watch(databaseProvider);
  final syncService = ref.watch(syncServiceProvider);

  late final StreamSubscription connectivitySubscription;
  late final StreamSubscription dbSubscription;

  void listener() {
    _calculateStatus(db, syncService, controller);
  }

  // Ouve mudanças no serviço (isProcessing)
  syncService.addListener(listener);

  // Ouve mudanças na tabela da fila
  dbSubscription = db.select(db.syncQueueItems).watch().listen((_) => listener());

  // Ouve mudanças na conectividade
  connectivitySubscription = Connectivity().onConnectivityChanged.listen((_) => listener());

  // Calcula o status inicial
  listener();

  ref.onDispose(() {
    syncService.removeListener(listener);
    dbSubscription.cancel();
    connectivitySubscription.cancel();
    controller.close();
  });

  return controller.stream;
});

Future<void> _calculateStatus(AppDatabase db, SyncService syncService, StreamController<SyncStatus> controller) async {
  final connectivity = await Connectivity().checkConnectivity();
  if (connectivity == ConnectivityResult.none) {
    controller.add(SyncStatus.offline);
    return;
  }

  if (syncService.isProcessing) {
    controller.add(SyncStatus.syncing);
    return;
  }

  final failedCount = await (db.select(db.syncQueueItems)..where((t) => t.status.equals('failed'))).get().then((l) => l.length);
  if (failedCount > 0) {
    controller.add(SyncStatus.error);
  } else {
    final pendingCount = await (db.select(db.syncQueueItems)..where((t) => t.status.equals('pending'))).get().then((l) => l.length);
    controller.add(pendingCount > 0 ? SyncStatus.pending : SyncStatus.synced);
  }
}