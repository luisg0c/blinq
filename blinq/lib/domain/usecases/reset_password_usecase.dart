import '../repositories/auth_repository.dart';

/// Caso de uso para recuperação de senha.
class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  /// Executa a solicitação de reset de senha para o [email] informado.
  /// 
  /// Retorna void em caso de sucesso.
  /// Lança exceção em caso de falha (ex: email não cadastrado).
  Future<void> execute({
    required String email,
  }) {
    return _repository.resetPassword(email: email);
  }
}
