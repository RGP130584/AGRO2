/// Configurações e URLs base da API do sistema AGRO.
/// Permite injeção de variáveis via `--dart-define=API_BASE_URL=...` ou fallback automático.
class ApiConstants {
  ApiConstants._();

  /// URL base da API REST (ex: http://10.0.2.2:3000 ou https://api.agro.com.br)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/v1',
  );

  /// Endpoint de Autenticação
  static String get authUrl => '$baseUrl/auth';

  /// Endpoint de Sincronização
  static String get syncUrl => '$baseUrl/sync';

  /// Endpoint de Gestão de Usuários e Equipe
  static String get usersUrl => '$baseUrl/users';

  /// Endpoint do Módulo Veterinário e Sharing Grants
  static String get vetUrl => '$baseUrl/vet';
}
