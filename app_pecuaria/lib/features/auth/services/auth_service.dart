import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

import '../../../data/local/database.dart';
import '../../../providers/database_provider.dart';

final authStateProvider = StateProvider<Usuario?>((ref) => null);

final authServiceProvider = Provider<AuthService>((ref) {
  final db = ref.watch(databaseProvider);
  return AuthService(db, ref);
});

class AuthService {
  final AppDatabase _db;
  final ProviderRef _ref;
  static const String _sessionKey = 'logged_in_user_id';

  AuthService(this._db, this._ref);

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
    final user = await (_db.select(_db.usuarios)
          ..where((u) => u.cpfCnpj.equals(cpfCnpj) & u.senhaHash.equals(senha)))
        .getSingleOrNull();

    if (user == null) {
      throw Exception('Credenciais inválidas.');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, user.id);
    _ref.read(authStateProvider.notifier).state = user;
  }

  Future<void> cadastro(String nome, String cpfCnpj, String senha) async {
    // Check se já existe
    final existing = await (_db.select(_db.usuarios)..where((u) => u.cpfCnpj.equals(cpfCnpj))).getSingleOrNull();
    if (existing != null) {
      throw Exception('CPF/CNPJ já cadastrado.');
    }

    final userId = const Uuid().v4();
    final companion = UsuariosCompanion.insert(
      id: userId,
      nome: nome,
      cpfCnpj: cpfCnpj,
      senhaHash: senha, // Num app real, deve ser hash (ex: BCrypt)
      deviceId: 'device_local_01', 
    );

    await _db.into(_db.usuarios).insert(companion);

    // Cria uma fazenda inicial para o usuário não ver tela vazia
    await _db.into(_db.fazendas).insert(FazendasCompanion.insert(
      id: const Uuid().v4(),
      nome: 'Fazenda Principal',
      cpfCnpj: Value(cpfCnpj),
      responsavel: Value(nome),
      deviceId: 'device_local_01',
    ));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, userId);
    
    final newUser = await (_db.select(_db.usuarios)..where((u) => u.id.equals(userId))).getSingle();
    _ref.read(authStateProvider.notifier).state = newUser;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    _ref.read(authStateProvider.notifier).state = null;
  }
}
