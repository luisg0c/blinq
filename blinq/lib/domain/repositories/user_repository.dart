import '../entities/user.dart';
import '../entities/transaction.dart';

/// Contrato da camada de domínio para operações relacionadas ao usuário.
abstract class UserRepository {
  Future<User> getUserById(String userId);
  Future<User> getUserByEmail(String email);
  Future<User> getCurrentUser();
  Future<void> createTransactionForUser(String userId, Transaction transaction);
  Future<void> saveUser(User user);
}
