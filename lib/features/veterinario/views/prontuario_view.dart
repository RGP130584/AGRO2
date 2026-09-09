import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../services/prontuario_service.dart';

final _prontuarioProvider = FutureProvider.autoDispose.family<ProntuarioData, ({String animalId, String tenantContaId})>((ref, arg) {
  final service = ref.watch(prontuarioServiceProvider);
  return service.carregarProntuario(animalId: arg.animalId, tenantContaId: arg.tenantContaId);
});

class ProntuarioView extends ConsumerStatefulWidget {
  final String animalId;
  final String tenantContaId;
  final String? brincoAnimal;

  const ProntuarioView({
    super.key,
    required this.animalId,
    required this.tenantContaId,
    this.brincoAnimal,
  });

  @override
  ConsumerState<ProntuarioView> createState() => _ProntuarioViewState();
}

class _ProntuarioViewState extends ConsumerState<ProntuarioView> {
  void _recarregar() {
    ref.invalidate(_prontuarioProvider((animalId: widget.animalId, tenantContaId: widget.tenantContaId)));
  }

  void _abrirModalIntervencao() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _NovaIntervencaoSheet(
        animalId: widget.animalId,
        tenantContaId: widget.tenantContaId,
        onSalvo: () {
          _recarregar();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prontuarioAsync = ref.watch(_prontuarioProvider((animalId: widget.animalId, tenantContaId: widget.tenantContaId)));
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('Prontuário ${widget.brincoAnimal != null ? "• ${widget.brincoAnimal}" : ""}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _recarregar,
            tooltip: 'Atualizar Prontuário',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirModalIntervencao,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Nova Intervenção'),
      ),
      body: prontuarioAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text('Erro ao carregar prontuário: $err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: _recarregar,
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
        data: (data) {
          final timeline = data.timeline;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Alerta de Múltiplos Profissionais (Passo 3)
              if (data.multiplosProfissionaisRecentes) ...[
                Card(
                  color: Colors.amber.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.amber.shade400, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade900, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Múltiplos Atendimentos Recentes',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Este animal foi atendido por mais de um veterinário nos últimos 30 dias. Revise o histórico abaixo para alinhar protocolos.',
                                style: TextStyle(color: Colors.amber.shade900, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Cabeçalho da Timeline
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Histórico Clínico Unificado',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${data.totalEventos} registro${data.totalEventos > 1 ? "s" : ""}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (timeline.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'Nenhum evento clínico ou manejo registrado para este animal.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...timeline.map((item) {
                  Color iconColor = Colors.blueGrey;
                  IconData iconData = Icons.notes;

                  if (item.origem == 'veterinaria') {
                    iconColor = Colors.teal.shade800;
                    iconData = Icons.medical_services;
                  } else if (item.origem == 'sanitaria') {
                    iconColor = Colors.red.shade700;
                    iconData = Icons.vaccines;
                  } else if (item.origem == 'ocorrencia') {
                    iconColor = Colors.orange.shade800;
                    iconData = Icons.warning_amber;
                  } else if (item.origem == 'manejo') {
                    iconColor = Colors.blue.shade800;
                    iconData = Icons.scale;
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: iconColor.withOpacity(0.1),
                            child: Icon(iconData, color: iconColor, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.titulo,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ),
                                    Text(
                                      dateFormat.format(item.data),
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.autor,
                                  style: TextStyle(fontSize: 12, color: iconColor, fontWeight: FontWeight.w600),
                                ),
                                if (item.detalhes.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Text(
                                      item.detalhes.entries
                                          .where((e) => e.value != null && e.value.toString().isNotEmpty)
                                          .map((e) => '${e.key}: ${e.value}')
                                          .join('\n'),
                                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}

class _NovaIntervencaoSheet extends ConsumerStatefulWidget {
  final String animalId;
  final String tenantContaId;
  final VoidCallback onSalvo;

  const _NovaIntervencaoSheet({
    required this.animalId,
    required this.tenantContaId,
    required this.onSalvo,
  });

  @override
  ConsumerState<_NovaIntervencaoSheet> createState() => _NovaIntervencaoSheetState();
}

class _NovaIntervencaoSheetState extends ConsumerState<_NovaIntervencaoSheet> {
  final _formKey = GlobalKey<FormState>();
  String _tipo = 'avaliacao';
  final _descricaoCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  final _carenciaCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _descricaoCtrl.dispose();
    _doseCtrl.dispose();
    _carenciaCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final payload = <String, dynamic>{
        'descricao': _descricaoCtrl.text.trim(),
      };

      if (_tipo == 'aplicacao') {
        payload['doseMl'] = double.tryParse(_doseCtrl.text) ?? 0;
        payload['carenciaDias'] = int.tryParse(_carenciaCtrl.text) ?? 0;
      }

      await ref.read(prontuarioServiceProvider).registrarIntervencao(
        animalId: widget.animalId,
        tenantContaId: widget.tenantContaId,
        tipo: _tipo,
        payload: payload,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onSalvo();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Intervenção registrada com sucesso!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString().replaceAll("Exception: ", "")}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: keyboardPadding + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Registrar Intervenção Clínica', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(labelText: 'Tipo de Intervenção', prefixIcon: Icon(Icons.category)),
                items: const [
                  DropdownMenuItem(value: 'avaliacao', child: Text('Avaliação Clínica / Observação')),
                  DropdownMenuItem(value: 'prescricao', child: Text('Prescrição Médica')),
                  DropdownMenuItem(value: 'aplicacao', child: Text('Aplicação Sanitária (Medicamento)')),
                  DropdownMenuItem(value: 'retorno', child: Text('Consulta de Retorno')),
                  DropdownMenuItem(value: 'encerramento', child: Text('Encerramento de Protocolo')),
                ],
                onChanged: (v) => setState(() => _tipo = v ?? 'avaliacao'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricaoCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição do Procedimento / Diagnóstico',
                  alignLabelWithHint: true,
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Informe os detalhes da intervenção' : null,
              ),
              if (_tipo == 'aplicacao') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _doseCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Dose (ml)'),
                        validator: (v) => v == null || v.isEmpty ? 'Informe a dose' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _carenciaCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Carência (dias)'),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _loading ? null : _salvar,
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Salvar no Prontuário'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
