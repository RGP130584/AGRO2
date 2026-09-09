import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';

final relatorioRebanhoServiceProvider = Provider<RelatorioRebanhoService>((ref) {
  return RelatorioRebanhoService(ref.watch(databaseProvider));
});

class EfetivoLote {
  final String loteNome;
  final String loteCategoria;
  final String? piqueteNome;
  final int totalAnimais;
  final int machos;
  final int femeas;
  EfetivoLote({
    required this.loteNome,
    required this.loteCategoria,
    this.piqueteNome,
    required this.totalAnimais,
    required this.machos,
    required this.femeas,
  });
}

class ComposicaoItem {
  final String label;
  final int quantidade;
  final double percentual;
  ComposicaoItem({required this.label, required this.quantidade, required this.percentual});
}

class GmdLote {
  final String loteId;
  final String loteNome;
  final double gmdMedio;
  final double pesoMedioAtual;
  final int totalPesagens;
  GmdLote({
    required this.loteId,
    required this.loteNome,
    required this.gmdMedio,
    required this.pesoMedioAtual,
    required this.totalPesagens,
  });
}

class AnimaisEmCarencia {
  final Animal animal;
  final String produtoNome;
  final DateTime carenciaFim;
  final int diasRestantes;
  AnimaisEmCarencia({
    required this.animal,
    required this.produtoNome,
    required this.carenciaFim,
    required this.diasRestantes,
  });
}

class RelatorioRebanhoService {
  final AppDatabase _db;

  RelatorioRebanhoService(this._db);

  // 1.1 Efetivo do Rebanho por lote/piquete
  Future<List<EfetivoLote>> getEfetivoRebanho(String fazendaId) async {
    final lotes = await (_db.select(_db.lotes)..where((l) => l.fazendaId.equals(fazendaId))).get();
    final result = <EfetivoLote>[];

    for (final lote in lotes) {
      final animais = await (_db.select(_db.animais)
            ..where((a) => a.loteId.equals(lote.id) & a.deletedAt.isNull()))
          .get();

      if (animais.isEmpty) continue;

      String? piqueteNome;
      if (lote.piqueteId != null) {
        final piquete = await (_db.select(_db.piquetes)..where((p) => p.id.equals(lote.piqueteId!))).getSingleOrNull();
        piqueteNome = piquete?.nome;
      }

      result.add(EfetivoLote(
        loteNome: lote.nome,
        loteCategoria: lote.categoria,
        piqueteNome: piqueteNome,
        totalAnimais: animais.length,
        machos: animais.where((a) => a.sexo == 'M').length,
        femeas: animais.where((a) => a.sexo == 'F').length,
      ));
    }

    return result;
  }

  // 1.2 Composição por categoria e raça
  Future<Map<String, List<ComposicaoItem>>> getComposicaoRebanho(String fazendaId) async {
    final animais = await (_db.select(_db.animais)
          ..where((a) =>
              a.deletedAt.isNull() &
              drift.CustomExpression('a.lote_id IN (SELECT id FROM lotes WHERE fazenda_id = ?)'.replaceAll('?', "'$fazendaId'"))))
        .get();

    // Agrupamentos por categoria
    final porCategoria = <String, int>{};
    final porRaca = <String, int>{};
    final porSexo = {'Macho': 0, 'Fêmea': 0};

    for (final a in animais) {
      porCategoria[a.categoria] = (porCategoria[a.categoria] ?? 0) + 1;
      porRaca[a.raca] = (porRaca[a.raca] ?? 0) + 1;
      if (a.sexo == 'M') {
        porSexo['Macho'] = porSexo['Macho']! + 1;
      } else {
        porSexo['Fêmea'] = porSexo['Fêmea']! + 1;
      }
    }

    final total = animais.length.toDouble();

    List<ComposicaoItem> toItems(Map<String, int> map) => map.entries
        .map((e) => ComposicaoItem(label: e.key, quantidade: e.value, percentual: total > 0 ? e.value / total * 100 : 0))
        .toList()
      ..sort((a, b) => b.quantidade.compareTo(a.quantidade));

    return {
      'categoria': toItems(porCategoria),
      'raca': toItems(porRaca),
      'sexo': toItems(porSexo),
    };
  }

  // 1.4 Partos previstos nos próximos N dias
  Stream<List<Animal>> watchPartosPrevistos(String fazendaId, {int diasAFrente = 30}) {
    final limite = DateTime.now().add(Duration(days: diasAFrente));
    return (_db.select(_db.animais)
          ..where((a) =>
              a.sexo.equals('F') &
              a.prenha.equals(true) &
              a.dataPartoPrevisto.isSmallerOrEqualValue(limite) &
              a.deletedAt.isNull())
          ..orderBy([(a) => drift.OrderingTerm.asc(a.dataPartoPrevisto)]))
        .watch();
  }

  // 2.1 GMD por lote
  Future<List<GmdLote>> getGmdPorLote(String fazendaId) async {
    final lotes = await (_db.select(_db.lotes)..where((l) => l.fazendaId.equals(fazendaId))).get();
    final result = <GmdLote>[];

    for (final lote in lotes) {
      final animaisDoLote = await (_db.select(_db.animais)..where((a) => a.loteId.equals(lote.id) & a.deletedAt.isNull())).get();
      if (animaisDoLote.isEmpty) continue;

      final animalIds = animaisDoLote.map((a) => a.id).toList();
      final todasPesagens = await (_db.select(_db.pesagens)
            ..where((p) => p.animalId.isIn(animalIds))
            ..orderBy([(p) => drift.OrderingTerm.asc(p.dataPesagem)]))
          .get();

      if (todasPesagens.length < 2) continue;

      double totalGmd = 0;
      int countGmd = 0;
      final pesosByAnimal = <String, List<Pesagem>>{};
      for (final p in todasPesagens) {
        pesosByAnimal.putIfAbsent(p.animalId, () => []).add(p);
      }

      for (final pesagensAnimal in pesosByAnimal.values) {
        if (pesagensAnimal.length >= 2) {
          for (int i = 1; i < pesagensAnimal.length; i++) {
            final diffDias = pesagensAnimal[i].dataPesagem.difference(pesagensAnimal[i - 1].dataPesagem).inDays;
            if (diffDias > 0) {
              totalGmd += (pesagensAnimal[i].peso - pesagensAnimal[i - 1].peso) / diffDias;
              countGmd++;
            }
          }
        }
      }

      final ultimasPesagens = pesosByAnimal.values.map((ps) => ps.last.peso).toList();
      final pesoMedio = ultimasPesagens.isNotEmpty ? ultimasPesagens.reduce((a, b) => a + b) / ultimasPesagens.length : 0.0;

      result.add(GmdLote(
        loteId: lote.id,
        loteNome: lote.nome,
        gmdMedio: countGmd > 0 ? totalGmd / countGmd : 0.0,
        pesoMedioAtual: pesoMedio,
        totalPesagens: todasPesagens.length,
      ));
    }

    result.sort((a, b) => b.gmdMedio.compareTo(a.gmdMedio));
    return result;
  }

  // Pesagens de um animal em ordem cronológica (para gráfico de curva de crescimento)
  Stream<List<Pesagem>> watchPesagensAnimal(String animalId) {
    return (_db.select(_db.pesagens)
          ..where((p) => p.animalId.equals(animalId))
          ..orderBy([(p) => drift.OrderingTerm.asc(p.dataPesagem)]))
        .watch();
  }

  // 3.1 Animais em período de carência hoje
  Future<List<AnimaisEmCarencia>> getAnimaisEmCarencia() async {
    final now = DateTime.now();
    final query = _db.select(_db.aplicacoesSanitarias).join([
      drift.innerJoin(_db.animais, _db.animais.id.equalsExp(_db.aplicacoesSanitarias.animalId)),
      drift.innerJoin(_db.produtos, _db.produtos.id.equalsExp(_db.aplicacoesSanitarias.produtoId)),
    ])
      ..where(_db.aplicacoesSanitarias.carenciaFimCalculada.isBiggerThanValue(now))
      ..orderBy([drift.OrderingTerm.asc(_db.aplicacoesSanitarias.carenciaFimCalculada)]);

    final rows = await query.get();
    final result = <String, AnimaisEmCarencia>{}; // key = animalId, mantém apenas carência máxima

    for (final row in rows) {
      final app = row.readTable(_db.aplicacoesSanitarias);
      final animal = row.readTable(_db.animais);
      final produto = row.readTable(_db.produtos);
      final carenciaFim = app.carenciaFimCalculada!;
      final dias = carenciaFim.difference(now).inDays + 1;

      final existente = result[animal.id];
      if (existente == null || carenciaFim.isAfter(existente.carenciaFim)) {
        result[animal.id] = AnimaisEmCarencia(
          animal: animal,
          produtoNome: produto.nome,
          carenciaFim: carenciaFim,
          diasRestantes: dias,
        );
      }
    }

    return result.values.toList()..sort((a, b) => a.carenciaFim.compareTo(b.carenciaFim));
  }

  Stream<int> watchContadorCarencia() {
    final now = DateTime.now();
    return (_db.select(_db.aplicacoesSanitarias)
          ..where((a) => a.carenciaFimCalculada.isBiggerThanValue(now)))
        .watch()
        .map((list) {
      final animaisUnicosSets = <String>{};
      for (final a in list) {
        if (a.animalId != null) animaisUnicosSets.add(a.animalId!);
      }
      return animaisUnicosSets.length;
    });
  }
}
