import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/device_info_provider.dart';

final authStateProvider = StateProvider<Usuario?>((ref) => null);

final authServiceProvider = Provider<AuthService>((ref) {
  final db = ref.watch(databaseProvider);
  return AuthService(db, ref);
});

class AuthService {
  final AppDatabase _db;
  final ProviderRef _ref;
  static const String _sessionKey = 'logged_in_user_id';
  static const String _jwtKey = 'jwt_token';
  final _storage = const FlutterSecureStorage();
  
  // TODO: extract to env
  static const String _apiBaseUrl = 'http://10.0.2.2:3000/v1/auth';

  AuthService(this._db, this._ref);

  String _hashSenha(String senha) {
    return sha256.convert(utf8.encode(senha)).toString();
  }

  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_sessionKey);
    
    if (userId != null) {
      final user = await (_db.select(_db.usuarios)..where((u) => u.id.equals(userId))).getSingleOrNull();
      if (user != null) {
        _ref.read(authStateProvider.notifier).state = user;
        return;
      }
    }
    _ref.read(authStateProvider.notifier).state = null;
  }

  Future<void> login(String cpfCnpj, String senha) async {
    final hashedSenha = _hashSenha(senha);
    
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cpfCnpj': cpfCnpj, 'senha': senha}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userId = data['user']['id'];
        
        await _storage.write(key: _jwtKey, value: token);
        
        // Salva hash e info localmente
        await _db.into(_db.usuarios).insertOnConflictUpdate(UsuariosCompanion.insert(
          id: userId,
          nome: data['user']['nome'],
          cpfCnpj: data['user']['cpfCnpj'],
          email: drift.Value(data['user']['email'] ?? ''),
          senhaHash: hashedSenha,
          deviceId: await _ref.read(deviceIdProvider.future)
        ));

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_sessionKey, userId);
        _ref.read(authStateProvider.notifier).state = await (_db.select(_db.usuarios)..where((u) => u.id.equals(userId))).getSingle();
        return;
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Falha no login');
      }
    } catch (e) {
      // Fallback offline
      final user = await (_db.select(_db.usuarios)
            ..where((u) => u.cpfCnpj.equals(cpfCnpj) & u.senhaHash.equals(hashedSenha)))
          .getSingleOrNull();

      if (user == null) {
        throw Exception('Credenciais inválidas ou você está offline no seu primeiro acesso.');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, user.id);
      _ref.read(authStateProvider.notifier).state = user;
    }
  }

  Future<void> cadastro(String nome, String cpfCnpj, String email, String senha) async {
    final hashedSenha = _hashSenha(senha);
    
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nome,
          'cpfCnpj': cpfCnpj,
          'email': email,
          'senha': senha,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userId = data['user']['id'];
        final deviceId = await _ref.read(deviceIdProvider.future);
        
        await _storage.write(key: _jwtKey, value: token);
        
        final companion = UsuariosCompanion.insert(
          id: userId,
          nome: nome,
          cpfCnpj: cpfCnpj,
          email: drift.Value(email),
          senhaHash: hashedSenha,
          deviceId: deviceId, 
        );

        await _db.into(_db.usuarios).insert(companion);

        await _db.into(_db.fazendas).insert(FazendasCompanion.insert(
          id: const Uuid().v4(),
          nome: 'Fazenda Principal',
          cpfCnpj: drift.Value(cpfCnpj),
          responsavel: drift.Value(nome),
          deviceId: deviceId,
        ));

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_sessionKey, userId);
        _ref.read(authStateProvider.notifier).state = await (_db.select(_db.usuarios)..where((u) => u.id.equals(userId))).getSingle();
        return;
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Falha no cadastro');
      }
    } catch (e) {
       throw Exception('Erro de conexão com o servidor. O cadastro inicial precisa de internet.');
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _jwtKey);
  }

  Future<void> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse('$_apiBaseUrl/password-reset/request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Falha ao solicitar reset');
    }
  }

  Future<void> confirmPasswordReset(String token, String novaSenha) async {
    final response = await http.post(
      Uri.parse('$_apiBaseUrl/password-reset/confirm'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'novaSenha': novaSenha}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Falha ao confirmar reset');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await _storage.delete(key: _jwtKey);
    _ref.read(authStateProvider.notifier).state = null;
  }
}
