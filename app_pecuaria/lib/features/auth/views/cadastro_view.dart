import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../services/auth_service.dart';
import '../../home/views/home_view.dart';

class CadastroView extends ConsumerStatefulWidget {
  const CadastroView({super.key});

  @override
  ConsumerState<CadastroView> createState() => _CadastroViewState();
}

class _CadastroViewState extends ConsumerState<CadastroView> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _cpfCnpjCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  String _perfil = 'proprietario';
  bool _loading = false;
  bool _obscureText = true;

  final _cpfCnpjFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _cpfCnpjCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  void _onCpfCnpjChanged(String value) {
    final unmasked = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (unmasked.length > 11) {
      if (_cpfCnpjFormatter.getMask() != '##.###.###/####-##') {
        _cpfCnpjFormatter.updateMask(
            mask: '##.###.###/####-##', filter: {"#": RegExp(r'[0-9]')});
        final newText = _cpfCnpjFormatter.maskText(unmasked);
        _cpfCnpjCtrl.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    } else {
      if (_cpfCnpjFormatter.getMask() != '###.###.###-##') {
        _cpfCnpjFormatter.updateMask(
            mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
        final newText = _cpfCnpjFormatter.maskText(unmasked);
        _cpfCnpjCtrl.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    }
  }

  Future<void> _fazerCadastro() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final unmaskedCpfCnpj = _cpfCnpjFormatter.getUnmaskedText();
      
      await ref.read(authServiceProvider).cadastro(
        _nomeCtrl.text.trim(),
        unmaskedCpfCnpj,
        _emailCtrl.text.trim(),
        _senhaCtrl.text,
        perfil: _perfil,
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeView()),
          (route) => false,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Crie sua conta para utilizar o modo offline',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // Seletor de Perfil (Proprietário vs Funcionário)
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'proprietario',
                      label: Text('Proprietário'),
                      icon: Icon(Icons.admin_panel_settings_outlined),
                    ),
                    ButtonSegment(
                      value: 'funcionario',
                      label: Text('Funcionário'),
                      icon: Icon(Icons.badge_outlined),
                    ),
                  ],
                  selected: {_perfil},
                  onSelectionChanged: (set) => setState(() => _perfil = set.first),
                ),
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: _nomeCtrl,
                  decoration: InputDecoration(
                    labelText: 'Seu Nome ou Razão Social',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Informe seu nome' : null,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _cpfCnpjCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cpfCnpjFormatter],
                  onChanged: _onCpfCnpjChanged,
                  decoration: InputDecoration(
                    labelText: 'CPF ou CNPJ',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                  ),
                  validator: (v) {
                    final len = _cpfCnpjFormatter.getUnmaskedText().length;
                    if (len != 11 && len != 14) {
                      return 'Informe um CPF ou CNPJ válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe seu e-mail';
                    if (!v.contains('@') || !v.contains('.')) return 'E-mail inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _senhaCtrl,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'Senha (mínimo 6 caracteres)',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                  ),
                  validator: (v) => v == null || v.length < 6 ? 'Senha deve ter pelo menos 6 caracteres' : null,
                ),
                const SizedBox(height: 48),
                
                FilledButton(
                  onPressed: _loading ? null : _fazerCadastro,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                  ),
                  child: _loading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('CADASTRAR E ENTRAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
