import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../services/nutricao_service.dart';

final lotesProvider = StreamProvider.family<List<Lote>, String>((ref, fazendaId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.lotes)..where((l) => l.fazendaId.equals(fazendaId))).watch();
});

final produtosRacaoProvider = StreamProvider<List<Produto>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.produtos)..where((p) => p.tipo.equals('racao'))).watch();
});

class DietaFormView extends ConsumerStatefulWidget {
  final String fazendaId;
  const DietaFormView({super.key, required this.fazendaId});

  @override
  ConsumerState<DietaFormView> createState() => _DietaFormViewState();
}

class _DietaFormViewState extends ConsumerState<DietaFormView> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeCtrl = TextEditingController();
  String? _loteSelecionado;
  String? _produtoSelecionado;
  bool _loading = false;

  @override
  void dispose() {
    _quantidadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate() || _produtoSelecionado == null) return;
    setState(() => _loading = true);

    try {
      await ref.read(nutricaoServiceProvider).criarDieta(
        loteId: _loteSelecionado,
        produtoId: _produtoSelecionado!,
        quantidadePorCabecaDia: double.parse(_quantidadeCtrl.text),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dieta criada com sucesso!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lotesAsync = ref.watch(lotesProvider(widget.fazendaId));
    final produtosAsync = ref.watch(produtosRacaoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nova Dieta')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            lotesAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erro: $e'),
              data: (lotes) => DropdownButtonFormField<String>(
                value: _loteSelecionado,
                decoration: InputDecoration(
                  labelText: 'Lote (Opcional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  const DropdownMenuItem<String>(value: null, child: Text('Geral (Categoria)')),
                  ...lotes.map((l) => DropdownMenuItem(value: l.id, child: Text(l.nome)))
                ],
                onChanged: (v) => setState(() => _loteSelecionado = v),
              ),
            ),
            const SizedBox(height: 16),
            produtosAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erro: $e'),
              data: (produtos) => DropdownButtonFormField<String>(
                value: _produtoSelecionado,
                decoration: InputDecoration(
                  labelText: 'Produto (Ração/Suplemento) *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: produtos.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nome))).toList(),
                onChanged: (v) => setState(() => _produtoSelecionado = v),
                validator: (v) => v == null ? 'Selecione um produto' : null,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantidadeCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantidade por Cabeça/Dia (kg)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Informe a quantidade' : null,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _loading ? null : _salvar,
              child: Text(_loading ? 'Salvando...' : 'CADASTRAR DIETA'),
            ),
          ],
        ),
      ),
    );
  }
}
