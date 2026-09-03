import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/device_info_provider.dart';
import '../../sync/services/sync_service.dart';

final financeiroServiceProvider = Provider<FinanceiroService>((ref) {
  final db = ref.watch(databaseProvider);
  final deviceId = ref.watch(deviceIdProvider).asData?.value;

  if (deviceId == null) {
    throw Exception("DeviceId não está disponível para o FinanceiroService");
  }

  return FinanceiroService(db, deviceId);
});

class FinanceiroService {
  final AppDatabase _db;
  final String _deviceId;
  final Uuid _uuid = const Uuid();

  FinanceiroService(this._db, this._deviceId);

  Future<void> criarLancamento({
    required String fazendaId,
    required String tipo, // pagar, receber
    required String descricao,
    required String categoria,
    required double valor,
    required DateTime dataVencimento,
    DateTime? dataPagamento,
    String status = 'pendente',
  }) async {
    final lancamentoId = _uuid.v4();
    final companion = LancamentosFinanceirosCompanion.insert(
      id: lancamentoId,
      fazendaId: fazendaId,
      tipo: tipo,
      descricao: descricao,
      categoria: categoria,
      valor: valor,
      dataVencimento: dataVencimento,
      dataPagamento: Value(dataPagamento),
      status: status,
      deviceId: _deviceId,
    );

    await _db.into(_db.lancamentosFinanceiros).insert(companion);

    await SyncService.enqueueSync(
      _db,
      'lancamentos_financeiros',
      lancamentoId,
      'insert',
      {
        'fazendaId': fazendaId,
        'tipo': tipo,
        'descricao': descricao,
        'categoria': categoria,
        'valor': valor,
        'dataVencimento': dataVencimento.toIso8601String(),
        'dataPagamento': dataPagamento?.toIso8601String(),
        'status': status
      },
      _deviceId,
    );
  }

  Future<void> darBaixaLancamento(String id, {DateTime? dataPagamento}) async {
    final now = dataPagamento ?? DateTime.now();
    await (_db.update(_db.lancamentosFinanceiros)..where((l) => l.id.equals(id))).write(
      LancamentosFinanceirosCompanion(
        status: const Value('pago'),
        dataPagamento: Value(now),
        updatedAt: Value(DateTime.now()),
      ),
    );

    await SyncService.enqueueSync(
      _db,
      'lancamentos_financeiros',
      id,
      'update',
      {
        'status': 'pago',
        'dataPagamento': now.toIso8601String(),
      },
      _deviceId,
    );
  }

  Stream<List<LancamentoFinanceiro>> watchLancamentos(String fazendaId, {String? statusFiltro}) {
    final query = _db.select(_db.lancamentosFinanceiros)
      ..where((l) => l.fazendaId.equals(fazendaId) & l.deletedAt.isNull());

    if (statusFiltro != null && statusFiltro != 'todos') {
      query.where((l) => l.status.equals(statusFiltro));
    }

    query.orderBy([(l) => OrderingTerm.asc(l.dataVencimento)]);
    return query.watch();
  }
}
