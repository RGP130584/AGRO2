import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/pesagem_service.dart';

class RegistroPesagemView extends ConsumerStatefulWidget {
  final String animalId;
  final String animalBrinco;

  const RegistroPesagemView({
    super.key,
    required this.animalId,
    required this.animalBrinco,
  });

  @override
  ConsumerState<RegistroPesagemView> createState() => _RegistroPesagemViewState();
}

class _RegistroPesagemViewState extends ConsumerState<RegistroPesagemView> {
  final _formKey = GlobalKey<FormState>();
  final _pesoCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _pesoCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final peso = double.parse(_pesoCtrl.text.replaceAll(',', '.'));
      await ref.read(pesagemServiceProvider).registrarPesagem(widget.animalId, peso);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesagem registrada com sucesso!'), backgroundColor: Colors.green),
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
      appBar: AppBar(title: Text('Nova Pesagem - ${widget.animalBrinco}')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _pesoCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Peso (kg)',
                  prefixIcon: const Icon(Icons.scale),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Informe o peso' : null,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _loading ? null : _salvar,
                icon: _loading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.check),
                label: Text(_loading ? 'Salvando...' : 'REGISTRAR PESAGEM'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
