import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para autenticação de usuário.
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  /// Executa o login com [email] e [password].
  /// 
  /// Retorna a entidade [User] em caso de sucesso.
  /// Lança exceção em caso de erro no login.
  Future<User> execute({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
