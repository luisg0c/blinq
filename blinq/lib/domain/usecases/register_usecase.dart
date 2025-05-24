import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para registro de novo usuário.
class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  /// Executa o registro com [name], [email] e [password].
  /// 
  /// Retorna a entidade [User] criada em caso de sucesso.
  /// Lança exceção em caso de erro (ex: email já cadastrado).
  Future<User> execute({
    required String name,
    required String email,
    required String password,
  }) {
    return _repository.register(
      name: name,
      email: email,
      password: password,
    );
  }
}
