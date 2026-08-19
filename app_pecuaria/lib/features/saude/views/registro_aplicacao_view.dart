import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../services/saude_service.dart';

final produtosParaAplicacaoProvider = StreamProvider<List<Produto>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.produtos)
        ..where((p) => p.tipo.isIn(['vacina', 'medicamento'])))
      .watch();
});

class RegistroAplicacaoView extends ConsumerStatefulWidget {
  const RegistroAplicacaoView({super.key});

  @override
  ConsumerState<RegistroAplicacaoView> createState() => _RegistroAplicacaoViewState();
}

class _RegistroAplicacaoViewState extends ConsumerState<RegistroAplicacaoView> {
  final _formKey = GlobalKey<FormState>();
  Produto? _produtoSelecionado;
  String _via = 'subcutânea';
  final _motivoCtrl = TextEditingController();
  double _dose = 1.0;
  bool _loading = false;

  @override
  void dispose() {
    _motivoCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate() || _produtoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o produto para continuar'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _loading = true);

    try {
      final saudeService = ref.read(saudeServiceProvider);
      final carenciaFim = await saudeService.registrarAplicacao(
        produto: _produtoSelecionado!,
        dose: _dose,
        via: _via,
        motivo: _motivoCtrl.text.trim().isEmpty ? 'Rotina' : _motivoCtrl.text.trim(),
      );

      if (mounted) {
        _limparFormulario();
        final msg = carenciaFim != null
            ? 'Aplicação salva! Carência até ${_formatDate(carenciaFim)}. Estoque atualizado.'
            : 'Aplicação salva e estoque atualizado!';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.green, duration: const Duration(seconds: 4)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  void _limparFormulario() {
    _motivoCtrl.clear();
    setState(() { _produtoSelecionado = null; _dose = 1.0; _via = 'subcutânea'; });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final produtosAsync = ref.watch(produtosParaAplicacaoProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Registrar Aplicação'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // CARD: Produto
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Produto Aplicado', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    produtosAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Erro ao carregar produtos: $e'),
                      data: (produtos) {
                        if (produtos.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.warning_amber, color: Colors.orange),
                                SizedBox(width: 8),
                                Expanded(child: Text('Nenhum produto cadastrado. Cadastre primeiro na aba Estoque.')),
                              ],
                            ),
                          );
                        }
                        return DropdownButtonFormField<Produto>(
                          value: _produtoSelecionado,
                          decoration: InputDecoration(
                            labelText: 'Selecione o produto',
                            prefixIcon: const Icon(Icons.vaccines),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: produtos.map((p) => DropdownMenuItem(
                            value: p,
                            child: Text('${p.nome} (${p.unidade})'),
                          )).toList(),
                          onChanged: (v) => setState(() => _produtoSelecionado = v),
                        );
                      },
                    ),
                    if (_produtoSelecionado != null && _produtoSelecionado!.carenciaDiasPadrao > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_outlined, color: Colors.amber),
                            const SizedBox(width: 8),
                            Text('Carência: ${_produtoSelecionado!.carenciaDiasPadrao} dias após aplicação'),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // CARD: Dose
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dose Aplicada', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle, size: 48, color: Colors.red),
                          onPressed: () => setState(() { if (_dose > 1) _dose -= 0.5; }),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            Text(
                              _dose.toString(),
                              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _produtoSelecionado?.unidade ?? 'unidade',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.add_circle, size: 48, color: Colors.green),
                          onPressed: () => setState(() => _dose += 0.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // CARD: Via e Motivo
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Detalhes', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _via,
                      decoration: InputDecoration(
                        labelText: 'Via de Administração',
                        prefixIcon: const Icon(Icons.medical_services_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'subcutânea', child: Text('Subcutânea')),
                        DropdownMenuItem(value: 'intramuscular', child: Text('Intramuscular')),
                        DropdownMenuItem(value: 'oral', child: Text('Oral')),
                        DropdownMenuItem(value: 'intravenosa', child: Text('Intravenosa')),
                        DropdownMenuItem(value: 'tópica', child: Text('Tópica')),
                      ],
                      onChanged: (v) => setState(() => _via = v!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _motivoCtrl,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Motivo / Observação (opcional)',
                        prefixIcon: const Icon(Icons.notes_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _loading ? null : _salvar,
              icon: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save),
              label: Text(_loading ? 'Salvando...' : 'REGISTRAR APLICAÇÃO'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                backgroundColor: Colors.blue[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
