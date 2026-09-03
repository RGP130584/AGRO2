import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../services/rebanho_service.dart';

final piquetesProvider = StreamProvider.family<List<Piquete>, String>((ref, fazendaId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.piquetes)..where((p) => p.fazendaId.equals(fazendaId))).watch();
});

class LoteFormView extends ConsumerStatefulWidget {
  final String fazendaId;
  const LoteFormView({super.key, required this.fazendaId});

  @override
  ConsumerState<LoteFormView> createState() => _LoteFormViewState();
}

class _LoteFormViewState extends ConsumerState<LoteFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  String _tipo = 'cria';
  String? _piqueteSelecionado;
  bool _loading = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await ref.read(rebanhoServiceProvider).cadastrarLote(
        fazendaId: widget.fazendaId,
        nome: _nomeCtrl.text.trim(),
        tipo: _tipo,
        piqueteId: _piqueteSelecionado,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lote cadastrado com sucesso!'), backgroundColor: Colors.green),
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
    final piquetesAsync = ref.watch(piquetesProvider(widget.fazendaId));

    return Scaffold(
      appBar: AppBar(title: const Text('Novo Lote')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nomeCtrl,
              decoration: InputDecoration(
                labelText: 'Nome do Lote *',
                prefixIcon: const Icon(Icons.group_work_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _tipo,
              decoration: InputDecoration(
                labelText: 'Tipo de Lote',
                prefixIcon: const Icon(Icons.category_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: 'cria', child: Text('Cria')),
                DropdownMenuItem(value: 'recria', child: Text('Recria')),
                DropdownMenuItem(value: 'engorda', child: Text('Engorda')),
                DropdownMenuItem(value: 'touros', child: Text('Touros')),
                DropdownMenuItem(value: 'descarte', child: Text('Descarte')),
              ],
              onChanged: (v) => setState(() => _tipo = v!),
            ),
            const SizedBox(height: 16),
            piquetesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erro ao carregar piquetes: $e'),
              data: (piquetes) {
                if (piquetes.isEmpty) {
                  return const Text('Nenhum piquete cadastrado na fazenda. Cadastre um para associar o lote.');
                }
                return DropdownButtonFormField<String>(
                  value: _piqueteSelecionado,
                  decoration: InputDecoration(
                    labelText: 'Piquete (opcional)',
                    prefixIcon: const Icon(Icons.fence),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: [
                    const DropdownMenuItem<String>(value: null, child: Text('Nenhum')),
                    ...piquetes.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nome)))
                  ],
                  onChanged: (v) => setState(() => _piqueteSelecionado = v),
                );
              },
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _loading ? null : _salvar,
              icon: _loading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.check),
              label: Text(_loading ? 'Salvando...' : 'CADASTRAR LOTE'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
