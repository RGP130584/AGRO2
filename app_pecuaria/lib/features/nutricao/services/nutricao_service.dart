import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/device_info_provider.dart';
import '../../sync/services/sync_service.dart';

class FornecimentoResultado {
  final double totalPlanejado;
  final double quantidadeFornecida;
  final double divergenciaPercentual;
  final bool isDivergente;

  FornecimentoResultado({
    required this.totalPlanejado,
    required this.quantidadeFornecida,
    required this.divergenciaPercentual,
    required this.isDivergente,
  });
}

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
    await SyncService.enqueueSync(
      _db,
      'dietas',
      companion.id.value,
      'insert',
      {
        'loteId': loteId,
        'categoria': categoria,
        'produtoId': produtoId,
        'quantidadePorCabecaDia': quantidadePorCabecaDia
      },
      _deviceId,
    );
  }

  Future<double> calcularTotalPlanejado(String loteId, String dietaId) async {
    final dieta = await (_db.select(_db.dietas)..where((d) => d.id.equals(dietaId))).getSingleOrNull();
    if (dieta == null) return 0.0;

    final animaisCount = await (_db.select(_db.animais)..where((a) => a.loteId.equals(loteId))).get();
    final totalCabecas = animaisCount.length;
    return totalCabecas * dieta.quantidadePorCabecaDia;
  }

  Future<FornecimentoResultado> registrarFornecimento({
    required String loteId,
    required String dietaId,
    required double quantidadeFornecida,
  }) async {
    final now = DateTime.now();
    final totalPlanejado = await calcularTotalPlanejado(loteId, dietaId);
    
    double divergencia = 0.0;
    bool isDivergente = false;

    if (totalPlanejado > 0) {
      divergencia = ((quantidadeFornecida - totalPlanejado).abs() / totalPlanejado) * 100;
      isDivergente = divergencia > 15.0; // Alerta se divergência for maior que 15%
    }

    final fornecimentoId = _uuid.v4();

    await _db.transaction(() async {
      await _db.into(_db.fornecimentosDieta).insert(FornecimentosDietaCompanion.insert(
        id: fornecimentoId,
        loteId: loteId,
        dietaId: dietaId,
        quantidadeFornecida: quantidadeFornecida,
        dataFornecimento: Value(now),
        deviceId: _deviceId,
      ));

      // Busca o produto da dieta para baixar o estoque
      final dieta = await (_db.select(_db.dietas)..where((d) => d.id.equals(dietaId))).getSingle();
      
      final movimentoId = _uuid.v4();
      await _db.into(_db.estoqueMovimentos).insert(EstoqueMovimentosCompanion.insert(
        id: movimentoId,
        produtoId: dieta.produtoId,
        tipo: 'saida',
        quantidade: quantidadeFornecida,
        origem: 'fornecimento_dieta',
        deviceId: _deviceId,
      ));

      await SyncService.enqueueSync(
        _db,
        'fornecimentos_dieta',
        fornecimentoId,
        'insert',
        {
          'loteId': loteId,
          'dietaId': dietaId,
          'quantidadeFornecida': quantidadeFornecida,
          'dataFornecimento': now.toIso8601String()
        },
        _deviceId,
      );
    });

    return FornecimentoResultado(
      totalPlanejado: totalPlanejado,
      quantidadeFornecida: quantidadeFornecida,
      divergenciaPercentual: divergencia,
      isDivergente: isDivergente,
    );
  }

  Stream<List<TypedResult>> watchDietasDetalhadas(String fazendaId) {
    final query = _db.select(_db.dietas).join([
      innerJoin(_db.produtos, _db.produtos.id.equalsExp(_db.dietas.produtoId)),
      leftOuterJoin(_db.lotes, _db.lotes.id.equalsExp(_db.dietas.loteId)),
    ]);
    return query.watch();
  }

  Stream<List<TypedResult>> watchFornecimentosDetalhados(String fazendaId) {
    final query = _db.select(_db.fornecimentosDieta).join([
      innerJoin(_db.dietas, _db.dietas.id.equalsExp(_db.fornecimentosDieta.dietaId)),
      innerJoin(_db.produtos, _db.produtos.id.equalsExp(_db.dietas.produtoId)),
      innerJoin(_db.lotes, _db.lotes.id.equalsExp(_db.fornecimentosDieta.loteId)),
    ])..orderBy([OrderingTerm.desc(_db.fornecimentosDieta.dataFornecimento)]);
    return query.watch();
  }
}
