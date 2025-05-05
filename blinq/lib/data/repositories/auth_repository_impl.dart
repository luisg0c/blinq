import '../models/user_model.dart';
<<<<<<< HEAD
import '../../data/repositories/auth_repository_impl.dart';
=======
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d

/// Interface para o repositório de autenticação
abstract class AuthRepository {
  /// Stream do estado de autenticação (logado/deslogado)
  Stream<bool> get authStateChanges;
<<<<<<< HEAD

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

=======
  
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
  
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
  /// Atualiza dados do perfil do usuário
  Future<void> updateProfile({
    String? name,
    String? photoUrl,
    String? phoneNumber,
  });
<<<<<<< HEAD

  /// Verifica se um email já está em uso
  Future<bool> isEmailInUse(String email);

  /// Atualiza email do usuário
  Future<void> updateEmail(String newEmail, String password);

  /// Atualiza senha do usuário
  Future<void> updatePassword(String currentPassword, String newPassword);

  /// Recarrega dados do usuário
  Future<void> reloadUser();
}
=======
  
  /// Verifica se um email já está em uso
  Future<bool> isEmailInUse(String email);
  
  /// Atualiza email do usuário
  Future<void> updateEmail(String newEmail, String password);
  
  /// Atualiza senha do usuário
  Future<void> updatePassword(String currentPassword, String newPassword);
  
  /// Recarrega dados do usuário
  Future<void> reloadUser();
}
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
