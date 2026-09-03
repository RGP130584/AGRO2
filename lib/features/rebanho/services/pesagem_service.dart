import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/device_info_provider.dart';
import '../models/pesagem_com_gmd.dart';

final pesagemServiceProvider = Provider<PesagemService>((ref) {
  final db = ref.watch(databaseProvider);
  final deviceId = ref.watch(deviceIdProvider).asData?.value;
  if (deviceId == null) throw Exception('Device ID não disponível');
  return PesagemService(db, deviceId);
});

/// Serviço de domínio focado na funcionalidade de Pesagem de animais e lotes.
/// Responsável por registrar pesos e calcular a métrica Zootécnica GMD
/// (Ganho Médio Diário), essencial para a gestão do crescimento animal.
class PesagemService {
  final AppDatabase _db;
  final String _deviceId;

  PesagemService(this._db, this._deviceId);

  /// Registra uma nova pesagem para o animal específico e atualiza
  /// automaticamente seu `pesoKg` mais recente. Ambas operações são persistidas
  /// localmente. (Nota: Para offline, esta gravação deveria idealmente entrar
  /// na fila de sincronização - Outbox).
  Future<void> registrarPesagem(String animalId, double peso) async {
    await _db.into(_db.pesagens).insert(PesagensCompanion.insert(
      id: const Uuid().v4(),
      animalId: animalId,
      peso: peso,
      deviceId: _deviceId,
    ));
    
    // Atualiza o peso atual no animal
    await (_db.update(_db.animais)..where((a) => a.id.equals(animalId)))
        .write(AnimaisCompanion(pesoKg: Value(peso)));
  }

  /// Acompanha o histórico de pesagens em tempo real para um animal específico.
  /// Calcula "on the fly" o Ganho Médio Diário (GMD) comparando cada pesagem
  /// com a imediatamente anterior e os dias decorridos, garantindo que
  /// dados sempre fiquem atualizados visualmente sem requerer re-cálculos pesados.
  Stream<List<PesagemComGMD>> watchHistoricoComGMD(String animalId) {
    return (_db.select(_db.pesagens)
          ..where((p) => p.animalId.equals(animalId))
          ..orderBy([(p) => OrderingTerm(expression: p.dataPesagem)]))
        .watch()
        .map((pesagens) {
      final result = <PesagemComGMD>[];
      for (int i = 0; i < pesagens.length; i++) {
        double? gmd;
        if (i > 0) {
          final atual = pesagens[i];
          final anterior = pesagens[i - 1];
          final diffDias = atual.dataPesagem.difference(anterior.dataPesagem).inDays;
          if (diffDias > 0) {
            gmd = (atual.peso - anterior.peso) / diffDias;
          }
        }
        result.add(PesagemComGMD(pesagem: pesagens[i], gmd: gmd));
      }
      return result.reversed.toList();
    });
  }
}
