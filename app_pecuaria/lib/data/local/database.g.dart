// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FazendasTable extends Fazendas with TableInfo<$FazendasTable, Fazenda> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FazendasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
      'nome', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 2, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _cpfCnpjMeta =
      const VerificationMeta('cpfCnpj');
  @override
  late final GeneratedColumn<String> cpfCnpj = GeneratedColumn<String>(
      'cpf_cnpj', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 11, maxTextLength: 18),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _responsavelMeta =
      const VerificationMeta('responsavel');
  @override
  late final GeneratedColumn<String> responsavel = GeneratedColumn<String>(
      'responsavel', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cidadeMeta = const VerificationMeta('cidade');
  @override
  late final GeneratedColumn<String> cidade = GeneratedColumn<String>(
      'cidade', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
      'estado', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 2, maxTextLength: 2),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _logoBase64Meta =
      const VerificationMeta('logoBase64');
  @override
  late final GeneratedColumn<String> logoBase64 = GeneratedColumn<String>(
      'logo_base64', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        syncStatus,
        deviceId,
        createdAt,
        updatedAt,
        deletedAt,
        nome,
        cpfCnpj,
        responsavel,
        cidade,
        estado,
        logoBase64
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fazendas';
  @override
  VerificationContext validateIntegrity(Insertable<Fazenda> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
          _nomeMeta, nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta));
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('cpf_cnpj')) {
      context.handle(_cpfCnpjMeta,
          cpfCnpj.isAcceptableOrUnknown(data['cpf_cnpj']!, _cpfCnpjMeta));
    }
    if (data.containsKey('responsavel')) {
      context.handle(
          _responsavelMeta,
          responsavel.isAcceptableOrUnknown(
              data['responsavel']!, _responsavelMeta));
    }
    if (data.containsKey('cidade')) {
      context.handle(_cidadeMeta,
          cidade.isAcceptableOrUnknown(data['cidade']!, _cidadeMeta));
    }
    if (data.containsKey('estado')) {
      context.handle(_estadoMeta,
          estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta));
    }
    if (data.containsKey('logo_base64')) {
      context.handle(
          _logoBase64Meta,
          logoBase64.isAcceptableOrUnknown(
              data['logo_base64']!, _logoBase64Meta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Fazenda map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Fazenda(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      nome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nome'])!,
      cpfCnpj: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cpf_cnpj']),
      responsavel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}responsavel']),
      cidade: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cidade']),
      estado: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}estado']),
      logoBase64: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}logo_base64']),
    );
  }

  @override
  $FazendasTable createAlias(String alias) {
    return $FazendasTable(attachedDatabase, alias);
  }
}

class Fazenda extends DataClass implements Insertable<Fazenda> {
  /// Identificador único universal (UUID V4) gerado localmente.
  /// Funciona como chave de idempotência e identificador principal.
  final String id;

  /// Identificador gerado pelo servidor após a sincronização bem-sucedida.
  /// Fica nulo enquanto o registro existir apenas no dispositivo local.
  final String? serverId;

  /// Status atual da sincronização do registro:
  /// - `pending`: aguardando envio para o servidor
  /// - `synced`: sincronizado com sucesso
  /// - `conflict`: ocorreu um conflito de versão que precisa de resolução
  final String syncStatus;

  /// Identificador único do dispositivo que criou ou modificou este registro.
  /// Usado para auditoria e resolução de conflitos.
  final String deviceId;

  /// Data e hora da criação original do registro.
  final DateTime createdAt;

  /// Data e hora da última modificação do registro.
  final DateTime updatedAt;

  /// Data e hora da exclusão lógica (soft delete). Se preenchido, o registro
  /// é considerado apagado, mas é mantido no banco para sincronizar a exclusão.
  final DateTime? deletedAt;
  final String nome;
  final String? cpfCnpj;
  final String? responsavel;
  final String? cidade;
  final String? estado;
  final String? logoBase64;
  const Fazenda(
      {required this.id,
      this.serverId,
      required this.syncStatus,
      required this.deviceId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.nome,
      this.cpfCnpj,
      this.responsavel,
      this.cidade,
      this.estado,
      this.logoBase64});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['nome'] = Variable<String>(nome);
    if (!nullToAbsent || cpfCnpj != null) {
      map['cpf_cnpj'] = Variable<String>(cpfCnpj);
    }
    if (!nullToAbsent || responsavel != null) {
      map['responsavel'] = Variable<String>(responsavel);
    }
    if (!nullToAbsent || cidade != null) {
      map['cidade'] = Variable<String>(cidade);
    }
    if (!nullToAbsent || estado != null) {
      map['estado'] = Variable<String>(estado);
    }
    if (!nullToAbsent || logoBase64 != null) {
      map['logo_base64'] = Variable<String>(logoBase64);
    }
    return map;
  }

  FazendasCompanion toCompanion(bool nullToAbsent) {
    return FazendasCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      syncStatus: Value(syncStatus),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      nome: Value(nome),
      cpfCnpj: cpfCnpj == null && nullToAbsent
          ? const Value.absent()
          : Value(cpfCnpj),
      responsavel: responsavel == null && nullToAbsent
          ? const Value.absent()
          : Value(responsavel),
      cidade:
          cidade == null && nullToAbsent ? const Value.absent() : Value(cidade),
      estado:
          estado == null && nullToAbsent ? const Value.absent() : Value(estado),
      logoBase64: logoBase64 == null && nullToAbsent
          ? const Value.absent()
          : Value(logoBase64),
    );
  }

  factory Fazenda.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Fazenda(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      nome: serializer.fromJson<String>(json['nome']),
      cpfCnpj: serializer.fromJson<String?>(json['cpfCnpj']),
      responsavel: serializer.fromJson<String?>(json['responsavel']),
      cidade: serializer.fromJson<String?>(json['cidade']),
      estado: serializer.fromJson<String?>(json['estado']),
      logoBase64: serializer.fromJson<String?>(json['logoBase64']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'nome': serializer.toJson<String>(nome),
      'cpfCnpj': serializer.toJson<String?>(cpfCnpj),
      'responsavel': serializer.toJson<String?>(responsavel),
      'cidade': serializer.toJson<String?>(cidade),
      'estado': serializer.toJson<String?>(estado),
      'logoBase64': serializer.toJson<String?>(logoBase64),
    };
  }

  Fazenda copyWith(
          {String? id,
          Value<String?> serverId = const Value.absent(),
          String? syncStatus,
          String? deviceId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? nome,
          Value<String?> cpfCnpj = const Value.absent(),
          Value<String?> responsavel = const Value.absent(),
          Value<String?> cidade = const Value.absent(),
          Value<String?> estado = const Value.absent(),
          Value<String?> logoBase64 = const Value.absent()}) =>
      Fazenda(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        syncStatus: syncStatus ?? this.syncStatus,
        deviceId: deviceId ?? this.deviceId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        nome: nome ?? this.nome,
        cpfCnpj: cpfCnpj.present ? cpfCnpj.value : this.cpfCnpj,
        responsavel: responsavel.present ? responsavel.value : this.responsavel,
        cidade: cidade.present ? cidade.value : this.cidade,
        estado: estado.present ? estado.value : this.estado,
        logoBase64: logoBase64.present ? logoBase64.value : this.logoBase64,
      );
  Fazenda copyWithCompanion(FazendasCompanion data) {
    return Fazenda(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      nome: data.nome.present ? data.nome.value : this.nome,
      cpfCnpj: data.cpfCnpj.present ? data.cpfCnpj.value : this.cpfCnpj,
      responsavel:
          data.responsavel.present ? data.responsavel.value : this.responsavel,
      cidade: data.cidade.present ? data.cidade.value : this.cidade,
      estado: data.estado.present ? data.estado.value : this.estado,
      logoBase64:
          data.logoBase64.present ? data.logoBase64.value : this.logoBase64,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Fazenda(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('nome: $nome, ')
          ..write('cpfCnpj: $cpfCnpj, ')
          ..write('responsavel: $responsavel, ')
          ..write('cidade: $cidade, ')
          ..write('estado: $estado, ')
          ..write('logoBase64: $logoBase64')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      syncStatus,
      deviceId,
      createdAt,
      updatedAt,
      deletedAt,
      nome,
      cpfCnpj,
      responsavel,
      cidade,
      estado,
      logoBase64);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Fazenda &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.syncStatus == this.syncStatus &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.nome == this.nome &&
          other.cpfCnpj == this.cpfCnpj &&
          other.responsavel == this.responsavel &&
          other.cidade == this.cidade &&
          other.estado == this.estado &&
          other.logoBase64 == this.logoBase64);
}

class FazendasCompanion extends UpdateCompanion<Fazenda> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> syncStatus;
  final Value<String> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> nome;
  final Value<String?> cpfCnpj;
  final Value<String?> responsavel;
  final Value<String?> cidade;
  final Value<String?> estado;
  final Value<String?> logoBase64;
  final Value<int> rowid;
  const FazendasCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.nome = const Value.absent(),
    this.cpfCnpj = const Value.absent(),
    this.responsavel = const Value.absent(),
    this.cidade = const Value.absent(),
    this.estado = const Value.absent(),
    this.logoBase64 = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FazendasCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String deviceId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String nome,
    this.cpfCnpj = const Value.absent(),
    this.responsavel = const Value.absent(),
    this.cidade = const Value.absent(),
    this.estado = const Value.absent(),
    this.logoBase64 = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deviceId = Value(deviceId),
        nome = Value(nome);
  static Insertable<Fazenda> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? syncStatus,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? nome,
    Expression<String>? cpfCnpj,
    Expression<String>? responsavel,
    Expression<String>? cidade,
    Expression<String>? estado,
    Expression<String>? logoBase64,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (nome != null) 'nome': nome,
      if (cpfCnpj != null) 'cpf_cnpj': cpfCnpj,
      if (responsavel != null) 'responsavel': responsavel,
      if (cidade != null) 'cidade': cidade,
      if (estado != null) 'estado': estado,
      if (logoBase64 != null) 'logo_base64': logoBase64,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FazendasCompanion copyWith(
      {Value<String>? id,
      Value<String?>? serverId,
      Value<String>? syncStatus,
      Value<String>? deviceId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? nome,
      Value<String?>? cpfCnpj,
      Value<String?>? responsavel,
      Value<String?>? cidade,
      Value<String?>? estado,
      Value<String?>? logoBase64,
      Value<int>? rowid}) {
    return FazendasCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      syncStatus: syncStatus ?? this.syncStatus,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      nome: nome ?? this.nome,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
      responsavel: responsavel ?? this.responsavel,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      logoBase64: logoBase64 ?? this.logoBase64,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (cpfCnpj.present) {
      map['cpf_cnpj'] = Variable<String>(cpfCnpj.value);
    }
    if (responsavel.present) {
      map['responsavel'] = Variable<String>(responsavel.value);
    }
    if (cidade.present) {
      map['cidade'] = Variable<String>(cidade.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (logoBase64.present) {
      map['logo_base64'] = Variable<String>(logoBase64.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FazendasCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('nome: $nome, ')
          ..write('cpfCnpj: $cpfCnpj, ')
          ..write('responsavel: $responsavel, ')
          ..write('cidade: $cidade, ')
          ..write('estado: $estado, ')
          ..write('logoBase64: $logoBase64, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PiquetesTable extends Piquetes with TableInfo<$PiquetesTable, Piquete> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PiquetesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _fazendaIdMeta =
      const VerificationMeta('fazendaId');
  @override
  late final GeneratedColumn<String> fazendaId = GeneratedColumn<String>(
      'fazenda_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
      'nome', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _coordenadasMeta =
      const VerificationMeta('coordenadas');
  @override
  late final GeneratedColumn<String> coordenadas = GeneratedColumn<String>(
      'coordenadas', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _areaHectaresMeta =
      const VerificationMeta('areaHectares');
  @override
  late final GeneratedColumn<double> areaHectares = GeneratedColumn<double>(
      'area_hectares', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _capacidadeCabecasMeta =
      const VerificationMeta('capacidadeCabecas');
  @override
  late final GeneratedColumn<int> capacidadeCabecas = GeneratedColumn<int>(
      'capacidade_cabecas', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        syncStatus,
        deviceId,
        createdAt,
        updatedAt,
        deletedAt,
        fazendaId,
        nome,
        coordenadas,
        areaHectares,
        capacidadeCabecas
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'piquetes';
  @override
  VerificationContext validateIntegrity(Insertable<Piquete> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('fazenda_id')) {
      context.handle(_fazendaIdMeta,
          fazendaId.isAcceptableOrUnknown(data['fazenda_id']!, _fazendaIdMeta));
    } else if (isInserting) {
      context.missing(_fazendaIdMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
          _nomeMeta, nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta));
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('coordenadas')) {
      context.handle(
          _coordenadasMeta,
          coordenadas.isAcceptableOrUnknown(
              data['coordenadas']!, _coordenadasMeta));
    }
    if (data.containsKey('area_hectares')) {
      context.handle(
          _areaHectaresMeta,
          areaHectares.isAcceptableOrUnknown(
              data['area_hectares']!, _areaHectaresMeta));
    }
    if (data.containsKey('capacidade_cabecas')) {
      context.handle(
          _capacidadeCabecasMeta,
          capacidadeCabecas.isAcceptableOrUnknown(
              data['capacidade_cabecas']!, _capacidadeCabecasMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Piquete map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Piquete(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      fazendaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fazenda_id'])!,
      nome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nome'])!,
      coordenadas: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}coordenadas']),
      areaHectares: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}area_hectares']),
      capacidadeCabecas: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}capacidade_cabecas']),
    );
  }

  @override
  $PiquetesTable createAlias(String alias) {
    return $PiquetesTable(attachedDatabase, alias);
  }
}

class Piquete extends DataClass implements Insertable<Piquete> {
  /// Identificador único universal (UUID V4) gerado localmente.
  /// Funciona como chave de idempotência e identificador principal.
  final String id;

  /// Identificador gerado pelo servidor após a sincronização bem-sucedida.
  /// Fica nulo enquanto o registro existir apenas no dispositivo local.
  final String? serverId;

  /// Status atual da sincronização do registro:
  /// - `pending`: aguardando envio para o servidor
  /// - `synced`: sincronizado com sucesso
  /// - `conflict`: ocorreu um conflito de versão que precisa de resolução
  final String syncStatus;

  /// Identificador único do dispositivo que criou ou modificou este registro.
  /// Usado para auditoria e resolução de conflitos.
  final String deviceId;

  /// Data e hora da criação original do registro.
  final DateTime createdAt;

  /// Data e hora da última modificação do registro.
  final DateTime updatedAt;

  /// Data e hora da exclusão lógica (soft delete). Se preenchido, o registro
  /// é considerado apagado, mas é mantido no banco para sincronizar a exclusão.
  final DateTime? deletedAt;
  final String fazendaId;
  final String nome;
  final String? coordenadas;
  final double? areaHectares;
  final int? capacidadeCabecas;
  const Piquete(
      {required this.id,
      this.serverId,
      required this.syncStatus,
      required this.deviceId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.fazendaId,
      required this.nome,
      this.coordenadas,
      this.areaHectares,
      this.capacidadeCabecas});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['fazenda_id'] = Variable<String>(fazendaId);
    map['nome'] = Variable<String>(nome);
    if (!nullToAbsent || coordenadas != null) {
      map['coordenadas'] = Variable<String>(coordenadas);
    }
    if (!nullToAbsent || areaHectares != null) {
      map['area_hectares'] = Variable<double>(areaHectares);
    }
    if (!nullToAbsent || capacidadeCabecas != null) {
      map['capacidade_cabecas'] = Variable<int>(capacidadeCabecas);
    }
    return map;
  }

  PiquetesCompanion toCompanion(bool nullToAbsent) {
    return PiquetesCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      syncStatus: Value(syncStatus),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      fazendaId: Value(fazendaId),
      nome: Value(nome),
      coordenadas: coordenadas == null && nullToAbsent
          ? const Value.absent()
          : Value(coordenadas),
      areaHectares: areaHectares == null && nullToAbsent
          ? const Value.absent()
          : Value(areaHectares),
      capacidadeCabecas: capacidadeCabecas == null && nullToAbsent
          ? const Value.absent()
          : Value(capacidadeCabecas),
    );
  }

  factory Piquete.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Piquete(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      fazendaId: serializer.fromJson<String>(json['fazendaId']),
      nome: serializer.fromJson<String>(json['nome']),
      coordenadas: serializer.fromJson<String?>(json['coordenadas']),
      areaHectares: serializer.fromJson<double?>(json['areaHectares']),
      capacidadeCabecas: serializer.fromJson<int?>(json['capacidadeCabecas']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'fazendaId': serializer.toJson<String>(fazendaId),
      'nome': serializer.toJson<String>(nome),
      'coordenadas': serializer.toJson<String?>(coordenadas),
      'areaHectares': serializer.toJson<double?>(areaHectares),
      'capacidadeCabecas': serializer.toJson<int?>(capacidadeCabecas),
    };
  }

  Piquete copyWith(
          {String? id,
          Value<String?> serverId = const Value.absent(),
          String? syncStatus,
          String? deviceId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? fazendaId,
          String? nome,
          Value<String?> coordenadas = const Value.absent(),
          Value<double?> areaHectares = const Value.absent(),
          Value<int?> capacidadeCabecas = const Value.absent()}) =>
      Piquete(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        syncStatus: syncStatus ?? this.syncStatus,
        deviceId: deviceId ?? this.deviceId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        fazendaId: fazendaId ?? this.fazendaId,
        nome: nome ?? this.nome,
        coordenadas: coordenadas.present ? coordenadas.value : this.coordenadas,
        areaHectares:
            areaHectares.present ? areaHectares.value : this.areaHectares,
        capacidadeCabecas: capacidadeCabecas.present
            ? capacidadeCabecas.value
            : this.capacidadeCabecas,
      );
  Piquete copyWithCompanion(PiquetesCompanion data) {
    return Piquete(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      fazendaId: data.fazendaId.present ? data.fazendaId.value : this.fazendaId,
      nome: data.nome.present ? data.nome.value : this.nome,
      coordenadas:
          data.coordenadas.present ? data.coordenadas.value : this.coordenadas,
      areaHectares: data.areaHectares.present
          ? data.areaHectares.value
          : this.areaHectares,
      capacidadeCabecas: data.capacidadeCabecas.present
          ? data.capacidadeCabecas.value
          : this.capacidadeCabecas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Piquete(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('fazendaId: $fazendaId, ')
          ..write('nome: $nome, ')
          ..write('coordenadas: $coordenadas, ')
          ..write('areaHectares: $areaHectares, ')
          ..write('capacidadeCabecas: $capacidadeCabecas')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      syncStatus,
      deviceId,
      createdAt,
      updatedAt,
      deletedAt,
      fazendaId,
      nome,
      coordenadas,
      areaHectares,
      capacidadeCabecas);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Piquete &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.syncStatus == this.syncStatus &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.fazendaId == this.fazendaId &&
          other.nome == this.nome &&
          other.coordenadas == this.coordenadas &&
          other.areaHectares == this.areaHectares &&
          other.capacidadeCabecas == this.capacidadeCabecas);
}

class PiquetesCompanion extends UpdateCompanion<Piquete> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> syncStatus;
  final Value<String> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> fazendaId;
  final Value<String> nome;
  final Value<String?> coordenadas;
  final Value<double?> areaHectares;
  final Value<int?> capacidadeCabecas;
  final Value<int> rowid;
  const PiquetesCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.fazendaId = const Value.absent(),
    this.nome = const Value.absent(),
    this.coordenadas = const Value.absent(),
    this.areaHectares = const Value.absent(),
    this.capacidadeCabecas = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PiquetesCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String deviceId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String fazendaId,
    required String nome,
    this.coordenadas = const Value.absent(),
    this.areaHectares = const Value.absent(),
    this.capacidadeCabecas = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deviceId = Value(deviceId),
        fazendaId = Value(fazendaId),
        nome = Value(nome);
  static Insertable<Piquete> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? syncStatus,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? fazendaId,
    Expression<String>? nome,
    Expression<String>? coordenadas,
    Expression<double>? areaHectares,
    Expression<int>? capacidadeCabecas,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (fazendaId != null) 'fazenda_id': fazendaId,
      if (nome != null) 'nome': nome,
      if (coordenadas != null) 'coordenadas': coordenadas,
      if (areaHectares != null) 'area_hectares': areaHectares,
      if (capacidadeCabecas != null) 'capacidade_cabecas': capacidadeCabecas,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PiquetesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? serverId,
      Value<String>? syncStatus,
      Value<String>? deviceId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? fazendaId,
      Value<String>? nome,
      Value<String?>? coordenadas,
      Value<double?>? areaHectares,
      Value<int?>? capacidadeCabecas,
      Value<int>? rowid}) {
    return PiquetesCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      syncStatus: syncStatus ?? this.syncStatus,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      fazendaId: fazendaId ?? this.fazendaId,
      nome: nome ?? this.nome,
      coordenadas: coordenadas ?? this.coordenadas,
      areaHectares: areaHectares ?? this.areaHectares,
      capacidadeCabecas: capacidadeCabecas ?? this.capacidadeCabecas,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (fazendaId.present) {
      map['fazenda_id'] = Variable<String>(fazendaId.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (coordenadas.present) {
      map['coordenadas'] = Variable<String>(coordenadas.value);
    }
    if (areaHectares.present) {
      map['area_hectares'] = Variable<double>(areaHectares.value);
    }
    if (capacidadeCabecas.present) {
      map['capacidade_cabecas'] = Variable<int>(capacidadeCabecas.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PiquetesCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('fazendaId: $fazendaId, ')
          ..write('nome: $nome, ')
          ..write('coordenadas: $coordenadas, ')
          ..write('areaHectares: $areaHectares, ')
          ..write('capacidadeCabecas: $capacidadeCabecas, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LotesTable extends Lotes with TableInfo<$LotesTable, Lote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _fazendaIdMeta =
      const VerificationMeta('fazendaId');
  @override
  late final GeneratedColumn<String> fazendaId = GeneratedColumn<String>(
      'fazenda_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _piqueteIdMeta =
      const VerificationMeta('piqueteId');
  @override
  late final GeneratedColumn<String> piqueteId = GeneratedColumn<String>(
      'piquete_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
      'nome', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _categoriaMeta =
      const VerificationMeta('categoria');
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
      'categoria', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _quantidadeMeta =
      const VerificationMeta('quantidade');
  @override
  late final GeneratedColumn<int> quantidade = GeneratedColumn<int>(
      'quantidade', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        syncStatus,
        deviceId,
        createdAt,
        updatedAt,
        deletedAt,
        fazendaId,
        piqueteId,
        nome,
        categoria,
        quantidade
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lotes';
  @override
  VerificationContext validateIntegrity(Insertable<Lote> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('fazenda_id')) {
      context.handle(_fazendaIdMeta,
          fazendaId.isAcceptableOrUnknown(data['fazenda_id']!, _fazendaIdMeta));
    } else if (isInserting) {
      context.missing(_fazendaIdMeta);
    }
    if (data.containsKey('piquete_id')) {
      context.handle(_piqueteIdMeta,
          piqueteId.isAcceptableOrUnknown(data['piquete_id']!, _piqueteIdMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
          _nomeMeta, nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta));
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('categoria')) {
      context.handle(_categoriaMeta,
          categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta));
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    if (data.containsKey('quantidade')) {
      context.handle(
          _quantidadeMeta,
          quantidade.isAcceptableOrUnknown(
              data['quantidade']!, _quantidadeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lote(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      fazendaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fazenda_id'])!,
      piqueteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}piquete_id']),
      nome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nome'])!,
      categoria: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categoria'])!,
      quantidade: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantidade'])!,
    );
  }

  @override
  $LotesTable createAlias(String alias) {
    return $LotesTable(attachedDatabase, alias);
  }
}

class Lote extends DataClass implements Insertable<Lote> {
  /// Identificador único universal (UUID V4) gerado localmente.
  /// Funciona como chave de idempotência e identificador principal.
  final String id;

  /// Identificador gerado pelo servidor após a sincronização bem-sucedida.
  /// Fica nulo enquanto o registro existir apenas no dispositivo local.
  final String? serverId;

  /// Status atual da sincronização do registro:
  /// - `pending`: aguardando envio para o servidor
  /// - `synced`: sincronizado com sucesso
  /// - `conflict`: ocorreu um conflito de versão que precisa de resolução
  final String syncStatus;

  /// Identificador único do dispositivo que criou ou modificou este registro.
  /// Usado para auditoria e resolução de conflitos.
  final String deviceId;

  /// Data e hora da criação original do registro.
  final DateTime createdAt;

  /// Data e hora da última modificação do registro.
  final DateTime updatedAt;

  /// Data e hora da exclusão lógica (soft delete). Se preenchido, o registro
  /// é considerado apagado, mas é mantido no banco para sincronizar a exclusão.
  final DateTime? deletedAt;
  final String fazendaId;
  final String? piqueteId;
  final String nome;
  final String categoria;
  final int quantidade;
  const Lote(
      {required this.id,
      this.serverId,
      required this.syncStatus,
      required this.deviceId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.fazendaId,
      this.piqueteId,
      required this.nome,
      required this.categoria,
      required this.quantidade});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['fazenda_id'] = Variable<String>(fazendaId);
    if (!nullToAbsent || piqueteId != null) {
      map['piquete_id'] = Variable<String>(piqueteId);
    }
    map['nome'] = Variable<String>(nome);
    map['categoria'] = Variable<String>(categoria);
    map['quantidade'] = Variable<int>(quantidade);
    return map;
  }

  LotesCompanion toCompanion(bool nullToAbsent) {
    return LotesCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      syncStatus: Value(syncStatus),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      fazendaId: Value(fazendaId),
      piqueteId: piqueteId == null && nullToAbsent
          ? const Value.absent()
          : Value(piqueteId),
      nome: Value(nome),
      categoria: Value(categoria),
      quantidade: Value(quantidade),
    );
  }

  factory Lote.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lote(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      fazendaId: serializer.fromJson<String>(json['fazendaId']),
      piqueteId: serializer.fromJson<String?>(json['piqueteId']),
      nome: serializer.fromJson<String>(json['nome']),
      categoria: serializer.fromJson<String>(json['categoria']),
      quantidade: serializer.fromJson<int>(json['quantidade']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'fazendaId': serializer.toJson<String>(fazendaId),
      'piqueteId': serializer.toJson<String?>(piqueteId),
      'nome': serializer.toJson<String>(nome),
      'categoria': serializer.toJson<String>(categoria),
      'quantidade': serializer.toJson<int>(quantidade),
    };
  }

  Lote copyWith(
          {String? id,
          Value<String?> serverId = const Value.absent(),
          String? syncStatus,
          String? deviceId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? fazendaId,
          Value<String?> piqueteId = const Value.absent(),
          String? nome,
          String? categoria,
          int? quantidade}) =>
      Lote(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        syncStatus: syncStatus ?? this.syncStatus,
        deviceId: deviceId ?? this.deviceId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        fazendaId: fazendaId ?? this.fazendaId,
        piqueteId: piqueteId.present ? piqueteId.value : this.piqueteId,
        nome: nome ?? this.nome,
        categoria: categoria ?? this.categoria,
        quantidade: quantidade ?? this.quantidade,
      );
  Lote copyWithCompanion(LotesCompanion data) {
    return Lote(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      fazendaId: data.fazendaId.present ? data.fazendaId.value : this.fazendaId,
      piqueteId: data.piqueteId.present ? data.piqueteId.value : this.piqueteId,
      nome: data.nome.present ? data.nome.value : this.nome,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      quantidade:
          data.quantidade.present ? data.quantidade.value : this.quantidade,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lote(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('fazendaId: $fazendaId, ')
          ..write('piqueteId: $piqueteId, ')
          ..write('nome: $nome, ')
          ..write('categoria: $categoria, ')
          ..write('quantidade: $quantidade')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, serverId, syncStatus, deviceId, createdAt,
      updatedAt, deletedAt, fazendaId, piqueteId, nome, categoria, quantidade);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lote &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.syncStatus == this.syncStatus &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.fazendaId == this.fazendaId &&
          other.piqueteId == this.piqueteId &&
          other.nome == this.nome &&
          other.categoria == this.categoria &&
          other.quantidade == this.quantidade);
}

class LotesCompanion extends UpdateCompanion<Lote> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> syncStatus;
  final Value<String> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> fazendaId;
  final Value<String?> piqueteId;
  final Value<String> nome;
  final Value<String> categoria;
  final Value<int> quantidade;
  final Value<int> rowid;
  const LotesCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.fazendaId = const Value.absent(),
    this.piqueteId = const Value.absent(),
    this.nome = const Value.absent(),
    this.categoria = const Value.absent(),
    this.quantidade = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LotesCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String deviceId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String fazendaId,
    this.piqueteId = const Value.absent(),
    required String nome,
    required String categoria,
    this.quantidade = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deviceId = Value(deviceId),
        fazendaId = Value(fazendaId),
        nome = Value(nome),
        categoria = Value(categoria);
  static Insertable<Lote> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? syncStatus,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? fazendaId,
    Expression<String>? piqueteId,
    Expression<String>? nome,
    Expression<String>? categoria,
    Expression<int>? quantidade,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (fazendaId != null) 'fazenda_id': fazendaId,
      if (piqueteId != null) 'piquete_id': piqueteId,
      if (nome != null) 'nome': nome,
      if (categoria != null) 'categoria': categoria,
      if (quantidade != null) 'quantidade': quantidade,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LotesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? serverId,
      Value<String>? syncStatus,
      Value<String>? deviceId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? fazendaId,
      Value<String?>? piqueteId,
      Value<String>? nome,
      Value<String>? categoria,
      Value<int>? quantidade,
      Value<int>? rowid}) {
    return LotesCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      syncStatus: syncStatus ?? this.syncStatus,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      fazendaId: fazendaId ?? this.fazendaId,
      piqueteId: piqueteId ?? this.piqueteId,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      quantidade: quantidade ?? this.quantidade,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (fazendaId.present) {
      map['fazenda_id'] = Variable<String>(fazendaId.value);
    }
    if (piqueteId.present) {
      map['piquete_id'] = Variable<String>(piqueteId.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (quantidade.present) {
      map['quantidade'] = Variable<int>(quantidade.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LotesCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('fazendaId: $fazendaId, ')
          ..write('piqueteId: $piqueteId, ')
          ..write('nome: $nome, ')
          ..write('categoria: $categoria, ')
          ..write('quantidade: $quantidade, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnimaisTable extends Animais with TableInfo<$AnimaisTable, Animal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimaisTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _loteIdMeta = const VerificationMeta('loteId');
  @override
  late final GeneratedColumn<String> loteId = GeneratedColumn<String>(
      'lote_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _brincoMeta = const VerificationMeta('brinco');
  @override
  late final GeneratedColumn<String> brinco = GeneratedColumn<String>(
      'brinco', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _tipoAnimalMeta =
      const VerificationMeta('tipoAnimal');
  @override
  late final GeneratedColumn<String> tipoAnimal = GeneratedColumn<String>(
      'tipo_animal', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Bovino'));
  static const VerificationMeta _categoriaMeta =
      const VerificationMeta('categoria');
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
      'categoria', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _racaMeta = const VerificationMeta('raca');
  @override
  late final GeneratedColumn<String> raca = GeneratedColumn<String>(
      'raca', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sexoMeta = const VerificationMeta('sexo');
  @override
  late final GeneratedColumn<String> sexo = GeneratedColumn<String>(
      'sexo', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('M'));
  static const VerificationMeta _dataNascimentoMeta =
      const VerificationMeta('dataNascimento');
  @override
  late final GeneratedColumn<DateTime> dataNascimento =
      GeneratedColumn<DateTime>('data_nascimento', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _pesoKgMeta = const VerificationMeta('pesoKg');
  @override
  late final GeneratedColumn<double> pesoKg = GeneratedColumn<double>(
      'peso_kg', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _prenhaMeta = const VerificationMeta('prenha');
  @override
  late final GeneratedColumn<bool> prenha = GeneratedColumn<bool>(
      'prenha', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("prenha" IN (0, 1))'));
  static const VerificationMeta _dataCoberturaMeta =
      const VerificationMeta('dataCobertura');
  @override
  late final GeneratedColumn<DateTime> dataCobertura =
      GeneratedColumn<DateTime>('data_cobertura', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dataPartoPrevistoMeta =
      const VerificationMeta('dataPartoPrevisto');
  @override
  late final GeneratedColumn<DateTime> dataPartoPrevisto =
      GeneratedColumn<DateTime>('data_parto_previsto', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dataPartoMeta =
      const VerificationMeta('dataParto');
  @override
  late final GeneratedColumn<DateTime> dataParto = GeneratedColumn<DateTime>(
      'data_parto', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _qtdFilhotesMeta =
      const VerificationMeta('qtdFilhotes');
  @override
  late final GeneratedColumn<int> qtdFilhotes = GeneratedColumn<int>(
      'qtd_filhotes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _qtdFilhotesVivosMeta =
      const VerificationMeta('qtdFilhotesVivos');
  @override
  late final GeneratedColumn<int> qtdFilhotesVivos = GeneratedColumn<int>(
      'qtd_filhotes_vivos', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        syncStatus,
        deviceId,
        createdAt,
        updatedAt,
        deletedAt,
        loteId,
        brinco,
        tipoAnimal,
        categoria,
        raca,
        sexo,
        dataNascimento,
        pesoKg,
        prenha,
        dataCobertura,
        dataPartoPrevisto,
        dataParto,
        qtdFilhotes,
        qtdFilhotesVivos
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'animais';
  @override
  VerificationContext validateIntegrity(Insertable<Animal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('lote_id')) {
      context.handle(_loteIdMeta,
          loteId.isAcceptableOrUnknown(data['lote_id']!, _loteIdMeta));
    } else if (isInserting) {
      context.missing(_loteIdMeta);
    }
    if (data.containsKey('brinco')) {
      context.handle(_brincoMeta,
          brinco.isAcceptableOrUnknown(data['brinco']!, _brincoMeta));
    } else if (isInserting) {
      context.missing(_brincoMeta);
    }
    if (data.containsKey('tipo_animal')) {
      context.handle(
          _tipoAnimalMeta,
          tipoAnimal.isAcceptableOrUnknown(
              data['tipo_animal']!, _tipoAnimalMeta));
    }
    if (data.containsKey('categoria')) {
      context.handle(_categoriaMeta,
          categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta));
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    if (data.containsKey('raca')) {
      context.handle(
          _racaMeta, raca.isAcceptableOrUnknown(data['raca']!, _racaMeta));
    } else if (isInserting) {
      context.missing(_racaMeta);
    }
    if (data.containsKey('sexo')) {
      context.handle(
          _sexoMeta, sexo.isAcceptableOrUnknown(data['sexo']!, _sexoMeta));
    }
    if (data.containsKey('data_nascimento')) {
      context.handle(
          _dataNascimentoMeta,
          dataNascimento.isAcceptableOrUnknown(
              data['data_nascimento']!, _dataNascimentoMeta));
    }
    if (data.containsKey('peso_kg')) {
      context.handle(_pesoKgMeta,
          pesoKg.isAcceptableOrUnknown(data['peso_kg']!, _pesoKgMeta));
    }
    if (data.containsKey('prenha')) {
      context.handle(_prenhaMeta,
          prenha.isAcceptableOrUnknown(data['prenha']!, _prenhaMeta));
    }
    if (data.containsKey('data_cobertura')) {
      context.handle(
          _dataCoberturaMeta,
          dataCobertura.isAcceptableOrUnknown(
              data['data_cobertura']!, _dataCoberturaMeta));
    }
    if (data.containsKey('data_parto_previsto')) {
      context.handle(
          _dataPartoPrevistoMeta,
          dataPartoPrevisto.isAcceptableOrUnknown(
              data['data_parto_previsto']!, _dataPartoPrevistoMeta));
    }
    if (data.containsKey('data_parto')) {
      context.handle(_dataPartoMeta,
          dataParto.isAcceptableOrUnknown(data['data_parto']!, _dataPartoMeta));
    }
    if (data.containsKey('qtd_filhotes')) {
      context.handle(
          _qtdFilhotesMeta,
          qtdFilhotes.isAcceptableOrUnknown(
              data['qtd_filhotes']!, _qtdFilhotesMeta));
    }
    if (data.containsKey('qtd_filhotes_vivos')) {
      context.handle(
          _qtdFilhotesVivosMeta,
          qtdFilhotesVivos.isAcceptableOrUnknown(
              data['qtd_filhotes_vivos']!, _qtdFilhotesVivosMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Animal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Animal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      loteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lote_id'])!,
      brinco: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brinco'])!,
      tipoAnimal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo_animal'])!,
      categoria: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categoria'])!,
      raca: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raca'])!,
      sexo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sexo'])!,
      dataNascimento: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}data_nascimento']),
      pesoKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}peso_kg']),
      prenha: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}prenha']),
      dataCobertura: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}data_cobertura']),
      dataPartoPrevisto: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}data_parto_previsto']),
      dataParto: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}data_parto']),
      qtdFilhotes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}qtd_filhotes']),
      qtdFilhotesVivos: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}qtd_filhotes_vivos']),
    );
  }

  @override
  $AnimaisTable createAlias(String alias) {
    return $AnimaisTable(attachedDatabase, alias);
  }
}

class Animal extends DataClass implements Insertable<Animal> {
  /// Identificador único universal (UUID V4) gerado localmente.
  /// Funciona como chave de idempotência e identificador principal.
  final String id;

  /// Identificador gerado pelo servidor após a sincronização bem-sucedida.
  /// Fica nulo enquanto o registro existir apenas no dispositivo local.
  final String? serverId;

  /// Status atual da sincronização do registro:
  /// - `pending`: aguardando envio para o servidor
  /// - `synced`: sincronizado com sucesso
  /// - `conflict`: ocorreu um conflito de versão que precisa de resolução
  final String syncStatus;

  /// Identificador único do dispositivo que criou ou modificou este registro.
  /// Usado para auditoria e resolução de conflitos.
  final String deviceId;

  /// Data e hora da criação original do registro.
  final DateTime createdAt;

  /// Data e hora da última modificação do registro.
  final DateTime updatedAt;

  /// Data e hora da exclusão lógica (soft delete). Se preenchido, o registro
  /// é considerado apagado, mas é mantido no banco para sincronizar a exclusão.
  final DateTime? deletedAt;
  final String loteId;
  final String brinco;
  final String tipoAnimal;
  final String categoria;
  final String raca;
  final String sexo;
  final DateTime? dataNascimento;
  final double? pesoKg;
  final bool? prenha;
  final DateTime? dataCobertura;
  final DateTime? dataPartoPrevisto;
  final DateTime? dataParto;
  final int? qtdFilhotes;
  final int? qtdFilhotesVivos;
  const Animal(
      {required this.id,
      this.serverId,
      required this.syncStatus,
      required this.deviceId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.loteId,
      required this.brinco,
      required this.tipoAnimal,
      required this.categoria,
      required this.raca,
      required this.sexo,
      this.dataNascimento,
      this.pesoKg,
      this.prenha,
      this.dataCobertura,
      this.dataPartoPrevisto,
      this.dataParto,
      this.qtdFilhotes,
      this.qtdFilhotesVivos});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['lote_id'] = Variable<String>(loteId);
    map['brinco'] = Variable<String>(brinco);
    map['tipo_animal'] = Variable<String>(tipoAnimal);
    map['categoria'] = Variable<String>(categoria);
    map['raca'] = Variable<String>(raca);
    map['sexo'] = Variable<String>(sexo);
    if (!nullToAbsent || dataNascimento != null) {
      map['data_nascimento'] = Variable<DateTime>(dataNascimento);
    }
    if (!nullToAbsent || pesoKg != null) {
      map['peso_kg'] = Variable<double>(pesoKg);
    }
    if (!nullToAbsent || prenha != null) {
      map['prenha'] = Variable<bool>(prenha);
    }
    if (!nullToAbsent || dataCobertura != null) {
      map['data_cobertura'] = Variable<DateTime>(dataCobertura);
    }
    if (!nullToAbsent || dataPartoPrevisto != null) {
      map['data_parto_previsto'] = Variable<DateTime>(dataPartoPrevisto);
    }
    if (!nullToAbsent || dataParto != null) {
      map['data_parto'] = Variable<DateTime>(dataParto);
    }
    if (!nullToAbsent || qtdFilhotes != null) {
      map['qtd_filhotes'] = Variable<int>(qtdFilhotes);
    }
    if (!nullToAbsent || qtdFilhotesVivos != null) {
      map['qtd_filhotes_vivos'] = Variable<int>(qtdFilhotesVivos);
    }
    return map;
  }

  AnimaisCompanion toCompanion(bool nullToAbsent) {
    return AnimaisCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      syncStatus: Value(syncStatus),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      loteId: Value(loteId),
      brinco: Value(brinco),
      tipoAnimal: Value(tipoAnimal),
      categoria: Value(categoria),
      raca: Value(raca),
      sexo: Value(sexo),
      dataNascimento: dataNascimento == null && nullToAbsent
          ? const Value.absent()
          : Value(dataNascimento),
      pesoKg:
          pesoKg == null && nullToAbsent ? const Value.absent() : Value(pesoKg),
      prenha:
          prenha == null && nullToAbsent ? const Value.absent() : Value(prenha),
      dataCobertura: dataCobertura == null && nullToAbsent
          ? const Value.absent()
          : Value(dataCobertura),
      dataPartoPrevisto: dataPartoPrevisto == null && nullToAbsent
          ? const Value.absent()
          : Value(dataPartoPrevisto),
      dataParto: dataParto == null && nullToAbsent
          ? const Value.absent()
          : Value(dataParto),
      qtdFilhotes: qtdFilhotes == null && nullToAbsent
          ? const Value.absent()
          : Value(qtdFilhotes),
      qtdFilhotesVivos: qtdFilhotesVivos == null && nullToAbsent
          ? const Value.absent()
          : Value(qtdFilhotesVivos),
    );
  }

  factory Animal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Animal(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      loteId: serializer.fromJson<String>(json['loteId']),
      brinco: serializer.fromJson<String>(json['brinco']),
      tipoAnimal: serializer.fromJson<String>(json['tipoAnimal']),
      categoria: serializer.fromJson<String>(json['categoria']),
      raca: serializer.fromJson<String>(json['raca']),
      sexo: serializer.fromJson<String>(json['sexo']),
      dataNascimento: serializer.fromJson<DateTime?>(json['dataNascimento']),
      pesoKg: serializer.fromJson<double?>(json['pesoKg']),
      prenha: serializer.fromJson<bool?>(json['prenha']),
      dataCobertura: serializer.fromJson<DateTime?>(json['dataCobertura']),
      dataPartoPrevisto:
          serializer.fromJson<DateTime?>(json['dataPartoPrevisto']),
      dataParto: serializer.fromJson<DateTime?>(json['dataParto']),
      qtdFilhotes: serializer.fromJson<int?>(json['qtdFilhotes']),
      qtdFilhotesVivos: serializer.fromJson<int?>(json['qtdFilhotesVivos']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'loteId': serializer.toJson<String>(loteId),
      'brinco': serializer.toJson<String>(brinco),
      'tipoAnimal': serializer.toJson<String>(tipoAnimal),
      'categoria': serializer.toJson<String>(categoria),
      'raca': serializer.toJson<String>(raca),
      'sexo': serializer.toJson<String>(sexo),
      'dataNascimento': serializer.toJson<DateTime?>(dataNascimento),
      'pesoKg': serializer.toJson<double?>(pesoKg),
      'prenha': serializer.toJson<bool?>(prenha),
      'dataCobertura': serializer.toJson<DateTime?>(dataCobertura),
      'dataPartoPrevisto': serializer.toJson<DateTime?>(dataPartoPrevisto),
      'dataParto': serializer.toJson<DateTime?>(dataParto),
      'qtdFilhotes': serializer.toJson<int?>(qtdFilhotes),
      'qtdFilhotesVivos': serializer.toJson<int?>(qtdFilhotesVivos),
    };
  }

  Animal copyWith(
          {String? id,
          Value<String?> serverId = const Value.absent(),
          String? syncStatus,
          String? deviceId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? loteId,
          String? brinco,
          String? tipoAnimal,
          String? categoria,
          String? raca,
          String? sexo,
          Value<DateTime?> dataNascimento = const Value.absent(),
          Value<double?> pesoKg = const Value.absent(),
          Value<bool?> prenha = const Value.absent(),
          Value<DateTime?> dataCobertura = const Value.absent(),
          Value<DateTime?> dataPartoPrevisto = const Value.absent(),
          Value<DateTime?> dataParto = const Value.absent(),
          Value<int?> qtdFilhotes = const Value.absent(),
          Value<int?> qtdFilhotesVivos = const Value.absent()}) =>
      Animal(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        syncStatus: syncStatus ?? this.syncStatus,
        deviceId: deviceId ?? this.deviceId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        loteId: loteId ?? this.loteId,
        brinco: brinco ?? this.brinco,
        tipoAnimal: tipoAnimal ?? this.tipoAnimal,
        categoria: categoria ?? this.categoria,
        raca: raca ?? this.raca,
        sexo: sexo ?? this.sexo,
        dataNascimento:
            dataNascimento.present ? dataNascimento.value : this.dataNascimento,
        pesoKg: pesoKg.present ? pesoKg.value : this.pesoKg,
        prenha: prenha.present ? prenha.value : this.prenha,
        dataCobertura:
            dataCobertura.present ? dataCobertura.value : this.dataCobertura,
        dataPartoPrevisto: dataPartoPrevisto.present
            ? dataPartoPrevisto.value
            : this.dataPartoPrevisto,
        dataParto: dataParto.present ? dataParto.value : this.dataParto,
        qtdFilhotes: qtdFilhotes.present ? qtdFilhotes.value : this.qtdFilhotes,
        qtdFilhotesVivos: qtdFilhotesVivos.present
            ? qtdFilhotesVivos.value
            : this.qtdFilhotesVivos,
      );
  Animal copyWithCompanion(AnimaisCompanion data) {
    return Animal(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      loteId: data.loteId.present ? data.loteId.value : this.loteId,
      brinco: data.brinco.present ? data.brinco.value : this.brinco,
      tipoAnimal:
          data.tipoAnimal.present ? data.tipoAnimal.value : this.tipoAnimal,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      raca: data.raca.present ? data.raca.value : this.raca,
      sexo: data.sexo.present ? data.sexo.value : this.sexo,
      dataNascimento: data.dataNascimento.present
          ? data.dataNascimento.value
          : this.dataNascimento,
      pesoKg: data.pesoKg.present ? data.pesoKg.value : this.pesoKg,
      prenha: data.prenha.present ? data.prenha.value : this.prenha,
      dataCobertura: data.dataCobertura.present
          ? data.dataCobertura.value
          : this.dataCobertura,
      dataPartoPrevisto: data.dataPartoPrevisto.present
          ? data.dataPartoPrevisto.value
          : this.dataPartoPrevisto,
      dataParto: data.dataParto.present ? data.dataParto.value : this.dataParto,
      qtdFilhotes:
          data.qtdFilhotes.present ? data.qtdFilhotes.value : this.qtdFilhotes,
      qtdFilhotesVivos: data.qtdFilhotesVivos.present
          ? data.qtdFilhotesVivos.value
          : this.qtdFilhotesVivos,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Animal(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('loteId: $loteId, ')
          ..write('brinco: $brinco, ')
          ..write('tipoAnimal: $tipoAnimal, ')
          ..write('categoria: $categoria, ')
          ..write('raca: $raca, ')
          ..write('sexo: $sexo, ')
          ..write('dataNascimento: $dataNascimento, ')
          ..write('pesoKg: $pesoKg, ')
          ..write('prenha: $prenha, ')
          ..write('dataCobertura: $dataCobertura, ')
          ..write('dataPartoPrevisto: $dataPartoPrevisto, ')
          ..write('dataParto: $dataParto, ')
          ..write('qtdFilhotes: $qtdFilhotes, ')
          ..write('qtdFilhotesVivos: $qtdFilhotesVivos')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        serverId,
        syncStatus,
        deviceId,
        createdAt,
        updatedAt,
        deletedAt,
        loteId,
        brinco,
        tipoAnimal,
        categoria,
        raca,
        sexo,
        dataNascimento,
        pesoKg,
        prenha,
        dataCobertura,
        dataPartoPrevisto,
        dataParto,
        qtdFilhotes,
        qtdFilhotesVivos
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Animal &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.syncStatus == this.syncStatus &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.loteId == this.loteId &&
          other.brinco == this.brinco &&
          other.tipoAnimal == this.tipoAnimal &&
          other.categoria == this.categoria &&
          other.raca == this.raca &&
          other.sexo == this.sexo &&
          other.dataNascimento == this.dataNascimento &&
          other.pesoKg == this.pesoKg &&
          other.prenha == this.prenha &&
          other.dataCobertura == this.dataCobertura &&
          other.dataPartoPrevisto == this.dataPartoPrevisto &&
          other.dataParto == this.dataParto &&
          other.qtdFilhotes == this.qtdFilhotes &&
          other.qtdFilhotesVivos == this.qtdFilhotesVivos);
}

class AnimaisCompanion extends UpdateCompanion<Animal> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> syncStatus;
  final Value<String> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> loteId;
  final Value<String> brinco;
  final Value<String> tipoAnimal;
  final Value<String> categoria;
  final Value<String> raca;
  final Value<String> sexo;
  final Value<DateTime?> dataNascimento;
  final Value<double?> pesoKg;
  final Value<bool?> prenha;
  final Value<DateTime?> dataCobertura;
  final Value<DateTime?> dataPartoPrevisto;
  final Value<DateTime?> dataParto;
  final Value<int?> qtdFilhotes;
  final Value<int?> qtdFilhotesVivos;
  final Value<int> rowid;
  const AnimaisCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.loteId = const Value.absent(),
    this.brinco = const Value.absent(),
    this.tipoAnimal = const Value.absent(),
    this.categoria = const Value.absent(),
    this.raca = const Value.absent(),
    this.sexo = const Value.absent(),
    this.dataNascimento = const Value.absent(),
    this.pesoKg = const Value.absent(),
    this.prenha = const Value.absent(),
    this.dataCobertura = const Value.absent(),
    this.dataPartoPrevisto = const Value.absent(),
    this.dataParto = const Value.absent(),
    this.qtdFilhotes = const Value.absent(),
    this.qtdFilhotesVivos = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimaisCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String deviceId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String loteId,
    required String brinco,
    this.tipoAnimal = const Value.absent(),
    required String categoria,
    required String raca,
    this.sexo = const Value.absent(),
    this.dataNascimento = const Value.absent(),
    this.pesoKg = const Value.absent(),
    this.prenha = const Value.absent(),
    this.dataCobertura = const Value.absent(),
    this.dataPartoPrevisto = const Value.absent(),
    this.dataParto = const Value.absent(),
    this.qtdFilhotes = const Value.absent(),
    this.qtdFilhotesVivos = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deviceId = Value(deviceId),
        loteId = Value(loteId),
        brinco = Value(brinco),
        categoria = Value(categoria),
        raca = Value(raca);
  static Insertable<Animal> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? syncStatus,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? loteId,
    Expression<String>? brinco,
    Expression<String>? tipoAnimal,
    Expression<String>? categoria,
    Expression<String>? raca,
    Expression<String>? sexo,
    Expression<DateTime>? dataNascimento,
    Expression<double>? pesoKg,
    Expression<bool>? prenha,
    Expression<DateTime>? dataCobertura,
    Expression<DateTime>? dataPartoPrevisto,
    Expression<DateTime>? dataParto,
    Expression<int>? qtdFilhotes,
    Expression<int>? qtdFilhotesVivos,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (loteId != null) 'lote_id': loteId,
      if (brinco != null) 'brinco': brinco,
      if (tipoAnimal != null) 'tipo_animal': tipoAnimal,
      if (categoria != null) 'categoria': categoria,
      if (raca != null) 'raca': raca,
      if (sexo != null) 'sexo': sexo,
      if (dataNascimento != null) 'data_nascimento': dataNascimento,
      if (pesoKg != null) 'peso_kg': pesoKg,
      if (prenha != null) 'prenha': prenha,
      if (dataCobertura != null) 'data_cobertura': dataCobertura,
      if (dataPartoPrevisto != null) 'data_parto_previsto': dataPartoPrevisto,
      if (dataParto != null) 'data_parto': dataParto,
      if (qtdFilhotes != null) 'qtd_filhotes': qtdFilhotes,
      if (qtdFilhotesVivos != null) 'qtd_filhotes_vivos': qtdFilhotesVivos,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimaisCompanion copyWith(
      {Value<String>? id,
      Value<String?>? serverId,
      Value<String>? syncStatus,
      Value<String>? deviceId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? loteId,
      Value<String>? brinco,
      Value<String>? tipoAnimal,
      Value<String>? categoria,
      Value<String>? raca,
      Value<String>? sexo,
      Value<DateTime?>? dataNascimento,
      Value<double?>? pesoKg,
      Value<bool?>? prenha,
      Value<DateTime?>? dataCobertura,
      Value<DateTime?>? dataPartoPrevisto,
      Value<DateTime?>? dataParto,
      Value<int?>? qtdFilhotes,
      Value<int?>? qtdFilhotesVivos,
      Value<int>? rowid}) {
    return AnimaisCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      syncStatus: syncStatus ?? this.syncStatus,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      loteId: loteId ?? this.loteId,
      brinco: brinco ?? this.brinco,
      tipoAnimal: tipoAnimal ?? this.tipoAnimal,
      categoria: categoria ?? this.categoria,
      raca: raca ?? this.raca,
      sexo: sexo ?? this.sexo,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      pesoKg: pesoKg ?? this.pesoKg,
      prenha: prenha ?? this.prenha,
      dataCobertura: dataCobertura ?? this.dataCobertura,
      dataPartoPrevisto: dataPartoPrevisto ?? this.dataPartoPrevisto,
      dataParto: dataParto ?? this.dataParto,
      qtdFilhotes: qtdFilhotes ?? this.qtdFilhotes,
      qtdFilhotesVivos: qtdFilhotesVivos ?? this.qtdFilhotesVivos,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (loteId.present) {
      map['lote_id'] = Variable<String>(loteId.value);
    }
    if (brinco.present) {
      map['brinco'] = Variable<String>(brinco.value);
    }
    if (tipoAnimal.present) {
      map['tipo_animal'] = Variable<String>(tipoAnimal.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (raca.present) {
      map['raca'] = Variable<String>(raca.value);
    }
    if (sexo.present) {
      map['sexo'] = Variable<String>(sexo.value);
    }
    if (dataNascimento.present) {
      map['data_nascimento'] = Variable<DateTime>(dataNascimento.value);
    }
    if (pesoKg.present) {
      map['peso_kg'] = Variable<double>(pesoKg.value);
    }
    if (prenha.present) {
      map['prenha'] = Variable<bool>(prenha.value);
    }
    if (dataCobertura.present) {
      map['data_cobertura'] = Variable<DateTime>(dataCobertura.value);
    }
    if (dataPartoPrevisto.present) {
      map['data_parto_previsto'] = Variable<DateTime>(dataPartoPrevisto.value);
    }
    if (dataParto.present) {
      map['data_parto'] = Variable<DateTime>(dataParto.value);
    }
    if (qtdFilhotes.present) {
      map['qtd_filhotes'] = Variable<int>(qtdFilhotes.value);
    }
    if (qtdFilhotesVivos.present) {
      map['qtd_filhotes_vivos'] = Variable<int>(qtdFilhotesVivos.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimaisCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('loteId: $loteId, ')
          ..write('brinco: $brinco, ')
          ..write('tipoAnimal: $tipoAnimal, ')
          ..write('categoria: $categoria, ')
          ..write('raca: $raca, ')
          ..write('sexo: $sexo, ')
          ..write('dataNascimento: $dataNascimento, ')
          ..write('pesoKg: $pesoKg, ')
          ..write('prenha: $prenha, ')
          ..write('dataCobertura: $dataCobertura, ')
          ..write('dataPartoPrevisto: $dataPartoPrevisto, ')
          ..write('dataParto: $dataParto, ')
          ..write('qtdFilhotes: $qtdFilhotes, ')
          ..write('qtdFilhotesVivos: $qtdFilhotesVivos, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProdutosTable extends Produtos with TableInfo<$ProdutosTable, Produto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProdutosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
      'tipo', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
      'nome', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _carenciaDiasPadraoMeta =
      const VerificationMeta('carenciaDiasPadrao');
  @override
  late final GeneratedColumn<int> carenciaDiasPadrao = GeneratedColumn<int>(
      'carencia_dias_padrao', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _unidadeMeta =
      const VerificationMeta('unidade');
  @override
  late final GeneratedColumn<String> unidade = GeneratedColumn<String>(
      'unidade', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _estoqueMinimoMeta =
      const VerificationMeta('estoqueMinimo');
  @override
  late final GeneratedColumn<double> estoqueMinimo = GeneratedColumn<double>(
      'estoque_minimo', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        syncStatus,
        deviceId,
        createdAt,
        updatedAt,
        deletedAt,
        tipo,
        nome,
        carenciaDiasPadrao,
        unidade,
        estoqueMinimo
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'produtos';
  @override
  VerificationContext validateIntegrity(Insertable<Produto> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('tipo')) {
      context.handle(
          _tipoMeta, tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta));
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
          _nomeMeta, nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta));
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('carencia_dias_padrao')) {
      context.handle(
          _carenciaDiasPadraoMeta,
          carenciaDiasPadrao.isAcceptableOrUnknown(
              data['carencia_dias_padrao']!, _carenciaDiasPadraoMeta));
    }
    if (data.containsKey('unidade')) {
      context.handle(_unidadeMeta,
          unidade.isAcceptableOrUnknown(data['unidade']!, _unidadeMeta));
    } else if (isInserting) {
      context.missing(_unidadeMeta);
    }
    if (data.containsKey('estoque_minimo')) {
      context.handle(
          _estoqueMinimoMeta,
          estoqueMinimo.isAcceptableOrUnknown(
              data['estoque_minimo']!, _estoqueMinimoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Produto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Produto(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      tipo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo'])!,
      nome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nome'])!,
      carenciaDiasPadrao: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}carencia_dias_padrao'])!,
      unidade: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unidade'])!,
      estoqueMinimo: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}estoque_minimo'])!,
    );
  }

  @override
  $ProdutosTable createAlias(String alias) {
    return $ProdutosTable(attachedDatabase, alias);
  }
}

class Produto extends DataClass implements Insertable<Produto> {
  /// Identificador único universal (UUID V4) gerado localmente.
  /// Funciona como chave de idempotência e identificador principal.
  final String id;

  /// Identificador gerado pelo servidor após a sincronização bem-sucedida.
  /// Fica nulo enquanto o registro existir apenas no dispositivo local.
  final String? serverId;

  /// Status atual da sincronização do registro:
  /// - `pending`: aguardando envio para o servidor
  /// - `synced`: sincronizado com sucesso
  /// - `conflict`: ocorreu um conflito de versão que precisa de resolução
  final String syncStatus;

  /// Identificador único do dispositivo que criou ou modificou este registro.
  /// Usado para auditoria e resolução de conflitos.
  final String deviceId;

  /// Data e hora da criação original do registro.
  final DateTime createdAt;

  /// Data e hora da última modificação do registro.
  final DateTime updatedAt;

  /// Data e hora da exclusão lógica (soft delete). Se preenchido, o registro
  /// é considerado apagado, mas é mantido no banco para sincronizar a exclusão.
  final DateTime? deletedAt;
  final String tipo;
  final String nome;
  final int carenciaDiasPadrao;
  final String unidade;
  final double estoqueMinimo;
  const Produto(
      {required this.id,
      this.serverId,
      required this.syncStatus,
      required this.deviceId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.tipo,
      required this.nome,
      required this.carenciaDiasPadrao,
      required this.unidade,
      required this.estoqueMinimo});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['tipo'] = Variable<String>(tipo);
    map['nome'] = Variable<String>(nome);
    map['carencia_dias_padrao'] = Variable<int>(carenciaDiasPadrao);
    map['unidade'] = Variable<String>(unidade);
    map['estoque_minimo'] = Variable<double>(estoqueMinimo);
    return map;
  }

  ProdutosCompanion toCompanion(bool nullToAbsent) {
    return ProdutosCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      syncStatus: Value(syncStatus),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      tipo: Value(tipo),
      nome: Value(nome),
      carenciaDiasPadrao: Value(carenciaDiasPadrao),
      unidade: Value(unidade),
      estoqueMinimo: Value(estoqueMinimo),
    );
  }

  factory Produto.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Produto(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      tipo: serializer.fromJson<String>(json['tipo']),
      nome: serializer.fromJson<String>(json['nome']),
      carenciaDiasPadrao: serializer.fromJson<int>(json['carenciaDiasPadrao']),
      unidade: serializer.fromJson<String>(json['unidade']),
      estoqueMinimo: serializer.fromJson<double>(json['estoqueMinimo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'tipo': serializer.toJson<String>(tipo),
      'nome': serializer.toJson<String>(nome),
      'carenciaDiasPadrao': serializer.toJson<int>(carenciaDiasPadrao),
      'unidade': serializer.toJson<String>(unidade),
      'estoqueMinimo': serializer.toJson<double>(estoqueMinimo),
    };
  }

  Produto copyWith(
          {String? id,
          Value<String?> serverId = const Value.absent(),
          String? syncStatus,
          String? deviceId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? tipo,
          String? nome,
          int? carenciaDiasPadrao,
          String? unidade,
          double? estoqueMinimo}) =>
      Produto(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        syncStatus: syncStatus ?? this.syncStatus,
        deviceId: deviceId ?? this.deviceId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        tipo: tipo ?? this.tipo,
        nome: nome ?? this.nome,
        carenciaDiasPadrao: carenciaDiasPadrao ?? this.carenciaDiasPadrao,
        unidade: unidade ?? this.unidade,
        estoqueMinimo: estoqueMinimo ?? this.estoqueMinimo,
      );
  Produto copyWithCompanion(ProdutosCompanion data) {
    return Produto(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      nome: data.nome.present ? data.nome.value : this.nome,
      carenciaDiasPadrao: data.carenciaDiasPadrao.present
          ? data.carenciaDiasPadrao.value
          : this.carenciaDiasPadrao,
      unidade: data.unidade.present ? data.unidade.value : this.unidade,
      estoqueMinimo: data.estoqueMinimo.present
          ? data.estoqueMinimo.value
          : this.estoqueMinimo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Produto(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('tipo: $tipo, ')
          ..write('nome: $nome, ')
          ..write('carenciaDiasPadrao: $carenciaDiasPadrao, ')
          ..write('unidade: $unidade, ')
          ..write('estoqueMinimo: $estoqueMinimo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      syncStatus,
      deviceId,
      createdAt,
      updatedAt,
      deletedAt,
      tipo,
      nome,
      carenciaDiasPadrao,
      unidade,
      estoqueMinimo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Produto &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.syncStatus == this.syncStatus &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.tipo == this.tipo &&
          other.nome == this.nome &&
          other.carenciaDiasPadrao == this.carenciaDiasPadrao &&
          other.unidade == this.unidade &&
          other.estoqueMinimo == this.estoqueMinimo);
}

class ProdutosCompanion extends UpdateCompanion<Produto> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> syncStatus;
  final Value<String> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> tipo;
  final Value<String> nome;
  final Value<int> carenciaDiasPadrao;
  final Value<String> unidade;
  final Value<double> estoqueMinimo;
  final Value<int> rowid;
  const ProdutosCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.tipo = const Value.absent(),
    this.nome = const Value.absent(),
    this.carenciaDiasPadrao = const Value.absent(),
    this.unidade = const Value.absent(),
    this.estoqueMinimo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProdutosCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String deviceId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String tipo,
    required String nome,
    this.carenciaDiasPadrao = const Value.absent(),
    required String unidade,
    this.estoqueMinimo = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deviceId = Value(deviceId),
        tipo = Value(tipo),
        nome = Value(nome),
        unidade = Value(unidade);
  static Insertable<Produto> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? syncStatus,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? tipo,
    Expression<String>? nome,
    Expression<int>? carenciaDiasPadrao,
    Expression<String>? unidade,
    Expression<double>? estoqueMinimo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (tipo != null) 'tipo': tipo,
      if (nome != null) 'nome': nome,
      if (carenciaDiasPadrao != null)
        'carencia_dias_padrao': carenciaDiasPadrao,
      if (unidade != null) 'unidade': unidade,
      if (estoqueMinimo != null) 'estoque_minimo': estoqueMinimo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProdutosCompanion copyWith(
      {Value<String>? id,
      Value<String?>? serverId,
      Value<String>? syncStatus,
      Value<String>? deviceId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? tipo,
      Value<String>? nome,
      Value<int>? carenciaDiasPadrao,
      Value<String>? unidade,
      Value<double>? estoqueMinimo,
      Value<int>? rowid}) {
    return ProdutosCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      syncStatus: syncStatus ?? this.syncStatus,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      tipo: tipo ?? this.tipo,
      nome: nome ?? this.nome,
      carenciaDiasPadrao: carenciaDiasPadrao ?? this.carenciaDiasPadrao,
      unidade: unidade ?? this.unidade,
      estoqueMinimo: estoqueMinimo ?? this.estoqueMinimo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (carenciaDiasPadrao.present) {
      map['carencia_dias_padrao'] = Variable<int>(carenciaDiasPadrao.value);
    }
    if (unidade.present) {
      map['unidade'] = Variable<String>(unidade.value);
    }
    if (estoqueMinimo.present) {
      map['estoque_minimo'] = Variable<double>(estoqueMinimo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProdutosCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('tipo: $tipo, ')
          ..write('nome: $nome, ')
          ..write('carenciaDiasPadrao: $carenciaDiasPadrao, ')
          ..write('unidade: $unidade, ')
          ..write('estoqueMinimo: $estoqueMinimo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EstoqueMovimentosTable extends EstoqueMovimentos
    with TableInfo<$EstoqueMovimentosTable, EstoqueMovimento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EstoqueMovimentosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _produtoIdMeta =
      const VerificationMeta('produtoId');
  @override
  late final GeneratedColumn<String> produtoId = GeneratedColumn<String>(
      'produto_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
      'tipo', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 10),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _quantidadeMeta =
      const VerificationMeta('quantidade');
  @override
  late final GeneratedColumn<double> quantidade = GeneratedColumn<double>(
      'quantidade', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dataMovimentoMeta =
      const VerificationMeta('dataMovimento');
  @override
  late final GeneratedColumn<DateTime> dataMovimento =
      GeneratedColumn<DateTime>('data_movimento', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _dataValidadeMeta =
      const VerificationMeta('dataValidade');
  @override
  late final GeneratedColumn<DateTime> dataValidade = GeneratedColumn<DateTime>(
      'data_validade', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _origemMeta = const VerificationMeta('origem');
  @override
  late final GeneratedColumn<String> origem = GeneratedColumn<String>(
      'origem', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        syncStatus,
        deviceId,
        createdAt,
        updatedAt,
        deletedAt,
        produtoId,
        tipo,
        quantidade,
        dataMovimento,
        dataValidade,
        origem
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'estoque_movimentos';
  @override
  VerificationContext validateIntegrity(Insertable<EstoqueMovimento> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('produto_id')) {
      context.handle(_produtoIdMeta,
          produtoId.isAcceptableOrUnknown(data['produto_id']!, _produtoIdMeta));
    } else if (isInserting) {
      context.missing(_produtoIdMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
          _tipoMeta, tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta));
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('quantidade')) {
      context.handle(
          _quantidadeMeta,
          quantidade.isAcceptableOrUnknown(
              data['quantidade']!, _quantidadeMeta));
    } else if (isInserting) {
      context.missing(_quantidadeMeta);
    }
    if (data.containsKey('data_movimento')) {
      context.handle(
          _dataMovimentoMeta,
          dataMovimento.isAcceptableOrUnknown(
              data['data_movimento']!, _dataMovimentoMeta));
    }
    if (data.containsKey('data_validade')) {
      context.handle(
          _dataValidadeMeta,
          dataValidade.isAcceptableOrUnknown(
              data['data_validade']!, _dataValidadeMeta));
    }
    if (data.containsKey('origem')) {
      context.handle(_origemMeta,
          origem.isAcceptableOrUnknown(data['origem']!, _origemMeta));
    } else if (isInserting) {
      context.missing(_origemMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EstoqueMovimento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EstoqueMovimento(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      produtoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}produto_id'])!,
      tipo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo'])!,
      quantidade: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantidade'])!,
      dataMovimento: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}data_movimento'])!,
      dataValidade: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}data_validade']),
      origem: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}origem'])!,
    );
  }

  @override
  $EstoqueMovimentosTable createAlias(String alias) {
    return $EstoqueMovimentosTable(attachedDatabase, alias);
  }
}

class EstoqueMovimento extends DataClass
    implements Insertable<EstoqueMovimento> {
  /// Identificador único universal (UUID V4) gerado localmente.
  /// Funciona como chave de idempotência e identificador principal.
  final String id;

  /// Identificador gerado pelo servidor após a sincronização bem-sucedida.
  /// Fica nulo enquanto o registro existir apenas no dispositivo local.
  final String? serverId;

  /// Status atual da sincronização do registro:
  /// - `pending`: aguardando envio para o servidor
  /// - `synced`: sincronizado com sucesso
  /// - `conflict`: ocorreu um conflito de versão que precisa de resolução
  final String syncStatus;

  /// Identificador único do dispositivo que criou ou modificou este registro.
  /// Usado para auditoria e resolução de conflitos.
  final String deviceId;

  /// Data e hora da criação original do registro.
  final DateTime createdAt;

  /// Data e hora da última modificação do registro.
  final DateTime updatedAt;

  /// Data e hora da exclusão lógica (soft delete). Se preenchido, o registro
  /// é considerado apagado, mas é mantido no banco para sincronizar a exclusão.
  final DateTime? deletedAt;
  final String produtoId;
  final String tipo;
  final double quantidade;
  final DateTime dataMovimento;
  final DateTime? dataValidade;
  final String origem;
  const EstoqueMovimento(
      {required this.id,
      this.serverId,
      required this.syncStatus,
      required this.deviceId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.produtoId,
      required this.tipo,
      required this.quantidade,
      required this.dataMovimento,
      this.dataValidade,
      required this.origem});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['produto_id'] = Variable<String>(produtoId);
    map['tipo'] = Variable<String>(tipo);
    map['quantidade'] = Variable<double>(quantidade);
    map['data_movimento'] = Variable<DateTime>(dataMovimento);
    if (!nullToAbsent || dataValidade != null) {
      map['data_validade'] = Variable<DateTime>(dataValidade);
    }
    map['origem'] = Variable<String>(origem);
    return map;
  }

  EstoqueMovimentosCompanion toCompanion(bool nullToAbsent) {
    return EstoqueMovimentosCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      syncStatus: Value(syncStatus),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      produtoId: Value(produtoId),
      tipo: Value(tipo),
      quantidade: Value(quantidade),
      dataMovimento: Value(dataMovimento),
      dataValidade: dataValidade == null && nullToAbsent
          ? const Value.absent()
          : Value(dataValidade),
      origem: Value(origem),
    );
  }

  factory EstoqueMovimento.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EstoqueMovimento(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      produtoId: serializer.fromJson<String>(json['produtoId']),
      tipo: serializer.fromJson<String>(json['tipo']),
      quantidade: serializer.fromJson<double>(json['quantidade']),
      dataMovimento: serializer.fromJson<DateTime>(json['dataMovimento']),
      dataValidade: serializer.fromJson<DateTime?>(json['dataValidade']),
      origem: serializer.fromJson<String>(json['origem']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'produtoId': serializer.toJson<String>(produtoId),
      'tipo': serializer.toJson<String>(tipo),
      'quantidade': serializer.toJson<double>(quantidade),
      'dataMovimento': serializer.toJson<DateTime>(dataMovimento),
      'dataValidade': serializer.toJson<DateTime?>(dataValidade),
      'origem': serializer.toJson<String>(origem),
    };
  }

  EstoqueMovimento copyWith(
          {String? id,
          Value<String?> serverId = const Value.absent(),
          String? syncStatus,
          String? deviceId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? produtoId,
          String? tipo,
          double? quantidade,
          DateTime? dataMovimento,
          Value<DateTime?> dataValidade = const Value.absent(),
          String? origem}) =>
      EstoqueMovimento(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        syncStatus: syncStatus ?? this.syncStatus,
        deviceId: deviceId ?? this.deviceId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        produtoId: produtoId ?? this.produtoId,
        tipo: tipo ?? this.tipo,
        quantidade: quantidade ?? this.quantidade,
        dataMovimento: dataMovimento ?? this.dataMovimento,
        dataValidade:
            dataValidade.present ? dataValidade.value : this.dataValidade,
        origem: origem ?? this.origem,
      );
  EstoqueMovimento copyWithCompanion(EstoqueMovimentosCompanion data) {
    return EstoqueMovimento(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      produtoId: data.produtoId.present ? data.produtoId.value : this.produtoId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      quantidade:
          data.quantidade.present ? data.quantidade.value : this.quantidade,
      dataMovimento: data.dataMovimento.present
          ? data.dataMovimento.value
          : this.dataMovimento,
      dataValidade: data.dataValidade.present
          ? data.dataValidade.value
          : this.dataValidade,
      origem: data.origem.present ? data.origem.value : this.origem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EstoqueMovimento(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('produtoId: $produtoId, ')
          ..write('tipo: $tipo, ')
          ..write('quantidade: $quantidade, ')
          ..write('dataMovimento: $dataMovimento, ')
          ..write('dataValidade: $dataValidade, ')
          ..write('origem: $origem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      syncStatus,
      deviceId,
      createdAt,
      updatedAt,
      deletedAt,
      produtoId,
      tipo,
      quantidade,
      dataMovimento,
      dataValidade,
      origem);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EstoqueMovimento &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.syncStatus == this.syncStatus &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.produtoId == this.produtoId &&
          other.tipo == this.tipo &&
          other.quantidade == this.quantidade &&
          other.dataMovimento == this.dataMovimento &&
          other.dataValidade == this.dataValidade &&
          other.origem == this.origem);
}

class EstoqueMovimentosCompanion extends UpdateCompanion<EstoqueMovimento> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> syncStatus;
  final Value<String> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> produtoId;
  final Value<String> tipo;
  final Value<double> quantidade;
  final Value<DateTime> dataMovimento;
  final Value<DateTime?> dataValidade;
  final Value<String> origem;
  final Value<int> rowid;
  const EstoqueMovimentosCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.produtoId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.quantidade = const Value.absent(),
    this.dataMovimento = const Value.absent(),
    this.dataValidade = const Value.absent(),
    this.origem = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EstoqueMovimentosCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String deviceId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String produtoId,
    required String tipo,
    required double quantidade,
    this.dataMovimento = const Value.absent(),
    this.dataValidade = const Value.absent(),
    required String origem,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deviceId = Value(deviceId),
        produtoId = Value(produtoId),
        tipo = Value(tipo),
        quantidade = Value(quantidade),
        origem = Value(origem);
  static Insertable<EstoqueMovimento> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? syncStatus,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? produtoId,
    Expression<String>? tipo,
    Expression<double>? quantidade,
    Expression<DateTime>? dataMovimento,
    Expression<DateTime>? dataValidade,
    Expression<String>? origem,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (produtoId != null) 'produto_id': produtoId,
      if (tipo != null) 'tipo': tipo,
      if (quantidade != null) 'quantidade': quantidade,
      if (dataMovimento != null) 'data_movimento': dataMovimento,
      if (dataValidade != null) 'data_validade': dataValidade,
      if (origem != null) 'origem': origem,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EstoqueMovimentosCompanion copyWith(
      {Value<String>? id,
      Value<String?>? serverId,
      Value<String>? syncStatus,
      Value<String>? deviceId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? produtoId,
      Value<String>? tipo,
      Value<double>? quantidade,
      Value<DateTime>? dataMovimento,
      Value<DateTime?>? dataValidade,
      Value<String>? origem,
      Value<int>? rowid}) {
    return EstoqueMovimentosCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      syncStatus: syncStatus ?? this.syncStatus,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      produtoId: produtoId ?? this.produtoId,
      tipo: tipo ?? this.tipo,
      quantidade: quantidade ?? this.quantidade,
      dataMovimento: dataMovimento ?? this.dataMovimento,
      dataValidade: dataValidade ?? this.dataValidade,
      origem: origem ?? this.origem,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (produtoId.present) {
      map['produto_id'] = Variable<String>(produtoId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (quantidade.present) {
      map['quantidade'] = Variable<double>(quantidade.value);
    }
    if (dataMovimento.present) {
      map['data_movimento'] = Variable<DateTime>(dataMovimento.value);
    }
    if (dataValidade.present) {
      map['data_validade'] = Variable<DateTime>(dataValidade.value);
    }
    if (origem.present) {
      map['origem'] = Variable<String>(origem.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EstoqueMovimentosCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('produtoId: $produtoId, ')
          ..write('tipo: $tipo, ')
          ..write('quantidade: $quantidade, ')
          ..write('dataMovimento: $dataMovimento, ')
          ..write('dataValidade: $dataValidade, ')
          ..write('origem: $origem, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AplicacoesSanitariasTable extends AplicacoesSanitarias
    with TableInfo<$AplicacoesSanitariasTable, AplicacaoSanitaria> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AplicacoesSanitariasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _animalIdMeta =
      const VerificationMeta('animalId');
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
      'animal_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _loteIdMeta = const VerificationMeta('loteId');
  @override
  late final GeneratedColumn<String> loteId = GeneratedColumn<String>(
      'lote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _produtoIdMeta =
      const VerificationMeta('produtoId');
  @override
  late final GeneratedColumn<String> produtoId = GeneratedColumn<String>(
      'produto_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _doseMeta = const VerificationMeta('dose');
  @override
  late final GeneratedColumn<double> dose = GeneratedColumn<double>(
      'dose', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _viaMeta = const VerificationMeta('via');
  @override
  late final GeneratedColumn<String> via = GeneratedColumn<String>(
      'via', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _motivoMeta = const VerificationMeta('motivo');
  @override
  late final GeneratedColumn<String> motivo = GeneratedColumn<String>(
      'motivo', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _dataAplicacaoMeta =
      const VerificationMeta('dataAplicacao');
  @override
  late final GeneratedColumn<DateTime> dataAplicacao =
      GeneratedColumn<DateTime>('data_aplicacao', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _carenciaFimCalculadaMeta =
      const VerificationMeta('carenciaFimCalculada');
  @override
  late final GeneratedColumn<DateTime> carenciaFimCalculada =
      GeneratedColumn<DateTime>('carencia_fim_calculada', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _fotoPathMeta =
      const VerificationMeta('fotoPath');
  @override
  late final GeneratedColumn<String> fotoPath = GeneratedColumn<String>(
      'foto_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        syncStatus,
        deviceId,
        createdAt,
        updatedAt,
        deletedAt,
        animalId,
        loteId,
        produtoId,
        dose,
        via,
        motivo,
        dataAplicacao,
        carenciaFimCalculada,
        fotoPath
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'aplicacoes_sanitarias';
  @override
  VerificationContext validateIntegrity(Insertable<AplicacaoSanitaria> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('animal_id')) {
      context.handle(_animalIdMeta,
          animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta));
    }
    if (data.containsKey('lote_id')) {
      context.handle(_loteIdMeta,
          loteId.isAcceptableOrUnknown(data['lote_id']!, _loteIdMeta));
    }
    if (data.containsKey('produto_id')) {
      context.handle(_produtoIdMeta,
          produtoId.isAcceptableOrUnknown(data['produto_id']!, _produtoIdMeta));
    } else if (isInserting) {
      context.missing(_produtoIdMeta);
    }
    if (data.containsKey('dose')) {
      context.handle(
          _doseMeta, dose.isAcceptableOrUnknown(data['dose']!, _doseMeta));
    } else if (isInserting) {
      context.missing(_doseMeta);
    }
    if (data.containsKey('via')) {
      context.handle(
          _viaMeta, via.isAcceptableOrUnknown(data['via']!, _viaMeta));
    } else if (isInserting) {
      context.missing(_viaMeta);
    }
    if (data.containsKey('motivo')) {
      context.handle(_motivoMeta,
          motivo.isAcceptableOrUnknown(data['motivo']!, _motivoMeta));
    } else if (isInserting) {
      context.missing(_motivoMeta);
    }
    if (data.containsKey('data_aplicacao')) {
      context.handle(
          _dataAplicacaoMeta,
          dataAplicacao.isAcceptableOrUnknown(
              data['data_aplicacao']!, _dataAplicacaoMeta));
    }
    if (data.containsKey('carencia_fim_calculada')) {
      context.handle(
          _carenciaFimCalculadaMeta,
          carenciaFimCalculada.isAcceptableOrUnknown(
              data['carencia_fim_calculada']!, _carenciaFimCalculadaMeta));
    }
    if (data.containsKey('foto_path')) {
      context.handle(_fotoPathMeta,
          fotoPath.isAcceptableOrUnknown(data['foto_path']!, _fotoPathMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AplicacaoSanitaria map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AplicacaoSanitaria(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id']),
      loteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lote_id']),
      produtoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}produto_id'])!,
      dose: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}dose'])!,
      via: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}via'])!,
      motivo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}motivo'])!,
      dataAplicacao: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}data_aplicacao'])!,
      carenciaFimCalculada: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}carencia_fim_calculada']),
      fotoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}foto_path']),
    );
  }

  @override
  $AplicacoesSanitariasTable createAlias(String alias) {
    return $AplicacoesSanitariasTable(attachedDatabase, alias);
  }
}

class AplicacaoSanitaria extends DataClass
    implements Insertable<AplicacaoSanitaria> {
  /// Identificador único universal (UUID V4) gerado localmente.
  /// Funciona como chave de idempotência e identificador principal.
  final String id;

  /// Identificador gerado pelo servidor após a sincronização bem-sucedida.
  /// Fica nulo enquanto o registro existir apenas no dispositivo local.
  final String? serverId;

  /// Status atual da sincronização do registro:
  /// - `pending`: aguardando envio para o servidor
  /// - `synced`: sincronizado com sucesso
  /// - `conflict`: ocorreu um conflito de versão que precisa de resolução
  final String syncStatus;

  /// Identificador único do dispositivo que criou ou modificou este registro.
  /// Usado para auditoria e resolução de conflitos.
  final String deviceId;

  /// Data e hora da criação original do registro.
  final DateTime createdAt;

  /// Data e hora da última modificação do registro.
  final DateTime updatedAt;

  /// Data e hora da exclusão lógica (soft delete). Se preenchido, o registro
  /// é considerado apagado, mas é mantido no banco para sincronizar a exclusão.
  final DateTime? deletedAt;
  final String? animalId;
  final String? loteId;
  final String produtoId;
  final double dose;
  final String via;
  final String motivo;
  final DateTime dataAplicacao;
  final DateTime? carenciaFimCalculada;
  final String? fotoPath;
  const AplicacaoSanitaria(
      {required this.id,
      this.serverId,
      required this.syncStatus,
      required this.deviceId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.animalId,
      this.loteId,
      required this.produtoId,
      required this.dose,
      required this.via,
      required this.motivo,
      required this.dataAplicacao,
      this.carenciaFimCalculada,
      this.fotoPath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || animalId != null) {
      map['animal_id'] = Variable<String>(animalId);
    }
    if (!nullToAbsent || loteId != null) {
      map['lote_id'] = Variable<String>(loteId);
    }
    map['produto_id'] = Variable<String>(produtoId);
    map['dose'] = Variable<double>(dose);
    map['via'] = Variable<String>(via);
    map['motivo'] = Variable<String>(motivo);
    map['data_aplicacao'] = Variable<DateTime>(dataAplicacao);
    if (!nullToAbsent || carenciaFimCalculada != null) {
      map['carencia_fim_calculada'] = Variable<DateTime>(carenciaFimCalculada);
    }
    if (!nullToAbsent || fotoPath != null) {
      map['foto_path'] = Variable<String>(fotoPath);
    }
    return map;
  }

  AplicacoesSanitariasCompanion toCompanion(bool nullToAbsent) {
    return AplicacoesSanitariasCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      syncStatus: Value(syncStatus),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      animalId: animalId == null && nullToAbsent
          ? const Value.absent()
          : Value(animalId),
      loteId:
          loteId == null && nullToAbsent ? const Value.absent() : Value(loteId),
      produtoId: Value(produtoId),
      dose: Value(dose),
      via: Value(via),
      motivo: Value(motivo),
      dataAplicacao: Value(dataAplicacao),
      carenciaFimCalculada: carenciaFimCalculada == null && nullToAbsent
          ? const Value.absent()
          : Value(carenciaFimCalculada),
      fotoPath: fotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoPath),
    );
  }

  factory AplicacaoSanitaria.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AplicacaoSanitaria(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      animalId: serializer.fromJson<String?>(json['animalId']),
      loteId: serializer.fromJson<String?>(json['loteId']),
      produtoId: serializer.fromJson<String>(json['produtoId']),
      dose: serializer.fromJson<double>(json['dose']),
      via: serializer.fromJson<String>(json['via']),
      motivo: serializer.fromJson<String>(json['motivo']),
      dataAplicacao: serializer.fromJson<DateTime>(json['dataAplicacao']),
      carenciaFimCalculada:
          serializer.fromJson<DateTime?>(json['carenciaFimCalculada']),
      fotoPath: serializer.fromJson<String?>(json['fotoPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'animalId': serializer.toJson<String?>(animalId),
      'loteId': serializer.toJson<String?>(loteId),
      'produtoId': serializer.toJson<String>(produtoId),
      'dose': serializer.toJson<double>(dose),
      'via': serializer.toJson<String>(via),
      'motivo': serializer.toJson<String>(motivo),
      'dataAplicacao': serializer.toJson<DateTime>(dataAplicacao),
      'carenciaFimCalculada':
          serializer.toJson<DateTime?>(carenciaFimCalculada),
      'fotoPath': serializer.toJson<String?>(fotoPath),
    };
  }

  AplicacaoSanitaria copyWith(
          {String? id,
          Value<String?> serverId = const Value.absent(),
          String? syncStatus,
          String? deviceId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> animalId = const Value.absent(),
          Value<String?> loteId = const Value.absent(),
          String? produtoId,
          double? dose,
          String? via,
          String? motivo,
          DateTime? dataAplicacao,
          Value<DateTime?> carenciaFimCalculada = const Value.absent(),
          Value<String?> fotoPath = const Value.absent()}) =>
      AplicacaoSanitaria(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        syncStatus: syncStatus ?? this.syncStatus,
        deviceId: deviceId ?? this.deviceId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        animalId: animalId.present ? animalId.value : this.animalId,
        loteId: loteId.present ? loteId.value : this.loteId,
        produtoId: produtoId ?? this.produtoId,
        dose: dose ?? this.dose,
        via: via ?? this.via,
        motivo: motivo ?? this.motivo,
        dataAplicacao: dataAplicacao ?? this.dataAplicacao,
        carenciaFimCalculada: carenciaFimCalculada.present
            ? carenciaFimCalculada.value
            : this.carenciaFimCalculada,
        fotoPath: fotoPath.present ? fotoPath.value : this.fotoPath,
      );
  AplicacaoSanitaria copyWithCompanion(AplicacoesSanitariasCompanion data) {
    return AplicacaoSanitaria(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      loteId: data.loteId.present ? data.loteId.value : this.loteId,
      produtoId: data.produtoId.present ? data.produtoId.value : this.produtoId,
      dose: data.dose.present ? data.dose.value : this.dose,
      via: data.via.present ? data.via.value : this.via,
      motivo: data.motivo.present ? data.motivo.value : this.motivo,
      dataAplicacao: data.dataAplicacao.present
          ? data.dataAplicacao.value
          : this.dataAplicacao,
      carenciaFimCalculada: data.carenciaFimCalculada.present
          ? data.carenciaFimCalculada.value
          : this.carenciaFimCalculada,
      fotoPath: data.fotoPath.present ? data.fotoPath.value : this.fotoPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AplicacaoSanitaria(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('animalId: $animalId, ')
          ..write('loteId: $loteId, ')
          ..write('produtoId: $produtoId, ')
          ..write('dose: $dose, ')
          ..write('via: $via, ')
          ..write('motivo: $motivo, ')
          ..write('dataAplicacao: $dataAplicacao, ')
          ..write('carenciaFimCalculada: $carenciaFimCalculada, ')
          ..write('fotoPath: $fotoPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      syncStatus,
      deviceId,
      createdAt,
      updatedAt,
      deletedAt,
      animalId,
      loteId,
      produtoId,
      dose,
      via,
      motivo,
      dataAplicacao,
      carenciaFimCalculada,
      fotoPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AplicacaoSanitaria &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.syncStatus == this.syncStatus &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.animalId == this.animalId &&
          other.loteId == this.loteId &&
          other.produtoId == this.produtoId &&
          other.dose == this.dose &&
          other.via == this.via &&
          other.motivo == this.motivo &&
          other.dataAplicacao == this.dataAplicacao &&
          other.carenciaFimCalculada == this.carenciaFimCalculada &&
          other.fotoPath == this.fotoPath);
}

class AplicacoesSanitariasCompanion
    extends UpdateCompanion<AplicacaoSanitaria> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> syncStatus;
  final Value<String> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> animalId;
  final Value<String?> loteId;
  final Value<String> produtoId;
  final Value<double> dose;
  final Value<String> via;
  final Value<String> motivo;
  final Value<DateTime> dataAplicacao;
  final Value<DateTime?> carenciaFimCalculada;
  final Value<String?> fotoPath;
  final Value<int> rowid;
  const AplicacoesSanitariasCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.animalId = const Value.absent(),
    this.loteId = const Value.absent(),
    this.produtoId = const Value.absent(),
    this.dose = const Value.absent(),
    this.via = const Value.absent(),
    this.motivo = const Value.absent(),
    this.dataAplicacao = const Value.absent(),
    this.carenciaFimCalculada = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AplicacoesSanitariasCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String deviceId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.animalId = const Value.absent(),
    this.loteId = const Value.absent(),
    required String produtoId,
    required double dose,
    required String via,
    required String motivo,
    this.dataAplicacao = const Value.absent(),
    this.carenciaFimCalculada = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deviceId = Value(deviceId),
        produtoId = Value(produtoId),
        dose = Value(dose),
        via = Value(via),
        motivo = Value(motivo);
  static Insertable<AplicacaoSanitaria> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? syncStatus,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? animalId,
    Expression<String>? loteId,
    Expression<String>? produtoId,
    Expression<double>? dose,
    Expression<String>? via,
    Expression<String>? motivo,
    Expression<DateTime>? dataAplicacao,
    Expression<DateTime>? carenciaFimCalculada,
    Expression<String>? fotoPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (animalId != null) 'animal_id': animalId,
      if (loteId != null) 'lote_id': loteId,
      if (produtoId != null) 'produto_id': produtoId,
      if (dose != null) 'dose': dose,
      if (via != null) 'via': via,
      if (motivo != null) 'motivo': motivo,
      if (dataAplicacao != null) 'data_aplicacao': dataAplicacao,
      if (carenciaFimCalculada != null)
        'carencia_fim_calculada': carenciaFimCalculada,
      if (fotoPath != null) 'foto_path': fotoPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AplicacoesSanitariasCompanion copyWith(
      {Value<String>? id,
      Value<String?>? serverId,
      Value<String>? syncStatus,
      Value<String>? deviceId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? animalId,
      Value<String?>? loteId,
      Value<String>? produtoId,
      Value<double>? dose,
      Value<String>? via,
      Value<String>? motivo,
      Value<DateTime>? dataAplicacao,
      Value<DateTime?>? carenciaFimCalculada,
      Value<String?>? fotoPath,
      Value<int>? rowid}) {
    return AplicacoesSanitariasCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      syncStatus: syncStatus ?? this.syncStatus,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      animalId: animalId ?? this.animalId,
      loteId: loteId ?? this.loteId,
      produtoId: produtoId ?? this.produtoId,
      dose: dose ?? this.dose,
      via: via ?? this.via,
      motivo: motivo ?? this.motivo,
      dataAplicacao: dataAplicacao ?? this.dataAplicacao,
      carenciaFimCalculada: carenciaFimCalculada ?? this.carenciaFimCalculada,
      fotoPath: fotoPath ?? this.fotoPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (loteId.present) {
      map['lote_id'] = Variable<String>(loteId.value);
    }
    if (produtoId.present) {
      map['produto_id'] = Variable<String>(produtoId.value);
    }
    if (dose.present) {
      map['dose'] = Variable<double>(dose.value);
    }
    if (via.present) {
      map['via'] = Variable<String>(via.value);
    }
    if (motivo.present) {
      map['motivo'] = Variable<String>(motivo.value);
    }
    if (dataAplicacao.present) {
      map['data_aplicacao'] = Variable<DateTime>(dataAplicacao.value);
    }
    if (carenciaFimCalculada.present) {
      map['carencia_fim_calculada'] =
          Variable<DateTime>(carenciaFimCalculada.value);
    }
    if (fotoPath.present) {
      map['foto_path'] = Variable<String>(fotoPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AplicacoesSanitariasCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('animalId: $animalId, ')
          ..write('loteId: $loteId, ')
          ..write('produtoId: $produtoId, ')
          ..write('dose: $dose, ')
          ..write('via: $via, ')
          ..write('motivo: $motivo, ')
          ..write('dataAplicacao: $dataAplicacao, ')
          ..write('carenciaFimCalculada: $carenciaFimCalculada, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OcorrenciasSanitariasTable extends OcorrenciasSanitarias
    with TableInfo<$OcorrenciasSanitariasTable, OcorrenciaSanitaria> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OcorrenciasSanitariasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _animalIdMeta =
      const VerificationMeta('animalId');
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
      'animal_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
      'tipo', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descricaoMeta =
      const VerificationMeta('descricao');
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
      'descricao', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataOcorrenciaMeta =
      const VerificationMeta('dataOcorrencia');
  @override
  late final GeneratedColumn<DateTime> dataOcorrencia =
      GeneratedColumn<DateTime>('data_ocorrencia', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _fotoPathMeta =
      const VerificationMeta('fotoPath');
  @override
  late final GeneratedColumn<String> fotoPath = GeneratedColumn<String>(
      'foto_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        syncStatus,
        deviceId,
        createdAt,
        updatedAt,
        deletedAt,
        animalId,
        tipo,
        descricao,
        dataOcorrencia,
        fotoPath
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ocorrencias_sanitarias';
  @override
  VerificationContext validateIntegrity(
      Insertable<OcorrenciaSanitaria> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('animal_id')) {
      context.handle(_animalIdMeta,
          animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta));
    } else if (isInserting) {
      context.missing(_animalIdMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
          _tipoMeta, tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta));
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('descricao')) {
      context.handle(_descricaoMeta,
          descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta));
    } else if (isInserting) {
      context.missing(_descricaoMeta);
    }
    if (data.containsKey('data_ocorrencia')) {
      context.handle(
          _dataOcorrenciaMeta,
          dataOcorrencia.isAcceptableOrUnknown(
              data['data_ocorrencia']!, _dataOcorrenciaMeta));
    }
    if (data.containsKey('foto_path')) {
      context.handle(_fotoPathMeta,
          fotoPath.isAcceptableOrUnknown(data['foto_path']!, _fotoPathMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OcorrenciaSanitaria map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OcorrenciaSanitaria(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id'])!,
      tipo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo'])!,
      descricao: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descricao'])!,
      dataOcorrencia: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}data_ocorrencia'])!,
      fotoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}foto_path']),
    );
  }

  @override
  $OcorrenciasSanitariasTable createAlias(String alias) {
    return $OcorrenciasSanitariasTable(attachedDatabase, alias);
  }
}

class OcorrenciaSanitaria extends DataClass
    implements Insertable<OcorrenciaSanitaria> {
  /// Identificador único universal (UUID V4) gerado localmente.
  /// Funciona como chave de idempotência e identificador principal.
  final String id;

  /// Identificador gerado pelo servidor após a sincronização bem-sucedida.
  /// Fica nulo enquanto o registro existir apenas no dispositivo local.
  final String? serverId;

  /// Status atual da sincronização do registro:
  /// - `pending`: aguardando envio para o servidor
  /// - `synced`: sincronizado com sucesso
  /// - `conflict`: ocorreu um conflito de versão que precisa de resolução
  final String syncStatus;

  /// Identificador único do dispositivo que criou ou modificou este registro.
  /// Usado para auditoria e resolução de conflitos.
  final String deviceId;

  /// Data e hora da criação original do registro.
  final DateTime createdAt;

  /// Data e hora da última modificação do registro.
  final DateTime updatedAt;

  /// Data e hora da exclusão lógica (soft delete). Se preenchido, o registro
  /// é considerado apagado, mas é mantido no banco para sincronizar a exclusão.
  final DateTime? deletedAt;
  final String animalId;
  final String tipo;
  final String descricao;
  final DateTime dataOcorrencia;
  final String? fotoPath;
  const OcorrenciaSanitaria(
      {required this.id,
      this.serverId,
      required this.syncStatus,
      required this.deviceId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.animalId,
      required this.tipo,
      required this.descricao,
      required this.dataOcorrencia,
      this.fotoPath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['animal_id'] = Variable<String>(animalId);
    map['tipo'] = Variable<String>(tipo);
    map['descricao'] = Variable<String>(descricao);
    map['data_ocorrencia'] = Variable<DateTime>(dataOcorrencia);
    if (!nullToAbsent || fotoPath != null) {
      map['foto_path'] = Variable<String>(fotoPath);
    }
    return map;
  }

  OcorrenciasSanitariasCompanion toCompanion(bool nullToAbsent) {
    return OcorrenciasSanitariasCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      syncStatus: Value(syncStatus),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      animalId: Value(animalId),
      tipo: Value(tipo),
      descricao: Value(descricao),
      dataOcorrencia: Value(dataOcorrencia),
      fotoPath: fotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoPath),
    );
  }

  factory OcorrenciaSanitaria.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OcorrenciaSanitaria(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      animalId: serializer.fromJson<String>(json['animalId']),
      tipo: serializer.fromJson<String>(json['tipo']),
      descricao: serializer.fromJson<String>(json['descricao']),
      dataOcorrencia: serializer.fromJson<DateTime>(json['dataOcorrencia']),
      fotoPath: serializer.fromJson<String?>(json['fotoPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'animalId': serializer.toJson<String>(animalId),
      'tipo': serializer.toJson<String>(tipo),
      'descricao': serializer.toJson<String>(descricao),
      'dataOcorrencia': serializer.toJson<DateTime>(dataOcorrencia),
      'fotoPath': serializer.toJson<String?>(fotoPath),
    };
  }

  OcorrenciaSanitaria copyWith(
          {String? id,
          Value<String?> serverId = const Value.absent(),
          String? syncStatus,
          String? deviceId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? animalId,
          String? tipo,
          String? descricao,
          DateTime? dataOcorrencia,
          Value<String?> fotoPath = const Value.absent()}) =>
      OcorrenciaSanitaria(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        syncStatus: syncStatus ?? this.syncStatus,
        deviceId: deviceId ?? this.deviceId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        animalId: animalId ?? this.animalId,
        tipo: tipo ?? this.tipo,
        descricao: descricao ?? this.descricao,
        dataOcorrencia: dataOcorrencia ?? this.dataOcorrencia,
        fotoPath: fotoPath.present ? fotoPath.value : this.fotoPath,
      );
  OcorrenciaSanitaria copyWithCompanion(OcorrenciasSanitariasCompanion data) {
    return OcorrenciaSanitaria(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      dataOcorrencia: data.dataOcorrencia.present
          ? data.dataOcorrencia.value
          : this.dataOcorrencia,
      fotoPath: data.fotoPath.present ? data.fotoPath.value : this.fotoPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OcorrenciaSanitaria(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('animalId: $animalId, ')
          ..write('tipo: $tipo, ')
          ..write('descricao: $descricao, ')
          ..write('dataOcorrencia: $dataOcorrencia, ')
          ..write('fotoPath: $fotoPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      syncStatus,
      deviceId,
      createdAt,
      updatedAt,
      deletedAt,
      animalId,
      tipo,
      descricao,
      dataOcorrencia,
      fotoPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OcorrenciaSanitaria &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.syncStatus == this.syncStatus &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.animalId == this.animalId &&
          other.tipo == this.tipo &&
          other.descricao == this.descricao &&
          other.dataOcorrencia == this.dataOcorrencia &&
          other.fotoPath == this.fotoPath);
}

class OcorrenciasSanitariasCompanion
    extends UpdateCompanion<OcorrenciaSanitaria> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> syncStatus;
  final Value<String> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> animalId;
  final Value<String> tipo;
  final Value<String> descricao;
  final Value<DateTime> dataOcorrencia;
  final Value<String?> fotoPath;
  final Value<int> rowid;
  const OcorrenciasSanitariasCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.animalId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.descricao = const Value.absent(),
    this.dataOcorrencia = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OcorrenciasSanitariasCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String deviceId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String animalId,
    required String tipo,
    required String descricao,
    this.dataOcorrencia = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deviceId = Value(deviceId),
        animalId = Value(animalId),
        tipo = Value(tipo),
        descricao = Value(descricao);
  static Insertable<OcorrenciaSanitaria> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? syncStatus,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? animalId,
    Expression<String>? tipo,
    Expression<String>? descricao,
    Expression<DateTime>? dataOcorrencia,
    Expression<String>? fotoPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (animalId != null) 'animal_id': animalId,
      if (tipo != null) 'tipo': tipo,
      if (descricao != null) 'descricao': descricao,
      if (dataOcorrencia != null) 'data_ocorrencia': dataOcorrencia,
      if (fotoPath != null) 'foto_path': fotoPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OcorrenciasSanitariasCompanion copyWith(
      {Value<String>? id,
      Value<String?>? serverId,
      Value<String>? syncStatus,
      Value<String>? deviceId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? animalId,
      Value<String>? tipo,
      Value<String>? descricao,
      Value<DateTime>? dataOcorrencia,
      Value<String?>? fotoPath,
      Value<int>? rowid}) {
    return OcorrenciasSanitariasCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      syncStatus: syncStatus ?? this.syncStatus,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      animalId: animalId ?? this.animalId,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      dataOcorrencia: dataOcorrencia ?? this.dataOcorrencia,
      fotoPath: fotoPath ?? this.fotoPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    if (dataOcorrencia.present) {
      map['data_ocorrencia'] = Variable<DateTime>(dataOcorrencia.value);
    }
    if (fotoPath.present) {
      map['foto_path'] = Variable<String>(fotoPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OcorrenciasSanitariasCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('animalId: $animalId, ')
          ..write('tipo: $tipo, ')
          ..write('descricao: $descricao, ')
          ..write('dataOcorrencia: $dataOcorrencia, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DietasTable extends Dietas with TableInfo<$DietasTable, Dieta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DietasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _loteIdMeta = const VerificationMeta('loteId');
  @override
  late final GeneratedColumn<String> loteId = GeneratedColumn<String>(
      'lote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoriaMeta =
      const VerificationMeta('categoria');
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
      'categoria', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _produtoIdMeta =
      const VerificationMeta('produtoId');
  @override
  late final GeneratedColumn<String> produtoId = GeneratedColumn<String>(
      'produto_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantidadePorCabecaDiaMeta =
      const VerificationMeta('quantidadePorCabecaDia');
  @override
  late final GeneratedColumn<double> quantidadePorCabecaDia =
      GeneratedColumn<double>('quantidade_por_cabeca_dia', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        syncStatus,
        deviceId,
        createdAt,
        updatedAt,
        deletedAt,
        loteId,
        categoria,
        produtoId,
        quantidadePorCabecaDia
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dietas';
  @override
  VerificationContext validateIntegrity(Insertable<Dieta> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('lote_id')) {
      context.handle(_loteIdMeta,
          loteId.isAcceptableOrUnknown(data['lote_id']!, _loteIdMeta));
    }
    if (data.containsKey('categoria')) {
      context.handle(_categoriaMeta,
          categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta));
    }
    if (data.containsKey('produto_id')) {
      context.handle(_produtoIdMeta,
          produtoId.isAcceptableOrUnknown(data['produto_id']!, _produtoIdMeta));
    } else if (isInserting) {
      context.missing(_produtoIdMeta);
    }
    if (data.containsKey('quantidade_por_cabeca_dia')) {
      context.handle(
          _quantidadePorCabecaDiaMeta,
          quantidadePorCabecaDia.isAcceptableOrUnknown(
              data['quantidade_por_cabeca_dia']!, _quantidadePorCabecaDiaMeta));
    } else if (isInserting) {
      context.missing(_quantidadePorCabecaDiaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Dieta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Dieta(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      loteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lote_id']),
      categoria: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categoria']),
      produtoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}produto_id'])!,
      quantidadePorCabecaDia: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}quantidade_por_cabeca_dia'])!,
    );
  }

  @override
  $DietasTable createAlias(String alias) {
    return $DietasTable(attachedDatabase, alias);
  }
}

class Dieta extends DataClass implements Insertable<Dieta> {
  /// Identificador único universal (UUID V4) gerado localmente.
  /// Funciona como chave de idempotência e identificador principal.
  final String id;

  /// Identificador gerado pelo servidor após a sincronização bem-sucedida.
  /// Fica nulo enquanto o registro existir apenas no dispositivo local.
  final String? serverId;

  /// Status atual da sincronização do registro:
  /// - `pending`: aguardando envio para o servidor
  /// - `synced`: sincronizado com sucesso
  /// - `conflict`: ocorreu um conflito de versão que precisa de resolução
  final String syncStatus;

  /// Identificador único do dispositivo que criou ou modificou este registro.
  /// Usado para auditoria e resolução de conflitos.
  final String deviceId;

  /// Data e hora da criação original do registro.
  final DateTime createdAt;

  /// Data e hora da última modificação do registro.
  final DateTime updatedAt;

  /// Data e hora da exclusão lógica (soft delete). Se preenchido, o registro
  /// é considerado apagado, mas é mantido no banco para sincronizar a exclusão.
  final DateTime? deletedAt;
  final String? loteId;
  final String? categoria;
  final String produtoId;
  final double quantidadePorCabecaDia;
  const Dieta(
      {required this.id,
      this.serverId,
      required this.syncStatus,
      required this.deviceId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.loteId,
      this.categoria,
      required this.produtoId,
      required this.quantidadePorCabecaDia});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || loteId != null) {
      map['lote_id'] = Variable<String>(loteId);
    }
    if (!nullToAbsent || categoria != null) {
      map['categoria'] = Variable<String>(categoria);
    }
    map['produto_id'] = Variable<String>(produtoId);
    map['quantidade_por_cabeca_dia'] = Variable<double>(quantidadePorCabecaDia);
    return map;
  }

  DietasCompanion toCompanion(bool nullToAbsent) {
    return DietasCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      syncStatus: Value(syncStatus),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      loteId:
          loteId == null && nullToAbsent ? const Value.absent() : Value(loteId),
      categoria: categoria == null && nullToAbsent
          ? const Value.absent()
          : Value(categoria),
      produtoId: Value(produtoId),
      quantidadePorCabecaDia: Value(quantidadePorCabecaDia),
    );
  }

  factory Dieta.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Dieta(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      loteId: serializer.fromJson<String?>(json['loteId']),
      categoria: serializer.fromJson<String?>(json['categoria']),
      produtoId: serializer.fromJson<String>(json['produtoId']),
      quantidadePorCabecaDia:
          serializer.fromJson<double>(json['quantidadePorCabecaDia']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'loteId': serializer.toJson<String?>(loteId),
      'categoria': serializer.toJson<String?>(categoria),
      'produtoId': serializer.toJson<String>(produtoId),
      'quantidadePorCabecaDia':
          serializer.toJson<double>(quantidadePorCabecaDia),
    };
  }

  Dieta copyWith(
          {String? id,
          Value<String?> serverId = const Value.absent(),
          String? syncStatus,
          String? deviceId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> loteId = const Value.absent(),
          Value<String?> categoria = const Value.absent(),
          String? produtoId,
          double? quantidadePorCabecaDia}) =>
      Dieta(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        syncStatus: syncStatus ?? this.syncStatus,
        deviceId: deviceId ?? this.deviceId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        loteId: loteId.present ? loteId.value : this.loteId,
        categoria: categoria.present ? categoria.value : this.categoria,
        produtoId: produtoId ?? this.produtoId,
        quantidadePorCabecaDia:
            quantidadePorCabecaDia ?? this.quantidadePorCabecaDia,
      );
  Dieta copyWithCompanion(DietasCompanion data) {
    return Dieta(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      loteId: data.loteId.present ? data.loteId.value : this.loteId,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      produtoId: data.produtoId.present ? data.produtoId.value : this.produtoId,
      quantidadePorCabecaDia: data.quantidadePorCabecaDia.present
          ? data.quantidadePorCabecaDia.value
          : this.quantidadePorCabecaDia,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Dieta(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('loteId: $loteId, ')
          ..write('categoria: $categoria, ')
          ..write('produtoId: $produtoId, ')
          ..write('quantidadePorCabecaDia: $quantidadePorCabecaDia')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      syncStatus,
      deviceId,
      createdAt,
      updatedAt,
      deletedAt,
      loteId,
      categoria,
      produtoId,
      quantidadePorCabecaDia);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Dieta &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.syncStatus == this.syncStatus &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.loteId == this.loteId &&
          other.categoria == this.categoria &&
          other.produtoId == this.produtoId &&
          other.quantidadePorCabecaDia == this.quantidadePorCabecaDia);
}

class DietasCompanion extends UpdateCompanion<Dieta> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> syncStatus;
  final Value<String> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> loteId;
  final Value<String?> categoria;
  final Value<String> produtoId;
  final Value<double> quantidadePorCabecaDia;
  final Value<int> rowid;
  const DietasCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.loteId = const Value.absent(),
    this.categoria = const Value.absent(),
    this.produtoId = const Value.absent(),
    this.quantidadePorCabecaDia = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DietasCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String deviceId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.loteId = const Value.absent(),
    this.categoria = const Value.absent(),
    required String produtoId,
    required double quantidadePorCabecaDia,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deviceId = Value(deviceId),
        produtoId = Value(produtoId),
        quantidadePorCabecaDia = Value(quantidadePorCabecaDia);
  static Insertable<Dieta> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? syncStatus,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? loteId,
    Expression<String>? categoria,
    Expression<String>? produtoId,
    Expression<double>? quantidadePorCabecaDia,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (loteId != null) 'lote_id': loteId,
      if (categoria != null) 'categoria': categoria,
      if (produtoId != null) 'produto_id': produtoId,
      if (quantidadePorCabecaDia != null)
        'quantidade_por_cabeca_dia': quantidadePorCabecaDia,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DietasCompanion copyWith(
      {Value<String>? id,
      Value<String?>? serverId,
      Value<String>? syncStatus,
      Value<String>? deviceId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? loteId,
      Value<String?>? categoria,
      Value<String>? produtoId,
      Value<double>? quantidadePorCabecaDia,
      Value<int>? rowid}) {
    return DietasCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      syncStatus: syncStatus ?? this.syncStatus,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      loteId: loteId ?? this.loteId,
      categoria: categoria ?? this.categoria,
      produtoId: produtoId ?? this.produtoId,
      quantidadePorCabecaDia:
          quantidadePorCabecaDia ?? this.quantidadePorCabecaDia,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (loteId.present) {
      map['lote_id'] = Variable<String>(loteId.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (produtoId.present) {
      map['produto_id'] = Variable<String>(produtoId.value);
    }
    if (quantidadePorCabecaDia.present) {
      map['quantidade_por_cabeca_dia'] =
          Variable<double>(quantidadePorCabecaDia.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DietasCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('loteId: $loteId, ')
          ..write('categoria: $categoria, ')
          ..write('produtoId: $produtoId, ')
          ..write('quantidadePorCabecaDia: $quantidadePorCabecaDia, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FornecimentosDietaTable extends FornecimentosDieta
    with TableInfo<$FornecimentosDietaTable, FornecimentoDieta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FornecimentosDietaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _loteIdMeta = const VerificationMeta('loteId');
  @override
  late final GeneratedColumn<String> loteId = GeneratedColumn<String>(
      'lote_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dietaIdMeta =
      const VerificationMeta('dietaId');
  @override
  late final GeneratedColumn<String> dietaId = GeneratedColumn<String>(
      'dieta_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataFornecimentoMeta =
      const VerificationMeta('dataFornecimento');
  @override
  late final GeneratedColumn<DateTime> dataFornecimento =
      GeneratedColumn<DateTime>('data_fornecimento', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _quantidadeFornecidaMeta =
      const VerificationMeta('quantidadeFornecida');
  @override
  late final GeneratedColumn<double> quantidadeFornecida =
      GeneratedColumn<double>('quantidade_fornecida', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        syncStatus,
        deviceId,
        createdAt,
        updatedAt,
        deletedAt,
        loteId,
        dietaId,
        dataFornecimento,
        quantidadeFornecida
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fornecimentos_dieta';
  @override
  VerificationContext validateIntegrity(Insertable<FornecimentoDieta> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('lote_id')) {
      context.handle(_loteIdMeta,
          loteId.isAcceptableOrUnknown(data['lote_id']!, _loteIdMeta));
    } else if (isInserting) {
      context.missing(_loteIdMeta);
    }
    if (data.containsKey('dieta_id')) {
      context.handle(_dietaIdMeta,
          dietaId.isAcceptableOrUnknown(data['dieta_id']!, _dietaIdMeta));
    } else if (isInserting) {
      context.missing(_dietaIdMeta);
    }
    if (data.containsKey('data_fornecimento')) {
      context.handle(
          _dataFornecimentoMeta,
          dataFornecimento.isAcceptableOrUnknown(
              data['data_fornecimento']!, _dataFornecimentoMeta));
    }
    if (data.containsKey('quantidade_fornecida')) {
      context.handle(
          _quantidadeFornecidaMeta,
          quantidadeFornecida.isAcceptableOrUnknown(
              data['quantidade_fornecida']!, _quantidadeFornecidaMeta));
    } else if (isInserting) {
      context.missing(_quantidadeFornecidaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FornecimentoDieta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FornecimentoDieta(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      loteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lote_id'])!,
      dietaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dieta_id'])!,
      dataFornecimento: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}data_fornecimento'])!,
      quantidadeFornecida: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}quantidade_fornecida'])!,
    );
  }

  @override
  $FornecimentosDietaTable createAlias(String alias) {
    return $FornecimentosDietaTable(attachedDatabase, alias);
  }
}

class FornecimentoDieta extends DataClass
    implements Insertable<FornecimentoDieta> {
  /// Identificador único universal (UUID V4) gerado localmente.
  /// Funciona como chave de idempotência e identificador principal.
  final String id;

  /// Identificador gerado pelo servidor após a sincronização bem-sucedida.
  /// Fica nulo enquanto o registro existir apenas no dispositivo local.
  final String? serverId;

  /// Status atual da sincronização do registro:
  /// - `pending`: aguardando envio para o servidor
  /// - `synced`: sincronizado com sucesso
  /// - `conflict`: ocorreu um conflito de versão que precisa de resolução
  final String syncStatus;

  /// Identificador único do dispositivo que criou ou modificou este registro.
  /// Usado para auditoria e resolução de conflitos.
  final String deviceId;

  /// Data e hora da criação original do registro.
  final DateTime createdAt;

  /// Data e hora da última modificação do registro.
  final DateTime updatedAt;

  /// Data e hora da exclusão lógica (soft delete). Se preenchido, o registro
  /// é considerado apagado, mas é mantido no banco para sincronizar a exclusão.
  final DateTime? deletedAt;
  final String loteId;
  final String dietaId;
  final DateTime dataFornecimento;
  final double quantidadeFornecida;
  const FornecimentoDieta(
      {required this.id,
      this.serverId,
      required this.syncStatus,
      required this.deviceId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.loteId,
      required this.dietaId,
      required this.dataFornecimento,
      required this.quantidadeFornecida});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['lote_id'] = Variable<String>(loteId);
    map['dieta_id'] = Variable<String>(dietaId);
    map['data_fornecimento'] = Variable<DateTime>(dataFornecimento);
    map['quantidade_fornecida'] = Variable<double>(quantidadeFornecida);
    return map;
  }

  FornecimentosDietaCompanion toCompanion(bool nullToAbsent) {
    return FornecimentosDietaCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      syncStatus: Value(syncStatus),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      loteId: Value(loteId),
      dietaId: Value(dietaId),
      dataFornecimento: Value(dataFornecimento),
      quantidadeFornecida: Value(quantidadeFornecida),
    );
  }

  factory FornecimentoDieta.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FornecimentoDieta(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      loteId: serializer.fromJson<String>(json['loteId']),
      dietaId: serializer.fromJson<String>(json['dietaId']),
      dataFornecimento: serializer.fromJson<DateTime>(json['dataFornecimento']),
      quantidadeFornecida:
          serializer.fromJson<double>(json['quantidadeFornecida']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'loteId': serializer.toJson<String>(loteId),
      'dietaId': serializer.toJson<String>(dietaId),
      'dataFornecimento': serializer.toJson<DateTime>(dataFornecimento),
      'quantidadeFornecida': serializer.toJson<double>(quantidadeFornecida),
    };
  }

  FornecimentoDieta copyWith(
          {String? id,
          Value<String?> serverId = const Value.absent(),
          String? syncStatus,
          String? deviceId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? loteId,
          String? dietaId,
          DateTime? dataFornecimento,
          double? quantidadeFornecida}) =>
      FornecimentoDieta(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        syncStatus: syncStatus ?? this.syncStatus,
        deviceId: deviceId ?? this.deviceId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        loteId: loteId ?? this.loteId,
        dietaId: dietaId ?? this.dietaId,
        dataFornecimento: dataFornecimento ?? this.dataFornecimento,
        quantidadeFornecida: quantidadeFornecida ?? this.quantidadeFornecida,
      );
  FornecimentoDieta copyWithCompanion(FornecimentosDietaCompanion data) {
    return FornecimentoDieta(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      loteId: data.loteId.present ? data.loteId.value : this.loteId,
      dietaId: data.dietaId.present ? data.dietaId.value : this.dietaId,
      dataFornecimento: data.dataFornecimento.present
          ? data.dataFornecimento.value
          : this.dataFornecimento,
      quantidadeFornecida: data.quantidadeFornecida.present
          ? data.quantidadeFornecida.value
          : this.quantidadeFornecida,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FornecimentoDieta(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('loteId: $loteId, ')
          ..write('dietaId: $dietaId, ')
          ..write('dataFornecimento: $dataFornecimento, ')
          ..write('quantidadeFornecida: $quantidadeFornecida')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      syncStatus,
      deviceId,
      createdAt,
      updatedAt,
      deletedAt,
      loteId,
      dietaId,
      dataFornecimento,
      quantidadeFornecida);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FornecimentoDieta &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.syncStatus == this.syncStatus &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.loteId == this.loteId &&
          other.dietaId == this.dietaId &&
          other.dataFornecimento == this.dataFornecimento &&
          other.quantidadeFornecida == this.quantidadeFornecida);
}

class FornecimentosDietaCompanion extends UpdateCompanion<FornecimentoDieta> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> syncStatus;
  final Value<String> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> loteId;
  final Value<String> dietaId;
  final Value<DateTime> dataFornecimento;
  final Value<double> quantidadeFornecida;
  final Value<int> rowid;
  const FornecimentosDietaCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.loteId = const Value.absent(),
    this.dietaId = const Value.absent(),
    this.dataFornecimento = const Value.absent(),
    this.quantidadeFornecida = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FornecimentosDietaCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String deviceId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String loteId,
    required String dietaId,
    this.dataFornecimento = const Value.absent(),
    required double quantidadeFornecida,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deviceId = Value(deviceId),
        loteId = Value(loteId),
        dietaId = Value(dietaId),
        quantidadeFornecida = Value(quantidadeFornecida);
  static Insertable<FornecimentoDieta> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? syncStatus,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? loteId,
    Expression<String>? dietaId,
    Expression<DateTime>? dataFornecimento,
    Expression<double>? quantidadeFornecida,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (loteId != null) 'lote_id': loteId,
      if (dietaId != null) 'dieta_id': dietaId,
      if (dataFornecimento != null) 'data_fornecimento': dataFornecimento,
      if (quantidadeFornecida != null)
        'quantidade_fornecida': quantidadeFornecida,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FornecimentosDietaCompanion copyWith(
      {Value<String>? id,
      Value<String?>? serverId,
      Value<String>? syncStatus,
      Value<String>? deviceId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? loteId,
      Value<String>? dietaId,
      Value<DateTime>? dataFornecimento,
      Value<double>? quantidadeFornecida,
      Value<int>? rowid}) {
    return FornecimentosDietaCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      syncStatus: syncStatus ?? this.syncStatus,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      loteId: loteId ?? this.loteId,
      dietaId: dietaId ?? this.dietaId,
      dataFornecimento: dataFornecimento ?? this.dataFornecimento,
      quantidadeFornecida: quantidadeFornecida ?? this.quantidadeFornecida,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (loteId.present) {
      map['lote_id'] = Variable<String>(loteId.value);
    }
    if (dietaId.present) {
      map['dieta_id'] = Variable<String>(dietaId.value);
    }
    if (dataFornecimento.present) {
      map['data_fornecimento'] = Variable<DateTime>(dataFornecimento.value);
    }
    if (quantidadeFornecida.present) {
      map['quantidade_fornecida'] = Variable<double>(quantidadeFornecida.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FornecimentosDietaCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('loteId: $loteId, ')
          ..write('dietaId: $dietaId, ')
          ..write('dataFornecimento: $dataFornecimento, ')
          ..write('quantidadeFornecida: $quantidadeFornecida, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueItemsTable extends SyncQueueItems
    with TableInfo<$SyncQueueItemsTable, SyncQueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityType,
        entityId,
        action,
        payload,
        status,
        createdAt,
        retryCount,
        lastError,
        deviceId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue_items';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
    );
  }

  @override
  $SyncQueueItemsTable createAlias(String alias) {
    return $SyncQueueItemsTable(attachedDatabase, alias);
  }
}

class SyncQueueItem extends DataClass implements Insertable<SyncQueueItem> {
  /// ID interno incremental para ordenação rigorosa da fila.
  final int id;

  /// Nome da tabela/entidade alvo da mutação (Ex: 'animais', 'produtos', 'aplicacoes_sanitarias').
  final String entityType;

  /// O identificador único universal (UUID local) da entidade alterada.
  final String entityId;

  /// Ação realizada localmente que deve ser refletida no servidor ('create', 'update', 'delete').
  final String action;

  /// Snapshot em JSON do estado da entidade no exato momento da ação.
  final String payload;

  /// Estado atual do processamento deste item da fila:
  /// - `pending`: pronto para ser enviado.
  /// - `processing`: em trânsito/sendo processado pelo serviço.
  /// - `failed`: erro no envio, aguardando nova tentativa.
  final String status;

  /// Timestamp exato da mutação, usado para garantir a ordem cronológica de sincronização.
  final DateTime createdAt;

  /// Contador de tentativas de reenvio em caso de falha de comunicação ou erro 500 do servidor.
  final int retryCount;

  /// Mensagem técnica de erro registrada na última tentativa falha de sincronização.
  final String? lastError;

  /// ID único do dispositivo onde a mutação ocorreu, vital para auditoria e log.
  final String deviceId;
  const SyncQueueItem(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.action,
      required this.payload,
      required this.status,
      required this.createdAt,
      required this.retryCount,
      this.lastError,
      required this.deviceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['device_id'] = Variable<String>(deviceId);
    return map;
  }

  SyncQueueItemsCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueItemsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      payload: Value(payload),
      status: Value(status),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      deviceId: Value(deviceId),
    );
  }

  factory SyncQueueItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueItem(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'deviceId': serializer.toJson<String>(deviceId),
    };
  }

  SyncQueueItem copyWith(
          {int? id,
          String? entityType,
          String? entityId,
          String? action,
          String? payload,
          String? status,
          DateTime? createdAt,
          int? retryCount,
          Value<String?> lastError = const Value.absent(),
          String? deviceId}) =>
      SyncQueueItem(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        action: action ?? this.action,
        payload: payload ?? this.payload,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
        lastError: lastError.present ? lastError.value : this.lastError,
        deviceId: deviceId ?? this.deviceId,
      );
  SyncQueueItem copyWithCompanion(SyncQueueItemsCompanion data) {
    return SyncQueueItem(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueItem(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityType, entityId, action, payload,
      status, createdAt, retryCount, lastError, deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueItem &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.deviceId == this.deviceId);
}

class SyncQueueItemsCompanion extends UpdateCompanion<SyncQueueItem> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String> payload;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<String> deviceId;
  const SyncQueueItemsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.deviceId = const Value.absent(),
  });
  SyncQueueItemsCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityId,
    required String action,
    required String payload,
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    required String deviceId,
  })  : entityType = Value(entityType),
        entityId = Value(entityId),
        action = Value(action),
        payload = Value(payload),
        deviceId = Value(deviceId);
  static Insertable<SyncQueueItem> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<String>? deviceId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (deviceId != null) 'device_id': deviceId,
    });
  }

  SyncQueueItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? action,
      Value<String>? payload,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<int>? retryCount,
      Value<String?>? lastError,
      Value<String>? deviceId}) {
    return SyncQueueItemsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueItemsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }
}

class $UsuariosTable extends Usuarios with TableInfo<$UsuariosTable, Usuario> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsuariosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
      'nome', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cpfCnpjMeta =
      const VerificationMeta('cpfCnpj');
  @override
  late final GeneratedColumn<String> cpfCnpj = GeneratedColumn<String>(
      'cpf_cnpj', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _senhaHashMeta =
      const VerificationMeta('senhaHash');
  @override
  late final GeneratedColumn<String> senhaHash = GeneratedColumn<String>(
      'senha_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _perfilMeta = const VerificationMeta('perfil');
  @override
  late final GeneratedColumn<String> perfil = GeneratedColumn<String>(
      'perfil', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('proprietario'));
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _telefoneMeta =
      const VerificationMeta('telefone');
  @override
  late final GeneratedColumn<String> telefone = GeneratedColumn<String>(
      'telefone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailVerificadoMeta =
      const VerificationMeta('emailVerificado');
  @override
  late final GeneratedColumn<bool> emailVerificado = GeneratedColumn<bool>(
      'email_verificado', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("email_verificado" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        syncStatus,
        deviceId,
        createdAt,
        updatedAt,
        deletedAt,
        nome,
        cpfCnpj,
        senhaHash,
        perfil,
        email,
        telefone,
        emailVerificado
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usuarios';
  @override
  VerificationContext validateIntegrity(Insertable<Usuario> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
          _nomeMeta, nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta));
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('cpf_cnpj')) {
      context.handle(_cpfCnpjMeta,
          cpfCnpj.isAcceptableOrUnknown(data['cpf_cnpj']!, _cpfCnpjMeta));
    } else if (isInserting) {
      context.missing(_cpfCnpjMeta);
    }
    if (data.containsKey('senha_hash')) {
      context.handle(_senhaHashMeta,
          senhaHash.isAcceptableOrUnknown(data['senha_hash']!, _senhaHashMeta));
    } else if (isInserting) {
      context.missing(_senhaHashMeta);
    }
    if (data.containsKey('perfil')) {
      context.handle(_perfilMeta,
          perfil.isAcceptableOrUnknown(data['perfil']!, _perfilMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('telefone')) {
      context.handle(_telefoneMeta,
          telefone.isAcceptableOrUnknown(data['telefone']!, _telefoneMeta));
    }
    if (data.containsKey('email_verificado')) {
      context.handle(
          _emailVerificadoMeta,
          emailVerificado.isAcceptableOrUnknown(
              data['email_verificado']!, _emailVerificadoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Usuario map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Usuario(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      nome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nome'])!,
      cpfCnpj: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cpf_cnpj'])!,
      senhaHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}senha_hash'])!,
      perfil: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}perfil'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      telefone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}telefone']),
      emailVerificado: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}email_verificado'])!,
    );
  }

  @override
  $UsuariosTable createAlias(String alias) {
    return $UsuariosTable(attachedDatabase, alias);
  }
}

class Usuario extends DataClass implements Insertable<Usuario> {
  final String id;

  /// Identificador gerado pelo servidor após a sincronização bem-sucedida.
  /// Fica nulo enquanto o registro existir apenas no dispositivo local.
  final String? serverId;

  /// Status atual da sincronização do registro:
  /// - `pending`: aguardando envio para o servidor
  /// - `synced`: sincronizado com sucesso
  /// - `conflict`: ocorreu um conflito de versão que precisa de resolução
  final String syncStatus;

  /// Identificador único do dispositivo que criou ou modificou este registro.
  /// Usado para auditoria e resolução de conflitos.
  final String deviceId;

  /// Data e hora da criação original do registro.
  final DateTime createdAt;

  /// Data e hora da última modificação do registro.
  final DateTime updatedAt;

  /// Data e hora da exclusão lógica (soft delete). Se preenchido, o registro
  /// é considerado apagado, mas é mantido no banco para sincronizar a exclusão.
  final DateTime? deletedAt;
  final String nome;
  final String cpfCnpj;
  final String senhaHash;
  final String perfil;
  final String? email;
  final String? telefone;
  final bool emailVerificado;
  const Usuario(
      {required this.id,
      this.serverId,
      required this.syncStatus,
      required this.deviceId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.nome,
      required this.cpfCnpj,
      required this.senhaHash,
      required this.perfil,
      this.email,
      this.telefone,
      required this.emailVerificado});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['nome'] = Variable<String>(nome);
    map['cpf_cnpj'] = Variable<String>(cpfCnpj);
    map['senha_hash'] = Variable<String>(senhaHash);
    map['perfil'] = Variable<String>(perfil);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || telefone != null) {
      map['telefone'] = Variable<String>(telefone);
    }
    map['email_verificado'] = Variable<bool>(emailVerificado);
    return map;
  }

  UsuariosCompanion toCompanion(bool nullToAbsent) {
    return UsuariosCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      syncStatus: Value(syncStatus),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      nome: Value(nome),
      cpfCnpj: Value(cpfCnpj),
      senhaHash: Value(senhaHash),
      perfil: Value(perfil),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      telefone: telefone == null && nullToAbsent
          ? const Value.absent()
          : Value(telefone),
      emailVerificado: Value(emailVerificado),
    );
  }

  factory Usuario.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Usuario(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      nome: serializer.fromJson<String>(json['nome']),
      cpfCnpj: serializer.fromJson<String>(json['cpfCnpj']),
      senhaHash: serializer.fromJson<String>(json['senhaHash']),
      perfil: serializer.fromJson<String>(json['perfil']),
      email: serializer.fromJson<String?>(json['email']),
      telefone: serializer.fromJson<String?>(json['telefone']),
      emailVerificado: serializer.fromJson<bool>(json['emailVerificado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'nome': serializer.toJson<String>(nome),
      'cpfCnpj': serializer.toJson<String>(cpfCnpj),
      'senhaHash': serializer.toJson<String>(senhaHash),
      'perfil': serializer.toJson<String>(perfil),
      'email': serializer.toJson<String?>(email),
      'telefone': serializer.toJson<String?>(telefone),
      'emailVerificado': serializer.toJson<bool>(emailVerificado),
    };
  }

  Usuario copyWith(
          {String? id,
          Value<String?> serverId = const Value.absent(),
          String? syncStatus,
          String? deviceId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? nome,
          String? cpfCnpj,
          String? senhaHash,
          String? perfil,
          Value<String?> email = const Value.absent(),
          Value<String?> telefone = const Value.absent(),
          bool? emailVerificado}) =>
      Usuario(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        syncStatus: syncStatus ?? this.syncStatus,
        deviceId: deviceId ?? this.deviceId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        nome: nome ?? this.nome,
        cpfCnpj: cpfCnpj ?? this.cpfCnpj,
        senhaHash: senhaHash ?? this.senhaHash,
        perfil: perfil ?? this.perfil,
        email: email.present ? email.value : this.email,
        telefone: telefone.present ? telefone.value : this.telefone,
        emailVerificado: emailVerificado ?? this.emailVerificado,
      );
  Usuario copyWithCompanion(UsuariosCompanion data) {
    return Usuario(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      nome: data.nome.present ? data.nome.value : this.nome,
      cpfCnpj: data.cpfCnpj.present ? data.cpfCnpj.value : this.cpfCnpj,
      senhaHash: data.senhaHash.present ? data.senhaHash.value : this.senhaHash,
      perfil: data.perfil.present ? data.perfil.value : this.perfil,
      email: data.email.present ? data.email.value : this.email,
      telefone: data.telefone.present ? data.telefone.value : this.telefone,
      emailVerificado: data.emailVerificado.present
          ? data.emailVerificado.value
          : this.emailVerificado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Usuario(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('nome: $nome, ')
          ..write('cpfCnpj: $cpfCnpj, ')
          ..write('senhaHash: $senhaHash, ')
          ..write('perfil: $perfil, ')
          ..write('email: $email, ')
          ..write('telefone: $telefone, ')
          ..write('emailVerificado: $emailVerificado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      syncStatus,
      deviceId,
      createdAt,
      updatedAt,
      deletedAt,
      nome,
      cpfCnpj,
      senhaHash,
      perfil,
      email,
      telefone,
      emailVerificado);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Usuario &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.syncStatus == this.syncStatus &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.nome == this.nome &&
          other.cpfCnpj == this.cpfCnpj &&
          other.senhaHash == this.senhaHash &&
          other.perfil == this.perfil &&
          other.email == this.email &&
          other.telefone == this.telefone &&
          other.emailVerificado == this.emailVerificado);
}

class UsuariosCompanion extends UpdateCompanion<Usuario> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> syncStatus;
  final Value<String> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> nome;
  final Value<String> cpfCnpj;
  final Value<String> senhaHash;
  final Value<String> perfil;
  final Value<String?> email;
  final Value<String?> telefone;
  final Value<bool> emailVerificado;
  final Value<int> rowid;
  const UsuariosCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.nome = const Value.absent(),
    this.cpfCnpj = const Value.absent(),
    this.senhaHash = const Value.absent(),
    this.perfil = const Value.absent(),
    this.email = const Value.absent(),
    this.telefone = const Value.absent(),
    this.emailVerificado = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsuariosCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String deviceId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String nome,
    required String cpfCnpj,
    required String senhaHash,
    this.perfil = const Value.absent(),
    this.email = const Value.absent(),
    this.telefone = const Value.absent(),
    this.emailVerificado = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deviceId = Value(deviceId),
        nome = Value(nome),
        cpfCnpj = Value(cpfCnpj),
        senhaHash = Value(senhaHash);
  static Insertable<Usuario> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? syncStatus,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? nome,
    Expression<String>? cpfCnpj,
    Expression<String>? senhaHash,
    Expression<String>? perfil,
    Expression<String>? email,
    Expression<String>? telefone,
    Expression<bool>? emailVerificado,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (nome != null) 'nome': nome,
      if (cpfCnpj != null) 'cpf_cnpj': cpfCnpj,
      if (senhaHash != null) 'senha_hash': senhaHash,
      if (perfil != null) 'perfil': perfil,
      if (email != null) 'email': email,
      if (telefone != null) 'telefone': telefone,
      if (emailVerificado != null) 'email_verificado': emailVerificado,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsuariosCompanion copyWith(
      {Value<String>? id,
      Value<String?>? serverId,
      Value<String>? syncStatus,
      Value<String>? deviceId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? nome,
      Value<String>? cpfCnpj,
      Value<String>? senhaHash,
      Value<String>? perfil,
      Value<String?>? email,
      Value<String?>? telefone,
      Value<bool>? emailVerificado,
      Value<int>? rowid}) {
    return UsuariosCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      syncStatus: syncStatus ?? this.syncStatus,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      nome: nome ?? this.nome,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
      senhaHash: senhaHash ?? this.senhaHash,
      perfil: perfil ?? this.perfil,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      emailVerificado: emailVerificado ?? this.emailVerificado,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (cpfCnpj.present) {
      map['cpf_cnpj'] = Variable<String>(cpfCnpj.value);
    }
    if (senhaHash.present) {
      map['senha_hash'] = Variable<String>(senhaHash.value);
    }
    if (perfil.present) {
      map['perfil'] = Variable<String>(perfil.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (telefone.present) {
      map['telefone'] = Variable<String>(telefone.value);
    }
    if (emailVerificado.present) {
      map['email_verificado'] = Variable<bool>(emailVerificado.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsuariosCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('nome: $nome, ')
          ..write('cpfCnpj: $cpfCnpj, ')
          ..write('senhaHash: $senhaHash, ')
          ..write('perfil: $perfil, ')
          ..write('email: $email, ')
          ..write('telefone: $telefone, ')
          ..write('emailVerificado: $emailVerificado, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PesagensTable extends Pesagens with TableInfo<$PesagensTable, Pesagem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PesagensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _animalIdMeta =
      const VerificationMeta('animalId');
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
      'animal_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pesoMeta = const VerificationMeta('peso');
  @override
  late final GeneratedColumn<double> peso = GeneratedColumn<double>(
      'peso', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dataPesagemMeta =
      const VerificationMeta('dataPesagem');
  @override
  late final GeneratedColumn<DateTime> dataPesagem = GeneratedColumn<DateTime>(
      'data_pesagem', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        syncStatus,
        deviceId,
        createdAt,
        updatedAt,
        deletedAt,
        animalId,
        peso,
        dataPesagem
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pesagens';
  @override
  VerificationContext validateIntegrity(Insertable<Pesagem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('animal_id')) {
      context.handle(_animalIdMeta,
          animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta));
    } else if (isInserting) {
      context.missing(_animalIdMeta);
    }
    if (data.containsKey('peso')) {
      context.handle(
          _pesoMeta, peso.isAcceptableOrUnknown(data['peso']!, _pesoMeta));
    } else if (isInserting) {
      context.missing(_pesoMeta);
    }
    if (data.containsKey('data_pesagem')) {
      context.handle(
          _dataPesagemMeta,
          dataPesagem.isAcceptableOrUnknown(
              data['data_pesagem']!, _dataPesagemMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pesagem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pesagem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id'])!,
      peso: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}peso'])!,
      dataPesagem: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}data_pesagem'])!,
    );
  }

  @override
  $PesagensTable createAlias(String alias) {
    return $PesagensTable(attachedDatabase, alias);
  }
}

class Pesagem extends DataClass implements Insertable<Pesagem> {
  /// Identificador único universal (UUID V4) gerado localmente.
  /// Funciona como chave de idempotência e identificador principal.
  final String id;

  /// Identificador gerado pelo servidor após a sincronização bem-sucedida.
  /// Fica nulo enquanto o registro existir apenas no dispositivo local.
  final String? serverId;

  /// Status atual da sincronização do registro:
  /// - `pending`: aguardando envio para o servidor
  /// - `synced`: sincronizado com sucesso
  /// - `conflict`: ocorreu um conflito de versão que precisa de resolução
  final String syncStatus;

  /// Identificador único do dispositivo que criou ou modificou este registro.
  /// Usado para auditoria e resolução de conflitos.
  final String deviceId;

  /// Data e hora da criação original do registro.
  final DateTime createdAt;

  /// Data e hora da última modificação do registro.
  final DateTime updatedAt;

  /// Data e hora da exclusão lógica (soft delete). Se preenchido, o registro
  /// é considerado apagado, mas é mantido no banco para sincronizar a exclusão.
  final DateTime? deletedAt;
  final String animalId;
  final double peso;
  final DateTime dataPesagem;
  const Pesagem(
      {required this.id,
      this.serverId,
      required this.syncStatus,
      required this.deviceId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.animalId,
      required this.peso,
      required this.dataPesagem});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['animal_id'] = Variable<String>(animalId);
    map['peso'] = Variable<double>(peso);
    map['data_pesagem'] = Variable<DateTime>(dataPesagem);
    return map;
  }

  PesagensCompanion toCompanion(bool nullToAbsent) {
    return PesagensCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      syncStatus: Value(syncStatus),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      animalId: Value(animalId),
      peso: Value(peso),
      dataPesagem: Value(dataPesagem),
    );
  }

  factory Pesagem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pesagem(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      animalId: serializer.fromJson<String>(json['animalId']),
      peso: serializer.fromJson<double>(json['peso']),
      dataPesagem: serializer.fromJson<DateTime>(json['dataPesagem']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'animalId': serializer.toJson<String>(animalId),
      'peso': serializer.toJson<double>(peso),
      'dataPesagem': serializer.toJson<DateTime>(dataPesagem),
    };
  }

  Pesagem copyWith(
          {String? id,
          Value<String?> serverId = const Value.absent(),
          String? syncStatus,
          String? deviceId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? animalId,
          double? peso,
          DateTime? dataPesagem}) =>
      Pesagem(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        syncStatus: syncStatus ?? this.syncStatus,
        deviceId: deviceId ?? this.deviceId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        animalId: animalId ?? this.animalId,
        peso: peso ?? this.peso,
        dataPesagem: dataPesagem ?? this.dataPesagem,
      );
  Pesagem copyWithCompanion(PesagensCompanion data) {
    return Pesagem(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      peso: data.peso.present ? data.peso.value : this.peso,
      dataPesagem:
          data.dataPesagem.present ? data.dataPesagem.value : this.dataPesagem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pesagem(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('animalId: $animalId, ')
          ..write('peso: $peso, ')
          ..write('dataPesagem: $dataPesagem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, serverId, syncStatus, deviceId, createdAt,
      updatedAt, deletedAt, animalId, peso, dataPesagem);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pesagem &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.syncStatus == this.syncStatus &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.animalId == this.animalId &&
          other.peso == this.peso &&
          other.dataPesagem == this.dataPesagem);
}

class PesagensCompanion extends UpdateCompanion<Pesagem> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> syncStatus;
  final Value<String> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> animalId;
  final Value<double> peso;
  final Value<DateTime> dataPesagem;
  final Value<int> rowid;
  const PesagensCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.animalId = const Value.absent(),
    this.peso = const Value.absent(),
    this.dataPesagem = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PesagensCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String deviceId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String animalId,
    required double peso,
    this.dataPesagem = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deviceId = Value(deviceId),
        animalId = Value(animalId),
        peso = Value(peso);
  static Insertable<Pesagem> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? syncStatus,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? animalId,
    Expression<double>? peso,
    Expression<DateTime>? dataPesagem,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (animalId != null) 'animal_id': animalId,
      if (peso != null) 'peso': peso,
      if (dataPesagem != null) 'data_pesagem': dataPesagem,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PesagensCompanion copyWith(
      {Value<String>? id,
      Value<String?>? serverId,
      Value<String>? syncStatus,
      Value<String>? deviceId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? animalId,
      Value<double>? peso,
      Value<DateTime>? dataPesagem,
      Value<int>? rowid}) {
    return PesagensCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      syncStatus: syncStatus ?? this.syncStatus,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      animalId: animalId ?? this.animalId,
      peso: peso ?? this.peso,
      dataPesagem: dataPesagem ?? this.dataPesagem,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (peso.present) {
      map['peso'] = Variable<double>(peso.value);
    }
    if (dataPesagem.present) {
      map['data_pesagem'] = Variable<DateTime>(dataPesagem.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PesagensCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('animalId: $animalId, ')
          ..write('peso: $peso, ')
          ..write('dataPesagem: $dataPesagem, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LancamentosFinanceirosTable extends LancamentosFinanceiros
    with TableInfo<$LancamentosFinanceirosTable, LancamentoFinanceiro> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LancamentosFinanceirosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _fazendaIdMeta =
      const VerificationMeta('fazendaId');
  @override
  late final GeneratedColumn<String> fazendaId = GeneratedColumn<String>(
      'fazenda_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
      'tipo', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descricaoMeta =
      const VerificationMeta('descricao');
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
      'descricao', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _categoriaMeta =
      const VerificationMeta('categoria');
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
      'categoria', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<double> valor = GeneratedColumn<double>(
      'valor', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dataVencimentoMeta =
      const VerificationMeta('dataVencimento');
  @override
  late final GeneratedColumn<DateTime> dataVencimento =
      GeneratedColumn<DateTime>('data_vencimento', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dataPagamentoMeta =
      const VerificationMeta('dataPagamento');
  @override
  late final GeneratedColumn<DateTime> dataPagamento =
      GeneratedColumn<DateTime>('data_pagamento', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        syncStatus,
        deviceId,
        createdAt,
        updatedAt,
        deletedAt,
        fazendaId,
        tipo,
        descricao,
        categoria,
        valor,
        dataVencimento,
        dataPagamento,
        status
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lancamentos_financeiros';
  @override
  VerificationContext validateIntegrity(
      Insertable<LancamentoFinanceiro> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('fazenda_id')) {
      context.handle(_fazendaIdMeta,
          fazendaId.isAcceptableOrUnknown(data['fazenda_id']!, _fazendaIdMeta));
    } else if (isInserting) {
      context.missing(_fazendaIdMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
          _tipoMeta, tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta));
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('descricao')) {
      context.handle(_descricaoMeta,
          descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta));
    } else if (isInserting) {
      context.missing(_descricaoMeta);
    }
    if (data.containsKey('categoria')) {
      context.handle(_categoriaMeta,
          categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta));
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
          _valorMeta, valor.isAcceptableOrUnknown(data['valor']!, _valorMeta));
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('data_vencimento')) {
      context.handle(
          _dataVencimentoMeta,
          dataVencimento.isAcceptableOrUnknown(
              data['data_vencimento']!, _dataVencimentoMeta));
    } else if (isInserting) {
      context.missing(_dataVencimentoMeta);
    }
    if (data.containsKey('data_pagamento')) {
      context.handle(
          _dataPagamentoMeta,
          dataPagamento.isAcceptableOrUnknown(
              data['data_pagamento']!, _dataPagamentoMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LancamentoFinanceiro map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LancamentoFinanceiro(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      fazendaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fazenda_id'])!,
      tipo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo'])!,
      descricao: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descricao'])!,
      categoria: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categoria'])!,
      valor: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}valor'])!,
      dataVencimento: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}data_vencimento'])!,
      dataPagamento: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}data_pagamento']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $LancamentosFinanceirosTable createAlias(String alias) {
    return $LancamentosFinanceirosTable(attachedDatabase, alias);
  }
}

class LancamentoFinanceiro extends DataClass
    implements Insertable<LancamentoFinanceiro> {
  /// Identificador único universal (UUID V4) gerado localmente.
  /// Funciona como chave de idempotência e identificador principal.
  final String id;

  /// Identificador gerado pelo servidor após a sincronização bem-sucedida.
  /// Fica nulo enquanto o registro existir apenas no dispositivo local.
  final String? serverId;

  /// Status atual da sincronização do registro:
  /// - `pending`: aguardando envio para o servidor
  /// - `synced`: sincronizado com sucesso
  /// - `conflict`: ocorreu um conflito de versão que precisa de resolução
  final String syncStatus;

  /// Identificador único do dispositivo que criou ou modificou este registro.
  /// Usado para auditoria e resolução de conflitos.
  final String deviceId;

  /// Data e hora da criação original do registro.
  final DateTime createdAt;

  /// Data e hora da última modificação do registro.
  final DateTime updatedAt;

  /// Data e hora da exclusão lógica (soft delete). Se preenchido, o registro
  /// é considerado apagado, mas é mantido no banco para sincronizar a exclusão.
  final DateTime? deletedAt;
  final String fazendaId;
  final String tipo;
  final String descricao;
  final String categoria;
  final double valor;
  final DateTime dataVencimento;
  final DateTime? dataPagamento;
  final String status;
  const LancamentoFinanceiro(
      {required this.id,
      this.serverId,
      required this.syncStatus,
      required this.deviceId,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.fazendaId,
      required this.tipo,
      required this.descricao,
      required this.categoria,
      required this.valor,
      required this.dataVencimento,
      this.dataPagamento,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['fazenda_id'] = Variable<String>(fazendaId);
    map['tipo'] = Variable<String>(tipo);
    map['descricao'] = Variable<String>(descricao);
    map['categoria'] = Variable<String>(categoria);
    map['valor'] = Variable<double>(valor);
    map['data_vencimento'] = Variable<DateTime>(dataVencimento);
    if (!nullToAbsent || dataPagamento != null) {
      map['data_pagamento'] = Variable<DateTime>(dataPagamento);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  LancamentosFinanceirosCompanion toCompanion(bool nullToAbsent) {
    return LancamentosFinanceirosCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      syncStatus: Value(syncStatus),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      fazendaId: Value(fazendaId),
      tipo: Value(tipo),
      descricao: Value(descricao),
      categoria: Value(categoria),
      valor: Value(valor),
      dataVencimento: Value(dataVencimento),
      dataPagamento: dataPagamento == null && nullToAbsent
          ? const Value.absent()
          : Value(dataPagamento),
      status: Value(status),
    );
  }

  factory LancamentoFinanceiro.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LancamentoFinanceiro(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      fazendaId: serializer.fromJson<String>(json['fazendaId']),
      tipo: serializer.fromJson<String>(json['tipo']),
      descricao: serializer.fromJson<String>(json['descricao']),
      categoria: serializer.fromJson<String>(json['categoria']),
      valor: serializer.fromJson<double>(json['valor']),
      dataVencimento: serializer.fromJson<DateTime>(json['dataVencimento']),
      dataPagamento: serializer.fromJson<DateTime?>(json['dataPagamento']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'fazendaId': serializer.toJson<String>(fazendaId),
      'tipo': serializer.toJson<String>(tipo),
      'descricao': serializer.toJson<String>(descricao),
      'categoria': serializer.toJson<String>(categoria),
      'valor': serializer.toJson<double>(valor),
      'dataVencimento': serializer.toJson<DateTime>(dataVencimento),
      'dataPagamento': serializer.toJson<DateTime?>(dataPagamento),
      'status': serializer.toJson<String>(status),
    };
  }

  LancamentoFinanceiro copyWith(
          {String? id,
          Value<String?> serverId = const Value.absent(),
          String? syncStatus,
          String? deviceId,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? fazendaId,
          String? tipo,
          String? descricao,
          String? categoria,
          double? valor,
          DateTime? dataVencimento,
          Value<DateTime?> dataPagamento = const Value.absent(),
          String? status}) =>
      LancamentoFinanceiro(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        syncStatus: syncStatus ?? this.syncStatus,
        deviceId: deviceId ?? this.deviceId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        fazendaId: fazendaId ?? this.fazendaId,
        tipo: tipo ?? this.tipo,
        descricao: descricao ?? this.descricao,
        categoria: categoria ?? this.categoria,
        valor: valor ?? this.valor,
        dataVencimento: dataVencimento ?? this.dataVencimento,
        dataPagamento:
            dataPagamento.present ? dataPagamento.value : this.dataPagamento,
        status: status ?? this.status,
      );
  LancamentoFinanceiro copyWithCompanion(LancamentosFinanceirosCompanion data) {
    return LancamentoFinanceiro(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      fazendaId: data.fazendaId.present ? data.fazendaId.value : this.fazendaId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      valor: data.valor.present ? data.valor.value : this.valor,
      dataVencimento: data.dataVencimento.present
          ? data.dataVencimento.value
          : this.dataVencimento,
      dataPagamento: data.dataPagamento.present
          ? data.dataPagamento.value
          : this.dataPagamento,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LancamentoFinanceiro(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('fazendaId: $fazendaId, ')
          ..write('tipo: $tipo, ')
          ..write('descricao: $descricao, ')
          ..write('categoria: $categoria, ')
          ..write('valor: $valor, ')
          ..write('dataVencimento: $dataVencimento, ')
          ..write('dataPagamento: $dataPagamento, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      syncStatus,
      deviceId,
      createdAt,
      updatedAt,
      deletedAt,
      fazendaId,
      tipo,
      descricao,
      categoria,
      valor,
      dataVencimento,
      dataPagamento,
      status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LancamentoFinanceiro &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.syncStatus == this.syncStatus &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.fazendaId == this.fazendaId &&
          other.tipo == this.tipo &&
          other.descricao == this.descricao &&
          other.categoria == this.categoria &&
          other.valor == this.valor &&
          other.dataVencimento == this.dataVencimento &&
          other.dataPagamento == this.dataPagamento &&
          other.status == this.status);
}

class LancamentosFinanceirosCompanion
    extends UpdateCompanion<LancamentoFinanceiro> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> syncStatus;
  final Value<String> deviceId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> fazendaId;
  final Value<String> tipo;
  final Value<String> descricao;
  final Value<String> categoria;
  final Value<double> valor;
  final Value<DateTime> dataVencimento;
  final Value<DateTime?> dataPagamento;
  final Value<String> status;
  final Value<int> rowid;
  const LancamentosFinanceirosCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.fazendaId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.descricao = const Value.absent(),
    this.categoria = const Value.absent(),
    this.valor = const Value.absent(),
    this.dataVencimento = const Value.absent(),
    this.dataPagamento = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LancamentosFinanceirosCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String deviceId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String fazendaId,
    required String tipo,
    required String descricao,
    required String categoria,
    required double valor,
    required DateTime dataVencimento,
    this.dataPagamento = const Value.absent(),
    required String status,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deviceId = Value(deviceId),
        fazendaId = Value(fazendaId),
        tipo = Value(tipo),
        descricao = Value(descricao),
        categoria = Value(categoria),
        valor = Value(valor),
        dataVencimento = Value(dataVencimento),
        status = Value(status);
  static Insertable<LancamentoFinanceiro> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? syncStatus,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? fazendaId,
    Expression<String>? tipo,
    Expression<String>? descricao,
    Expression<String>? categoria,
    Expression<double>? valor,
    Expression<DateTime>? dataVencimento,
    Expression<DateTime>? dataPagamento,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (fazendaId != null) 'fazenda_id': fazendaId,
      if (tipo != null) 'tipo': tipo,
      if (descricao != null) 'descricao': descricao,
      if (categoria != null) 'categoria': categoria,
      if (valor != null) 'valor': valor,
      if (dataVencimento != null) 'data_vencimento': dataVencimento,
      if (dataPagamento != null) 'data_pagamento': dataPagamento,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LancamentosFinanceirosCompanion copyWith(
      {Value<String>? id,
      Value<String?>? serverId,
      Value<String>? syncStatus,
      Value<String>? deviceId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? fazendaId,
      Value<String>? tipo,
      Value<String>? descricao,
      Value<String>? categoria,
      Value<double>? valor,
      Value<DateTime>? dataVencimento,
      Value<DateTime?>? dataPagamento,
      Value<String>? status,
      Value<int>? rowid}) {
    return LancamentosFinanceirosCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      syncStatus: syncStatus ?? this.syncStatus,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      fazendaId: fazendaId ?? this.fazendaId,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      valor: valor ?? this.valor,
      dataVencimento: dataVencimento ?? this.dataVencimento,
      dataPagamento: dataPagamento ?? this.dataPagamento,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (fazendaId.present) {
      map['fazenda_id'] = Variable<String>(fazendaId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (valor.present) {
      map['valor'] = Variable<double>(valor.value);
    }
    if (dataVencimento.present) {
      map['data_vencimento'] = Variable<DateTime>(dataVencimento.value);
    }
    if (dataPagamento.present) {
      map['data_pagamento'] = Variable<DateTime>(dataPagamento.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LancamentosFinanceirosCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('fazendaId: $fazendaId, ')
          ..write('tipo: $tipo, ')
          ..write('descricao: $descricao, ')
          ..write('categoria: $categoria, ')
          ..write('valor: $valor, ')
          ..write('dataVencimento: $dataVencimento, ')
          ..write('dataPagamento: $dataPagamento, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FazendasTable fazendas = $FazendasTable(this);
  late final $PiquetesTable piquetes = $PiquetesTable(this);
  late final $LotesTable lotes = $LotesTable(this);
  late final $AnimaisTable animais = $AnimaisTable(this);
  late final $ProdutosTable produtos = $ProdutosTable(this);
  late final $EstoqueMovimentosTable estoqueMovimentos =
      $EstoqueMovimentosTable(this);
  late final $AplicacoesSanitariasTable aplicacoesSanitarias =
      $AplicacoesSanitariasTable(this);
  late final $OcorrenciasSanitariasTable ocorrenciasSanitarias =
      $OcorrenciasSanitariasTable(this);
  late final $DietasTable dietas = $DietasTable(this);
  late final $FornecimentosDietaTable fornecimentosDieta =
      $FornecimentosDietaTable(this);
  late final $SyncQueueItemsTable syncQueueItems = $SyncQueueItemsTable(this);
  late final $UsuariosTable usuarios = $UsuariosTable(this);
  late final $PesagensTable pesagens = $PesagensTable(this);
  late final $LancamentosFinanceirosTable lancamentosFinanceiros =
      $LancamentosFinanceirosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        fazendas,
        piquetes,
        lotes,
        animais,
        produtos,
        estoqueMovimentos,
        aplicacoesSanitarias,
        ocorrenciasSanitarias,
        dietas,
        fornecimentosDieta,
        syncQueueItems,
        usuarios,
        pesagens,
        lancamentosFinanceiros
      ];
}

typedef $$FazendasTableCreateCompanionBuilder = FazendasCompanion Function({
  required String id,
  Value<String?> serverId,
  Value<String> syncStatus,
  required String deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String nome,
  Value<String?> cpfCnpj,
  Value<String?> responsavel,
  Value<String?> cidade,
  Value<String?> estado,
  Value<String?> logoBase64,
  Value<int> rowid,
});
typedef $$FazendasTableUpdateCompanionBuilder = FazendasCompanion Function({
  Value<String> id,
  Value<String?> serverId,
  Value<String> syncStatus,
  Value<String> deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> nome,
  Value<String?> cpfCnpj,
  Value<String?> responsavel,
  Value<String?> cidade,
  Value<String?> estado,
  Value<String?> logoBase64,
  Value<int> rowid,
});

class $$FazendasTableFilterComposer
    extends Composer<_$AppDatabase, $FazendasTable> {
  $$FazendasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nome => $composableBuilder(
      column: $table.nome, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cpfCnpj => $composableBuilder(
      column: $table.cpfCnpj, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get responsavel => $composableBuilder(
      column: $table.responsavel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cidade => $composableBuilder(
      column: $table.cidade, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get logoBase64 => $composableBuilder(
      column: $table.logoBase64, builder: (column) => ColumnFilters(column));
}

class $$FazendasTableOrderingComposer
    extends Composer<_$AppDatabase, $FazendasTable> {
  $$FazendasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nome => $composableBuilder(
      column: $table.nome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cpfCnpj => $composableBuilder(
      column: $table.cpfCnpj, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get responsavel => $composableBuilder(
      column: $table.responsavel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cidade => $composableBuilder(
      column: $table.cidade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get logoBase64 => $composableBuilder(
      column: $table.logoBase64, builder: (column) => ColumnOrderings(column));
}

class $$FazendasTableAnnotationComposer
    extends Composer<_$AppDatabase, $FazendasTable> {
  $$FazendasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get cpfCnpj =>
      $composableBuilder(column: $table.cpfCnpj, builder: (column) => column);

  GeneratedColumn<String> get responsavel => $composableBuilder(
      column: $table.responsavel, builder: (column) => column);

  GeneratedColumn<String> get cidade =>
      $composableBuilder(column: $table.cidade, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get logoBase64 => $composableBuilder(
      column: $table.logoBase64, builder: (column) => column);
}

class $$FazendasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FazendasTable,
    Fazenda,
    $$FazendasTableFilterComposer,
    $$FazendasTableOrderingComposer,
    $$FazendasTableAnnotationComposer,
    $$FazendasTableCreateCompanionBuilder,
    $$FazendasTableUpdateCompanionBuilder,
    (Fazenda, BaseReferences<_$AppDatabase, $FazendasTable, Fazenda>),
    Fazenda,
    PrefetchHooks Function()> {
  $$FazendasTableTableManager(_$AppDatabase db, $FazendasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FazendasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FazendasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FazendasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> nome = const Value.absent(),
            Value<String?> cpfCnpj = const Value.absent(),
            Value<String?> responsavel = const Value.absent(),
            Value<String?> cidade = const Value.absent(),
            Value<String?> estado = const Value.absent(),
            Value<String?> logoBase64 = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FazendasCompanion(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            nome: nome,
            cpfCnpj: cpfCnpj,
            responsavel: responsavel,
            cidade: cidade,
            estado: estado,
            logoBase64: logoBase64,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String deviceId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String nome,
            Value<String?> cpfCnpj = const Value.absent(),
            Value<String?> responsavel = const Value.absent(),
            Value<String?> cidade = const Value.absent(),
            Value<String?> estado = const Value.absent(),
            Value<String?> logoBase64 = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FazendasCompanion.insert(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            nome: nome,
            cpfCnpj: cpfCnpj,
            responsavel: responsavel,
            cidade: cidade,
            estado: estado,
            logoBase64: logoBase64,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FazendasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FazendasTable,
    Fazenda,
    $$FazendasTableFilterComposer,
    $$FazendasTableOrderingComposer,
    $$FazendasTableAnnotationComposer,
    $$FazendasTableCreateCompanionBuilder,
    $$FazendasTableUpdateCompanionBuilder,
    (Fazenda, BaseReferences<_$AppDatabase, $FazendasTable, Fazenda>),
    Fazenda,
    PrefetchHooks Function()>;
typedef $$PiquetesTableCreateCompanionBuilder = PiquetesCompanion Function({
  required String id,
  Value<String?> serverId,
  Value<String> syncStatus,
  required String deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String fazendaId,
  required String nome,
  Value<String?> coordenadas,
  Value<double?> areaHectares,
  Value<int?> capacidadeCabecas,
  Value<int> rowid,
});
typedef $$PiquetesTableUpdateCompanionBuilder = PiquetesCompanion Function({
  Value<String> id,
  Value<String?> serverId,
  Value<String> syncStatus,
  Value<String> deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> fazendaId,
  Value<String> nome,
  Value<String?> coordenadas,
  Value<double?> areaHectares,
  Value<int?> capacidadeCabecas,
  Value<int> rowid,
});

class $$PiquetesTableFilterComposer
    extends Composer<_$AppDatabase, $PiquetesTable> {
  $$PiquetesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fazendaId => $composableBuilder(
      column: $table.fazendaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nome => $composableBuilder(
      column: $table.nome, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coordenadas => $composableBuilder(
      column: $table.coordenadas, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get areaHectares => $composableBuilder(
      column: $table.areaHectares, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get capacidadeCabecas => $composableBuilder(
      column: $table.capacidadeCabecas,
      builder: (column) => ColumnFilters(column));
}

class $$PiquetesTableOrderingComposer
    extends Composer<_$AppDatabase, $PiquetesTable> {
  $$PiquetesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fazendaId => $composableBuilder(
      column: $table.fazendaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nome => $composableBuilder(
      column: $table.nome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coordenadas => $composableBuilder(
      column: $table.coordenadas, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get areaHectares => $composableBuilder(
      column: $table.areaHectares,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get capacidadeCabecas => $composableBuilder(
      column: $table.capacidadeCabecas,
      builder: (column) => ColumnOrderings(column));
}

class $$PiquetesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PiquetesTable> {
  $$PiquetesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get fazendaId =>
      $composableBuilder(column: $table.fazendaId, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get coordenadas => $composableBuilder(
      column: $table.coordenadas, builder: (column) => column);

  GeneratedColumn<double> get areaHectares => $composableBuilder(
      column: $table.areaHectares, builder: (column) => column);

  GeneratedColumn<int> get capacidadeCabecas => $composableBuilder(
      column: $table.capacidadeCabecas, builder: (column) => column);
}

class $$PiquetesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PiquetesTable,
    Piquete,
    $$PiquetesTableFilterComposer,
    $$PiquetesTableOrderingComposer,
    $$PiquetesTableAnnotationComposer,
    $$PiquetesTableCreateCompanionBuilder,
    $$PiquetesTableUpdateCompanionBuilder,
    (Piquete, BaseReferences<_$AppDatabase, $PiquetesTable, Piquete>),
    Piquete,
    PrefetchHooks Function()> {
  $$PiquetesTableTableManager(_$AppDatabase db, $PiquetesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PiquetesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PiquetesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PiquetesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> fazendaId = const Value.absent(),
            Value<String> nome = const Value.absent(),
            Value<String?> coordenadas = const Value.absent(),
            Value<double?> areaHectares = const Value.absent(),
            Value<int?> capacidadeCabecas = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PiquetesCompanion(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            fazendaId: fazendaId,
            nome: nome,
            coordenadas: coordenadas,
            areaHectares: areaHectares,
            capacidadeCabecas: capacidadeCabecas,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String deviceId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String fazendaId,
            required String nome,
            Value<String?> coordenadas = const Value.absent(),
            Value<double?> areaHectares = const Value.absent(),
            Value<int?> capacidadeCabecas = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PiquetesCompanion.insert(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            fazendaId: fazendaId,
            nome: nome,
            coordenadas: coordenadas,
            areaHectares: areaHectares,
            capacidadeCabecas: capacidadeCabecas,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PiquetesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PiquetesTable,
    Piquete,
    $$PiquetesTableFilterComposer,
    $$PiquetesTableOrderingComposer,
    $$PiquetesTableAnnotationComposer,
    $$PiquetesTableCreateCompanionBuilder,
    $$PiquetesTableUpdateCompanionBuilder,
    (Piquete, BaseReferences<_$AppDatabase, $PiquetesTable, Piquete>),
    Piquete,
    PrefetchHooks Function()>;
typedef $$LotesTableCreateCompanionBuilder = LotesCompanion Function({
  required String id,
  Value<String?> serverId,
  Value<String> syncStatus,
  required String deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String fazendaId,
  Value<String?> piqueteId,
  required String nome,
  required String categoria,
  Value<int> quantidade,
  Value<int> rowid,
});
typedef $$LotesTableUpdateCompanionBuilder = LotesCompanion Function({
  Value<String> id,
  Value<String?> serverId,
  Value<String> syncStatus,
  Value<String> deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> fazendaId,
  Value<String?> piqueteId,
  Value<String> nome,
  Value<String> categoria,
  Value<int> quantidade,
  Value<int> rowid,
});

class $$LotesTableFilterComposer extends Composer<_$AppDatabase, $LotesTable> {
  $$LotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fazendaId => $composableBuilder(
      column: $table.fazendaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get piqueteId => $composableBuilder(
      column: $table.piqueteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nome => $composableBuilder(
      column: $table.nome, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoria => $composableBuilder(
      column: $table.categoria, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantidade => $composableBuilder(
      column: $table.quantidade, builder: (column) => ColumnFilters(column));
}

class $$LotesTableOrderingComposer
    extends Composer<_$AppDatabase, $LotesTable> {
  $$LotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fazendaId => $composableBuilder(
      column: $table.fazendaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get piqueteId => $composableBuilder(
      column: $table.piqueteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nome => $composableBuilder(
      column: $table.nome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoria => $composableBuilder(
      column: $table.categoria, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantidade => $composableBuilder(
      column: $table.quantidade, builder: (column) => ColumnOrderings(column));
}

class $$LotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LotesTable> {
  $$LotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get fazendaId =>
      $composableBuilder(column: $table.fazendaId, builder: (column) => column);

  GeneratedColumn<String> get piqueteId =>
      $composableBuilder(column: $table.piqueteId, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<int> get quantidade => $composableBuilder(
      column: $table.quantidade, builder: (column) => column);
}

class $$LotesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LotesTable,
    Lote,
    $$LotesTableFilterComposer,
    $$LotesTableOrderingComposer,
    $$LotesTableAnnotationComposer,
    $$LotesTableCreateCompanionBuilder,
    $$LotesTableUpdateCompanionBuilder,
    (Lote, BaseReferences<_$AppDatabase, $LotesTable, Lote>),
    Lote,
    PrefetchHooks Function()> {
  $$LotesTableTableManager(_$AppDatabase db, $LotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> fazendaId = const Value.absent(),
            Value<String?> piqueteId = const Value.absent(),
            Value<String> nome = const Value.absent(),
            Value<String> categoria = const Value.absent(),
            Value<int> quantidade = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LotesCompanion(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            fazendaId: fazendaId,
            piqueteId: piqueteId,
            nome: nome,
            categoria: categoria,
            quantidade: quantidade,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String deviceId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String fazendaId,
            Value<String?> piqueteId = const Value.absent(),
            required String nome,
            required String categoria,
            Value<int> quantidade = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LotesCompanion.insert(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            fazendaId: fazendaId,
            piqueteId: piqueteId,
            nome: nome,
            categoria: categoria,
            quantidade: quantidade,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LotesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LotesTable,
    Lote,
    $$LotesTableFilterComposer,
    $$LotesTableOrderingComposer,
    $$LotesTableAnnotationComposer,
    $$LotesTableCreateCompanionBuilder,
    $$LotesTableUpdateCompanionBuilder,
    (Lote, BaseReferences<_$AppDatabase, $LotesTable, Lote>),
    Lote,
    PrefetchHooks Function()>;
typedef $$AnimaisTableCreateCompanionBuilder = AnimaisCompanion Function({
  required String id,
  Value<String?> serverId,
  Value<String> syncStatus,
  required String deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String loteId,
  required String brinco,
  Value<String> tipoAnimal,
  required String categoria,
  required String raca,
  Value<String> sexo,
  Value<DateTime?> dataNascimento,
  Value<double?> pesoKg,
  Value<bool?> prenha,
  Value<DateTime?> dataCobertura,
  Value<DateTime?> dataPartoPrevisto,
  Value<DateTime?> dataParto,
  Value<int?> qtdFilhotes,
  Value<int?> qtdFilhotesVivos,
  Value<int> rowid,
});
typedef $$AnimaisTableUpdateCompanionBuilder = AnimaisCompanion Function({
  Value<String> id,
  Value<String?> serverId,
  Value<String> syncStatus,
  Value<String> deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> loteId,
  Value<String> brinco,
  Value<String> tipoAnimal,
  Value<String> categoria,
  Value<String> raca,
  Value<String> sexo,
  Value<DateTime?> dataNascimento,
  Value<double?> pesoKg,
  Value<bool?> prenha,
  Value<DateTime?> dataCobertura,
  Value<DateTime?> dataPartoPrevisto,
  Value<DateTime?> dataParto,
  Value<int?> qtdFilhotes,
  Value<int?> qtdFilhotesVivos,
  Value<int> rowid,
});

class $$AnimaisTableFilterComposer
    extends Composer<_$AppDatabase, $AnimaisTable> {
  $$AnimaisTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get loteId => $composableBuilder(
      column: $table.loteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brinco => $composableBuilder(
      column: $table.brinco, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipoAnimal => $composableBuilder(
      column: $table.tipoAnimal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoria => $composableBuilder(
      column: $table.categoria, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get raca => $composableBuilder(
      column: $table.raca, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sexo => $composableBuilder(
      column: $table.sexo, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dataNascimento => $composableBuilder(
      column: $table.dataNascimento,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pesoKg => $composableBuilder(
      column: $table.pesoKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get prenha => $composableBuilder(
      column: $table.prenha, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dataCobertura => $composableBuilder(
      column: $table.dataCobertura, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dataPartoPrevisto => $composableBuilder(
      column: $table.dataPartoPrevisto,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dataParto => $composableBuilder(
      column: $table.dataParto, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get qtdFilhotes => $composableBuilder(
      column: $table.qtdFilhotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get qtdFilhotesVivos => $composableBuilder(
      column: $table.qtdFilhotesVivos,
      builder: (column) => ColumnFilters(column));
}

class $$AnimaisTableOrderingComposer
    extends Composer<_$AppDatabase, $AnimaisTable> {
  $$AnimaisTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get loteId => $composableBuilder(
      column: $table.loteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brinco => $composableBuilder(
      column: $table.brinco, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipoAnimal => $composableBuilder(
      column: $table.tipoAnimal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoria => $composableBuilder(
      column: $table.categoria, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get raca => $composableBuilder(
      column: $table.raca, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sexo => $composableBuilder(
      column: $table.sexo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dataNascimento => $composableBuilder(
      column: $table.dataNascimento,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pesoKg => $composableBuilder(
      column: $table.pesoKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get prenha => $composableBuilder(
      column: $table.prenha, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dataCobertura => $composableBuilder(
      column: $table.dataCobertura,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dataPartoPrevisto => $composableBuilder(
      column: $table.dataPartoPrevisto,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dataParto => $composableBuilder(
      column: $table.dataParto, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get qtdFilhotes => $composableBuilder(
      column: $table.qtdFilhotes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get qtdFilhotesVivos => $composableBuilder(
      column: $table.qtdFilhotesVivos,
      builder: (column) => ColumnOrderings(column));
}

class $$AnimaisTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnimaisTable> {
  $$AnimaisTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get loteId =>
      $composableBuilder(column: $table.loteId, builder: (column) => column);

  GeneratedColumn<String> get brinco =>
      $composableBuilder(column: $table.brinco, builder: (column) => column);

  GeneratedColumn<String> get tipoAnimal => $composableBuilder(
      column: $table.tipoAnimal, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<String> get raca =>
      $composableBuilder(column: $table.raca, builder: (column) => column);

  GeneratedColumn<String> get sexo =>
      $composableBuilder(column: $table.sexo, builder: (column) => column);

  GeneratedColumn<DateTime> get dataNascimento => $composableBuilder(
      column: $table.dataNascimento, builder: (column) => column);

  GeneratedColumn<double> get pesoKg =>
      $composableBuilder(column: $table.pesoKg, builder: (column) => column);

  GeneratedColumn<bool> get prenha =>
      $composableBuilder(column: $table.prenha, builder: (column) => column);

  GeneratedColumn<DateTime> get dataCobertura => $composableBuilder(
      column: $table.dataCobertura, builder: (column) => column);

  GeneratedColumn<DateTime> get dataPartoPrevisto => $composableBuilder(
      column: $table.dataPartoPrevisto, builder: (column) => column);

  GeneratedColumn<DateTime> get dataParto =>
      $composableBuilder(column: $table.dataParto, builder: (column) => column);

  GeneratedColumn<int> get qtdFilhotes => $composableBuilder(
      column: $table.qtdFilhotes, builder: (column) => column);

  GeneratedColumn<int> get qtdFilhotesVivos => $composableBuilder(
      column: $table.qtdFilhotesVivos, builder: (column) => column);
}

class $$AnimaisTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AnimaisTable,
    Animal,
    $$AnimaisTableFilterComposer,
    $$AnimaisTableOrderingComposer,
    $$AnimaisTableAnnotationComposer,
    $$AnimaisTableCreateCompanionBuilder,
    $$AnimaisTableUpdateCompanionBuilder,
    (Animal, BaseReferences<_$AppDatabase, $AnimaisTable, Animal>),
    Animal,
    PrefetchHooks Function()> {
  $$AnimaisTableTableManager(_$AppDatabase db, $AnimaisTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimaisTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimaisTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnimaisTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> loteId = const Value.absent(),
            Value<String> brinco = const Value.absent(),
            Value<String> tipoAnimal = const Value.absent(),
            Value<String> categoria = const Value.absent(),
            Value<String> raca = const Value.absent(),
            Value<String> sexo = const Value.absent(),
            Value<DateTime?> dataNascimento = const Value.absent(),
            Value<double?> pesoKg = const Value.absent(),
            Value<bool?> prenha = const Value.absent(),
            Value<DateTime?> dataCobertura = const Value.absent(),
            Value<DateTime?> dataPartoPrevisto = const Value.absent(),
            Value<DateTime?> dataParto = const Value.absent(),
            Value<int?> qtdFilhotes = const Value.absent(),
            Value<int?> qtdFilhotesVivos = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimaisCompanion(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            loteId: loteId,
            brinco: brinco,
            tipoAnimal: tipoAnimal,
            categoria: categoria,
            raca: raca,
            sexo: sexo,
            dataNascimento: dataNascimento,
            pesoKg: pesoKg,
            prenha: prenha,
            dataCobertura: dataCobertura,
            dataPartoPrevisto: dataPartoPrevisto,
            dataParto: dataParto,
            qtdFilhotes: qtdFilhotes,
            qtdFilhotesVivos: qtdFilhotesVivos,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String deviceId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String loteId,
            required String brinco,
            Value<String> tipoAnimal = const Value.absent(),
            required String categoria,
            required String raca,
            Value<String> sexo = const Value.absent(),
            Value<DateTime?> dataNascimento = const Value.absent(),
            Value<double?> pesoKg = const Value.absent(),
            Value<bool?> prenha = const Value.absent(),
            Value<DateTime?> dataCobertura = const Value.absent(),
            Value<DateTime?> dataPartoPrevisto = const Value.absent(),
            Value<DateTime?> dataParto = const Value.absent(),
            Value<int?> qtdFilhotes = const Value.absent(),
            Value<int?> qtdFilhotesVivos = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimaisCompanion.insert(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            loteId: loteId,
            brinco: brinco,
            tipoAnimal: tipoAnimal,
            categoria: categoria,
            raca: raca,
            sexo: sexo,
            dataNascimento: dataNascimento,
            pesoKg: pesoKg,
            prenha: prenha,
            dataCobertura: dataCobertura,
            dataPartoPrevisto: dataPartoPrevisto,
            dataParto: dataParto,
            qtdFilhotes: qtdFilhotes,
            qtdFilhotesVivos: qtdFilhotesVivos,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AnimaisTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AnimaisTable,
    Animal,
    $$AnimaisTableFilterComposer,
    $$AnimaisTableOrderingComposer,
    $$AnimaisTableAnnotationComposer,
    $$AnimaisTableCreateCompanionBuilder,
    $$AnimaisTableUpdateCompanionBuilder,
    (Animal, BaseReferences<_$AppDatabase, $AnimaisTable, Animal>),
    Animal,
    PrefetchHooks Function()>;
typedef $$ProdutosTableCreateCompanionBuilder = ProdutosCompanion Function({
  required String id,
  Value<String?> serverId,
  Value<String> syncStatus,
  required String deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String tipo,
  required String nome,
  Value<int> carenciaDiasPadrao,
  required String unidade,
  Value<double> estoqueMinimo,
  Value<int> rowid,
});
typedef $$ProdutosTableUpdateCompanionBuilder = ProdutosCompanion Function({
  Value<String> id,
  Value<String?> serverId,
  Value<String> syncStatus,
  Value<String> deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> tipo,
  Value<String> nome,
  Value<int> carenciaDiasPadrao,
  Value<String> unidade,
  Value<double> estoqueMinimo,
  Value<int> rowid,
});

class $$ProdutosTableFilterComposer
    extends Composer<_$AppDatabase, $ProdutosTable> {
  $$ProdutosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nome => $composableBuilder(
      column: $table.nome, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get carenciaDiasPadrao => $composableBuilder(
      column: $table.carenciaDiasPadrao,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unidade => $composableBuilder(
      column: $table.unidade, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get estoqueMinimo => $composableBuilder(
      column: $table.estoqueMinimo, builder: (column) => ColumnFilters(column));
}

class $$ProdutosTableOrderingComposer
    extends Composer<_$AppDatabase, $ProdutosTable> {
  $$ProdutosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nome => $composableBuilder(
      column: $table.nome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get carenciaDiasPadrao => $composableBuilder(
      column: $table.carenciaDiasPadrao,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unidade => $composableBuilder(
      column: $table.unidade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get estoqueMinimo => $composableBuilder(
      column: $table.estoqueMinimo,
      builder: (column) => ColumnOrderings(column));
}

class $$ProdutosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProdutosTable> {
  $$ProdutosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<int> get carenciaDiasPadrao => $composableBuilder(
      column: $table.carenciaDiasPadrao, builder: (column) => column);

  GeneratedColumn<String> get unidade =>
      $composableBuilder(column: $table.unidade, builder: (column) => column);

  GeneratedColumn<double> get estoqueMinimo => $composableBuilder(
      column: $table.estoqueMinimo, builder: (column) => column);
}

class $$ProdutosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProdutosTable,
    Produto,
    $$ProdutosTableFilterComposer,
    $$ProdutosTableOrderingComposer,
    $$ProdutosTableAnnotationComposer,
    $$ProdutosTableCreateCompanionBuilder,
    $$ProdutosTableUpdateCompanionBuilder,
    (Produto, BaseReferences<_$AppDatabase, $ProdutosTable, Produto>),
    Produto,
    PrefetchHooks Function()> {
  $$ProdutosTableTableManager(_$AppDatabase db, $ProdutosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProdutosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProdutosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProdutosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> tipo = const Value.absent(),
            Value<String> nome = const Value.absent(),
            Value<int> carenciaDiasPadrao = const Value.absent(),
            Value<String> unidade = const Value.absent(),
            Value<double> estoqueMinimo = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProdutosCompanion(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            tipo: tipo,
            nome: nome,
            carenciaDiasPadrao: carenciaDiasPadrao,
            unidade: unidade,
            estoqueMinimo: estoqueMinimo,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String deviceId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String tipo,
            required String nome,
            Value<int> carenciaDiasPadrao = const Value.absent(),
            required String unidade,
            Value<double> estoqueMinimo = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProdutosCompanion.insert(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            tipo: tipo,
            nome: nome,
            carenciaDiasPadrao: carenciaDiasPadrao,
            unidade: unidade,
            estoqueMinimo: estoqueMinimo,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProdutosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProdutosTable,
    Produto,
    $$ProdutosTableFilterComposer,
    $$ProdutosTableOrderingComposer,
    $$ProdutosTableAnnotationComposer,
    $$ProdutosTableCreateCompanionBuilder,
    $$ProdutosTableUpdateCompanionBuilder,
    (Produto, BaseReferences<_$AppDatabase, $ProdutosTable, Produto>),
    Produto,
    PrefetchHooks Function()>;
typedef $$EstoqueMovimentosTableCreateCompanionBuilder
    = EstoqueMovimentosCompanion Function({
  required String id,
  Value<String?> serverId,
  Value<String> syncStatus,
  required String deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String produtoId,
  required String tipo,
  required double quantidade,
  Value<DateTime> dataMovimento,
  Value<DateTime?> dataValidade,
  required String origem,
  Value<int> rowid,
});
typedef $$EstoqueMovimentosTableUpdateCompanionBuilder
    = EstoqueMovimentosCompanion Function({
  Value<String> id,
  Value<String?> serverId,
  Value<String> syncStatus,
  Value<String> deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> produtoId,
  Value<String> tipo,
  Value<double> quantidade,
  Value<DateTime> dataMovimento,
  Value<DateTime?> dataValidade,
  Value<String> origem,
  Value<int> rowid,
});

class $$EstoqueMovimentosTableFilterComposer
    extends Composer<_$AppDatabase, $EstoqueMovimentosTable> {
  $$EstoqueMovimentosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get produtoId => $composableBuilder(
      column: $table.produtoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantidade => $composableBuilder(
      column: $table.quantidade, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dataMovimento => $composableBuilder(
      column: $table.dataMovimento, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dataValidade => $composableBuilder(
      column: $table.dataValidade, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get origem => $composableBuilder(
      column: $table.origem, builder: (column) => ColumnFilters(column));
}

class $$EstoqueMovimentosTableOrderingComposer
    extends Composer<_$AppDatabase, $EstoqueMovimentosTable> {
  $$EstoqueMovimentosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get produtoId => $composableBuilder(
      column: $table.produtoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantidade => $composableBuilder(
      column: $table.quantidade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dataMovimento => $composableBuilder(
      column: $table.dataMovimento,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dataValidade => $composableBuilder(
      column: $table.dataValidade,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get origem => $composableBuilder(
      column: $table.origem, builder: (column) => ColumnOrderings(column));
}

class $$EstoqueMovimentosTableAnnotationComposer
    extends Composer<_$AppDatabase, $EstoqueMovimentosTable> {
  $$EstoqueMovimentosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get produtoId =>
      $composableBuilder(column: $table.produtoId, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<double> get quantidade => $composableBuilder(
      column: $table.quantidade, builder: (column) => column);

  GeneratedColumn<DateTime> get dataMovimento => $composableBuilder(
      column: $table.dataMovimento, builder: (column) => column);

  GeneratedColumn<DateTime> get dataValidade => $composableBuilder(
      column: $table.dataValidade, builder: (column) => column);

  GeneratedColumn<String> get origem =>
      $composableBuilder(column: $table.origem, builder: (column) => column);
}

class $$EstoqueMovimentosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EstoqueMovimentosTable,
    EstoqueMovimento,
    $$EstoqueMovimentosTableFilterComposer,
    $$EstoqueMovimentosTableOrderingComposer,
    $$EstoqueMovimentosTableAnnotationComposer,
    $$EstoqueMovimentosTableCreateCompanionBuilder,
    $$EstoqueMovimentosTableUpdateCompanionBuilder,
    (
      EstoqueMovimento,
      BaseReferences<_$AppDatabase, $EstoqueMovimentosTable, EstoqueMovimento>
    ),
    EstoqueMovimento,
    PrefetchHooks Function()> {
  $$EstoqueMovimentosTableTableManager(
      _$AppDatabase db, $EstoqueMovimentosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EstoqueMovimentosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EstoqueMovimentosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EstoqueMovimentosTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> produtoId = const Value.absent(),
            Value<String> tipo = const Value.absent(),
            Value<double> quantidade = const Value.absent(),
            Value<DateTime> dataMovimento = const Value.absent(),
            Value<DateTime?> dataValidade = const Value.absent(),
            Value<String> origem = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EstoqueMovimentosCompanion(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            produtoId: produtoId,
            tipo: tipo,
            quantidade: quantidade,
            dataMovimento: dataMovimento,
            dataValidade: dataValidade,
            origem: origem,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String deviceId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String produtoId,
            required String tipo,
            required double quantidade,
            Value<DateTime> dataMovimento = const Value.absent(),
            Value<DateTime?> dataValidade = const Value.absent(),
            required String origem,
            Value<int> rowid = const Value.absent(),
          }) =>
              EstoqueMovimentosCompanion.insert(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            produtoId: produtoId,
            tipo: tipo,
            quantidade: quantidade,
            dataMovimento: dataMovimento,
            dataValidade: dataValidade,
            origem: origem,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EstoqueMovimentosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EstoqueMovimentosTable,
    EstoqueMovimento,
    $$EstoqueMovimentosTableFilterComposer,
    $$EstoqueMovimentosTableOrderingComposer,
    $$EstoqueMovimentosTableAnnotationComposer,
    $$EstoqueMovimentosTableCreateCompanionBuilder,
    $$EstoqueMovimentosTableUpdateCompanionBuilder,
    (
      EstoqueMovimento,
      BaseReferences<_$AppDatabase, $EstoqueMovimentosTable, EstoqueMovimento>
    ),
    EstoqueMovimento,
    PrefetchHooks Function()>;
typedef $$AplicacoesSanitariasTableCreateCompanionBuilder
    = AplicacoesSanitariasCompanion Function({
  required String id,
  Value<String?> serverId,
  Value<String> syncStatus,
  required String deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> animalId,
  Value<String?> loteId,
  required String produtoId,
  required double dose,
  required String via,
  required String motivo,
  Value<DateTime> dataAplicacao,
  Value<DateTime?> carenciaFimCalculada,
  Value<String?> fotoPath,
  Value<int> rowid,
});
typedef $$AplicacoesSanitariasTableUpdateCompanionBuilder
    = AplicacoesSanitariasCompanion Function({
  Value<String> id,
  Value<String?> serverId,
  Value<String> syncStatus,
  Value<String> deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> animalId,
  Value<String?> loteId,
  Value<String> produtoId,
  Value<double> dose,
  Value<String> via,
  Value<String> motivo,
  Value<DateTime> dataAplicacao,
  Value<DateTime?> carenciaFimCalculada,
  Value<String?> fotoPath,
  Value<int> rowid,
});

class $$AplicacoesSanitariasTableFilterComposer
    extends Composer<_$AppDatabase, $AplicacoesSanitariasTable> {
  $$AplicacoesSanitariasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get animalId => $composableBuilder(
      column: $table.animalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get loteId => $composableBuilder(
      column: $table.loteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get produtoId => $composableBuilder(
      column: $table.produtoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get dose => $composableBuilder(
      column: $table.dose, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get via => $composableBuilder(
      column: $table.via, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get motivo => $composableBuilder(
      column: $table.motivo, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dataAplicacao => $composableBuilder(
      column: $table.dataAplicacao, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get carenciaFimCalculada => $composableBuilder(
      column: $table.carenciaFimCalculada,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fotoPath => $composableBuilder(
      column: $table.fotoPath, builder: (column) => ColumnFilters(column));
}

class $$AplicacoesSanitariasTableOrderingComposer
    extends Composer<_$AppDatabase, $AplicacoesSanitariasTable> {
  $$AplicacoesSanitariasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get animalId => $composableBuilder(
      column: $table.animalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get loteId => $composableBuilder(
      column: $table.loteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get produtoId => $composableBuilder(
      column: $table.produtoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get dose => $composableBuilder(
      column: $table.dose, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get via => $composableBuilder(
      column: $table.via, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get motivo => $composableBuilder(
      column: $table.motivo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dataAplicacao => $composableBuilder(
      column: $table.dataAplicacao,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get carenciaFimCalculada => $composableBuilder(
      column: $table.carenciaFimCalculada,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fotoPath => $composableBuilder(
      column: $table.fotoPath, builder: (column) => ColumnOrderings(column));
}

class $$AplicacoesSanitariasTableAnnotationComposer
    extends Composer<_$AppDatabase, $AplicacoesSanitariasTable> {
  $$AplicacoesSanitariasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get animalId =>
      $composableBuilder(column: $table.animalId, builder: (column) => column);

  GeneratedColumn<String> get loteId =>
      $composableBuilder(column: $table.loteId, builder: (column) => column);

  GeneratedColumn<String> get produtoId =>
      $composableBuilder(column: $table.produtoId, builder: (column) => column);

  GeneratedColumn<double> get dose =>
      $composableBuilder(column: $table.dose, builder: (column) => column);

  GeneratedColumn<String> get via =>
      $composableBuilder(column: $table.via, builder: (column) => column);

  GeneratedColumn<String> get motivo =>
      $composableBuilder(column: $table.motivo, builder: (column) => column);

  GeneratedColumn<DateTime> get dataAplicacao => $composableBuilder(
      column: $table.dataAplicacao, builder: (column) => column);

  GeneratedColumn<DateTime> get carenciaFimCalculada => $composableBuilder(
      column: $table.carenciaFimCalculada, builder: (column) => column);

  GeneratedColumn<String> get fotoPath =>
      $composableBuilder(column: $table.fotoPath, builder: (column) => column);
}

class $$AplicacoesSanitariasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AplicacoesSanitariasTable,
    AplicacaoSanitaria,
    $$AplicacoesSanitariasTableFilterComposer,
    $$AplicacoesSanitariasTableOrderingComposer,
    $$AplicacoesSanitariasTableAnnotationComposer,
    $$AplicacoesSanitariasTableCreateCompanionBuilder,
    $$AplicacoesSanitariasTableUpdateCompanionBuilder,
    (
      AplicacaoSanitaria,
      BaseReferences<_$AppDatabase, $AplicacoesSanitariasTable,
          AplicacaoSanitaria>
    ),
    AplicacaoSanitaria,
    PrefetchHooks Function()> {
  $$AplicacoesSanitariasTableTableManager(
      _$AppDatabase db, $AplicacoesSanitariasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AplicacoesSanitariasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AplicacoesSanitariasTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AplicacoesSanitariasTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> animalId = const Value.absent(),
            Value<String?> loteId = const Value.absent(),
            Value<String> produtoId = const Value.absent(),
            Value<double> dose = const Value.absent(),
            Value<String> via = const Value.absent(),
            Value<String> motivo = const Value.absent(),
            Value<DateTime> dataAplicacao = const Value.absent(),
            Value<DateTime?> carenciaFimCalculada = const Value.absent(),
            Value<String?> fotoPath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AplicacoesSanitariasCompanion(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            animalId: animalId,
            loteId: loteId,
            produtoId: produtoId,
            dose: dose,
            via: via,
            motivo: motivo,
            dataAplicacao: dataAplicacao,
            carenciaFimCalculada: carenciaFimCalculada,
            fotoPath: fotoPath,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String deviceId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> animalId = const Value.absent(),
            Value<String?> loteId = const Value.absent(),
            required String produtoId,
            required double dose,
            required String via,
            required String motivo,
            Value<DateTime> dataAplicacao = const Value.absent(),
            Value<DateTime?> carenciaFimCalculada = const Value.absent(),
            Value<String?> fotoPath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AplicacoesSanitariasCompanion.insert(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            animalId: animalId,
            loteId: loteId,
            produtoId: produtoId,
            dose: dose,
            via: via,
            motivo: motivo,
            dataAplicacao: dataAplicacao,
            carenciaFimCalculada: carenciaFimCalculada,
            fotoPath: fotoPath,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AplicacoesSanitariasTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $AplicacoesSanitariasTable,
        AplicacaoSanitaria,
        $$AplicacoesSanitariasTableFilterComposer,
        $$AplicacoesSanitariasTableOrderingComposer,
        $$AplicacoesSanitariasTableAnnotationComposer,
        $$AplicacoesSanitariasTableCreateCompanionBuilder,
        $$AplicacoesSanitariasTableUpdateCompanionBuilder,
        (
          AplicacaoSanitaria,
          BaseReferences<_$AppDatabase, $AplicacoesSanitariasTable,
              AplicacaoSanitaria>
        ),
        AplicacaoSanitaria,
        PrefetchHooks Function()>;
typedef $$OcorrenciasSanitariasTableCreateCompanionBuilder
    = OcorrenciasSanitariasCompanion Function({
  required String id,
  Value<String?> serverId,
  Value<String> syncStatus,
  required String deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String animalId,
  required String tipo,
  required String descricao,
  Value<DateTime> dataOcorrencia,
  Value<String?> fotoPath,
  Value<int> rowid,
});
typedef $$OcorrenciasSanitariasTableUpdateCompanionBuilder
    = OcorrenciasSanitariasCompanion Function({
  Value<String> id,
  Value<String?> serverId,
  Value<String> syncStatus,
  Value<String> deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> animalId,
  Value<String> tipo,
  Value<String> descricao,
  Value<DateTime> dataOcorrencia,
  Value<String?> fotoPath,
  Value<int> rowid,
});

class $$OcorrenciasSanitariasTableFilterComposer
    extends Composer<_$AppDatabase, $OcorrenciasSanitariasTable> {
  $$OcorrenciasSanitariasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get animalId => $composableBuilder(
      column: $table.animalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descricao => $composableBuilder(
      column: $table.descricao, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dataOcorrencia => $composableBuilder(
      column: $table.dataOcorrencia,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fotoPath => $composableBuilder(
      column: $table.fotoPath, builder: (column) => ColumnFilters(column));
}

class $$OcorrenciasSanitariasTableOrderingComposer
    extends Composer<_$AppDatabase, $OcorrenciasSanitariasTable> {
  $$OcorrenciasSanitariasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get animalId => $composableBuilder(
      column: $table.animalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descricao => $composableBuilder(
      column: $table.descricao, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dataOcorrencia => $composableBuilder(
      column: $table.dataOcorrencia,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fotoPath => $composableBuilder(
      column: $table.fotoPath, builder: (column) => ColumnOrderings(column));
}

class $$OcorrenciasSanitariasTableAnnotationComposer
    extends Composer<_$AppDatabase, $OcorrenciasSanitariasTable> {
  $$OcorrenciasSanitariasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get animalId =>
      $composableBuilder(column: $table.animalId, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);

  GeneratedColumn<DateTime> get dataOcorrencia => $composableBuilder(
      column: $table.dataOcorrencia, builder: (column) => column);

  GeneratedColumn<String> get fotoPath =>
      $composableBuilder(column: $table.fotoPath, builder: (column) => column);
}

class $$OcorrenciasSanitariasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OcorrenciasSanitariasTable,
    OcorrenciaSanitaria,
    $$OcorrenciasSanitariasTableFilterComposer,
    $$OcorrenciasSanitariasTableOrderingComposer,
    $$OcorrenciasSanitariasTableAnnotationComposer,
    $$OcorrenciasSanitariasTableCreateCompanionBuilder,
    $$OcorrenciasSanitariasTableUpdateCompanionBuilder,
    (
      OcorrenciaSanitaria,
      BaseReferences<_$AppDatabase, $OcorrenciasSanitariasTable,
          OcorrenciaSanitaria>
    ),
    OcorrenciaSanitaria,
    PrefetchHooks Function()> {
  $$OcorrenciasSanitariasTableTableManager(
      _$AppDatabase db, $OcorrenciasSanitariasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OcorrenciasSanitariasTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$OcorrenciasSanitariasTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OcorrenciasSanitariasTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> animalId = const Value.absent(),
            Value<String> tipo = const Value.absent(),
            Value<String> descricao = const Value.absent(),
            Value<DateTime> dataOcorrencia = const Value.absent(),
            Value<String?> fotoPath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OcorrenciasSanitariasCompanion(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            animalId: animalId,
            tipo: tipo,
            descricao: descricao,
            dataOcorrencia: dataOcorrencia,
            fotoPath: fotoPath,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String deviceId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String animalId,
            required String tipo,
            required String descricao,
            Value<DateTime> dataOcorrencia = const Value.absent(),
            Value<String?> fotoPath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OcorrenciasSanitariasCompanion.insert(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            animalId: animalId,
            tipo: tipo,
            descricao: descricao,
            dataOcorrencia: dataOcorrencia,
            fotoPath: fotoPath,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OcorrenciasSanitariasTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $OcorrenciasSanitariasTable,
        OcorrenciaSanitaria,
        $$OcorrenciasSanitariasTableFilterComposer,
        $$OcorrenciasSanitariasTableOrderingComposer,
        $$OcorrenciasSanitariasTableAnnotationComposer,
        $$OcorrenciasSanitariasTableCreateCompanionBuilder,
        $$OcorrenciasSanitariasTableUpdateCompanionBuilder,
        (
          OcorrenciaSanitaria,
          BaseReferences<_$AppDatabase, $OcorrenciasSanitariasTable,
              OcorrenciaSanitaria>
        ),
        OcorrenciaSanitaria,
        PrefetchHooks Function()>;
typedef $$DietasTableCreateCompanionBuilder = DietasCompanion Function({
  required String id,
  Value<String?> serverId,
  Value<String> syncStatus,
  required String deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> loteId,
  Value<String?> categoria,
  required String produtoId,
  required double quantidadePorCabecaDia,
  Value<int> rowid,
});
typedef $$DietasTableUpdateCompanionBuilder = DietasCompanion Function({
  Value<String> id,
  Value<String?> serverId,
  Value<String> syncStatus,
  Value<String> deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> loteId,
  Value<String?> categoria,
  Value<String> produtoId,
  Value<double> quantidadePorCabecaDia,
  Value<int> rowid,
});

class $$DietasTableFilterComposer
    extends Composer<_$AppDatabase, $DietasTable> {
  $$DietasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get loteId => $composableBuilder(
      column: $table.loteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoria => $composableBuilder(
      column: $table.categoria, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get produtoId => $composableBuilder(
      column: $table.produtoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantidadePorCabecaDia => $composableBuilder(
      column: $table.quantidadePorCabecaDia,
      builder: (column) => ColumnFilters(column));
}

class $$DietasTableOrderingComposer
    extends Composer<_$AppDatabase, $DietasTable> {
  $$DietasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get loteId => $composableBuilder(
      column: $table.loteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoria => $composableBuilder(
      column: $table.categoria, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get produtoId => $composableBuilder(
      column: $table.produtoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantidadePorCabecaDia => $composableBuilder(
      column: $table.quantidadePorCabecaDia,
      builder: (column) => ColumnOrderings(column));
}

class $$DietasTableAnnotationComposer
    extends Composer<_$AppDatabase, $DietasTable> {
  $$DietasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get loteId =>
      $composableBuilder(column: $table.loteId, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<String> get produtoId =>
      $composableBuilder(column: $table.produtoId, builder: (column) => column);

  GeneratedColumn<double> get quantidadePorCabecaDia => $composableBuilder(
      column: $table.quantidadePorCabecaDia, builder: (column) => column);
}

class $$DietasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DietasTable,
    Dieta,
    $$DietasTableFilterComposer,
    $$DietasTableOrderingComposer,
    $$DietasTableAnnotationComposer,
    $$DietasTableCreateCompanionBuilder,
    $$DietasTableUpdateCompanionBuilder,
    (Dieta, BaseReferences<_$AppDatabase, $DietasTable, Dieta>),
    Dieta,
    PrefetchHooks Function()> {
  $$DietasTableTableManager(_$AppDatabase db, $DietasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DietasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DietasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DietasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> loteId = const Value.absent(),
            Value<String?> categoria = const Value.absent(),
            Value<String> produtoId = const Value.absent(),
            Value<double> quantidadePorCabecaDia = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DietasCompanion(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            loteId: loteId,
            categoria: categoria,
            produtoId: produtoId,
            quantidadePorCabecaDia: quantidadePorCabecaDia,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String deviceId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> loteId = const Value.absent(),
            Value<String?> categoria = const Value.absent(),
            required String produtoId,
            required double quantidadePorCabecaDia,
            Value<int> rowid = const Value.absent(),
          }) =>
              DietasCompanion.insert(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            loteId: loteId,
            categoria: categoria,
            produtoId: produtoId,
            quantidadePorCabecaDia: quantidadePorCabecaDia,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DietasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DietasTable,
    Dieta,
    $$DietasTableFilterComposer,
    $$DietasTableOrderingComposer,
    $$DietasTableAnnotationComposer,
    $$DietasTableCreateCompanionBuilder,
    $$DietasTableUpdateCompanionBuilder,
    (Dieta, BaseReferences<_$AppDatabase, $DietasTable, Dieta>),
    Dieta,
    PrefetchHooks Function()>;
typedef $$FornecimentosDietaTableCreateCompanionBuilder
    = FornecimentosDietaCompanion Function({
  required String id,
  Value<String?> serverId,
  Value<String> syncStatus,
  required String deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String loteId,
  required String dietaId,
  Value<DateTime> dataFornecimento,
  required double quantidadeFornecida,
  Value<int> rowid,
});
typedef $$FornecimentosDietaTableUpdateCompanionBuilder
    = FornecimentosDietaCompanion Function({
  Value<String> id,
  Value<String?> serverId,
  Value<String> syncStatus,
  Value<String> deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> loteId,
  Value<String> dietaId,
  Value<DateTime> dataFornecimento,
  Value<double> quantidadeFornecida,
  Value<int> rowid,
});

class $$FornecimentosDietaTableFilterComposer
    extends Composer<_$AppDatabase, $FornecimentosDietaTable> {
  $$FornecimentosDietaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get loteId => $composableBuilder(
      column: $table.loteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dietaId => $composableBuilder(
      column: $table.dietaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dataFornecimento => $composableBuilder(
      column: $table.dataFornecimento,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantidadeFornecida => $composableBuilder(
      column: $table.quantidadeFornecida,
      builder: (column) => ColumnFilters(column));
}

class $$FornecimentosDietaTableOrderingComposer
    extends Composer<_$AppDatabase, $FornecimentosDietaTable> {
  $$FornecimentosDietaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get loteId => $composableBuilder(
      column: $table.loteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dietaId => $composableBuilder(
      column: $table.dietaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dataFornecimento => $composableBuilder(
      column: $table.dataFornecimento,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantidadeFornecida => $composableBuilder(
      column: $table.quantidadeFornecida,
      builder: (column) => ColumnOrderings(column));
}

class $$FornecimentosDietaTableAnnotationComposer
    extends Composer<_$AppDatabase, $FornecimentosDietaTable> {
  $$FornecimentosDietaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get loteId =>
      $composableBuilder(column: $table.loteId, builder: (column) => column);

  GeneratedColumn<String> get dietaId =>
      $composableBuilder(column: $table.dietaId, builder: (column) => column);

  GeneratedColumn<DateTime> get dataFornecimento => $composableBuilder(
      column: $table.dataFornecimento, builder: (column) => column);

  GeneratedColumn<double> get quantidadeFornecida => $composableBuilder(
      column: $table.quantidadeFornecida, builder: (column) => column);
}

class $$FornecimentosDietaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FornecimentosDietaTable,
    FornecimentoDieta,
    $$FornecimentosDietaTableFilterComposer,
    $$FornecimentosDietaTableOrderingComposer,
    $$FornecimentosDietaTableAnnotationComposer,
    $$FornecimentosDietaTableCreateCompanionBuilder,
    $$FornecimentosDietaTableUpdateCompanionBuilder,
    (
      FornecimentoDieta,
      BaseReferences<_$AppDatabase, $FornecimentosDietaTable, FornecimentoDieta>
    ),
    FornecimentoDieta,
    PrefetchHooks Function()> {
  $$FornecimentosDietaTableTableManager(
      _$AppDatabase db, $FornecimentosDietaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FornecimentosDietaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FornecimentosDietaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FornecimentosDietaTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> loteId = const Value.absent(),
            Value<String> dietaId = const Value.absent(),
            Value<DateTime> dataFornecimento = const Value.absent(),
            Value<double> quantidadeFornecida = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FornecimentosDietaCompanion(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            loteId: loteId,
            dietaId: dietaId,
            dataFornecimento: dataFornecimento,
            quantidadeFornecida: quantidadeFornecida,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String deviceId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String loteId,
            required String dietaId,
            Value<DateTime> dataFornecimento = const Value.absent(),
            required double quantidadeFornecida,
            Value<int> rowid = const Value.absent(),
          }) =>
              FornecimentosDietaCompanion.insert(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            loteId: loteId,
            dietaId: dietaId,
            dataFornecimento: dataFornecimento,
            quantidadeFornecida: quantidadeFornecida,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FornecimentosDietaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FornecimentosDietaTable,
    FornecimentoDieta,
    $$FornecimentosDietaTableFilterComposer,
    $$FornecimentosDietaTableOrderingComposer,
    $$FornecimentosDietaTableAnnotationComposer,
    $$FornecimentosDietaTableCreateCompanionBuilder,
    $$FornecimentosDietaTableUpdateCompanionBuilder,
    (
      FornecimentoDieta,
      BaseReferences<_$AppDatabase, $FornecimentosDietaTable, FornecimentoDieta>
    ),
    FornecimentoDieta,
    PrefetchHooks Function()>;
typedef $$SyncQueueItemsTableCreateCompanionBuilder = SyncQueueItemsCompanion
    Function({
  Value<int> id,
  required String entityType,
  required String entityId,
  required String action,
  required String payload,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<String?> lastError,
  required String deviceId,
});
typedef $$SyncQueueItemsTableUpdateCompanionBuilder = SyncQueueItemsCompanion
    Function({
  Value<int> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> action,
  Value<String> payload,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<String?> lastError,
  Value<String> deviceId,
});

class $$SyncQueueItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueItemsTable> {
  $$SyncQueueItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueItemsTable> {
  $$SyncQueueItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueItemsTable> {
  $$SyncQueueItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$SyncQueueItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueItemsTable,
    SyncQueueItem,
    $$SyncQueueItemsTableFilterComposer,
    $$SyncQueueItemsTableOrderingComposer,
    $$SyncQueueItemsTableAnnotationComposer,
    $$SyncQueueItemsTableCreateCompanionBuilder,
    $$SyncQueueItemsTableUpdateCompanionBuilder,
    (
      SyncQueueItem,
      BaseReferences<_$AppDatabase, $SyncQueueItemsTable, SyncQueueItem>
    ),
    SyncQueueItem,
    PrefetchHooks Function()> {
  $$SyncQueueItemsTableTableManager(
      _$AppDatabase db, $SyncQueueItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
          }) =>
              SyncQueueItemsCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            action: action,
            payload: payload,
            status: status,
            createdAt: createdAt,
            retryCount: retryCount,
            lastError: lastError,
            deviceId: deviceId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String entityType,
            required String entityId,
            required String action,
            required String payload,
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            required String deviceId,
          }) =>
              SyncQueueItemsCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            action: action,
            payload: payload,
            status: status,
            createdAt: createdAt,
            retryCount: retryCount,
            lastError: lastError,
            deviceId: deviceId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueItemsTable,
    SyncQueueItem,
    $$SyncQueueItemsTableFilterComposer,
    $$SyncQueueItemsTableOrderingComposer,
    $$SyncQueueItemsTableAnnotationComposer,
    $$SyncQueueItemsTableCreateCompanionBuilder,
    $$SyncQueueItemsTableUpdateCompanionBuilder,
    (
      SyncQueueItem,
      BaseReferences<_$AppDatabase, $SyncQueueItemsTable, SyncQueueItem>
    ),
    SyncQueueItem,
    PrefetchHooks Function()>;
typedef $$UsuariosTableCreateCompanionBuilder = UsuariosCompanion Function({
  required String id,
  Value<String?> serverId,
  Value<String> syncStatus,
  required String deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String nome,
  required String cpfCnpj,
  required String senhaHash,
  Value<String> perfil,
  Value<String?> email,
  Value<String?> telefone,
  Value<bool> emailVerificado,
  Value<int> rowid,
});
typedef $$UsuariosTableUpdateCompanionBuilder = UsuariosCompanion Function({
  Value<String> id,
  Value<String?> serverId,
  Value<String> syncStatus,
  Value<String> deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> nome,
  Value<String> cpfCnpj,
  Value<String> senhaHash,
  Value<String> perfil,
  Value<String?> email,
  Value<String?> telefone,
  Value<bool> emailVerificado,
  Value<int> rowid,
});

class $$UsuariosTableFilterComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nome => $composableBuilder(
      column: $table.nome, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cpfCnpj => $composableBuilder(
      column: $table.cpfCnpj, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get senhaHash => $composableBuilder(
      column: $table.senhaHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get perfil => $composableBuilder(
      column: $table.perfil, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telefone => $composableBuilder(
      column: $table.telefone, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get emailVerificado => $composableBuilder(
      column: $table.emailVerificado,
      builder: (column) => ColumnFilters(column));
}

class $$UsuariosTableOrderingComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nome => $composableBuilder(
      column: $table.nome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cpfCnpj => $composableBuilder(
      column: $table.cpfCnpj, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get senhaHash => $composableBuilder(
      column: $table.senhaHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get perfil => $composableBuilder(
      column: $table.perfil, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telefone => $composableBuilder(
      column: $table.telefone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get emailVerificado => $composableBuilder(
      column: $table.emailVerificado,
      builder: (column) => ColumnOrderings(column));
}

class $$UsuariosTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get cpfCnpj =>
      $composableBuilder(column: $table.cpfCnpj, builder: (column) => column);

  GeneratedColumn<String> get senhaHash =>
      $composableBuilder(column: $table.senhaHash, builder: (column) => column);

  GeneratedColumn<String> get perfil =>
      $composableBuilder(column: $table.perfil, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get telefone =>
      $composableBuilder(column: $table.telefone, builder: (column) => column);

  GeneratedColumn<bool> get emailVerificado => $composableBuilder(
      column: $table.emailVerificado, builder: (column) => column);
}

class $$UsuariosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsuariosTable,
    Usuario,
    $$UsuariosTableFilterComposer,
    $$UsuariosTableOrderingComposer,
    $$UsuariosTableAnnotationComposer,
    $$UsuariosTableCreateCompanionBuilder,
    $$UsuariosTableUpdateCompanionBuilder,
    (Usuario, BaseReferences<_$AppDatabase, $UsuariosTable, Usuario>),
    Usuario,
    PrefetchHooks Function()> {
  $$UsuariosTableTableManager(_$AppDatabase db, $UsuariosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsuariosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsuariosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsuariosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> nome = const Value.absent(),
            Value<String> cpfCnpj = const Value.absent(),
            Value<String> senhaHash = const Value.absent(),
            Value<String> perfil = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> telefone = const Value.absent(),
            Value<bool> emailVerificado = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsuariosCompanion(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            nome: nome,
            cpfCnpj: cpfCnpj,
            senhaHash: senhaHash,
            perfil: perfil,
            email: email,
            telefone: telefone,
            emailVerificado: emailVerificado,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String deviceId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String nome,
            required String cpfCnpj,
            required String senhaHash,
            Value<String> perfil = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> telefone = const Value.absent(),
            Value<bool> emailVerificado = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsuariosCompanion.insert(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            nome: nome,
            cpfCnpj: cpfCnpj,
            senhaHash: senhaHash,
            perfil: perfil,
            email: email,
            telefone: telefone,
            emailVerificado: emailVerificado,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsuariosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsuariosTable,
    Usuario,
    $$UsuariosTableFilterComposer,
    $$UsuariosTableOrderingComposer,
    $$UsuariosTableAnnotationComposer,
    $$UsuariosTableCreateCompanionBuilder,
    $$UsuariosTableUpdateCompanionBuilder,
    (Usuario, BaseReferences<_$AppDatabase, $UsuariosTable, Usuario>),
    Usuario,
    PrefetchHooks Function()>;
typedef $$PesagensTableCreateCompanionBuilder = PesagensCompanion Function({
  required String id,
  Value<String?> serverId,
  Value<String> syncStatus,
  required String deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String animalId,
  required double peso,
  Value<DateTime> dataPesagem,
  Value<int> rowid,
});
typedef $$PesagensTableUpdateCompanionBuilder = PesagensCompanion Function({
  Value<String> id,
  Value<String?> serverId,
  Value<String> syncStatus,
  Value<String> deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> animalId,
  Value<double> peso,
  Value<DateTime> dataPesagem,
  Value<int> rowid,
});

class $$PesagensTableFilterComposer
    extends Composer<_$AppDatabase, $PesagensTable> {
  $$PesagensTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get animalId => $composableBuilder(
      column: $table.animalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get peso => $composableBuilder(
      column: $table.peso, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dataPesagem => $composableBuilder(
      column: $table.dataPesagem, builder: (column) => ColumnFilters(column));
}

class $$PesagensTableOrderingComposer
    extends Composer<_$AppDatabase, $PesagensTable> {
  $$PesagensTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get animalId => $composableBuilder(
      column: $table.animalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get peso => $composableBuilder(
      column: $table.peso, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dataPesagem => $composableBuilder(
      column: $table.dataPesagem, builder: (column) => ColumnOrderings(column));
}

class $$PesagensTableAnnotationComposer
    extends Composer<_$AppDatabase, $PesagensTable> {
  $$PesagensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get animalId =>
      $composableBuilder(column: $table.animalId, builder: (column) => column);

  GeneratedColumn<double> get peso =>
      $composableBuilder(column: $table.peso, builder: (column) => column);

  GeneratedColumn<DateTime> get dataPesagem => $composableBuilder(
      column: $table.dataPesagem, builder: (column) => column);
}

class $$PesagensTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PesagensTable,
    Pesagem,
    $$PesagensTableFilterComposer,
    $$PesagensTableOrderingComposer,
    $$PesagensTableAnnotationComposer,
    $$PesagensTableCreateCompanionBuilder,
    $$PesagensTableUpdateCompanionBuilder,
    (Pesagem, BaseReferences<_$AppDatabase, $PesagensTable, Pesagem>),
    Pesagem,
    PrefetchHooks Function()> {
  $$PesagensTableTableManager(_$AppDatabase db, $PesagensTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PesagensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PesagensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PesagensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> animalId = const Value.absent(),
            Value<double> peso = const Value.absent(),
            Value<DateTime> dataPesagem = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PesagensCompanion(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            animalId: animalId,
            peso: peso,
            dataPesagem: dataPesagem,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String deviceId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String animalId,
            required double peso,
            Value<DateTime> dataPesagem = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PesagensCompanion.insert(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            animalId: animalId,
            peso: peso,
            dataPesagem: dataPesagem,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PesagensTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PesagensTable,
    Pesagem,
    $$PesagensTableFilterComposer,
    $$PesagensTableOrderingComposer,
    $$PesagensTableAnnotationComposer,
    $$PesagensTableCreateCompanionBuilder,
    $$PesagensTableUpdateCompanionBuilder,
    (Pesagem, BaseReferences<_$AppDatabase, $PesagensTable, Pesagem>),
    Pesagem,
    PrefetchHooks Function()>;
typedef $$LancamentosFinanceirosTableCreateCompanionBuilder
    = LancamentosFinanceirosCompanion Function({
  required String id,
  Value<String?> serverId,
  Value<String> syncStatus,
  required String deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  required String fazendaId,
  required String tipo,
  required String descricao,
  required String categoria,
  required double valor,
  required DateTime dataVencimento,
  Value<DateTime?> dataPagamento,
  required String status,
  Value<int> rowid,
});
typedef $$LancamentosFinanceirosTableUpdateCompanionBuilder
    = LancamentosFinanceirosCompanion Function({
  Value<String> id,
  Value<String?> serverId,
  Value<String> syncStatus,
  Value<String> deviceId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> fazendaId,
  Value<String> tipo,
  Value<String> descricao,
  Value<String> categoria,
  Value<double> valor,
  Value<DateTime> dataVencimento,
  Value<DateTime?> dataPagamento,
  Value<String> status,
  Value<int> rowid,
});

class $$LancamentosFinanceirosTableFilterComposer
    extends Composer<_$AppDatabase, $LancamentosFinanceirosTable> {
  $$LancamentosFinanceirosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fazendaId => $composableBuilder(
      column: $table.fazendaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descricao => $composableBuilder(
      column: $table.descricao, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoria => $composableBuilder(
      column: $table.categoria, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get valor => $composableBuilder(
      column: $table.valor, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dataVencimento => $composableBuilder(
      column: $table.dataVencimento,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dataPagamento => $composableBuilder(
      column: $table.dataPagamento, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$LancamentosFinanceirosTableOrderingComposer
    extends Composer<_$AppDatabase, $LancamentosFinanceirosTable> {
  $$LancamentosFinanceirosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fazendaId => $composableBuilder(
      column: $table.fazendaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descricao => $composableBuilder(
      column: $table.descricao, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoria => $composableBuilder(
      column: $table.categoria, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get valor => $composableBuilder(
      column: $table.valor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dataVencimento => $composableBuilder(
      column: $table.dataVencimento,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dataPagamento => $composableBuilder(
      column: $table.dataPagamento,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$LancamentosFinanceirosTableAnnotationComposer
    extends Composer<_$AppDatabase, $LancamentosFinanceirosTable> {
  $$LancamentosFinanceirosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get fazendaId =>
      $composableBuilder(column: $table.fazendaId, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<double> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<DateTime> get dataVencimento => $composableBuilder(
      column: $table.dataVencimento, builder: (column) => column);

  GeneratedColumn<DateTime> get dataPagamento => $composableBuilder(
      column: $table.dataPagamento, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$LancamentosFinanceirosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LancamentosFinanceirosTable,
    LancamentoFinanceiro,
    $$LancamentosFinanceirosTableFilterComposer,
    $$LancamentosFinanceirosTableOrderingComposer,
    $$LancamentosFinanceirosTableAnnotationComposer,
    $$LancamentosFinanceirosTableCreateCompanionBuilder,
    $$LancamentosFinanceirosTableUpdateCompanionBuilder,
    (
      LancamentoFinanceiro,
      BaseReferences<_$AppDatabase, $LancamentosFinanceirosTable,
          LancamentoFinanceiro>
    ),
    LancamentoFinanceiro,
    PrefetchHooks Function()> {
  $$LancamentosFinanceirosTableTableManager(
      _$AppDatabase db, $LancamentosFinanceirosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LancamentosFinanceirosTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LancamentosFinanceirosTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LancamentosFinanceirosTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> fazendaId = const Value.absent(),
            Value<String> tipo = const Value.absent(),
            Value<String> descricao = const Value.absent(),
            Value<String> categoria = const Value.absent(),
            Value<double> valor = const Value.absent(),
            Value<DateTime> dataVencimento = const Value.absent(),
            Value<DateTime?> dataPagamento = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LancamentosFinanceirosCompanion(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            fazendaId: fazendaId,
            tipo: tipo,
            descricao: descricao,
            categoria: categoria,
            valor: valor,
            dataVencimento: dataVencimento,
            dataPagamento: dataPagamento,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String deviceId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            required String fazendaId,
            required String tipo,
            required String descricao,
            required String categoria,
            required double valor,
            required DateTime dataVencimento,
            Value<DateTime?> dataPagamento = const Value.absent(),
            required String status,
            Value<int> rowid = const Value.absent(),
          }) =>
              LancamentosFinanceirosCompanion.insert(
            id: id,
            serverId: serverId,
            syncStatus: syncStatus,
            deviceId: deviceId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            fazendaId: fazendaId,
            tipo: tipo,
            descricao: descricao,
            categoria: categoria,
            valor: valor,
            dataVencimento: dataVencimento,
            dataPagamento: dataPagamento,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LancamentosFinanceirosTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LancamentosFinanceirosTable,
        LancamentoFinanceiro,
        $$LancamentosFinanceirosTableFilterComposer,
        $$LancamentosFinanceirosTableOrderingComposer,
        $$LancamentosFinanceirosTableAnnotationComposer,
        $$LancamentosFinanceirosTableCreateCompanionBuilder,
        $$LancamentosFinanceirosTableUpdateCompanionBuilder,
        (
          LancamentoFinanceiro,
          BaseReferences<_$AppDatabase, $LancamentosFinanceirosTable,
              LancamentoFinanceiro>
        ),
        LancamentoFinanceiro,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FazendasTableTableManager get fazendas =>
      $$FazendasTableTableManager(_db, _db.fazendas);
  $$PiquetesTableTableManager get piquetes =>
      $$PiquetesTableTableManager(_db, _db.piquetes);
  $$LotesTableTableManager get lotes =>
      $$LotesTableTableManager(_db, _db.lotes);
  $$AnimaisTableTableManager get animais =>
      $$AnimaisTableTableManager(_db, _db.animais);
  $$ProdutosTableTableManager get produtos =>
      $$ProdutosTableTableManager(_db, _db.produtos);
  $$EstoqueMovimentosTableTableManager get estoqueMovimentos =>
      $$EstoqueMovimentosTableTableManager(_db, _db.estoqueMovimentos);
  $$AplicacoesSanitariasTableTableManager get aplicacoesSanitarias =>
      $$AplicacoesSanitariasTableTableManager(_db, _db.aplicacoesSanitarias);
  $$OcorrenciasSanitariasTableTableManager get ocorrenciasSanitarias =>
      $$OcorrenciasSanitariasTableTableManager(_db, _db.ocorrenciasSanitarias);
  $$DietasTableTableManager get dietas =>
      $$DietasTableTableManager(_db, _db.dietas);
  $$FornecimentosDietaTableTableManager get fornecimentosDieta =>
      $$FornecimentosDietaTableTableManager(_db, _db.fornecimentosDieta);
  $$SyncQueueItemsTableTableManager get syncQueueItems =>
      $$SyncQueueItemsTableTableManager(_db, _db.syncQueueItems);
  $$UsuariosTableTableManager get usuarios =>
      $$UsuariosTableTableManager(_db, _db.usuarios);
  $$PesagensTableTableManager get pesagens =>
      $$PesagensTableTableManager(_db, _db.pesagens);
  $$LancamentosFinanceirosTableTableManager get lancamentosFinanceiros =>
      $$LancamentosFinanceirosTableTableManager(
          _db, _db.lancamentosFinanceiros);
}
