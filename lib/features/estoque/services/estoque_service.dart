import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/device_info_provider.dart';
import '../models/produto_list_item.dart';

final estoqueServiceProvider = Provider<EstoqueService>((ref) {
  final db = ref.watch(databaseProvider);
  final deviceId = ref.watch(deviceIdProvider).asData?.value;

  if (deviceId == null) {
    throw Exception("DeviceId não está disponível para o EstoqueService");
  }

  return EstoqueService(db, deviceId);
});

/// Serviço que encapsula as regras de negócio para o módulo de Estoque.
class EstoqueService {
  final AppDatabase _db;
  final String _deviceId;
  final Uuid _uuid = const Uuid();

  EstoqueService(this._db, this._deviceId);

  /// Cadastra um novo produto no sistema.
  Future<void> cadastrarProduto({
    required String nome,
    required String tipo,
    required String unidade,
    int? carenciaDias,
  }) async {
    final produtoCompanion = ProdutosCompanion.insert(
      id: _uuid.v4(),
      nome: nome,
      tipo: tipo,
      unidade: unidade,
      carenciaDiasPadrao: Value(carenciaDias ?? 0),
      deviceId: _deviceId,
    );
    await _db.into(_db.produtos).insert(produtoCompanion);
  }

  /// Registra uma entrada de estoque para um produto (ex: compra).
  Future<void> registrarEntrada({
    required String produtoId,
    required double quantidade,
    required DateTime data,
  }) async {
    final movimentoCompanion = EstoqueMovimentosCompanion.insert(
      id: _uuid.v4(),
      produtoId: produtoId,
      tipo: 'entrada',
      quantidade: quantidade,
      dataMovimento: Value(data),
      origem: 'compra', // Origem manual de entrada
      deviceId: _deviceId,
    );
    await _db.into(_db.estoqueMovimentos).insert(movimentoCompanion);
  }

  /// Observa a lista de produtos e calcula o saldo atual para cada um.
  Stream<List<ProdutoListItem>> watchProdutosComSaldo() {
    final produtosStream = (_db.select(_db.produtos)
          ..where((p) => p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm(expression: p.nome)]))
        .watch();

    return produtosStream.asyncMap((produtos) async {
      final List<ProdutoListItem> result = [];
      for (final produto in produtos) {
        final saldo = await _calcularSaldo(produto.id);
        result.add(ProdutoListItem(produto: produto, saldo: saldo));
      }
      return result;
    });
  }

  /// Calcula o saldo de um produto somando entradas e subtraindo saídas.
  Future<double> _calcularSaldo(String produtoId) async {
    final movimentos = await (_db.select(_db.estoqueMovimentos)
          ..where((tbl) => tbl.produtoId.equals(produtoId)))
        .get();

    double saldo = 0;
    for (final mov in movimentos) {
      saldo += (mov.tipo == 'entrada' ? mov.quantidade : -mov.quantidade);
    }
    return saldo;
  }
}