import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/device_info_provider.dart';
import '../../sync/services/sync_service.dart';

final saudeServiceProvider = Provider<SaudeService>((ref) {
  final db = ref.watch(databaseProvider);
  final deviceId = ref.watch(deviceIdProvider).asData?.value;

  if (deviceId == null) {
    throw Exception("DeviceId não está disponível para o SaudeService");
  }

  return SaudeService(db, deviceId);
});

class SaudeService {
  final AppDatabase _db;
  final String _deviceId;
  final Uuid _uuid = const Uuid();

  SaudeService(this._db, this._deviceId);

  Future<DateTime?> registrarAplicacao({
    String? animalId,
    String? loteId,
    required Produto produto,
    required double dose,
    required String via,
    required String motivo,
    String? fotoPath,
  }) async {
    final now = DateTime.now();
    DateTime? carenciaFim;
    if (produto.carenciaDiasPadrao > 0) {
      carenciaFim = now.add(Duration(days: produto.carenciaDiasPadrao));
    }

    final aplicacaoId = _uuid.v4();
    final movimentoId = _uuid.v4();

    await _db.transaction(() async {
      await _db.into(_db.aplicacoesSanitarias).insert(AplicacoesSanitariasCompanion.insert(
        id: aplicacaoId,
        animalId: Value(animalId),
        loteId: Value(loteId),
        produtoId: produto.id,
        dose: dose,
        via: via,
        motivo: motivo,
        dataAplicacao: Value(now),
        carenciaFimCalculada: Value(carenciaFim),
        fotoPath: Value(fotoPath),
        deviceId: _deviceId,
      ));

      await _db.into(_db.estoqueMovimentos).insert(EstoqueMovimentosCompanion.insert(
        id: movimentoId,
        produtoId: produto.id,
        tipo: 'saida',
        quantidade: dose,
        origem: 'aplicacao',
        deviceId: _deviceId,
      ));

      await SyncService.enqueueSync(
        _db,
        'aplicacoes_sanitarias',
        aplicacaoId,
        'insert',
        {
          'animalId': animalId,
          'loteId': loteId,
          'produtoId': produto.id,
          'dose': dose,
          'via': via,
          'motivo': motivo,
          'dataAplicacao': now.toIso8601String(),
          'carenciaFimCalculada': carenciaFim?.toIso8601String(),
          'fotoPath': fotoPath
        },
        _deviceId,
      );
    });

    return carenciaFim;
  }

  Future<void> registrarOcorrencia({
    required String animalId,
    required String tipo,
    required String descricao,
    String? fotoPath,
  }) async {
    final now = DateTime.now();
    final ocorrenciaId = _uuid.v4();

    final companion = OcorrenciasSanitariasCompanion.insert(
      id: ocorrenciaId,
      animalId: animalId,
      tipo: tipo,
      descricao: descricao,
      dataOcorrencia: Value(now),
      fotoPath: Value(fotoPath),
      deviceId: _deviceId,
    );

    await _db.into(_db.ocorrenciasSanitarias).insert(companion);

    await SyncService.enqueueSync(
      _db,
      'ocorrencias_sanitarias',
      ocorrenciaId,
      'insert',
      {
        'animalId': animalId,
        'tipo': tipo,
        'descricao': descricao,
        'dataOcorrencia': now.toIso8601String(),
        'fotoPath': fotoPath
      },
      _deviceId,
    );
  }

  Future<DateTime?> verificarCarenciaAnimal(String animalId) async {
    final now = DateTime.now();
    final animal = await (_db.select(_db.animais)..where((a) => a.id.equals(animalId))).getSingleOrNull();
    if (animal == null) return null;

    final aplicacoes = await (_db.select(_db.aplicacoesSanitarias)
          ..where((a) => a.animalId.equals(animalId) | a.loteId.equals(animal.loteId)))
        .get();

    DateTime? maxCarencia;
    for (final app in aplicacoes) {
      if (app.carenciaFimCalculada != null && app.carenciaFimCalculada!.isAfter(now)) {
        if (maxCarencia == null || app.carenciaFimCalculada!.isAfter(maxCarencia)) {
          maxCarencia = app.carenciaFimCalculada;
        }
      }
    }
    return maxCarencia;
  }

  Stream<List<TypedResult>> watchAplicacoesDetalhadas() {
    final query = _db.select(_db.aplicacoesSanitarias).join([
      innerJoin(_db.produtos, _db.produtos.id.equalsExp(_db.aplicacoesSanitarias.produtoId)),
      leftOuterJoin(_db.animais, _db.animais.id.equalsExp(_db.aplicacoesSanitarias.animalId)),
      leftOuterJoin(_db.lotes, _db.lotes.id.equalsExp(_db.aplicacoesSanitarias.loteId)),
    ])..orderBy([OrderingTerm.desc(_db.aplicacoesSanitarias.dataAplicacao)]);
    return query.watch();
  }

  Stream<List<TypedResult>> watchOcorrenciasDetalhadas() {
    final query = _db.select(_db.ocorrenciasSanitarias).join([
      innerJoin(_db.animais, _db.animais.id.equalsExp(_db.ocorrenciasSanitarias.animalId)),
    ])..orderBy([OrderingTerm.desc(_db.ocorrenciasSanitarias.dataOcorrencia)]);
    return query.watch();
  }
}