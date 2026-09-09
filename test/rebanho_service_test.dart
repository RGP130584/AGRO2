import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:app_pecuaria/data/local/database.dart';
import 'package:app_pecuaria/features/rebanho/services/rebanho_service.dart';
import 'package:app_pecuaria/features/rebanho/services/pesagem_service.dart';
import 'package:app_pecuaria/features/saude/services/saude_service.dart';
import 'package:app_pecuaria/features/nutricao/services/nutricao_service.dart';

/// Helper: cria banco em memória para testes isolados.
AppDatabase createTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

/// Helper: seed de dados base (Fazenda → Piquete → Lote → Animal → Produto).
/// Retorna um Map com os IDs gerados.
Future<Map<String, String>> seedBaseData(AppDatabase db, String deviceId) async {
  const fazendaId = 'fazenda_test_01';
  const piqueteId = 'piquete_test_01';
  const loteId = 'lote_test_01';
  const animalId = 'animal_test_01';
  const produtoVacinaId = 'produto_vacina_01';
  const produtoRacaoId = 'produto_racao_01';

  await db.into(db.fazendas).insert(FazendasCompanion.insert(
    id: fazendaId, nome: 'Fazenda Teste', deviceId: deviceId,
  ));
  await db.into(db.piquetes).insert(PiquetesCompanion.insert(
    id: piqueteId, nome: 'Piquete A', fazendaId: fazendaId, deviceId: deviceId,
  ));
  await db.into(db.lotes).insert(LotesCompanion.insert(
    id: loteId, nome: 'Lote Engorda', categoria: 'engorda',
    fazendaId: fazendaId, piqueteId: Value(piqueteId), deviceId: deviceId,
  ));
  await db.into(db.animais).insert(AnimaisCompanion.insert(
    id: animalId, loteId: loteId, brinco: 'BR-001',
    categoria: 'Nelore', raca: 'Nelore', deviceId: deviceId,
  ));
  await db.into(db.produtos).insert(ProdutosCompanion.insert(
    id: produtoVacinaId, tipo: 'vacina', nome: 'Aftosa',
    unidade: 'dose', carenciaDiasPadrao: Value(30), deviceId: deviceId,
  ));
  await db.into(db.produtos).insert(ProdutosCompanion.insert(
    id: produtoRacaoId, tipo: 'racao', nome: 'Ração Engorda Premium',
    unidade: 'kg', deviceId: deviceId,
  ));

  return {
    'fazendaId': fazendaId,
    'piqueteId': piqueteId,
    'loteId': loteId,
    'animalId': animalId,
    'produtoVacinaId': produtoVacinaId,
    'produtoRacaoId': produtoRacaoId,
  };
}

// ═══════════════════════════════════════════════════════════════════════
//  GRUPO 1: TESTES UNITÁRIOS DO REBANHO SERVICE
// ═══════════════════════════════════════════════════════════════════════
void main() {
  const deviceId = 'test_device_01';

  group('RebanhoService', () {
    late AppDatabase db;
    late RebanhoService service;

    setUp(() {
      db = createTestDb();
      service = RebanhoService(db, deviceId);
    });
    tearDown(() => db.close());

    test('cadastrarPiquete grava localmente e enfileira Outbox', () async {
      await db.into(db.fazendas).insert(FazendasCompanion.insert(
        id: 'f1', nome: 'Fazenda 1', deviceId: deviceId,
      ));

      await service.cadastrarPiquete(
        fazendaId: 'f1', nome: 'Piquete Norte', areaHectares: 25.0,
      );

      final piquetes = await db.select(db.piquetes).get();
      expect(piquetes.length, 1);
      expect(piquetes.first.nome, 'Piquete Norte');
      expect(piquetes.first.areaHectares, 25.0);

      final queue = await db.select(db.syncQueueItems).get();
      expect(queue.length, 1);
      expect(queue.first.entityType, 'Piquetes');
      expect(queue.first.action, 'insert');
      expect(queue.first.status, 'pending');
    });

    test('cadastrarLote grava localmente e enfileira Outbox', () async {
      await db.into(db.fazendas).insert(FazendasCompanion.insert(
        id: 'f2', nome: 'Fazenda 2', deviceId: deviceId,
      ));

      await service.cadastrarLote(
        fazendaId: 'f2', nome: 'Lote Cria', tipo: 'cria',
      );

      final lotes = await db.select(db.lotes).get();
      expect(lotes.length, 1);
      expect(lotes.first.nome, 'Lote Cria');
      expect(lotes.first.categoria, 'cria');

      final queue = await db.select(db.syncQueueItems).get();
      expect(queue.length, 1);
      expect(queue.first.entityType, 'Lotes');
    });

    test('cadastrarAnimal grava localmente e enfileira Outbox', () async {
      final ids = await seedBaseData(db, deviceId);
      // Service criado após seed para ter dados disponíveis
      service = RebanhoService(db, deviceId);

      await service.cadastrarAnimal(
        loteId: ids['loteId']!,
        brinco: 'BR-999',
        tipoAnimal: 'Bovino',
        categoria: 'Nelore',
        raca: 'Nelore',
        sexo: 'M',
        pesoKg: 350.0,
      );

      // Animal do seed + 1 novo = 2
      final animais = await db.select(db.animais).get();
      expect(animais.length, 2);
      expect(animais.any((a) => a.brinco == 'BR-999'), true);

      final queue = await db.select(db.syncQueueItems).get();
      expect(queue.length, 1);
      expect(queue.first.entityType, 'Animais');
    });
  });

  // ═══════════════════════════════════════════════════════════════════════
  //  GRUPO 2: TESTES UNITÁRIOS DO PESAGEM SERVICE
  // ═══════════════════════════════════════════════════════════════════════
  group('PesagemService', () {
    late AppDatabase db;
    late PesagemService service;

    setUp(() {
      db = createTestDb();
      service = PesagemService(db, deviceId);
    });
    tearDown(() => db.close());

    test('registrarPesagem grava pesagem e atualiza peso do animal', () async {
      final ids = await seedBaseData(db, deviceId);

      await service.registrarPesagem(ids['animalId']!, 420.5);

      final pesagens = await db.select(db.pesagens).get();
      expect(pesagens.length, 1);
      expect(pesagens.first.peso, 420.5);

      // Verifica se o peso do animal foi atualizado
      final animal = await (db.select(db.animais)
        ..where((a) => a.id.equals(ids['animalId']!)))
        .getSingle();
      expect(animal.pesoKg, 420.5);
    });

    test('watchHistoricoComGMD calcula GMD corretamente', () async {
      final ids = await seedBaseData(db, deviceId);

      // Pesagem 1: dia 0 → 400 kg
      await db.into(db.pesagens).insert(PesagensCompanion.insert(
        id: 'p1', animalId: ids['animalId']!, peso: 400.0,
        dataPesagem: Value(DateTime(2026, 1, 1)), deviceId: deviceId,
      ));
      // Pesagem 2: dia 30 → 430 kg → GMD = (430-400)/30 = 1.0
      await db.into(db.pesagens).insert(PesagensCompanion.insert(
        id: 'p2', animalId: ids['animalId']!, peso: 430.0,
        dataPesagem: Value(DateTime(2026, 1, 31)), deviceId: deviceId,
      ));
      // Pesagem 3: dia 60 → 445 kg → GMD = (445-430)/30 = 0.5
      await db.into(db.pesagens).insert(PesagensCompanion.insert(
        id: 'p3', animalId: ids['animalId']!, peso: 445.0,
        dataPesagem: Value(DateTime(2026, 3, 2)), deviceId: deviceId,
      ));

      final stream = service.watchHistoricoComGMD(ids['animalId']!);
      final result = await stream.first;

      // Retorno é reversed, então o mais recente vem primeiro
      expect(result.length, 3);
      // Mais recente (445kg) → GMD = 0.5
      expect(result[0].gmd, closeTo(0.5, 0.01));
      // Segundo (430kg) → GMD = 1.0
      expect(result[1].gmd, closeTo(1.0, 0.01));
      // Primeiro (400kg) → sem GMD (é a primeira pesagem)
      expect(result[2].gmd, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════
  //  GRUPO 3: TESTES UNITÁRIOS DO SAÚDE SERVICE
  // ═══════════════════════════════════════════════════════════════════════
  group('SaudeService', () {
    late AppDatabase db;
    late SaudeService service;

    setUp(() {
      db = createTestDb();
      service = SaudeService(db, deviceId);
    });
    tearDown(() => db.close());

    test('registrarAplicacao grava aplicação sanitária E dá baixa no estoque', () async {
      final ids = await seedBaseData(db, deviceId);

      // Busca o Produto completo do banco
      final produto = await (db.select(db.produtos)
        ..where((p) => p.id.equals(ids['produtoVacinaId']!)))
        .getSingle();

      final carenciaFim = await service.registrarAplicacao(
        animalId: ids['animalId']!,
        produto: produto,
        dose: 5.0,
        via: 'intramuscular',
        motivo: 'Vacinação obrigatória',
      );

      // 1. Verifica que a aplicação foi gravada
      final aplicacoes = await db.select(db.aplicacoesSanitarias).get();
      expect(aplicacoes.length, 1);
      expect(aplicacoes.first.dose, 5.0);
      expect(aplicacoes.first.via, 'intramuscular');

      // 2. Verifica que o estoque recebeu movimento de saída
      final movimentos = await db.select(db.estoqueMovimentos).get();
      expect(movimentos.length, 1);
      expect(movimentos.first.tipo, 'saida');
      expect(movimentos.first.quantidade, 5.0);
      expect(movimentos.first.origem, 'aplicacao');

      // 3. Verifica que a carência foi calculada (30 dias)
      expect(carenciaFim, isNotNull);
      final diasDiff = carenciaFim!.difference(DateTime.now()).inDays;
      expect(diasDiff, greaterThanOrEqualTo(29)); // ~30 dias no futuro
    });

    test('registrarAplicacao sem carência retorna null', () async {
      final ids = await seedBaseData(db, deviceId);

      // Cria produto sem carência
      await db.into(db.produtos).insert(ProdutosCompanion.insert(
        id: 'prod_sem_carencia', tipo: 'suplemento', nome: 'Vitamina ADE',
        unidade: 'ml', carenciaDiasPadrao: Value(0), deviceId: deviceId,
      ));
      final produto = await (db.select(db.produtos)
        ..where((p) => p.id.equals('prod_sem_carencia')))
        .getSingle();

      final carenciaFim = await service.registrarAplicacao(
        animalId: ids['animalId']!, produto: produto,
        dose: 10.0, via: 'subcutanea', motivo: 'Suplementação',
      );

      expect(carenciaFim, isNull);
    });

    test('registrarAplicacao é atômica (transação)', () async {
      final ids = await seedBaseData(db, deviceId);
      final produto = await (db.select(db.produtos)
        ..where((p) => p.id.equals(ids['produtoVacinaId']!)))
        .getSingle();

      // Grava com sucesso
      await service.registrarAplicacao(
        animalId: ids['animalId']!, produto: produto,
        dose: 3.0, via: 'oral', motivo: 'Teste de atomicidade',
      );

      // Ambos os registros devem existir (aplicação E estoque)
      final apps = await db.select(db.aplicacoesSanitarias).get();
      final movs = await db.select(db.estoqueMovimentos).get();
      expect(apps.length, movs.length); // Sempre 1:1
    });
  });

  // ═══════════════════════════════════════════════════════════════════════
  //  GRUPO 4: TESTES UNITÁRIOS DO NUTRIÇÃO SERVICE
  // ═══════════════════════════════════════════════════════════════════════
  group('NutricaoService', () {
    late AppDatabase db;
    late NutricaoService service;

    setUp(() {
      db = createTestDb();
      service = NutricaoService(db, deviceId);
    });
    tearDown(() => db.close());

    test('criarDieta grava dieta vinculada a lote e produto', () async {
      final ids = await seedBaseData(db, deviceId);

      await service.criarDieta(
        loteId: ids['loteId']!,
        produtoId: ids['produtoRacaoId']!,
        quantidadePorCabecaDia: 12.5,
      );

      final dietas = await db.select(db.dietas).get();
      expect(dietas.length, 1);
      expect(dietas.first.quantidadePorCabecaDia, 12.5);
      expect(dietas.first.produtoId, ids['produtoRacaoId']);
    });

    test('registrarFornecimento grava fornecimento E dá baixa no estoque', () async {
      final ids = await seedBaseData(db, deviceId);

      // Primeiro cria a dieta
      await db.into(db.dietas).insert(DietasCompanion.insert(
        id: 'dieta_01', loteId: Value(ids['loteId']),
        produtoId: ids['produtoRacaoId']!,
        quantidadePorCabecaDia: 10.0, deviceId: deviceId,
      ));

      await service.registrarFornecimento(
        loteId: ids['loteId']!,
        dietaId: 'dieta_01',
        quantidadeFornecida: 150.0,
      );

      // 1. Verifica fornecimento gravado
      final fornecimentos = await db.select(db.fornecimentosDieta).get();
      expect(fornecimentos.length, 1);
      expect(fornecimentos.first.quantidadeFornecida, 150.0);

      // 2. Verifica que deu baixa no estoque (saída)
      final movimentos = await db.select(db.estoqueMovimentos).get();
      expect(movimentos.length, 1);
      expect(movimentos.first.tipo, 'saida');
      expect(movimentos.first.quantidade, 150.0);
      expect(movimentos.first.origem, 'fornecimento_dieta');
      expect(movimentos.first.produtoId, ids['produtoRacaoId']);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════
  //  GRUPO 5: TESTES DE INTEGRAÇÃO / FUNCIONAL (End-to-End no Banco)
  //  Simula o fluxo completo de um operador de campo.
  // ═══════════════════════════════════════════════════════════════════════
  group('Teste Funcional: Fluxo Completo do Operador de Campo', () {
    late AppDatabase db;
    late RebanhoService rebanhoService;
    late PesagemService pesagemService;
    late SaudeService saudeService;
    late NutricaoService nutricaoService;

    setUp(() {
      db = createTestDb();
      rebanhoService = RebanhoService(db, deviceId);
      pesagemService = PesagemService(db, deviceId);
      saudeService = SaudeService(db, deviceId);
      nutricaoService = NutricaoService(db, deviceId);
    });
    tearDown(() => db.close());

    test('Ciclo completo: Fazenda → Piquete → Lote → Animal → Pesagem → Vacina → Dieta → Fornecimento', () async {
      // ── PASSO 1: Cadastrar Fazenda ────────────────────────────
      await db.into(db.fazendas).insert(FazendasCompanion.insert(
        id: 'faz_e2e', nome: 'Fazenda São José', deviceId: deviceId,
        cpfCnpj: const Value('12345678000190'),
      ));
      final fazenda = await (db.select(db.fazendas)
        ..where((f) => f.id.equals('faz_e2e'))).getSingle();
      expect(fazenda.nome, 'Fazenda São José');

      // ── PASSO 2: Cadastrar Piquete ────────────────────────────
      await rebanhoService.cadastrarPiquete(
        fazendaId: 'faz_e2e', nome: 'Piquete Beira Rio', areaHectares: 50.0,
      );
      final piquetes = await db.select(db.piquetes).get();
      expect(piquetes.length, 1);
      final piqueteId = piquetes.first.id;

      // ── PASSO 3: Cadastrar Lote no Piquete ───────────────────
      await rebanhoService.cadastrarLote(
        fazendaId: 'faz_e2e', nome: 'Engorda Safra 2026',
        tipo: 'engorda', piqueteId: piqueteId,
      );
      final lotes = await db.select(db.lotes).get();
      expect(lotes.length, 1);
      final loteId = lotes.first.id;

      // ── PASSO 4: Cadastrar Animal ─────────────────────────────
      await rebanhoService.cadastrarAnimal(
        loteId: loteId, brinco: 'BR-E2E-001',
        tipoAnimal: 'Bovino', categoria: 'Boi', raca: 'Angus', sexo: 'M',
        pesoKg: 380.0,
      );
      final animais = await db.select(db.animais).get();
      expect(animais.length, 1);
      final animalId = animais.first.id;
      expect(animais.first.pesoKg, 380.0);

      // ── PASSO 5: Registrar Pesagem (30 dias depois) ──────────
      await pesagemService.registrarPesagem(animalId, 410.0);
      final animalAtualizado = await (db.select(db.animais)
        ..where((a) => a.id.equals(animalId))).getSingle();
      expect(animalAtualizado.pesoKg, 410.0); // Peso atualizado!

      // ── PASSO 6: Aplicar Vacina ──────────────────────────────
      await db.into(db.produtos).insert(ProdutosCompanion.insert(
        id: 'vac_aftosa', tipo: 'vacina', nome: 'Aftosa Bivalente',
        unidade: 'dose', carenciaDiasPadrao: const Value(30), deviceId: deviceId,
      ));
      final vacina = await (db.select(db.produtos)
        ..where((p) => p.id.equals('vac_aftosa'))).getSingle();

      final carenciaFim = await saudeService.registrarAplicacao(
        animalId: animalId, produto: vacina,
        dose: 5.0, via: 'intramuscular', motivo: 'Vacinação Obrigatória',
      );
      expect(carenciaFim, isNotNull);

      // Verificar que estoque de vacinas teve saída
      final movVacina = await (db.select(db.estoqueMovimentos)
        ..where((m) => m.produtoId.equals('vac_aftosa'))).get();
      expect(movVacina.length, 1);
      expect(movVacina.first.tipo, 'saida');

      // ── PASSO 7: Criar Dieta para o Lote ─────────────────────
      await db.into(db.produtos).insert(ProdutosCompanion.insert(
        id: 'racao_engorda', tipo: 'racao', nome: 'Ração Confinamento',
        unidade: 'kg', deviceId: deviceId,
      ));
      await nutricaoService.criarDieta(
        loteId: loteId, produtoId: 'racao_engorda',
        quantidadePorCabecaDia: 15.0,
      );
      final dietas = await db.select(db.dietas).get();
      expect(dietas.length, 1);
      final dietaId = dietas.first.id;

      // ── PASSO 8: Registrar Fornecimento de Ração ─────────────
      await nutricaoService.registrarFornecimento(
        loteId: loteId, dietaId: dietaId, quantidadeFornecida: 200.0,
      );
      final movRacao = await (db.select(db.estoqueMovimentos)
        ..where((m) => m.produtoId.equals('racao_engorda'))).get();
      expect(movRacao.length, 1);
      expect(movRacao.first.quantidade, 200.0);

      // ── PASSO 9: Verificar a Fila de Sincronização ───────────
      // Cadastro de piquete, lote e animal = 3 itens na fila
      final syncQueue = await db.select(db.syncQueueItems).get();
      expect(syncQueue.length, 3);
      expect(syncQueue.where((s) => s.entityType == 'Piquetes').length, 1);
      expect(syncQueue.where((s) => s.entityType == 'Lotes').length, 1);
      expect(syncQueue.where((s) => s.entityType == 'Animais').length, 1);
      // Todos devem estar com status 'pending'
      expect(syncQueue.every((s) => s.status == 'pending'), true);
      // Todos devem ter o deviceId correto
      expect(syncQueue.every((s) => s.deviceId == deviceId), true);
    });

    test('Cenário de integridade: dados interligados mantêm referências válidas', () async {
      final ids = await seedBaseData(db, deviceId);

      // Verifica que é possível ler a cadeia completa: Animal → Lote → Piquete → Fazenda
      final animal = await (db.select(db.animais)..where((a) => a.id.equals(ids['animalId']!))).getSingle();
      final lote = await (db.select(db.lotes)..where((l) => l.id.equals(animal.loteId))).getSingle();
      final fazenda = await (db.select(db.fazendas)..where((f) => f.id.equals(lote.fazendaId))).getSingle();

      expect(animal.brinco, 'BR-001');
      expect(lote.nome, 'Lote Engorda');
      expect(fazenda.nome, 'Fazenda Teste');
    });
  });
}
