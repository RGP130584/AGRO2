import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';

final syncServiceProvider = ChangeNotifierProvider<SyncService>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncService(db);
});

/// Serviço central responsável pela sincronização offline-first bidirecional.
/// Ele executa o ciclo completo de sincronização:
/// 1. Envio (Push): processa a fila local de eventos (Outbox) pendentes e envia em lote.
/// 2. Recebimento (Pull): obtém alterações do servidor baseadas no último timestamp (lastSyncAt) 
///    e aplica de forma idempotente, gerindo resolução de conflitos (mantendo local se houver disputa).
class SyncService extends ChangeNotifier {
  static const int maxRetries = 3;
  // TODO: Mover para variáveis de ambiente
  static const String _apiBaseUrl = 'http://10.0.2.2:3000/v1'; // 10.0.2.2 para emulador Android rodando servidor localhost

  final AppDatabase _db;
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  SyncService(this._db);

  /// Processa a fila de sincronização enviando as operações pendentes e recebendo novas atualizações.
  /// Evita concorrência disparando o processamento apenas se não houver um em andamento.
  /// Requer conectividade com a rede.
  Future<void> processQueue() async {
    if (_isProcessing) return;

    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return; 
    }

    _isProcessing = true;
    notifyListeners();

    try {
      // 1. Coletar todos os eventos pendentes/falhados
      final pendingItems = await (_db.select(_db.syncQueueItems)
            ..where((t) =>
                t.status.isIn(['pending', 'failed']) &
                (t.retryCount.isSmallerThanValue(maxRetries)))
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
          .get();

      // Pegar lastSyncAt do SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final lastSyncAt = prefs.getString('lastSyncAt') ?? "1970-01-01T00:00:00.000Z";

      final body = jsonEncode({
        'outbox': pendingItems.map((item) => {
          'id': item.id,
          'entityType': item.entityType,
          'entityId': item.entityId,
          'action': item.action,
          'payload': jsonDecode(item.payload),
          'deviceId': item.deviceId,
          'createdAt': item.createdAt.toIso8601String(),
        }).toList(),
        'lastSyncAt': lastSyncAt,
      });

      print('SYNC: Enviando ${pendingItems.length} itens. lastSyncAt: $lastSyncAt');

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/sync'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer SEU_TOKEN_JWT'},
        body: body,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        
        // 2. Processar os resultados do Outbox (Sync ou Conflito)
        final results = data['results'] as List<dynamic>? ?? [];
        for (final res in results) {
          final queueId = res['id'] as int;
          final status = res['status'] as String;
          final serverId = res['serverId'] as String?;
          
          final originalQueueItem = pendingItems.firstWhere((i) => i.id == queueId);
          
          if (status == 'synced') {
            await (_db.delete(_db.syncQueueItems)..where((t) => t.id.equals(queueId))).go();
            if (serverId != null) {
              await _updateEntitySyncStatus(originalQueueItem.entityType, originalQueueItem.entityId, 'synced', serverId);
            }
          } else if (status == 'conflict') {
            await (_db.delete(_db.syncQueueItems)..where((t) => t.id.equals(queueId))).go();
            await _updateEntitySyncStatus(originalQueueItem.entityType, originalQueueItem.entityId, 'conflict', serverId);
          }
        }

        // 3. Processar as alterações vindas do servidor (Pull)
        final changes = data['changes'] as List<dynamic>? ?? [];
        for (final change in changes) {
          final entityType = change['entityType'] as String;
          final payload = change['payload'] as Map<String, dynamic>;
          final serverId = change['serverId'] as String;
          final isDeleted = change['deletedAt'] != null;

          // Sobrescreve localmente com a versão do servidor
          await _applyRemoteChange(entityType, payload, serverId, isDeleted);
        }

        // Atualizar lastSyncAt
        if (data['serverTime'] != null) {
          await prefs.setString('lastSyncAt', data['serverTime']);
        }
        
        print('SYNC: Sucesso! Outbox processada, ${changes.length} alterações recebidas.');
      } else {
        throw HttpException('Falha na sincronização: Status ${response.statusCode}');
      }
    } on SocketException {
      print('SYNC: Falha - Erro de conexão de rede');
    } catch (e) {
      print('SYNC: Falha - $e');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Enfileira uma mutação (create, update ou delete) no Outbox para ser sincronizada de 
  /// forma assíncrona assim que houver internet.
  /// 
  /// É fundamental que isso ocorra na mesma transação local do banco de dados 
  /// (através de comandos atômicos ou dependência procedural rigorosa).
  static Future<void> enqueueSync(AppDatabase db, String entityType, String entityId, String action, Map<String, dynamic> payload, String deviceId) async {
    await db.into(db.syncQueueItems).insert(SyncQueueItemsCompanion.insert(
      entityType: entityType,
      entityId: entityId,
      action: action,
      payload: jsonEncode(payload),
      deviceId: deviceId,
    ));
  }

  // Helper para atualizar o status da entidade local após retorno do servidor
  Future<void> _updateEntitySyncStatus(String entityType, String entityId, String syncStatus, String? serverId) async {
    final query = 'UPDATE $entityType SET sync_status = ?, server_id = ? WHERE id = ?';
    await _db.customStatement(query, [syncStatus, serverId, entityId]);
  }

  // Helper para aplicar mudança do servidor usando SQL puro devido ao dinamismo
  Future<void> _applyRemoteChange(String entityType, Map<String, dynamic> payload, String serverId, bool isDeleted) async {
    final entityId = payload['id'] as String;
    payload['sync_status'] = 'synced';
    payload['server_id'] = serverId;
    
    // Verificar se existe localmente
    final rs = await _db.customSelect('SELECT id FROM $entityType WHERE id = ?', variables: [Variable.withString(entityId)]).get();
    
    if (rs.isNotEmpty) {
      if (isDeleted) {
        await _db.customStatement('UPDATE $entityType SET deleted_at = ? WHERE id = ?', [DateTime.now().toIso8601String(), entityId]);
      } else {
        // Build UPDATE query
        final keys = payload.keys.toList();
        final setClause = keys.map((k) => '$k = ?').join(', ');
        final values = keys.map((k) => payload[k]).toList();
        values.add(entityId); // for WHERE id = ?
        
        await _db.customStatement('UPDATE $entityType SET $setClause WHERE id = ?', values);
      }
    } else {
      if (!isDeleted) {
        // Build INSERT query
        final keys = payload.keys.toList();
        final cols = keys.join(', ');
        final placeholders = keys.map((_) => '?').join(', ');
        final values = keys.map((k) => payload[k]).toList();
        
        await _db.customStatement('INSERT INTO $entityType ($cols) VALUES ($placeholders)', values);
      }
    }
  }
}