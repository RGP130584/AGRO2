import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/device_info_provider.dart';

final nutricaoServiceProvider = Provider<NutricaoService>((ref) {
  final db = ref.watch(databaseProvider);
  final deviceId = ref.watch(deviceIdProvider).asData?.value;
  if (deviceId == null) {
    throw Exception("DeviceId não está disponível para NutricaoService");
  }
  return NutricaoService(db, deviceId);
});

class NutricaoService {
  final AppDatabase _db;
  final String _deviceId;
  final Uuid _uuid = const Uuid();

  NutricaoService(this._db, this._deviceId);

  Future<void> criarDieta({
    String? loteId,
    String? categoria,
    required String produtoId,
    required double quantidadePorCabecaDia,
  }) async {
    final companion = DietasCompanion.insert(
      id: _uuid.v4(),
      loteId: Value(loteId),
      categoria: Value(categoria),
      produtoId: produtoId,
      quantidadePorCabecaDia: quantidadePorCabecaDia,
      deviceId: _deviceId,
    );
    await _db.into(_db.dietas).insert(companion);
  }

  Future<void> registrarFornecimento({
    required String loteId,
    required String dietaId,
    required double quantidadeFornecida,
  }) async {
    final now = DateTime.now();

    await _db.transaction(() async {
      await _db.into(_db.fornecimentosDieta).insert(FornecimentosDietaCompanion.insert(
        id: _uuid.v4(),
        loteId: loteId,
        dietaId: dietaId,
        quantidadeFornecida: quantidadeFornecida,
        dataFornecimento: Value(now),
        deviceId: _deviceId,
      ));

      // Busca o produto da dieta para baixar o estoque
      final dieta = await (_db.select(_db.dietas)..where((d) => d.id.equals(dietaId))).getSingle();
      
      await _db.into(_db.estoqueMovimentos).insert(EstoqueMovimentosCompanion.insert(
        id: _uuid.v4(),
        produtoId: dieta.produtoId,
        tipo: 'saida',
        quantidade: quantidadeFornecida,
        origem: 'fornecimento_dieta',
        deviceId: _deviceId,
      ));
    });
  }
}
