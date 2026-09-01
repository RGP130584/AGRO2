import 'package:drift/drift.dart';
import 'sync_mixin.dart';

@DataClassName('Fazenda')
class Fazendas extends Table with SyncMixin {
  TextColumn get nome => text().withLength(min: 2, max: 100)();
  TextColumn get cpfCnpj => text().withLength(min: 11, max: 18).nullable()();
  TextColumn get responsavel => text().nullable()();
  TextColumn get cidade => text().nullable()();
  TextColumn get estado => text().withLength(min: 2, max: 2).nullable()();
  TextColumn get logoBase64 => text().nullable()();
}

@DataClassName('Piquete')
class Piquetes extends Table with SyncMixin {
  TextColumn get fazendaId => text().references(Fazendas, #id)();
  TextColumn get nome => text().withLength(min: 1, max: 50)();
  TextColumn get coordenadas => text().nullable()();
  RealColumn get areaHectares => real().nullable()();
  IntColumn get capacidadeCabecas => integer().nullable()();
}

@DataClassName('Lote')
class Lotes extends Table with SyncMixin {
  TextColumn get fazendaId => text().references(Fazendas, #id)();
  TextColumn get piqueteId => text().nullable().references(Piquetes, #id)();
  TextColumn get nome => text().withLength(min: 1, max: 100)();
  TextColumn get categoria => text().withLength(min: 1, max: 50)();
  IntColumn get quantidade => integer().withDefault(const Constant(0))();
}

@DataClassName('Animal')
class Animais extends Table with SyncMixin {
  TextColumn get loteId => text().references(Lotes, #id)();
  TextColumn get brinco => text().withLength(min: 1, max: 50)();
  // Bovino, Equino, Ovino, Suíno, Caprino
  TextColumn get tipoAnimal => text().withDefault(const Constant('Bovino'))();
  TextColumn get categoria => text()();
  TextColumn get raca => text()();
  // M = Macho, F = Fêmea
  TextColumn get sexo => text().withDefault(const Constant('M'))();
  DateTimeColumn get dataNascimento => dateTime().nullable()();
  RealColumn get pesoKg => real().nullable()();

  // ── Reprodução ────────────────────────────────────────
  // Se fêmea: está prenha atualmente?
  BoolColumn get prenha => boolean().nullable()();
  // Data da última cobertura / IA
  DateTimeColumn get dataCobertura => dateTime().nullable()();
  // Data prevista do parto (calculada automaticamente)
  DateTimeColumn get dataPartoPrevisto => dateTime().nullable()();
  // Data em que efetivamente pariu
  DateTimeColumn get dataParto => dateTime().nullable()();
  // Quantos filhotes nasceram
  IntColumn get qtdFilhotes => integer().nullable()();
  // Quantos filhotes sobreviveram
  IntColumn get qtdFilhotesVivos => integer().nullable()();
}

@DataClassName('Pesagem')
class Pesagens extends Table with SyncMixin {
  TextColumn get animalId => text().references(Animais, #id)();
  RealColumn get peso => real()();
  DateTimeColumn get dataPesagem => dateTime().withDefault(currentDateAndTime)();
}
