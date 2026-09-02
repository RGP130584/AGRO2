import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../auth/services/auth_service.dart';
import '../../../core/constants/api_constants.dart';

class AlertasInteligenteService {
  final AuthService _authService;
  AlertasInteligenteService(this._authService);

  /// Busca alertas baseados em regra para os tenants autorizados.
  /// [tenantContaId] opcional — filtra para uma fazenda específica.
  Future<Map<String, dynamic>> getAlertas({String? tenantContaId}) async {
    final token = await _authService.getToken();
    final uri = Uri.parse(
      '${ApiConstants.vetUrl}/alertas${tenantContaId != null ? '?tenantContaId=$tenantContaId' : ''}',
    );
    final resp = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Erro ao buscar alertas: ${resp.body}');
  }
}
