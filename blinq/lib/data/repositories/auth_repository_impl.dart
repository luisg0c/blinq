import '../models/user_model.dart';
import '../../data/repositories/auth_repository_impl.dart';

/// Interface para o repositório de autenticação
abstract class AuthRepository {
  /// Stream do estado de autenticação (logado/deslogado)
  Stream<bool> get authStateChanges;

  /// Recupera o ID do usuário atual
  String? getCurrentUserId();

  /// Verifica se o usuário está autenticado
  bool isAuthenticated();

  /// Registra um novo usuário com email e senha
  Future<UserModel?> signUp(String email, String password, String name);

  /// Faz login com email e senha
  Future<UserModel?> signIn(String email, String password);

  /// Faz logout do usuário atual
  Future<void> signOut();

  /// Recupera dados do usuário atual
  Future<UserModel?> getCurrentUser();

  /// Envia email de recuperação de senha
  Future<void> sendPasswordResetEmail(String email);

  /// Atualiza dados do perfil do usuário
  Future<void> updateProfile({
    String? name,
    String? photoUrl,
    String? phoneNumber,
  });

  /// Verifica se um email já está em uso
  Future<bool> isEmailInUse(String email);

  /// Atualiza email do usuário
  Future<void> updateEmail(String newEmail, String password);

  /// Atualiza senha do usuário
  Future<void> updatePassword(String currentPassword, String newPassword);

  /// Recarrega dados do usuário
  Future<void> reloadUser();
}
