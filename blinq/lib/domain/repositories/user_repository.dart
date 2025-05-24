import '../entities/user.dart';

/// Contrato da camada de domínio para operações relacionadas ao usuário.
abstract class UserRepository {
  /// Obtém um usuário pelo ID.
  Future<User> getUserById(String userId);
  
  /// Obtém um usuário pelo email.
  Future<User> getUserByEmail(String email);
  
  /// Salva ou atualiza informações do usuário.
  Future<void> saveUser(User user);
  
  /// Busca usuários por email (para autocomplete em transferências).
  Future<List<User>> searchUsersByEmail(String emailQuery);
}