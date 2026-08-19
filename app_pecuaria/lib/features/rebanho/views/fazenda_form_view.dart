import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart'; 
import '../../../providers/device_info_provider.dart';

class FazendaFormView extends ConsumerStatefulWidget {
  const FazendaFormView({super.key});

  @override
  ConsumerState<FazendaFormView> createState() => _FazendaFormViewState();
}

class _FazendaFormViewState extends ConsumerState<FazendaFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _cpfCnpjCtrl = TextEditingController();
  final _responsavelCtrl = TextEditingController();
  final _cidadeCtrl = TextEditingController();
  String? _estado;
  bool _loading = false;

  final List<String> _estados = [
    'AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS',
    'MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC',
    'SP','SE','TO'
  ];

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _cpfCnpjCtrl.dispose();
    _responsavelCtrl.dispose();
    _cidadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final db = ref.read(databaseProvider);
    const uuid = Uuid();
    final deviceId = ref.read(deviceIdProvider).asData?.value ?? 'fallback_device_id';

    await db.into(db.fazendas).insert(
      FazendasCompanion.insert(
        id: uuid.v4(),
        nome: _nomeCtrl.text.trim(),
        cpfCnpj: Value(_cpfCnpjCtrl.text.trim().isEmpty ? null : _cpfCnpjCtrl.text.trim()),
        responsavel: Value(_responsavelCtrl.text.trim().isEmpty ? null : _responsavelCtrl.text.trim()),
        cidade: Value(_cidadeCtrl.text.trim().isEmpty ? null : _cidadeCtrl.text.trim()),
        estado: Value(_estado),
        deviceId: deviceId,
      ),
    );

    if (mounted) {
      setState(() => _loading = false);
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fazenda cadastrada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Fazenda'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildField(
              controller: _nomeCtrl,
              label: 'Nome da Fazenda *',
              icon: Icons.landscape,
              validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _cpfCnpjCtrl,
              label: 'CPF / CNPJ',
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _responsavelCtrl,
              label: 'Responsável',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildField(
                    controller: _cidadeCtrl,
                    label: 'Cidade',
                    icon: Icons.location_city,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _estado,
                    decoration: InputDecoration(
                      labelText: 'UF',
                      prefixIcon: const Icon(Icons.map_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                    items: _estados.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _estado = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _loading ? null : _salvar,
              icon: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check),
              label: Text(_loading ? 'Salvando...' : 'CADASTRAR FAZENDA'),
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
    );
  }
}
