import 'package:drift/drift.dart';

/// Tabela que implementa o padrão Outbox (Fila de Saída) para sincronização assíncrona.
/// Cada linha representa uma mutação local (create/update/delete) que aguarda envio ao servidor.
/// Este mecanismo garante que nenhuma operação offline seja perdida, mesmo em quedas bruscas de energia.
@DataClassName('SyncQueueItem')
class SyncQueueItems extends Table {
  /// ID interno incremental para ordenação rigorosa da fila.
  IntColumn get id => integer().autoIncrement()();
  
  /// Nome da tabela/entidade alvo da mutação (Ex: 'animais', 'produtos', 'aplicacoes_sanitarias').
  TextColumn get entityType => text()(); 
  
  /// O identificador único universal (UUID local) da entidade alterada.
  TextColumn get entityId => text()(); 
  
  /// Ação realizada localmente que deve ser refletida no servidor ('create', 'update', 'delete').
  TextColumn get action => text()(); 
  
  /// Snapshot em JSON do estado da entidade no exato momento da ação.
  TextColumn get payload => text()(); 
  
  /// Estado atual do processamento deste item da fila:
  /// - `pending`: pronto para ser enviado.
  /// - `processing`: em trânsito/sendo processado pelo serviço.
  /// - `failed`: erro no envio, aguardando nova tentativa.
  TextColumn get status => text().withDefault(const Constant('pending'))(); 
  
  /// Timestamp exato da mutação, usado para garantir a ordem cronológica de sincronização.
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
  
  /// Contador de tentativas de reenvio em caso de falha de comunicação ou erro 500 do servidor.
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  
  /// Mensagem técnica de erro registrada na última tentativa falha de sincronização.
  TextColumn get lastError => text().nullable()();
  
  /// ID único do dispositivo onde a mutação ocorreu, vital para auditoria e log.
  TextColumn get deviceId => text()();
}