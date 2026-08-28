import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';

final relatorioEstoqueServiceProvider = Provider<RelatorioEstoqueService>((ref) {
  return RelatorioEstoqueService(ref.watch(databaseProvider));
});

class KardexItem {
  final EstoqueMovimento movimento;
  final double saldoAcumulado;
  KardexItem({required this.movimento, required this.saldoAcumulado});
}

class ConsumoOrigem {
  final String origem;
  final double total;
  ConsumoOrigem({required this.origem, required this.total});
}

class SaldoProduto {
  final Produto produto;
  final double saldo;
  final DateTime? proximoVencimento;
  SaldoProduto({required this.produto, required this.saldo, this.proximoVencimento});
}

class RelatorioEstoqueService {
  final AppDatabase _db;

  RelatorioEstoqueService(this._db);

  // 5.1 Saldo Consolidado de todos os produtos
  Stream<List<SaldoProduto>> watchSaldoConsolidado() {
    final now = DateTime.now();
    final limite30 = now.add(const Duration(days: 30));

    return _db.select(_db.produtos).watch().asyncMap((produtos) async {
      final result = <SaldoProduto>[];
      for (final p in produtos) {
        final movimentos = await (_db.select(_db.estoqueMovimentos)..where((m) => m.produtoId.equals(p.id))).get();
        double saldo = 0;
        DateTime? proximoVencimento;
        for (final m in movimentos) {
          if (m.tipo == 'entrada') saldo += m.quantidade;
          if (m.tipo == 'saida') saldo -= m.quantidade;
          if (m.dataValidade != null && m.dataValidade!.isAfter(now) && m.dataValidade!.isBefore(limite30)) {
            if (proximoVencimento == null || m.dataValidade!.isBefore(proximoVencimento)) {
              proximoVencimento = m.dataValidade;
            }
          }
        }
        result.add(SaldoProduto(produto: p, saldo: saldo, proximoVencimento: proximoVencimento));
      }
      return result..sort((a, b) => a.produto.nome.compareTo(b.produto.nome));
    });
  }

  // 5.2 Kardex — extrato de movimentos de um produto com saldo corrente
  Stream<List<KardexItem>> watchKardex(String produtoId) {
    return (_db.select(_db.estoqueMovimentos)
          ..where((m) => m.produtoId.equals(produtoId))
          ..orderBy([(m) => drift.OrderingTerm.asc(m.createdAt)]))
        .watch()
        .map((movimentos) {
      double saldo = 0;
      return movimentos.map((m) {
        if (m.tipo == 'entrada') saldo += m.quantidade;
        if (m.tipo == 'saida') saldo -= m.quantidade;
        return KardexItem(movimento: m, saldoAcumulado: saldo);
      }).toList();
    });
  }

  // 5.3 Consumo por origem (aplicacao, fornecimento_dieta, compra) de um produto
  Future<List<ConsumoOrigem>> getConsumoByOrigem(String produtoId, {DateTime? inicio, DateTime? fim}) async {
    var query = _db.select(_db.estoqueMovimentos)
      ..where((m) => m.produtoId.equals(produtoId) & m.tipo.equals('saida'));

    final movimentos = await query.get().then((list) => list.where((m) {
          if (inicio != null && m.createdAt.isBefore(inicio)) return false;
          if (fim != null && m.createdAt.isAfter(fim)) return false;
          return true;
        }).toList());

    final totaisByOrigem = <String, double>{};
    for (final m in movimentos) {
      totaisByOrigem[m.origem] = (totaisByOrigem[m.origem] ?? 0) + m.quantidade;
    }

    return totaisByOrigem.entries
        .map((e) => ConsumoOrigem(origem: e.key, total: e.value))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));
  }

  // 5.4 Produtos próximos ao vencimento
  Future<List<({Produto produto, DateTime dataValidade, double quantidade})>> getProdutosAVencer({int diasLimite = 30}) async {
    final now = DateTime.now();
    final limite = now.add(Duration(days: diasLimite));

    final movimentos = await (_db.select(_db.estoqueMovimentos)
          ..where((m) => m.tipo.equals('entrada') & m.dataValidade.isNotNull() & m.dataValidade.isBiggerThanValue(now) & m.dataValidade.isSmallerOrEqualValue(limite))
          ..orderBy([(m) => drift.OrderingTerm.asc(m.dataValidade)]))
        .get();

    final result = <({Produto produto, DateTime dataValidade, double quantidade})>[];
    for (final m in movimentos) {
      final produto = await (_db.select(_db.produtos)..where((p) => p.id.equals(m.produtoId))).getSingleOrNull();
      if (produto != null && m.dataValidade != null) {
        result.add((produto: produto, dataValidade: m.dataValidade!, quantidade: m.quantidade));
      }
    }
    return result;
  }
}
