import '../entities/user.dart';
import '../entities/transaction.dart';

/// Contrato de repositório para informações e ações sobre usuários.
abstract class UserRepository {
  /// Retorna os dados do usuário atualmente autenticado.
  Future<User> getCurrentUser();

  /// Busca um usuário a partir do e-mail.
  Future<User> getUserByEmail(String email);

  /// Cria uma transação para outro usuário (usado em transferências).
  Future<void> createTransactionForUser(String userId, Transaction transaction);
}
