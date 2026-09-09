import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

class ForgotPasswordView extends ConsumerStatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  ConsumerState<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends ConsumerState<ForgotPasswordView> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _tokenSent = false;
  
  final _tokenCtrl = TextEditingController();
  final _novaSenhaCtrl = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _tokenCtrl.dispose();
    _novaSenhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestReset() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E-mail inválido')));
      return;
    }
    
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).requestPasswordReset(email);
      if (mounted) setState(() => _tokenSent = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmReset() async {
    final token = _tokenCtrl.text.trim();
    final senha = _novaSenhaCtrl.text;
    
    if (token.isEmpty || senha.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dados inválidos')));
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).confirmPasswordReset(token, senha);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senha alterada com sucesso!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Senha')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_tokenSent) ...[
                const Text('Informe o seu e-mail de cadastro para receber um código de recuperação.'),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _requestReset,
                  child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('ENVIAR CÓDIGO'),
                ),
              ] else ...[
                const Text('Enviamos um código para o seu e-mail. Informe-o abaixo junto com a sua nova senha.'),
                const SizedBox(height: 24),
                TextField(
                  controller: _tokenCtrl,
                  decoration: const InputDecoration(labelText: 'Código de Recuperação', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _novaSenhaCtrl,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'Nova Senha',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _confirmReset,
                  child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('CONFIRMAR NOVA SENHA'),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
