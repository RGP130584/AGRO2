import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../auth/services/auth_service.dart';

class VetGrant {
  final String id;
  final String? veterinarianId;
  final String? veterinarianNome;
  final String? crmv;
  final String? telefone;
  final String scopeType;
  final List<String> permissions;
  final String status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? expiresAt;
  final DateTime? revokedAt;

  VetGrant({
    required this.id,
    this.veterinarianId,
    this.veterinarianNome,
    this.crmv,
    this.telefone,
    required this.scopeType,
    required this.permissions,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.expiresAt,
    this.revokedAt,
  });

  factory VetGrant.fromJson(Map<String, dynamic> json) {
    return VetGrant(
      id: json['id'],
      veterinarianId: json['veterinarianId'],
      veterinarianNome: json['veterinarianNome'],
      crmv: json['crmv'],
      telefone: json['telefone'],
      scopeType: json['scopeType'] ?? 'fazenda',
      permissions: (json['permissions'] as List?)?.map((e) => e.toString()).toList() ?? ['consulta'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      acceptedAt: json['acceptedAt'] != null ? DateTime.tryParse(json['acceptedAt']) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt']) : null,
      revokedAt: json['revokedAt'] != null ? DateTime.tryParse(json['revokedAt']) : null,
    );
  }
}

final vetGrantServiceProvider = Provider<VetGrantService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return VetGrantService(authService);
});

class VetGrantService {
  final AuthService _authService;

  VetGrantService(this._authService);

  Future<List<VetGrant>> listarGrants() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Usuário não autenticado.');

    final response = await http.get(
      Uri.parse('${ApiConstants.vetUrl}/grants'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => VetGrant.fromJson(item)).toList();
    } else {
      final err = jsonDecode(response.body)['error'] ?? 'Falha ao buscar compartilhamentos';
      throw Exception(err);
    }
  }

  Future<VetGrant> convidarVeterinario({
    String? crmv,
    String? email,
    List<String> permissions = const ['consulta', 'tecnico', 'intervencao'],
  }) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Usuário não autenticado.');

    final response = await http.post(
      Uri.parse('${ApiConstants.vetUrl}/grants'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        if (crmv != null && crmv.isNotEmpty) 'crmv': crmv,
        if (email != null && email.isNotEmpty) 'email': email,
        'scopeType': 'fazenda',
        'permissions': permissions,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return VetGrant.fromJson(data['grant']);
    } else {
      final err = jsonDecode(response.body)['error'] ?? 'Falha ao convidar veterinário';
      throw Exception(err);
    }
  }

  Future<void> revogarGrant(String grantId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Usuário não autenticado.');

    final response = await http.delete(
      Uri.parse('${ApiConstants.vetUrl}/grants/$grantId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      final err = jsonDecode(response.body)['error'] ?? 'Falha ao revogar acesso';
      throw Exception(err);
    }
  }
}
