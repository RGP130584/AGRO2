import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../auth/services/auth_service.dart';

class VetVisitaItem {
  final String id;
  final String tenantContaId;
  final String produtorNome;
  final DateTime dataHora;
  final String status;
  final String? observacoes;
  final int totalIntervencoes;
  final DateTime createdAt;
  final DateTime? concluidaAt;

  VetVisitaItem({
    required this.id,
    required this.tenantContaId,
    required this.produtorNome,
    required this.dataHora,
    required this.status,
    this.observacoes,
    required this.totalIntervencoes,
    required this.createdAt,
    this.concluidaAt,
  });

  factory VetVisitaItem.fromJson(Map<String, dynamic> json) {
    return VetVisitaItem(
      id: json['id'] ?? '',
      tenantContaId: json['tenant_conta_id'] ?? json['tenantContaId'] ?? '',
      produtorNome: json['produtorNome'] ?? json['produtor_nome'] ?? 'Produtor',
      dataHora: DateTime.tryParse(json['data_hora'] ?? json['dataHora'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'agendada',
      observacoes: json['observacoes'],
      totalIntervencoes: json['totalIntervencoes'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
      concluidaAt: json['concluida_at'] != null ? DateTime.tryParse(json['concluida_at']) : null,
    );
  }
}

class VetOrdemServicoItem {
  final String id;
  final String? visitaId;
  final String tenantContaId;
  final String produtorNome;
  final String descricao;
  final List<dynamic> itens;
  final double valorTotal;
  final String status;
  final String? dataVencimento;
  final String? dataPagamento;
  final DateTime createdAt;

  VetOrdemServicoItem({
    required this.id,
    this.visitaId,
    required this.tenantContaId,
    required this.produtorNome,
    required this.descricao,
    required this.itens,
    required this.valorTotal,
    required this.status,
    this.dataVencimento,
    this.dataPagamento,
    required this.createdAt,
  });

  factory VetOrdemServicoItem.fromJson(Map<String, dynamic> json) {
    return VetOrdemServicoItem(
      id: json['id'] ?? '',
      visitaId: json['visita_id'] ?? json['visitaId'],
      tenantContaId: json['tenant_conta_id'] ?? json['tenantContaId'] ?? '',
      produtorNome: json['produtorNome'] ?? json['produtor_nome'] ?? 'Produtor',
      descricao: json['descricao'] ?? '',
      itens: json['itens'] is List ? json['itens'] : [],
      valorTotal: (json['valor_total'] ?? json['valorTotal'] ?? 0).toDouble(),
      status: json['status'] ?? 'aberta',
      dataVencimento: json['data_vencimento'] ?? json['dataVencimento'],
      dataPagamento: json['data_pagamento'] ?? json['dataPagamento'],
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

final vetOperacaoServiceProvider = Provider<VetOperacaoService>((ref) {
  final authService = ref.watch(authServiceProvider);
  return VetOperacaoService(authService);
});

class VetOperacaoService {
  final AuthService _authService;

  VetOperacaoService(this._authService);

  Future<List<VetVisitaItem>> listarVisitas({String? tenantContaId, String? status}) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Usuário não autenticado.');

    final qParams = <String, String>{};
    if (tenantContaId != null) qParams['tenantContaId'] = tenantContaId;
    if (status != null) qParams['status'] = status;

    final uri = Uri.parse('${ApiConstants.vetUrl}/visitas').replace(queryParameters: qParams.isNotEmpty ? qParams : null);
    final res = await http.get(uri, headers: {'Authorization': 'Bearer $token'}).timeout(const Duration(seconds: 10));

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => VetVisitaItem.fromJson(e)).toList();
    } else {
      throw Exception(jsonDecode(res.body)['error'] ?? 'Falha ao buscar visitas');
    }
  }

  Future<List<VetOrdemServicoItem>> listarOrdensServico({String? tenantContaId, String? status}) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Usuário não autenticado.');

    final qParams = <String, String>{};
    if (tenantContaId != null) qParams['tenantContaId'] = tenantContaId;
    if (status != null) qParams['status'] = status;

    final uri = Uri.parse('${ApiConstants.vetUrl}/ordens-servico').replace(queryParameters: qParams.isNotEmpty ? qParams : null);
    final res = await http.get(uri, headers: {'Authorization': 'Bearer $token'}).timeout(const Duration(seconds: 10));

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => VetOrdemServicoItem.fromJson(e)).toList();
    } else {
      throw Exception(jsonDecode(res.body)['error'] ?? 'Falha ao buscar ordens de serviço');
    }
  }

  Future<void> atualizarStatusPagamentoOS(String osId, String status) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Usuário não autenticado.');

    final res = await http.patch(
      Uri.parse('${ApiConstants.vetUrl}/ordens-servico/$osId/pagamento'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status}),
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['error'] ?? 'Falha ao atualizar pagamento da OS');
    }
  }

  Future<Map<String, dynamic>> obterLaudoVisita(String visitaId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Usuário não autenticado.');

    final res = await http.get(
      Uri.parse('${ApiConstants.vetUrl}/visitas/$visitaId/laudo'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception(jsonDecode(res.body)['error'] ?? 'Falha ao buscar laudo da visita');
    }
  }
}
