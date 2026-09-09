import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../auth/services/auth_service.dart';

class RecomendacaoNutricional {
  final String id;
  final String loteId;
  final String? loteNome;
  final String tenantContaId;
  final String veterinarianId;
  final String? veterinarianNome;
  final String? veterinarianCrmv;
  final Map<String, dynamic> dietaSugerida;
  final String? justificativa;
  final String status;
  final DateTime createdAt;
  final DateTime? decidedAt;

  RecomendacaoNutricional({
    required this.id,
    required this.loteId,
    this.loteNome,
    required this.tenantContaId,
    required this.veterinarianId,
    this.veterinarianNome,
    this.veterinarianCrmv,
    required this.dietaSugerida,
    this.justificativa,
    required this.status,
    required this.createdAt,
    this.decidedAt,
  });

  factory RecomendacaoNutricional.fromJson(Map<String, dynamic> json) {
    return RecomendacaoNutricional(
      id: json['id'] ?? '',
      loteId: json['lote_id'] ?? json['loteId'] ?? '',
      loteNome: json['loteNome'] ?? json['lote_nome'],
      tenantContaId: json['tenant_conta_id'] ?? json['tenantContaId'] ?? '',
      veterinarianId: json['veterinarian_id'] ?? json['veterinarianId'] ?? '',
      veterinarianNome: json['veterinarianNome'] ?? json['veterinarian_nome'],
      veterinarianCrmv: json['veterinarianCrmv'] ?? json['veterinarian_crmv'],
      dietaSugerida: json['dietaSugerida'] is Map<String, dynamic>
          ? json['dietaSugerida']
          : json['dieta_sugerida'] is String
              ? jsonDecode(json['dieta_sugerida'])
              : {},
      justificativa: json['justificativa'],
      status: json['status'] ?? 'pendente',
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
      decidedAt: json['decided_at'] != null ? DateTime.tryParse(json['decided_at']) : null,
    );
  }
}

final nutricaoRecomendacaoServiceProvider = Provider<NutricaoRecomendacaoService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return NutricaoRecomendacaoService(authService);
});

class NutricaoRecomendacaoService {
  final AuthService _authService;

  NutricaoRecomendacaoService(this._authService);

  Future<List<RecomendacaoNutricional>> listarRecomendacoes({String? loteId, String? tenantContaId}) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Usuário não autenticado.');

    final queryParams = <String, String>{};
    if (loteId != null) queryParams['loteId'] = loteId;
    if (tenantContaId != null) queryParams['tenantContaId'] = tenantContaId;

    final uri = Uri.parse('${ApiConstants.vetUrl}/nutricao/recomendacoes').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => RecomendacaoNutricional.fromJson(e)).toList();
    } else {
      final err = jsonDecode(response.body)['error'] ?? 'Falha ao buscar recomendações nutricionais';
      throw Exception(err);
    }
  }

  Future<void> aplicarRecomendacao(String recomendacaoId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Usuário não autenticado.');

    final response = await http.post(
      Uri.parse('${ApiConstants.vetUrl}/nutricao/recomendacoes/$recomendacaoId/aplicar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      final err = jsonDecode(response.body)['error'] ?? 'Falha ao aplicar recomendação nutricional';
      throw Exception(err);
    }
  }

  Future<void> enviarRecomendacao({
    required String loteId,
    required String tenantContaId,
    required Map<String, dynamic> dietaSugerida,
    String? justificativa,
  }) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Usuário não autenticado.');

    final response = await http.post(
      Uri.parse('${ApiConstants.vetUrl}/nutricao/recomendacoes'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'loteId': loteId,
        'tenantContaId': tenantContaId,
        'dietaSugerida': dietaSugerida,
        'justificativa': justificativa,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 201) {
      final err = jsonDecode(response.body)['error'] ?? 'Falha ao enviar recomendação nutricional';
      throw Exception(err);
    }
  }
}
