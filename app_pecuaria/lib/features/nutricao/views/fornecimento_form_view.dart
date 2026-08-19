import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../services/nutricao_service.dart';

final dietasProvider = StreamProvider<List<Dieta>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.dietas).watch();
});

final lotesProvider = StreamProvider.family<List<Lote>, String>((ref, fazendaId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.lotes)..where((l) => l.fazendaId.equals(fazendaId))).watch();
});

class FornecimentoFormView extends ConsumerStatefulWidget {
  final String fazendaId;
  const FornecimentoFormView({super.key, required this.fazendaId});

  @override
  ConsumerState<FornecimentoFormView> createState() => _FornecimentoFormViewState();
}

class _FornecimentoFormViewState extends ConsumerState<FornecimentoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeCtrl = TextEditingController();
  String? _loteSelecionado;
  String? _dietaSelecionada;
  bool _loading = false;

  @override
  void dispose() {
    _quantidadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate() || _loteSelecionado == null || _dietaSelecionada == null) return;
    setState(() => _loading = true);

    try {
      await ref.read(nutricaoServiceProvider).registrarFornecimento(
        loteId: _loteSelecionado!,
        dietaId: _dietaSelecionada!,
        quantidadeFornecida: double.parse(_quantidadeCtrl.text),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fornecimento registrado com sucesso!'), backgroundColor: Colors.green),
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
    final dietasAsync = ref.watch(dietasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Fornecimento')),
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
                  labelText: 'Lote *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: lotes.map((l) => DropdownMenuItem(value: l.id, child: Text(l.nome))).toList(),
                onChanged: (v) => setState(() => _loteSelecionado = v),
                validator: (v) => v == null ? 'Selecione o lote' : null,
              ),
            ),
            const SizedBox(height: 16),
            dietasAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erro: $e'),
              data: (dietas) => DropdownButtonFormField<String>(
                value: _dietaSelecionada,
                decoration: InputDecoration(
                  labelText: 'Dieta *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: dietas.map((d) => DropdownMenuItem(value: d.id, child: Text('Dieta ${d.categoria ?? "Geral"}'))).toList(),
                onChanged: (v) => setState(() => _dietaSelecionada = v),
                validator: (v) => v == null ? 'Selecione uma dieta' : null,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantidadeCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantidade Fornecida (Total em kg)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Informe a quantidade' : null,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _loading ? null : _salvar,
              child: Text(_loading ? 'Salvando...' : 'REGISTRAR FORNECIMENTO'),
            ),
          ],
        ),
      ),
    );
  }
}
