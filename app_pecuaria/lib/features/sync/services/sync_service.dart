import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';

final syncServiceProvider = ChangeNotifierProvider<SyncService>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncService(db);
});

class SyncService extends ChangeNotifier {
  static const int maxRetries = 3;
  static String get _syncUrl => ApiConstants.syncUrl; 

  static const Map<String, Set<String>> _whitelist = {
    'fazendas': {'id', 'nome', 'cpfCnpj', 'responsavel', 'deviceId', 'sync_status', 'server_id', 'created_at', 'updated_at', 'deleted_at'},
    'piquetes': {'id', 'nome', 'capacidade', 'fazendaId', 'deviceId', 'sync_status', 'server_id', 'created_at', 'updated_at', 'deleted_at'},
    'lotes': {'id', 'nome', 'descricao', 'fazendaId', 'piqueteId', 'deviceId', 'sync_status', 'server_id', 'created_at', 'updated_at', 'deleted_at'},
    'animais': {'id', 'brinco', 'raca', 'sexo', 'dataNascimento', 'pesoNascimento', 'fazendaId', 'loteId', 'deviceId', 'sync_status', 'server_id', 'created_at', 'updated_at', 'deleted_at'},
    'produtos': {'id', 'nome', 'tipo', 'unidade', 'fazendaId', 'deviceId', 'sync_status', 'server_id', 'created_at', 'updated_at', 'deleted_at'},
    'estoque_movimentos': {'id', 'produtoId', 'quantidade', 'tipoMovimento', 'dataMovimento', 'deviceId', 'sync_status', 'server_id', 'created_at', 'updated_at', 'deleted_at'},
    'aplicacoes_sanitarias': {'id', 'animalId', 'loteId', 'produtoId', 'dose', 'via', 'motivo', 'dataAplicacao', 'carenciaFimCalculada', 'fotoPath', 'deviceId', 'sync_status', 'server_id', 'created_at', 'updated_at', 'deleted_at'},
    'ocorrencias_sanitarias': {'id', 'animalId', 'tipo', 'descricao', 'dataOcorrencia', 'fotoPath', 'deviceId', 'sync_status', 'server_id', 'created_at', 'updated_at', 'deleted_at'},
    'dietas': {'id', 'nome', 'descricao', 'fazendaId', 'loteId', 'categoria', 'produtoId', 'quantidadePorCabecaDia', 'deviceId', 'sync_status', 'server_id', 'created_at', 'updated_at', 'deleted_at'},
    'fornecimentos_dieta': {'id', 'dietaId', 'loteId', 'quantidadeFornecida', 'dataFornecimento', 'deviceId', 'sync_status', 'server_id', 'created_at', 'updated_at', 'deleted_at'},
    'usuarios': {'id', 'nome', 'cpfCnpj', 'email', 'telefone', 'emailVerificado', 'senhaHash', 'perfil', 'deviceId', 'sync_status', 'server_id', 'created_at', 'updated_at', 'deleted_at'},
    'pesagens': {'id', 'animalId', 'peso', 'dataPesagem', 'gmdCalculado', 'deviceId', 'sync_status', 'server_id', 'created_at', 'updated_at', 'deleted_at'},
    'lancamentos_financeiros': {'id', 'fazendaId', 'tipo', 'descricao', 'categoria', 'valor', 'dataVencimento', 'dataPagamento', 'status', 'deviceId', 'sync_status', 'server_id', 'created_at', 'updated_at', 'deleted_at'},
  };

  final AppDatabase _db;
  final _storage = const FlutterSecureStorage();
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  SyncService(this._db);

  Future<void> processQueue() async {
    if (_isProcessing) return;

    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return; 
    }

    final token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      print('SYNC: Falha - Usuário não autenticado no backend.');
      return;
    }

    _isProcessing = true;
    notifyListeners();

    try {
      final pendingItems = await (_db.select(_db.syncQueueItems)
            ..where((t) =>
                t.status.isIn(['pending', 'failed']) &
                (t.retryCount.isSmallerThanValue(maxRetries)))
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
          .get();

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
        Uri.parse(_syncUrl),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: body,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        
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

        final changes = data['changes'] as List<dynamic>? ?? [];
        for (final change in changes) {
          final entityType = change['entityType'] as String;
          final payload = change['payload'] as Map<String, dynamic>;
          final serverId = change['serverId'] as String;
          final isDeleted = change['deletedAt'] != null;

          await _applyRemoteChange(entityType, payload, serverId, isDeleted);
        }

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

  static Future<void> enqueueSync(AppDatabase db, String entityType, String entityId, String action, Map<String, dynamic> payload, String deviceId) async {
    await db.into(db.syncQueueItems).insert(SyncQueueItemsCompanion.insert(
      entityType: entityType,
      entityId: entityId,
      action: action,
      payload: jsonEncode(payload),
      deviceId: deviceId,
    ));
  }

  Future<void> _updateEntitySyncStatus(String entityType, String entityId, String syncStatus, String? serverId) async {
    if (!_whitelist.containsKey(entityType)) {
      print('SYNC ERROR: Tentativa de atualizar entidade não permitida: $entityType');
      return;
    }
    final query = 'UPDATE $entityType SET sync_status = ?, server_id = ? WHERE id = ?';
    await _db.customStatement(query, [syncStatus, serverId, entityId]);
  }

  Future<void> _applyRemoteChange(String entityType, Map<String, dynamic> payload, String serverId, bool isDeleted) async {
    if (!_whitelist.containsKey(entityType)) {
      print('SYNC ERROR: Entidade ignorada por segurança (não permitida): $entityType');
      return;
    }

    final entityId = payload['id'] as String;
    payload['sync_status'] = 'synced';
    payload['server_id'] = serverId;

    // Filter payload keys to only allowed columns for this table
    final allowed = _whitelist[entityType]!;
    final keys = payload.keys.toList().where((k) {
      if (!allowed.contains(k)) {
        print('SYNC WARN: Coluna $k ignorada por segurança em $entityType.');
        return false;
      }
      return true;
    }).toList();

    final rs = await _db.customSelect('SELECT id FROM $entityType WHERE id = ?', variables: [Variable.withString(entityId)]).get();
    
    if (rs.isNotEmpty) {
      if (isDeleted) {
        await _db.customStatement('UPDATE $entityType SET deleted_at = ? WHERE id = ?', [DateTime.now().toIso8601String(), entityId]);
      } else {
        final setClause = keys.map((k) => '$k = ?').join(', ');
        final values = keys.map((k) => payload[k]).toList();
        values.add(entityId); 
        
        await _db.customStatement('UPDATE $entityType SET $setClause WHERE id = ?', values);
      }
    } else {
      if (!isDeleted) {
        final cols = keys.join(', ');
        final placeholders = keys.map((_) => '?').join(', ');
        final values = keys.map((k) => payload[k]).toList();
        
        await _db.customStatement('INSERT INTO $entityType ($cols) VALUES ($placeholders)', values);
      }
    }
  }
}