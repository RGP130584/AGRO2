import 'package:drift/drift.dart';
import 'sync_mixin.dart';
import 'rebanho_tables.dart';
import 'estoque_tables.dart';

@DataClassName('AplicacaoSanitaria')
class AplicacoesSanitarias extends Table with SyncMixin {
  // Uma aplicação pode ser num lote inteiro ou apenas num animal específico
  TextColumn get animalId => text().nullable().references(Animais, #id)();
  TextColumn get loteId => text().nullable().references(Lotes, #id)();
  
  TextColumn get produtoId => text().references(Produtos, #id)();
  RealColumn get dose => real()();
  TextColumn get via => text().withLength(min: 1, max: 50)();
  TextColumn get motivo => text().withLength(min: 1, max: 100)();
  
  DateTimeColumn get dataAplicacao => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get carenciaFimCalculada => dateTime().nullable()();
  
  TextColumn get fotoPath => text().nullable()();
}

@DataClassName('OcorrenciaSanitaria')
class OcorrenciasSanitarias extends Table with SyncMixin {
  TextColumn get animalId => text().references(Animais, #id)();
  TextColumn get tipo => text().withLength(min: 1, max: 50)(); // doenca, obito, acidente, outro
  TextColumn get descricao => text()();
  DateTimeColumn get dataOcorrencia => dateTime().withDefault(currentDateAndTime)();
  TextColumn get fotoPath => text().nullable()();
}

