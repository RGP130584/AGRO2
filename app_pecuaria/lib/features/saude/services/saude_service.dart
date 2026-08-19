import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/device_info_provider.dart';

/// Provider para injetar o SaudeService na aplicação.
final saudeServiceProvider = Provider<SaudeService>((ref) {
  final db = ref.watch(databaseProvider);
  // Usamos watch aqui para que o provider seja reconstruído se o deviceId mudar.
  final deviceId = ref.watch(deviceIdProvider).asData?.value;

  // Se o deviceId ainda não estiver disponível, o serviço não pode ser criado.
  if (deviceId == null) {
    throw Exception("DeviceId não está disponível para o SaudeService");
  }

  return SaudeService(db, deviceId);
});

/// Classe de serviço principal do módulo de Saúde Animal.
/// Encapsula as complexas regras de negócio de aplicação sanitária:
/// cálculo automático de período de carência (withdrawal period) e
/// reflexo no módulo de estoque através da baixa do produto aplicado.
class SaudeService {
  final AppDatabase _db;
  final String _deviceId;
  final Uuid _uuid = const Uuid();

  SaudeService(this._db, this._deviceId);

  /// Registra uma aplicação sanitária para um animal ou um lote inteiro, executando
  /// duas operações de forma atômica (dentro da mesma transação local):
  /// 1. Salva o registro da aplicação e prevê automaticamente a [carenciaFim].
  /// 2. Abate imediatamente a dose equivalente do estoque do [produto].
  ///
  /// Retorna a data calculada de fim da carência (ou null se o produto não tiver carência).
  Future<DateTime?> registrarAplicacao({
    String? animalId,
    String? loteId,
    required Produto produto,
    required double dose,
    required String via,
    required String motivo,
  }) async {
    final now = DateTime.now();
    DateTime? carenciaFim;
    if (produto.carenciaDiasPadrao > 0) {
      carenciaFim = now.add(Duration(days: produto.carenciaDiasPadrao));
    }

    await _db.transaction(() async {
      await _db.into(_db.aplicacoesSanitarias).insert(AplicacoesSanitariasCompanion.insert(
          id: _uuid.v4(), animalId: Value(animalId), loteId: Value(loteId), produtoId: produto.id, dose: dose, via: via, motivo: motivo,
          dataAplicacao: Value(now), carenciaFimCalculada: Value(carenciaFim), deviceId: _deviceId));

      await _db.into(_db.estoqueMovimentos).insert(EstoqueMovimentosCompanion.insert(
          id: _uuid.v4(), produtoId: produto.id, tipo: 'saida', quantidade: dose,
          origem: 'aplicacao', deviceId: _deviceId));
    });

    return carenciaFim;
  }
}