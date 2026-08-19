import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/rebanho_service.dart';

class PiqueteFormView extends ConsumerStatefulWidget {
  final String fazendaId;
  const PiqueteFormView({super.key, required this.fazendaId});

  @override
  ConsumerState<PiqueteFormView> createState() => _PiqueteFormViewState();
}

class _PiqueteFormViewState extends ConsumerState<PiqueteFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _capacidadeCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _areaCtrl.dispose();
    _capacidadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await ref.read(rebanhoServiceProvider).cadastrarPiquete(
        fazendaId: widget.fazendaId,
        nome: _nomeCtrl.text.trim(),
        areaHectares: double.tryParse(_areaCtrl.text),
        capacidadeCabecas: int.tryParse(_capacidadeCtrl.text),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Piquete cadastrado com sucesso!'), backgroundColor: Colors.green),
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
      appBar: AppBar(title: const Text('Novo Piquete')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nomeCtrl,
              decoration: InputDecoration(
                labelText: 'Nome do Piquete *',
                prefixIcon: const Icon(Icons.fence_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _areaCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Área (hectares)',
                prefixIcon: const Icon(Icons.aspect_ratio),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _capacidadeCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Capacidade (cabeças)',
                prefixIcon: const Icon(Icons.pets),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _loading ? null : _salvar,
              icon: _loading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.check),
              label: Text(_loading ? 'Salvando...' : 'CADASTRAR PIQUETE'),
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
