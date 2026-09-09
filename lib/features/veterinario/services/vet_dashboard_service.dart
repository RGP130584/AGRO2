import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../auth/services/auth_service.dart';

class VetDashboardOverview {
  final int totalFazendasConectadas;
  final int totalAnimais;
  final int totalAlertasCarencia;
  final int totalOcorrenciasAbertas;
  final int totalAlertasEstoque;

  VetDashboardOverview({
    required this.totalFazendasConectadas,
    required this.totalAnimais,
    required this.totalAlertasCarencia,
    required this.totalOcorrenciasAbertas,
    required this.totalAlertasEstoque,
  });

  factory VetDashboardOverview.fromJson(Map<String, dynamic> json) {
    return VetDashboardOverview(
      totalFazendasConectadas: json['totalFazendasConectadas'] ?? 0,
      totalAnimais: json['totalAnimais'] ?? 0,
      totalAlertasCarencia: json['totalAlertasCarencia'] ?? 0,
      totalOcorrenciasAbertas: json['totalOcorrenciasAbertas'] ?? 0,
      totalAlertasEstoque: json['totalAlertasEstoque'] ?? 0,
    );
  }
}

class VetFazendaCardData {
  final String grantId;
  final String tenantContaId;
  final String fazendaNome;
  final String? cidade;
  final String? estado;
  final String produtorNome;
  final String? produtorEmail;
  final List<String> permissions;
  final String? expiresAt;
  final int? diasParaExpirar;
  final int animais;
  final int carenciasAtivas;
  final int ocorrenciasAbertas;
  final int alertasEstoque;

  VetFazendaCardData({
    required this.grantId,
    required this.tenantContaId,
    required this.fazendaNome,
    this.cidade,
    this.estado,
    required this.produtorNome,
    this.produtorEmail,
    required this.permissions,
    this.expiresAt,
    this.diasParaExpirar,
    required this.animais,
    required this.carenciasAtivas,
    required this.ocorrenciasAbertas,
    required this.alertasEstoque,
  });

  factory VetFazendaCardData.fromJson(Map<String, dynamic> json) {
    final ind = json['indicadores'] ?? {};
    return VetFazendaCardData(
      grantId: json['grantId'],
      tenantContaId: json['tenantContaId'],
      fazendaNome: json['fazendaNome'] ?? 'Fazenda',
      cidade: json['cidade'],
      estado: json['estado'],
      produtorNome: json['produtorNome'] ?? '',
      produtorEmail: json['produtorEmail'],
      permissions: (json['permissions'] as List?)?.map((e) => e.toString()).toList() ?? [],
      expiresAt: json['expiresAt'],
      diasParaExpirar: json['diasParaExpirar'],
      animais: ind['animais'] ?? 0,
      carenciasAtivas: ind['carenciasAtivas'] ?? 0,
      ocorrenciasAbertas: ind['ocorrenciasAbertas'] ?? 0,
      alertasEstoque: ind['alertasEstoque'] ?? 0,
    );
  }
}

class VetDashboardData {
  final VetDashboardOverview overview;
  final List<VetFazendaCardData> fazendas;

  VetDashboardData({required this.overview, required this.fazendas});

  factory VetDashboardData.fromJson(Map<String, dynamic> json) {
    return VetDashboardData(
      overview: VetDashboardOverview.fromJson(json['overview'] ?? {}),
      fazendas: (json['fazendas'] as List?)?.map((f) => VetFazendaCardData.fromJson(f)).toList() ?? [],
    );
  }
}

class VetAgendaItem {
  final String id;
  final String tenantContaId;
  final String titulo;
  final String? descricao;
  final DateTime dataHora;
  final String tipo;
  final String status;
  final String produtorNome;

  VetAgendaItem({
    required this.id,
    required this.tenantContaId,
    required this.titulo,
    this.descricao,
    required this.dataHora,
    required this.tipo,
    required this.status,
    required this.produtorNome,
  });

  factory VetAgendaItem.fromJson(Map<String, dynamic> json) {
    return VetAgendaItem(
      id: json['id'],
      tenantContaId: json['tenantContaId'],
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'],
      dataHora: DateTime.tryParse(json['dataHora'] ?? '') ?? DateTime.now(),
      tipo: json['tipo'] ?? 'visita',
      status: json['status'] ?? 'agendado',
      produtorNome: json['produtorNome'] ?? 'Produtor',
    );
  }
}

final vetDashboardServiceProvider = Provider<VetDashboardService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return VetDashboardService(authService);
});

class VetDashboardService {
  final AuthService _authService;

  VetDashboardService(this._authService);

  /// Expõe o AuthService para serviços dependentes (ex: AlertasInteligenteService).
  AuthService get authService => _authService;

  Future<VetDashboardData> carregarDashboard() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Usuário não autenticado.');

    final response = await http.get(
      Uri.parse('${ApiConstants.vetUrl}/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return VetDashboardData.fromJson(jsonDecode(response.body));
    } else {
      final err = jsonDecode(response.body)['error'] ?? 'Falha ao buscar dashboard';
      throw Exception(err);
    }
  }

  Future<List<VetAgendaItem>> carregarAgenda() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Usuário não autenticado.');

    final response = await http.get(
      Uri.parse('${ApiConstants.vetUrl}/agenda'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => VetAgendaItem.fromJson(e)).toList();
    } else {
      final err = jsonDecode(response.body)['error'] ?? 'Falha ao buscar agenda';
      throw Exception(err);
    }
  }

  Future<void> agendarVisita({
    required String tenantContaId,
    required String titulo,
    String? descricao,
    required DateTime dataHora,
    String tipo = 'visita',
  }) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Usuário não autenticado.');

    final response = await http.post(
      Uri.parse('${ApiConstants.vetUrl}/agenda'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'tenantContaId': tenantContaId,
        'titulo': titulo,
        'descricao': descricao,
        'dataHora': dataHora.toIso8601String(),
        'tipo': tipo,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 201) {
      final err = jsonDecode(response.body)['error'] ?? 'Falha ao agendar visita';
      throw Exception(err);
    }
  }
}
