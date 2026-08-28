import 'package:drift/drift.dart';
import 'sync_mixin.dart';

@DataClassName('Usuario')
class Usuarios extends Table with SyncMixin {
  TextColumn get id => text()();
  TextColumn get nome => text()();
  TextColumn get cpfCnpj => text()();
  TextColumn get senhaHash => text()();
  TextColumn get perfil => text().withDefault(const Constant('proprietario'))();
  TextColumn get email => text().nullable()();
  TextColumn get telefone => text().nullable()();
  BoolColumn get emailVerificado => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
