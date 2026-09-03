import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

import 'tables/rebanho_tables.dart';
import 'tables/estoque_tables.dart';
import 'tables/saude_tables.dart';
import 'tables/nutricao_tables.dart';
import 'tables/sync_tables.dart';
import 'tables/auth_tables.dart';
import 'tables/financeiro_tables.dart';

// O código gerado pelo Drift irá para database.g.dart (após rodar build_runner)
part 'database.g.dart';

@DriftDatabase(tables: [
  Fazendas, Piquetes, Lotes, Animais,
  Produtos, EstoqueMovimentos,
  AplicacoesSanitarias, OcorrenciasSanitarias,
  Dietas, FornecimentosDieta,
  SyncQueueItems,
  Usuarios,
  Pesagens,
  LancamentosFinanceiros
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(usuarios, usuarios.email);
          await m.addColumn(usuarios, usuarios.telefone);
          await m.addColumn(usuarios, usuarios.emailVerificado);
        }
        if (from < 3) {
          await m.createTable(ocorrenciasSanitarias);
          await m.createTable(lancamentosFinanceiros);
          await m.addColumn(estoqueMovimentos, estoqueMovimentos.dataValidade);
        }
        if (from < 4) {
          await m.addColumn(fazendas, fazendas.logoBase64);
        }
      },
      beforeOpen: (details) async {
        // PRAGMA foreign_keys não é suportado no WASM (web)
        if (!kIsWeb) {
          await customStatement('PRAGMA foreign_keys = ON');
        }
      },
    );
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'pecuaria',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}

