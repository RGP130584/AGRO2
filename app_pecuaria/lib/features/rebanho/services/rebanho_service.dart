import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/device_info_provider.dart';
import '../models/animal_list_item.dart';
import '../../sync/services/sync_service.dart';

final rebanhoServiceProvider = Provider<RebanhoService>((ref) {
  final db = ref.watch(databaseProvider);
  final deviceId = ref.watch(deviceIdProvider).asData?.value;

  if (deviceId == null) {
    throw Exception("DeviceId não está disponível para o RebanhoService");
  }

  return RebanhoService(db, deviceId);
});

/// Service class that encapsulates business rules for the Herd module.
class RebanhoService {
  final AppDatabase _db;
  final String _deviceId;
  final Uuid _uuid = const Uuid();

  RebanhoService(this._db, this._deviceId);

  /// Registers a new animal in the database.
  Future<void> cadastrarAnimal({
    required String loteId,
    required String brinco,
    required String tipoAnimal,
    required String categoria,
    required String raca,
    required String sexo,
    DateTime? dataNascimento,
    double? pesoKg,
    bool? prenha,
    DateTime? dataCobertura,
    DateTime? dataPartoPrevisto,
    DateTime? dataParto,
    int? qtdFilhotes,
    int? qtdFilhotesVivos,
  }) async {
    final animalCompanion = AnimaisCompanion.insert(
      id: _uuid.v4(),
      loteId: loteId,
      brinco: brinco,
      tipoAnimal: Value(tipoAnimal),
      categoria: categoria,
      raca: raca,
      sexo: Value(sexo),
      dataNascimento: Value(dataNascimento),
      pesoKg: Value(pesoKg),
      prenha: Value(prenha),
      dataCobertura: Value(dataCobertura),
      dataPartoPrevisto: Value(dataPartoPrevisto),
      dataParto: Value(dataParto),
      qtdFilhotes: Value(qtdFilhotes),
      qtdFilhotesVivos: Value(qtdFilhotesVivos),
      deviceId: _deviceId,
    );

    await _db.transaction(() async {
      await _db.into(_db.animais).insert(animalCompanion);
      
      await SyncService.enqueueSync(
        _db, 
        'Animais', 
        animalCompanion.id.value, 
        'insert', 
        {'brinco': brinco, 'loteId': loteId}, // Simplificado para o MVP
        _deviceId
      );
    });
  }

  Future<void> cadastrarPiquete({
    required String fazendaId,
    required String nome,
    double? areaHectares,
    int? capacidadeCabecas,
  }) async {
    final companion = PiquetesCompanion.insert(
      id: _uuid.v4(),
      nome: nome,
      fazendaId: fazendaId,
      areaHectares: Value(areaHectares),
      capacidadeCabecas: Value(capacidadeCabecas),
      deviceId: _deviceId,
    );
    await _db.transaction(() async {
      await _db.into(_db.piquetes).insert(companion);
      await SyncService.enqueueSync(
        _db, 
        'Piquetes', 
        companion.id.value, 
        'insert', 
        {'nome': nome, 'fazendaId': fazendaId}, 
        _deviceId
      );
    });
  }

  Future<void> cadastrarLote({
    required String fazendaId,
    required String nome,
    required String tipo,
    String? piqueteId,
  }) async {
    final companion = LotesCompanion.insert(
      id: _uuid.v4(),
      nome: nome,
      categoria: tipo,
      fazendaId: fazendaId,
      piqueteId: Value(piqueteId),
      deviceId: _deviceId,
    );
    await _db.transaction(() async {
      await _db.into(_db.lotes).insert(companion);
      await SyncService.enqueueSync(
        _db, 
        'Lotes', 
        companion.id.value, 
        'insert', 
        {'nome': nome, 'fazendaId': fazendaId, 'tipo': tipo}, 
        _deviceId
      );
    });
  }

  /// Observes animals for listing, calculating if they are in withdrawal period.
  Stream<List<AnimalListItem>> watchAnimaisParaListagem() {
    final query = _db.select(_db.animais).join([
      innerJoin(_db.lotes, _db.lotes.id.equalsExp(_db.animais.loteId)),
    ]);

    return query.watch().asyncMap((rows) async {
      final result = <AnimalListItem>[];
      final now = DateTime.now();

      for (final row in rows) {
        final animal = row.readTable(_db.animais);
        final lote = row.readTable(_db.lotes);

        // Calculate if animal is in withdrawal (carência)
        final aplicacoes = await (_db.select(_db.aplicacoesSanitarias)
              ..where((a) => a.animalId.equals(animal.id) | a.loteId.equals(lote.id)))
            .get();

        bool emCarencia = false;
        DateTime? carenciaFim;

        for (final app in aplicacoes) {
          if (app.carenciaFimCalculada != null && app.carenciaFimCalculada!.isAfter(now)) {
            emCarencia = true;
            if (carenciaFim == null || app.carenciaFimCalculada!.isAfter(carenciaFim)) {
              carenciaFim = app.carenciaFimCalculada;
            }
          }
        }

        result.add(AnimalListItem(
          animal: animal,
          lote: lote,
          emCarencia: emCarencia,
          carenciaFim: carenciaFim,
        ));
      }
      return result;
    });
  }
}