import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../services/equipe_service.dart';

final _equipeListProvider = FutureProvider.autoDispose<List<MembroEquipe>>((ref) {
  final service = ref.watch(equipeServiceProvider);
  return service.listarEquipe();
});

class EquipeView extends ConsumerStatefulWidget {
  const EquipeView({super.key});

  @override
  ConsumerState<EquipeView> createState() => _EquipeViewState();
}

class _EquipeViewState extends ConsumerState<EquipeView> {
  void _abrirDialogoConvite() {
    showDialog(
      context: context,
      builder: (ctx) => const _ConvidarFuncionarioDialog(),
    ).then((sucesso) {
      if (sucesso == true) {
        ref.invalidate(_equipeListProvider);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final equipeAsync = ref.watch(_equipeListProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Equipe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(_equipeListProvider),
            tooltip: 'Atualizar Lista',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirDialogoConvite,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Convidar Funcionário'),
      ),
      body: equipeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text('Erro ao carregar equipe: $err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () => ref.invalidate(_equipeListProvider),
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
        data: (membros) {
          if (membros.isEmpty) {
            return const Center(child: Text('Nenhum membro cadastrado na equipe.'));
          }

          final proprietarios = membros.where((m) => m.perfil == 'proprietario').length;
          final funcionarios = membros.where((m) => m.perfil == 'funcionario').length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Card de Resumo da Conta
              Card(
                color: Colors.blueGrey.shade800,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.badge, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${membros.length} Usuário${membros.length > 1 ? 's' : ''} na Fazenda',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$proprietarios Proprietário${proprietarios > 1 ? 's' : ''} • $funcionarios Funcionário${funcionarios > 1 ? 's' : ''}',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Membros Cadastrados',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),

              ...membros.map((membro) {
                final isOwner = membro.perfil == 'proprietario';

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isOwner ? Colors.amber.shade100 : Colors.blue.shade100,
                      child: Icon(
                        isOwner ? Icons.admin_panel_settings : Icons.person,
                        color: isOwner ? Colors.amber.shade900 : Colors.blue.shade900,
                      ),
                    ),
                    title: Text(membro.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'CPF: ${membro.cpfCnpj}${membro.email != null && membro.email!.isNotEmpty ? " • ${membro.email}" : ""}\nCadastrado em: ${dateFormat.format(membro.criadoEm)}',
                    ),
                    isThreeLine: true,
                    trailing: Chip(
                      label: Text(
                        isOwner ? 'Proprietário' : 'Funcionário',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isOwner ? Colors.amber.shade900 : Colors.blue.shade900,
                        ),
                      ),
                      backgroundColor: isOwner ? Colors.amber.shade50 : Colors.blue.shade50,
                      side: BorderSide.none,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 80), // Espaço para FAB
            ],
          );
        },
      ),
    );
  }
}

class _ConvidarFuncionarioDialog extends ConsumerStatefulWidget {
  const _ConvidarFuncionarioDialog();

  @override
  ConsumerState<_ConvidarFuncionarioDialog> createState() => _ConvidarFuncionarioDialogState();
}

class _ConvidarFuncionarioDialogState extends ConsumerState<_ConvidarFuncionarioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _loading = false;

  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _cpfCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviarConvite() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final unmaskedCpf = _cpfFormatter.getUnmaskedText();
      await ref.read(equipeServiceProvider).convidarFuncionario(
        nome: _nomeCtrl.text.trim(),
        cpfCnpj: unmaskedCpf,
        email: _emailCtrl.text.trim(),
        senha: _senhaCtrl.text,
        perfil: 'funcionario',
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Funcionário cadastrado com sucesso!'), backgroundColor: Colors.green),
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
      title: const Text('Convidar Funcionário'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'O funcionário poderá acessar a mesma fazenda e sincronizar manejos no campo.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(labelText: 'Nome Completo', prefixIcon: Icon(Icons.person)),
                validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cpfCtrl,
                inputFormatters: [_cpfFormatter],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'CPF', prefixIcon: Icon(Icons.badge)),
                validator: (v) => _cpfFormatter.getUnmaskedText().length != 11 ? 'Informe um CPF válido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail (opcional)', prefixIcon: Icon(Icons.email)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _senhaCtrl,
                decoration: const InputDecoration(labelText: 'Senha Provisória (mín. 6)', prefixIcon: Icon(Icons.lock)),
                validator: (v) => v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
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
          child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Cadastrar'),
        ),
      ],
    );
  }
}
