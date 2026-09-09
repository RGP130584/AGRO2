import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../core/widgets/pwa_install_button.dart';
import '../services/auth_service.dart';
import '../../home/views/home_view.dart';
import 'cadastro_view.dart';
import 'forgot_password_view.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _cpfCnpjCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _loading = false;
  bool _obscureText = true;

  final _cpfCnpjFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _cpfCnpjCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  void _onCpfCnpjChanged(String value) {
    // Retira a formatação atual para contar apenas os números
    final unmasked = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Se passar de 11 dígitos numéricos, muda para máscara de CNPJ
    if (unmasked.length > 11) {
      if (_cpfCnpjFormatter.getMask() != '##.###.###/####-##') {
        _cpfCnpjFormatter.updateMask(
            mask: '##.###.###/####-##', filter: {"#": RegExp(r'[0-9]')});
        
        // Aplica a nova máscara ao texto atual
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
            
        // Aplica a nova máscara ao texto atual
        final newText = _cpfCnpjFormatter.maskText(unmasked);
        _cpfCnpjCtrl.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    }
  }

  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final unmaskedCpfCnpj = _cpfCnpjFormatter.getUnmaskedText();
      
      await ref.read(authServiceProvider).login(
        unmaskedCpfCnpj,
        _senhaCtrl.text,
      );
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeView()));
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
        title: const Text('AGRO Pecuária'),
        centerTitle: false,
        actions: const [
          PwaInstallButton(),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/images/logo.png', height: 80, fit: BoxFit.contain, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 24),
                  Text(
                    'AGRO Pecuária',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gestão inteligente na palma da mão',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 48),
                  
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
                    controller: _senhaCtrl,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscureText = !_obscureText),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Informe a senha' : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordView()));
                      },
                      child: const Text('Esqueci minha senha'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  FilledButton(
                    onPressed: _loading ? null : _fazerLogin,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                    ),
                    child: _loading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('ENTRAR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 32),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Primeiro acesso? ', style: TextStyle(fontSize: 16)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastroView()));
                        },
                        child: const Text('Criar conta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
