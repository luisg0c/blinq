// lib/domain/repositories/auth_repository.dart

import '../entities/user.dart';

/// Contrato da camada de domínio para operações de autenticação.
abstract class AuthRepository {
  /// Autentica um usuário com [email] e [password].
  /// 
  /// Retorna a entidade [User] em caso de sucesso.
  /// Lança uma exceção em caso de falha (ex: credenciais inválidas).
  Future<User> login({
    required String email,
    required String password,
  });

  /// Registra um novo usuário com [name], [email] e [password].
  /// 
  /// Retorna a entidade [User] criada.
  /// Lança uma exceção em caso de falha (ex: email já cadastrado).
  Future<User> register({
    required String name,
    required String email,
    required String password,
  });

  /// Solicita recuperação de senha para o [email].
  /// 
  /// Retorna void se o envio do e-mail de recuperação for bem-sucedido.
  /// Lança uma exceção em caso de falha.
  Future<void> resetPassword({
    required String email,
  });
}
