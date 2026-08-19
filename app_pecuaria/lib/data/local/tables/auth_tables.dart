import 'package:drift/drift.dart';
import 'sync_mixin.dart';

@DataClassName('Usuario')
class Usuarios extends Table with SyncMixin {
  TextColumn get id => text()();
  TextColumn get nome => text()();
  TextColumn get cpfCnpj => text()();
  TextColumn get senhaHash => text()();
  TextColumn get perfil => text().withDefault(const Constant('proprietario'))();

  @override
  Set<Column> get primaryKey => {id};
}
