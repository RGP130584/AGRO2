import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../services/vet_grant_service.dart';

final _vetGrantsProvider = FutureProvider.autoDispose<List<VetGrant>>((ref) {
  final service = ref.watch(vetGrantServiceProvider);
  return service.listarGrants();
});

class MeusVeterinariosView extends ConsumerStatefulWidget {
  const MeusVeterinariosView({super.key});

  @override
  ConsumerState<MeusVeterinariosView> createState() => _MeusVeterinariosViewState();
}

class _MeusVeterinariosViewState extends ConsumerState<MeusVeterinariosView> {
  void _abrirDialogoConvite() {
    showDialog(
      context: context,
      builder: (ctx) => const _ConvidarVeterinarioDialog(),
    ).then((sucesso) {
      if (sucesso == true) {
        ref.invalidate(_vetGrantsProvider);
      }
    });
  }

  Future<void> _confirmarRevogacao(VetGrant grant) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revogar Acesso?'),
        content: Text(
          'Deseja revogar o acesso do ${grant.veterinarianNome ?? "veterinário"}?\n\n'
          'Ele não poderá mais acessar ou sincronizar dados desta fazenda. O histórico existente será mantido.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Revogar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await ref.read(vetGrantServiceProvider).revogarGrant(grant.id);
        ref.invalidate(_vetGrantsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Acesso revogado com sucesso.'), backgroundColor: Colors.orange),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final grantsAsync = ref.watch(_vetGrantsProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Veterinários & Consultores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(_vetGrantsProvider),
            tooltip: 'Atualizar Lista',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirDialogoConvite,
        icon: const Icon(Icons.medical_services_outlined),
        label: const Text('Convidar Veterinário'),
      ),
      body: grantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text('Erro ao carregar compartilhamentos: $err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () => ref.invalidate(_vetGrantsProvider),
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
        data: (grants) {
          if (grants.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Nenhum veterinário ou consultor vinculado a esta fazenda.\n\nClique no botão abaixo para conceder acesso técnico.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.teal.shade900,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.verified_user, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${grants.length} Profissional${grants.length > 1 ? 'is' : ''} Conectado${grants.length > 1 ? 's' : ''}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Acesso técnico com consentimento e rastreabilidade total (LGPD).',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Compartilhamentos Ativos e Pendentes',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),

              ...grants.map((grant) {
                final isActive = grant.status == 'active';
                final isPending = grant.status == 'pending';
                final isRevoked = grant.status == 'revoked';

                Color statusColor = Colors.grey;
                String statusLabel = 'Desconhecido';
                if (isActive) {
                  statusColor = Colors.green;
                  statusLabel = 'Ativo';
                } else if (isPending) {
                  statusColor = Colors.orange;
                  statusLabel = 'Pendente';
                } else if (isRevoked) {
                  statusColor = Colors.red;
                  statusLabel = 'Revogado';
                }

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.teal.shade100,
                              child: Icon(Icons.health_and_safety, color: Colors.teal.shade900),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    grant.veterinarianNome ?? 'Veterinário Convidado',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  if (grant.crmv != null)
                                    Text('CRMV: ${grant.crmv}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                ],
                              ),
                            ),
                            Chip(
                              label: Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                              backgroundColor: statusColor.withOpacity(0.1),
                              side: BorderSide.none,
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            const Text('Permissões: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ...grant.permissions.map((p) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(6)),
                              child: Text(p, style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade800)),
                            )),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Concedido em: ${dateFormat.format(grant.createdAt)}'
                          '${grant.acceptedAt != null ? " • Aceito em: ${dateFormat.format(grant.acceptedAt!)}" : ""}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        if (!isRevoked) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => _confirmarRevogacao(grant),
                              icon: const Icon(Icons.block, size: 18, color: Colors.red),
                              label: const Text('Revogar Acesso', style: TextStyle(color: Colors.red)),
                            ),
                          ),
                        ],
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

class _ConvidarVeterinarioDialog extends ConsumerStatefulWidget {
  const _ConvidarVeterinarioDialog();

  @override
  ConsumerState<_ConvidarVeterinarioDialog> createState() => _ConvidarVeterinarioDialogState();
}

class _ConvidarVeterinarioDialogState extends ConsumerState<_ConvidarVeterinarioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _crmvCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _crmvCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviarConvite() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await ref.read(vetGrantServiceProvider).convidarVeterinario(
        crmv: _crmvCtrl.text.trim().isNotEmpty ? _crmvCtrl.text.trim() : null,
        email: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Convite enviado com sucesso!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString().replaceAll('Exception: ', '')}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Convidar Veterinário'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Informe o CRMV ou e-mail do veterinário cadastrado na plataforma.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _crmvCtrl,
                decoration: const InputDecoration(labelText: 'CRMV (ex: CRMV-SP-12345)', prefixIcon: Icon(Icons.badge)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail do profissional', prefixIcon: Icon(Icons.email)),
                validator: (v) {
                  if (_crmvCtrl.text.trim().isEmpty && (v == null || v.trim().isEmpty)) {
                    return 'Informe o CRMV ou o E-mail';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _loading ? null : _enviarConvite,
          child: _loading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Enviar Convite'),
        ),
      ],
    );
  }
}
