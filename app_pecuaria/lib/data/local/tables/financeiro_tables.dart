import 'package:drift/drift.dart';
import 'sync_mixin.dart';
import 'rebanho_tables.dart';

@DataClassName('LancamentoFinanceiro')
class LancamentosFinanceiros extends Table with SyncMixin {
  TextColumn get fazendaId => text().references(Fazendas, #id)();
  TextColumn get tipo => text().withLength(min: 1, max: 20)(); // pagar, receber
  TextColumn get descricao => text().withLength(min: 1, max: 200)();
  TextColumn get categoria => text().withLength(min: 1, max: 50)(); // insumos, animais, maquinario, venda, outros
  RealColumn get valor => real()();
  DateTimeColumn get dataVencimento => dateTime()();
  DateTimeColumn get dataPagamento => dateTime().nullable()();
  TextColumn get status => text().withLength(min: 1, max: 20)(); // pendente, pago, atrasado
}
