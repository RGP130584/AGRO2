import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../services/saude_service.dart';
import 'registro_aplicacao_view.dart';
import 'ocorrencia_form_view.dart';

class SaudeView extends ConsumerStatefulWidget {
  const SaudeView({super.key});

  @override
  ConsumerState<SaudeView> createState() => _SaudeViewState();
}

class _SaudeViewState extends ConsumerState<SaudeView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saúde Animal'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.vaccines), text: 'Aplicações'),
            Tab(icon: Icon(Icons.warning_amber), text: 'Ocorrências'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAplicacoesTab(),
          _buildOcorrenciasTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistroAplicacaoView()));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const OcorrenciaFormView()));
          }
        },
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 0 ? 'NOVA APLICAÇÃO' : 'NOVA OCORRÊNCIA'),
      ),
    );
  }

  Widget _buildAplicacoesTab() {
    final saudeService = ref.watch(saudeServiceProvider);
    final db = ref.watch(databaseProvider);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final dateOnly = DateFormat('dd/MM/yyyy');
    final now = DateTime.now();

    return StreamBuilder<List<drift.TypedResult>>(
      stream: saudeService.watchAplicacoesDetalhadas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final rows = snapshot.data ?? [];
        if (rows.isEmpty) {
          return const Center(child: Text('Nenhuma aplicação sanitária registrada.\nToque em NOVA APLICAÇÃO.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rows.length,
          itemBuilder: (context, index) {
            final row = rows[index];
            final app = row.readTable(db.aplicacoesSanitarias);
            final produto = row.readTable(db.produtos);
            final animal = row.readTableOrNull(db.animais);
            final lote = row.readTableOrNull(db.lotes);

            final emCarencia = app.carenciaFimCalculada != null && app.carenciaFimCalculada!.isAfter(now);

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          produto.nome,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        Text(dateFormat.format(app.dataAplicacao), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      animal != null
                          ? 'Animal: Brinco ${animal.brinco}'
                          : (lote != null ? 'Lote: ${lote.nome}' : 'Aplicação Geral'),
                    ),
                    const SizedBox(height: 4),
                    Text('Dose: ${app.dose} ${produto.unidade} via ${app.via}'),
                    if (app.motivo.isNotEmpty) Text('Motivo: ${app.motivo}'),
                    const SizedBox(height: 8),
                    if (emCarencia)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade700),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined, size: 16, color: Colors.amber.shade900),
                            const SizedBox(width: 6),
                            Text(
                              'EM CARÊNCIA até ${dateOnly.format(app.carenciaFimCalculada!)}',
                              style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOcorrenciasTab() {
    final saudeService = ref.watch(saudeServiceProvider);
    final db = ref.watch(databaseProvider);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return StreamBuilder<List<drift.TypedResult>>(
      stream: saudeService.watchOcorrenciasDetalhadas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final rows = snapshot.data ?? [];
        if (rows.isEmpty) {
          return const Center(child: Text('Nenhuma ocorrência registrada.\nToque em NOVA OCORRÊNCIA.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rows.length,
          itemBuilder: (context, index) {
            final row = rows[index];
            final ocorrencia = row.readTable(db.ocorrenciasSanitarias);
            final animal = row.readTable(db.animais);

            final isObito = ocorrencia.tipo == 'obito';

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isObito ? Colors.red.shade100 : Colors.teal.shade100,
                  child: Icon(
                    isObito ? Icons.heart_broken : Icons.medical_information,
                    color: isObito ? Colors.red.shade800 : Colors.teal.shade800,
                  ),
                ),
                title: Text(
                  'Brinco: ${animal.brinco} — ${ocorrencia.tipo.toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(ocorrencia.descricao),
                    const SizedBox(height: 4),
                    Text(dateFormat.format(ocorrencia.dataOcorrencia), style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}