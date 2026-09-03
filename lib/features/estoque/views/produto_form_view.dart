import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/device_info_provider.dart';

class ProdutoFormView extends ConsumerStatefulWidget {
  const ProdutoFormView({super.key});

  @override
  ConsumerState<ProdutoFormView> createState() => _ProdutoFormViewState();
}

class _ProdutoFormViewState extends ConsumerState<ProdutoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _estoqueCtrl = TextEditingController();
  final _estoqueMinCtrl = TextEditingController();
  String _tipo = 'vacina';
  String _unidade = 'dose';
  int _carencia = 0;
  bool _loading = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _estoqueCtrl.dispose();
    _estoqueMinCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final db = ref.read(databaseProvider);
    final deviceId = ref.read(deviceIdProvider).asData?.value;
    if (deviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: ID do dispositivo não disponível'), backgroundColor: Colors.red),
      );
      setState(() => _loading = false);
      return;
    }
    const uuid = Uuid();
    final produtoId = uuid.v4();

    await db.transaction(() async {
      await db.into(db.produtos).insert(
        ProdutosCompanion.insert(
          id: produtoId,
          nome: _nomeCtrl.text.trim(),
          tipo: _tipo,
          unidade: _unidade,
          carenciaDiasPadrao: Value(_carencia),
          estoqueMinimo: Value(double.tryParse(_estoqueMinCtrl.text) ?? 0),
          deviceId: deviceId,
        ),
      );

      final qtd = double.tryParse(_estoqueCtrl.text);
      if (qtd != null && qtd > 0) {
        await db.into(db.estoqueMovimentos).insert(
          EstoqueMovimentosCompanion.insert(
            id: uuid.v4(),
            produtoId: produtoId,
            tipo: 'entrada',
            quantidade: qtd,
            origem: 'cadastro_inicial',
            deviceId: deviceId,
          ),
        );
      }
    });

    if (mounted) {
      setState(() => _loading = false);
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto cadastrado com sucesso!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Insumo / Produto')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<String>(
              value: _tipo,
              decoration: InputDecoration(
                labelText: 'Tipo de Produto',
                prefixIcon: const Icon(Icons.category_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              items: const [
                DropdownMenuItem(value: 'vacina', child: Text('Vacina')),
                DropdownMenuItem(value: 'medicamento', child: Text('Medicamento')),
                DropdownMenuItem(value: 'racao', child: Text('Ração / Suplemento')),
                DropdownMenuItem(value: 'mineral', child: Text('Mineral')),
              ],
              onChanged: (v) => setState(() { _tipo = v!; if(_tipo == 'racao') _carencia = 0; }),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomeCtrl,
              style: const TextStyle(fontSize: 16),
              validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
              decoration: InputDecoration(
                labelText: 'Nome do Produto *',
                prefixIcon: const Icon(Icons.medication_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _estoqueCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Qtd. Inicial',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _unidade,
                    decoration: InputDecoration(
                      labelText: 'Unidade',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'dose', child: Text('Dose')),
                      DropdownMenuItem(value: 'ml', child: Text('mL')),
                      DropdownMenuItem(value: 'kg', child: Text('kg')),
                      DropdownMenuItem(value: 'litro', child: Text('Litro')),
                      DropdownMenuItem(value: 'unidade', child: Text('Unidade')),
                    ],
                    onChanged: (v) => setState(() => _unidade = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _estoqueMinCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Estoque Mínimo (alerta abaixo disso)',
                prefixIcon: const Icon(Icons.warning_amber_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              ),
            ),
            if (_tipo != 'racao') ...[
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Carência: $_carencia dias',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _carencia.toDouble(),
                    min: 0,
                    max: 60,
                    divisions: 60,
                    label: '$_carencia dias',
                    onChanged: (v) => setState(() => _carencia = v.toInt()),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _loading ? null : _salvar,
              icon: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check),
              label: Text(_loading ? 'Salvando...' : 'CADASTRAR PRODUTO'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
