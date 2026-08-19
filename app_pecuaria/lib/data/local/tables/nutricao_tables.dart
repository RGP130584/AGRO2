import 'package:drift/drift.dart';
import 'sync_mixin.dart';
import 'rebanho_tables.dart';
import 'estoque_tables.dart';

@DataClassName('Dieta')
class Dietas extends Table with SyncMixin {
  TextColumn get loteId => text().nullable().references(Lotes, #id)();
  TextColumn get categoria => text().nullable()();
  TextColumn get produtoId => text().references(Produtos, #id)();
  RealColumn get quantidadePorCabecaDia => real()();
}

@DataClassName('FornecimentoDieta')
class FornecimentosDieta extends Table with SyncMixin {
  TextColumn get loteId => text().references(Lotes, #id)();
  TextColumn get dietaId => text().references(Dietas, #id)();
  DateTimeColumn get dataFornecimento => dateTime().withDefault(currentDateAndTime)();
  RealColumn get quantidadeFornecida => real()();
}
