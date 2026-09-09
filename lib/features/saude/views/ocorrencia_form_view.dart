import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../services/saude_service.dart';

final todosAnimaisProvider = StreamProvider<List<Animal>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.animais)..where((a) => a.deletedAt.isNull())).watch();
});

class OcorrenciaFormView extends ConsumerStatefulWidget {
  final String? animalIdPreselecionado;
  const OcorrenciaFormView({super.key, this.animalIdPreselecionado});

  @override
  ConsumerState<OcorrenciaFormView> createState() => _OcorrenciaFormViewState();
}

class _OcorrenciaFormViewState extends ConsumerState<OcorrenciaFormView> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoCtrl = TextEditingController();
  String? _animalSelecionado;
  String _tipo = 'doenca';
  String? _fotoPath;
  bool _loading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _animalSelecionado = widget.animalIdPreselecionado;
  }

  @override
  void dispose() {
    _descricaoCtrl.dispose();
    super.dispose();
  }

  Future<void> _tirarFoto() async {
    try {
      final XFile? foto = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
      if (foto != null) {
        setState(() => _fotoPath = foto.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao capturar foto: $e'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate() || _animalSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o animal'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _loading = true);

    try {
      await ref.read(saudeServiceProvider).registrarOcorrencia(
        animalId: _animalSelecionado!,
        tipo: _tipo,
        descricao: _descricaoCtrl.text.trim(),
        fotoPath: _fotoPath,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ocorrência sanitária registrada!'), backgroundColor: Colors.green),
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
    final animaisAsync = ref.watch(todosAnimaisProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Ocorrência')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            animaisAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erro ao carregar animais: $e'),
              data: (animais) {
                return DropdownButtonFormField<String>(
                  value: _animalSelecionado,
                  decoration: InputDecoration(
                    labelText: 'Animal (Brinco) *',
                    prefixIcon: const Icon(Icons.pets),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: animais.map((a) => DropdownMenuItem(
                    value: a.id,
                    child: Text('Brinco: ${a.brinco} (${a.raca})'),
                  )).toList(),
                  onChanged: (v) => setState(() => _animalSelecionado = v),
                  validator: (v) => v == null ? 'Selecione o animal' : null,
                );
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _tipo,
              decoration: InputDecoration(
                labelText: 'Tipo de Ocorrência *',
                prefixIcon: const Icon(Icons.warning_amber_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: 'doenca', child: Text('Sintoma / Doença')),
                DropdownMenuItem(value: 'obito', child: Text('Óbito / Morte')),
                DropdownMenuItem(value: 'acidente', child: Text('Acidente / Fratura')),
                DropdownMenuItem(value: 'outro', child: Text('Outro')),
              ],
              onChanged: (v) => setState(() => _tipo = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descricaoCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Descrição detalhada *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Informe os detalhes da ocorrência' : null,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _tirarFoto,
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(_fotoPath != null ? 'FOTO ANEXADA (Toque para trocar)' : 'ANEXAR FOTO DA OCORRÊNCIA'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (_fotoPath != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(_fotoPath!), height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _loading ? null : _salvar,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _tipo == 'obito' ? Colors.red[800] : Colors.teal[800],
              ),
              child: Text(_loading ? 'Salvando...' : 'REGISTRAR OCORRÊNCIA'),
            ),
          ],
        ),
      ),
    );
  }
}
