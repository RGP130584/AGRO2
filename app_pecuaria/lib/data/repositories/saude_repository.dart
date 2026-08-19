import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../local/database.dart';

class SaudeRepository {
  final AppDatabase db;
  final uuid = const Uuid();

  SaudeRepository(this.db);

  /// Registra uma aplicação sanitária, calcula carência e deduz estoque automaticamente
  Future<void> registrarAplicacao({
    String? animalId,
    String? loteId,
    required Produto produto,
    required double dose,
    required String via,
    required String motivo,
    required String deviceId,
  }) async {
    // A transação garante que ou tudo salva, ou nada salva.
    await db.transaction(() async {
      final now = DateTime.now();
      
      // Regra de negócio: Cálculo local da carência
      DateTime? carenciaFim;
      if (produto.carenciaDiasPadrao > 0) {
        carenciaFim = now.add(Duration(days: produto.carenciaDiasPadrao));
      }

      final aplicacaoId = uuid.v4();

      // 1. Grava a aplicação sanitária
      await db.into(db.aplicacoesSanitarias).insert(
        AplicacoesSanitariasCompanion.insert(
          id: aplicacaoId,
          animalId: Value(animalId),
          loteId: Value(loteId),
          produtoId: produto.id,
          dose: dose,
          via: via,
          motivo: motivo,
          dataAplicacao: Value(now),
          carenciaFimCalculada: Value(carenciaFim),
          deviceId: deviceId,
        ),
      );

      // 2. Grava a baixa automática de estoque
      await db.into(db.estoqueMovimentos).insert(
        EstoqueMovimentosCompanion.insert(
          id: uuid.v4(),
          produtoId: produto.id,
          tipo: 'saida',
          quantidade: dose,
          dataMovimento: Value(now),
          origem: 'aplicacao',
          deviceId: deviceId,
        ),
      );
    });
  }
}
