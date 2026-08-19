import 'package:drift/drift.dart';
import 'sync_mixin.dart';

@DataClassName('Produto')
class Produtos extends Table with SyncMixin {
  TextColumn get tipo => text().withLength(min: 1, max: 50)(); // vacina, medicamento, racao
  TextColumn get nome => text().withLength(min: 1, max: 100)();
  IntColumn get carenciaDiasPadrao => integer().withDefault(const Constant(0))();
  TextColumn get unidade => text().withLength(min: 1, max: 10)(); // kg, ml, dose
  RealColumn get estoqueMinimo => real().withDefault(const Constant(0))();
}

@DataClassName('EstoqueMovimento')
class EstoqueMovimentos extends Table with SyncMixin {
  TextColumn get produtoId => text().references(Produtos, #id)();
  TextColumn get tipo => text().withLength(min: 1, max: 10)(); // entrada, saida
  RealColumn get quantidade => real()();
  DateTimeColumn get dataMovimento => dateTime().withDefault(currentDateAndTime)();
  TextColumn get origem => text().withLength(min: 1, max: 50)(); // manual, aplicacao, dieta
}
