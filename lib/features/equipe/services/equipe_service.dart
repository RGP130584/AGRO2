import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../auth/services/auth_service.dart';

class MembroEquipe {
  final String id;
  final String? contaId;
  final String nome;
  final String cpfCnpj;
  final String? email;
  final String perfil;
  final DateTime criadoEm;

  MembroEquipe({
    required this.id,
    this.contaId,
    required this.nome,
    required this.cpfCnpj,
    this.email,
    required this.perfil,
    required this.criadoEm,
  });

  factory MembroEquipe.fromJson(Map<String, dynamic> json) {
    return MembroEquipe(
      id: json['id'],
      contaId: json['contaId'],
      nome: json['nome'],
      cpfCnpj: json['cpfCnpj'],
      email: json['email'],
      perfil: json['perfil'] ?? 'funcionario',
      criadoEm: DateTime.tryParse(json['criadoEm'] ?? '') ?? DateTime.now(),
    );
  }
}

final equipeServiceProvider = Provider<EquipeService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return EquipeService(authService);
});

class EquipeService {
  final AuthService _authService;

  EquipeService(this._authService);

  Future<List<MembroEquipe>> listarEquipe() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Usuário não autenticado.');

    final response = await http.get(
      Uri.parse(ApiConstants.usersUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => MembroEquipe.fromJson(item)).toList();
    } else {
      final err = jsonDecode(response.body)['error'] ?? 'Falha ao buscar equipe';
      throw Exception(err);
    }
  }

  Future<MembroEquipe> convidarFuncionario({
    required String nome,
    required String cpfCnpj,
    required String senha,
    String? email,
    String perfil = 'funcionario',
  }) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Usuário não autenticado.');

    final response = await http.post(
      Uri.parse('${ApiConstants.usersUrl}/invite'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nome': nome,
        'cpfCnpj': cpfCnpj,
        'email': email ?? '',
        'senha': senha,
        'perfil': perfil,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return MembroEquipe.fromJson(data['user']);
    } else {
      final err = jsonDecode(response.body)['error'] ?? 'Falha ao convidar funcionário';
      throw Exception(err);
    }
  }
}
