import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart'; 
import '../services/rebanho_service.dart';

final lotesProvider = StreamProvider<List<Lote>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.lotes)..where((l) => l.deletedAt.isNull())).watch();
});

class AnimalFormView extends ConsumerStatefulWidget {
  const AnimalFormView({super.key});

  @override
  ConsumerState<AnimalFormView> createState() => _AnimalFormViewState();
}

class _AnimalFormViewState extends ConsumerState<AnimalFormView> {
  final _formKey = GlobalKey<FormState>();
  final _brincoCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();

  String _tipoAnimal = 'Bovino';
  String _categoria = 'Novilha';
  String _raca = 'Nelore';
  String _sexo = 'F'; // M ou F
  Lote? _loteSelecionado;
  DateTime? _dataNascimento;
  bool _loading = false;

  // Reprodução (só ativo para Fêmeas)
  bool? _prenha;
  DateTime? _dataCobertura;
  DateTime? _dataParto;
  int? _qtdFilhotes;
  int? _qtdFilhotesVivos;

  bool get _ehFemea => _sexo == 'F';

  // A data prevista do parto é calculada automaticamente a partir da cobertura
  // Gestação bovina padrão: 283 dias
  DateTime? get _dataPartoPrevisto {
    if (_dataCobertura == null) return null;
    return _dataCobertura!.add(const Duration(days: 283));
  }

  @override
  void dispose() {
    _brincoCtrl.dispose();
    _pesoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, {required Function(DateTime) onPicked}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 400)),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_loteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um lote para o animal.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final rebanhoService = ref.read(rebanhoServiceProvider);
      await rebanhoService.cadastrarAnimal(
        loteId: _loteSelecionado!.id,
        brinco: _brincoCtrl.text.trim(),
        tipoAnimal: _tipoAnimal,
        categoria: _categoria,
        raca: _raca,
        sexo: _sexo,
        dataNascimento: _dataNascimento,
        pesoKg: double.tryParse(_pesoCtrl.text),
        prenha: _ehFemea ? _prenha : null,
        dataCobertura: _ehFemea ? _dataCobertura : null,
        dataPartoPrevisto: _ehFemea ? _dataPartoPrevisto : null,
        dataParto: _ehFemea ? _dataParto : null,
        qtdFilhotes: _ehFemea ? _qtdFilhotes : null,
        qtdFilhotesVivos: _ehFemea ? _qtdFilhotesVivos : null,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Animal cadastrado com sucesso!'), backgroundColor: Colors.green),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Animal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── IDENTIFICAÇÃO ──────────────────────────────────────
            _sectionTitle(context, 'Identificação', Icons.tag),
            const SizedBox(height: 12),
            TextFormField(
              controller: _brincoCtrl,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              validator: (v) => v == null || v.isEmpty ? 'Informe o brinco' : null,
              decoration: _inputDecoration('Nº Brinco / Identificação *', Icons.label_outline, context),
            ),
            const SizedBox(height: 12),
            Consumer(
              builder: (context, ref, child) {
                final lotesAsync = ref.watch(lotesProvider);
                return lotesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Erro ao carregar lotes: $e'),
                  data: (lotes) {
                    if (lotes.isEmpty) {
                      return const Text(
                        'Nenhum lote cadastrado. Crie um lote antes de adicionar animais.',
                        style: TextStyle(color: Colors.orange),
                      );
                    }
                    return _dropdown<Lote>(
                      label: 'Lote *',
                      value: _loteSelecionado,
                      items: lotes,
                      itemBuilder: (lote) => DropdownMenuItem<Lote>(
                        value: lote,
                        child: Text(lote.nome),
                      ),
                      onChanged: (v) => setState(() => _loteSelecionado = v),
                      decoration: _inputDecoration(
                        'Lote *',
                        Icons.group_work_outlined,
                        context,
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 12),

            // Sexo — toggle bem grande para uso em campo
            Row(
              children: [
                Expanded(
                  child: _sexoButton('M', 'MACHO', Icons.male, Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _sexoButton('F', 'FÊMEA', Icons.female, Colors.pink),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _dropdown<String>(
                    label: 'Tipo Animal',
                    value: _tipoAnimal,
                    items: const ['Bovino', 'Equino', 'Ovino', 'Suíno', 'Caprino', 'Búfalo'],
                    itemBuilder: (item) => DropdownMenuItem<String>(
                      value: item, child: Text(item),
                    ),
                    onChanged: (v) => setState(() => _tipoAnimal = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dropdown<String>(
                    label: 'Categoria',
                    value: _categoria,
                    items: const ['Bezerro(a)', 'Novilha', 'Vaca', 'Touro', 'Boi', 'Garrote'],
                    itemBuilder: (item) => DropdownMenuItem<String>(
                      value: item, child: Text(item),
                    ),
                    onChanged: (v) => setState(() => _categoria = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _dropdown<String>(
              label: 'Raça',
              value: _raca,
              items: const ['Nelore', 'Angus', 'Brahman', 'Gir', 'Guzerá', 'Girolando', 'Senepol', 'Cruzado', 'Outra'],
              itemBuilder: (item) => DropdownMenuItem<String>(
                value: item, child: Text(item),
              ),
              onChanged: (v) => setState(() => _raca = v!),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _dateTile(
                    label: 'Nascimento',
                    date: _dataNascimento,
                    icon: Icons.cake_outlined,
                    onTap: () => _pickDate(context, onPicked: (d) => setState(() => _dataNascimento = d)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _pesoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Peso (kg)', Icons.monitor_weight_outlined, context),
                  ),
                ),
              ],
            ),

            // ── REPRODUÇÃO (só para fêmeas) ───────────────────────
            if (_ehFemea) ...[
              const SizedBox(height: 24),
              _sectionTitle(context, 'Reprodução', Icons.pregnant_woman),
              const SizedBox(height: 12),
              // Prenha?
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.pregnant_woman, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('Está prenha atualmente?', style: TextStyle(fontSize: 16))),
                      ToggleButtons(
                        isSelected: [_prenha == true, _prenha == false],
                        onPressed: (i) => setState(() => _prenha = i == 0),
                        borderRadius: BorderRadius.circular(8),
                        children: const [
                          Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('SIM', style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('NÃO', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _dateTile(
                      label: 'Data Cobertura / IA',
                      date: _dataCobertura,
                      icon: Icons.event_outlined,
                      onTap: () => _pickDate(context, onPicked: (d) => setState(() => _dataCobertura = d)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dateTile(
                      label: 'Parto Previsto',
                      date: _dataPartoPrevisto,
                      icon: Icons.child_friendly_outlined,
                      onTap: null, // calculado automaticamente
                      isReadOnly: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _sectionTitle(context, 'Último Parto', Icons.history),
              const SizedBox(height: 12),
              _dateTile(
                label: 'Data do Parto',
                date: _dataParto,
                icon: Icons.calendar_today_outlined,
                onTap: () => _pickDate(context, onPicked: (d) => setState(() => _dataParto = d)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _counterField(
                      label: 'Nº Filhotes Nascidos',
                      value: _qtdFilhotes ?? 0,
                      onChanged: (v) => setState(() => _qtdFilhotes = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _counterField(
                      label: 'Nº Vivos',
                      value: _qtdFilhotesVivos ?? 0,
                      onChanged: (v) => setState(() => _qtdFilhotesVivos = v),
                    ),
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
              label: Text(_loading ? 'Salvando...' : 'CADASTRAR ANIMAL'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: Theme.of(context).colorScheme.primary.withOpacity(0.3))),
      ],
    );
  }

  Widget _sexoButton(String valor, String label, IconData icon, Color color) {
    final selected = _sexo == valor;
    return GestureDetector(
      onTap: () => setState(() { _sexo = valor; if (valor == 'M') { _prenha = null; _dataCobertura = null; _dataParto = null; _qtdFilhotes = null; _qtdFilhotesVivos = null; } }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.grey[100],
          border: Border.all(color: selected ? color : Colors.grey[300]!, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: selected ? color : Colors.grey),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: selected ? color : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required DropdownMenuItem<T> Function(T) itemBuilder,
    required void Function(T?) onChanged,
    InputDecoration? decoration,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: decoration ??
          InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
      items: items.map(itemBuilder).toList(),
      onChanged: onChanged,
    );
  }

  Widget _dateTile({required String label, required DateTime? date, required IconData icon, required VoidCallback? onTap, bool isReadOnly = false}) {
    final text = date == null ? 'Selecionar' : '${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year}';
    return GestureDetector(
      onTap: isReadOnly ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isReadOnly ? Colors.grey[100] : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isReadOnly ? Colors.grey : Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(text, style: TextStyle(fontSize: 14, fontWeight: date != null ? FontWeight.bold : FontWeight.normal, color: isReadOnly ? Colors.grey : null)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _counterField({required String label, required int value, required void Function(int) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () { if (value > 0) onChanged(value - 1); },
              ),
              Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => onChanged(value + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, BuildContext context) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
    );
  }
}
