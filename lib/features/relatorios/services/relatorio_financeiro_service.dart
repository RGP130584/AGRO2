import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';

final relatorioFinanceiroServiceProvider = Provider<RelatorioFinanceiroService>((ref) {
  return RelatorioFinanceiroService(ref.watch(databaseProvider));
});

class FluxoMensal {
  final int ano;
  final int mes;
  final double totalPagar;
  final double totalReceber;
  final double totalPago;
  final double totalRecebido;

  double get saldoProjetado => totalReceber - totalPagar;
  double get saldoRealizado => totalRecebido - totalPago;

  FluxoMensal({
    required this.ano,
    required this.mes,
    required this.totalPagar,
    required this.totalReceber,
    required this.totalPago,
    required this.totalRecebido,
  });
}

class RelatorioFinanceiroService {
  final AppDatabase _db;

  RelatorioFinanceiroService(this._db);

  // 6.1 Fluxo de Caixa Simplificado agrupado por mês
  Stream<List<FluxoMensal>> watchFluxoCaixaMensal(String fazendaId) {
    return (_db.select(_db.lancamentosFinanceiros)
          ..where((l) => l.fazendaId.equals(fazendaId) & l.deletedAt.isNull())
          ..orderBy([(l) => drift.OrderingTerm.asc(l.dataVencimento)]))
        .watch()
        .map((lancamentos) {
      final byMes = <String, FluxoMensal>{};
      for (final l in lancamentos) {
        final chave = '${l.dataVencimento.year}-${l.dataVencimento.month.toString().padLeft(2, '0')}';
        final existing = byMes[chave];
        final ano = l.dataVencimento.year;
        final mes = l.dataVencimento.month;

        final isPagar = l.tipo == 'pagar';
        final isPago = l.status == 'pago';

        byMes[chave] = FluxoMensal(
          ano: ano,
          mes: mes,
          totalPagar: (existing?.totalPagar ?? 0) + (isPagar ? l.valor : 0),
          totalReceber: (existing?.totalReceber ?? 0) + (!isPagar ? l.valor : 0),
          totalPago: (existing?.totalPago ?? 0) + (isPagar && isPago ? l.valor : 0),
          totalRecebido: (existing?.totalRecebido ?? 0) + (!isPagar && isPago ? l.valor : 0),
        );
      }
      return byMes.values.toList()..sort((a, b) => a.ano != b.ano ? a.ano.compareTo(b.ano) : a.mes.compareTo(b.mes));
    });
  }

  // 6.2 Contas em atraso (vencimento < hoje, status != pago)
  Stream<List<LancamentoFinanceiro>> watchContasEmAtraso(String fazendaId) {
    final hoje = DateTime.now();
    return (_db.select(_db.lancamentosFinanceiros)
          ..where((l) =>
              l.fazendaId.equals(fazendaId) &
              l.dataVencimento.isSmallerThanValue(hoje) &
              l.status.isNotIn(['pago']) &
              l.deletedAt.isNull())
          ..orderBy([(l) => drift.OrderingTerm.asc(l.dataVencimento)]))
        .watch();
  }

  // Totais gerais
  Stream<({double aPagar, double aReceber})> watchTotaisGerais(String fazendaId) {
    return (_db.select(_db.lancamentosFinanceiros)
          ..where((l) => l.fazendaId.equals(fazendaId) & l.status.isNotIn(['pago']) & l.deletedAt.isNull()))
        .watch()
        .map((list) {
      double aPagar = 0;
      double aReceber = 0;
      for (final l in list) {
        if (l.tipo == 'pagar') aPagar += l.valor;
        else aReceber += l.valor;
      }
      return (aPagar: aPagar, aReceber: aReceber);
    });
  }
}
