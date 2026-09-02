import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../auth/services/auth_service.dart';

class ProntuarioTimelineItem {
  final String id;
  final String origem;
  final String tipo;
  final DateTime data;
  final String titulo;
  final String autor;
  final Map<String, dynamic> detalhes;
  final String? intervencaoAnteriorId;

  ProntuarioTimelineItem({
    required this.id,
    required this.origem,
    required this.tipo,
    required this.data,
    required this.titulo,
    required this.autor,
    required this.detalhes,
    this.intervencaoAnteriorId,
  });

  factory ProntuarioTimelineItem.fromJson(Map<String, dynamic> json) {
    return ProntuarioTimelineItem(
      id: json['id'] ?? '',
      origem: json['origem'] ?? 'geral',
      tipo: json['tipo'] ?? '',
      data: DateTime.tryParse(json['data'] ?? '') ?? DateTime.now(),
      titulo: json['titulo'] ?? '',
      autor: json['autor'] ?? '',
      detalhes: json['detalhes'] is Map<String, dynamic> ? json['detalhes'] : {},
      intervencaoAnteriorId: json['intervencaoAnteriorId'],
    );
  }
}

class ProntuarioData {
  final Map<String, dynamic> animal;
  final bool multiplosProfissionaisRecentes;
  final List<dynamic> profissionaisRecentes;
  final int totalEventos;
  final List<ProntuarioTimelineItem> timeline;

  ProntuarioData({
    required this.animal,
    required this.multiplosProfissionaisRecentes,
    required this.profissionaisRecentes,
    required this.totalEventos,
    required this.timeline,
  });

  factory ProntuarioData.fromJson(Map<String, dynamic> json) {
    return ProntuarioData(
      animal: json['animal'] is Map<String, dynamic> ? json['animal'] : {},
      multiplosProfissionaisRecentes: json['multiplosProfissionaisRecentes'] ?? false,
      profissionaisRecentes: json['profissionaisRecentes'] as List? ?? [],
      totalEventos: json['totalEventos'] ?? 0,
      timeline: (json['timeline'] as List?)?.map((i) => ProntuarioTimelineItem.fromJson(i)).toList() ?? [],
    );
  }
}

final prontuarioServiceProvider = Provider<ProntuarioService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ProntuarioService(authService);
});

class ProntuarioService {
  final AuthService _authService;

  ProntuarioService(this._authService);

  Future<ProntuarioData> carregarProntuario({
    required String animalId,
    required String tenantContaId,
  }) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Usuário não autenticado.');

    final uri = Uri.parse('${ApiConstants.vetUrl}/animals/$animalId/prontuario?tenantContaId=$tenantContaId');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return ProntuarioData.fromJson(jsonDecode(response.body));
    } else {
      final err = jsonDecode(response.body)['error'] ?? 'Falha ao buscar prontuário';
      throw Exception(err);
    }
  }

  Future<void> registrarIntervencao({
    required String animalId,
    required String tenantContaId,
    required String tipo,
    required Map<String, dynamic> payload,
    String? intervencaoAnteriorId,
  }) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Usuário não autenticado.');

    final response = await http.post(
      Uri.parse('${ApiConstants.vetUrl}/intervencoes'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'animalId': animalId,
        'tenantContaId': tenantContaId,
        'tipo': tipo,
        'payload': payload,
        if (intervencaoAnteriorId != null) 'intervencaoAnteriorId': intervencaoAnteriorId,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 201) {
      final err = jsonDecode(response.body)['error'] ?? 'Falha ao registrar intervenção';
      throw Exception(err);
    }
  }
}
