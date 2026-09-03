import 'package:drift/drift.dart';

/// Mixin que adiciona os campos necessários para a sincronização offline-first.
/// Deve ser aplicado a todas as tabelas de domínio (negócio) do banco local,
/// garantindo que possuam rastreabilidade e controle de versão consistentes.
mixin SyncMixin on Table {
  /// Identificador único universal (UUID V4) gerado localmente.
  /// Funciona como chave de idempotência e identificador principal.
  TextColumn get id => text()();
  
  /// Identificador gerado pelo servidor após a sincronização bem-sucedida.
  /// Fica nulo enquanto o registro existir apenas no dispositivo local.
  TextColumn get serverId => text().nullable()();
  
  /// Status atual da sincronização do registro:
  /// - `pending`: aguardando envio para o servidor
  /// - `synced`: sincronizado com sucesso
  /// - `conflict`: ocorreu um conflito de versão que precisa de resolução
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  
  /// Identificador único do dispositivo que criou ou modificou este registro.
  /// Usado para auditoria e resolução de conflitos.
  TextColumn get deviceId => text()();
  
  /// Data e hora da criação original do registro.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  /// Data e hora da última modificação do registro.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  /// Data e hora da exclusão lógica (soft delete). Se preenchido, o registro
  /// é considerado apagado, mas é mantido no banco para sincronizar a exclusão.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
