import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../core/utils/logger.dart';

/// Serviço para autenticação usando Firebase Auth
class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AppLogger logger = AppLogger('AuthService');

  // Stream reativa do usuário atual
  Rx<User?> currentUser = Rx<User?>(null);

  // Estado de autenticação
  RxBool isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Inicializa o usuário atual
    currentUser.value = _auth.currentUser;
    isAuthenticated.value = _auth.currentUser != null;
    // Observa mudanças no estado de autenticação
    _auth.authStateChanges().listen((User? user) {
      currentUser.value = user;
      isAuthenticated.value = user != null;
      if (user != null) {
        logger.info('Usuário autenticado: ${user.uid}');
      } else {
        logger.info('Usuário desconectado');
      }
    });
  }

  /// Registra um novo usuário com email e senha
  Future<User?> signUp(String email, String password) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      currentUser.value = result.user;
      return result.user;
    } on FirebaseAuthException catch (e, stackTrace) {
      logger.error('Erro ao registrar usuário', e, stackTrace);
      _handleFirebaseAuthException(e);
      return null;
    }
  }

  /// Faz login com email e senha
  Future<User?> signIn(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      currentUser.value = result.user;
      return result.user;
    } on FirebaseAuthException catch (e, stackTrace) {
      logger.error('Erro ao fazer login', e, stackTrace);
      _handleFirebaseAuthException(e);
      return null;
    }
  }

  /// Faz logout do usuário atual
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      currentUser.value = null;
    } catch (e, stackTrace) {
      logger.error('Erro ao fazer logout', e, stackTrace);
      rethrow;
    }
  }

  /// Envia email de redefinição de senha
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e, stackTrace) {
      logger.error('Erro ao enviar email de redefinição', e, stackTrace);
      _handleFirebaseAuthException(e);
    }
  }

  /// Recarrega os dados do usuário atual
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
      currentUser.value = _auth.currentUser;
    } catch (e, stackTrace) {
      logger.error('Erro ao recarregar usuário', e, stackTrace);
    }
  }

  /// Verifica se o email já está em uso
  Future<bool> isEmailInUse(String email) async {
    try {
      final List<String> methods =
          await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Mapeia exceções do Firebase Auth para mensagens amigáveis
  void _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        throw 'Usuário não encontrado. Verifique seu email.';
      case 'wrong-password':
        throw 'Senha incorreta. Tente novamente.';
      case 'email-already-in-use':
        throw 'Este email já está em uso. Tente outro.';
      case 'weak-password':
        throw 'Senha muito fraca. Use pelo menos 6 caracteres.';
      case 'invalid-email':
        throw 'Email inválido. Verifique o formato.';
      case 'user-disabled':
        throw 'Esta conta foi desativada.';
      case 'too-many-requests':
        throw 'Muitas tentativas. Tente novamente mais tarde.';
      default:
        throw 'Erro de autenticação: ${e.message}';
    }
  }
}
