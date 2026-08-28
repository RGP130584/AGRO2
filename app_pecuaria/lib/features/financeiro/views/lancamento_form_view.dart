import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../services/financeiro_service.dart';

class LancamentoFormView extends ConsumerStatefulWidget {
  final String fazendaId;
  const LancamentoFormView({super.key, required this.fazendaId});

  @override
  ConsumerState<LancamentoFormView> createState() => _LancamentoFormViewState();
}

class _LancamentoFormViewState extends ConsumerState<LancamentoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  String _tipo = 'pagar'; // pagar, receber
  String _categoria = 'insumos';
  DateTime _dataVencimento = DateTime.now();
  bool _pagoAgora = false;
  bool _loading = false;

  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void dispose() {
    _descricaoCtrl.dispose();
    _valorCtrl.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataVencimento,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _dataVencimento = picked);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final valor = double.parse(_valorCtrl.text.replaceAll(',', '.'));
      await ref.read(financeiroServiceProvider).criarLancamento(
        fazendaId: widget.fazendaId,
        tipo: _tipo,
        descricao: _descricaoCtrl.text.trim(),
        categoria: _categoria,
        valor: valor,
        dataVencimento: _dataVencimento,
        dataPagamento: _pagoAgora ? DateTime.now() : null,
        status: _pagoAgora ? 'pago' : 'pendente',
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lançamento registrado com sucesso!'), backgroundColor: Colors.green),
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
    return Scaffold(
      appBar: AppBar(title: Text(_tipo == 'pagar' ? 'Nova Conta a Pagar' : 'Novo Valor a Receber')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'pagar', label: Text('A Pagar'), icon: Icon(Icons.arrow_downward, color: Colors.red)),
                ButtonSegment(value: 'receber', label: Text('A Receber'), icon: Icon(Icons.arrow_upward, color: Colors.green)),
              ],
              selected: {_tipo},
              onSelectionChanged: (set) => setState(() => _tipo = set.first),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descricaoCtrl,
              decoration: InputDecoration(
                labelText: 'Descrição *',
                hintText: 'Ex: Compra de Vacina Aftosa, Venda de 10 Novilhos',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Informe a descrição' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _categoria,
              decoration: InputDecoration(
                labelText: 'Categoria *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: 'insumos', child: Text('Insumos / Medicamentos / Ração')),
                DropdownMenuItem(value: 'animais', child: Text('Compra / Venda de Animais')),
                DropdownMenuItem(value: 'maquinario', child: Text('Combustível / Manutenção')),
                DropdownMenuItem(value: 'mao_de_obra', child: Text('Mão de Obra / Salários')),
                DropdownMenuItem(value: 'outros', child: Text('Outros')),
              ],
              onChanged: (v) => setState(() => _categoria = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valorCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Valor (R\$) *',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o valor';
                if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Valor inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              leading: const Icon(Icons.calendar_today),
              title: const Text('Data de Vencimento'),
              subtitle: Text(_dateFormat.format(_dataVencimento), style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.edit_calendar),
              onTap: _selecionarData,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Já foi pago / liquidado?'),
              value: _pagoAgora,
              onChanged: (v) => setState(() => _pagoAgora = v),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _loading ? null : _salvar,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _tipo == 'pagar' ? Colors.red[800] : Colors.green[800],
              ),
              child: Text(_loading ? 'Salvando...' : 'SALVAR LANÇAMENTO'),
            ),
          ],
        ),
      ),
    );
  }
}
