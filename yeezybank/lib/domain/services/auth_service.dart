import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable para monitorar o estado de autenticação
  final Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    // Inicializar o usuário atual
    currentUser.value = _auth.currentUser;

    // Ouvir alterações no estado de autenticação
    _auth.authStateChanges().listen((User? user) {
      currentUser.value = user;
    });
  }

  // Stream para alterações de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Entrar com email e senha
  Future<User?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      currentUser.value = result.user;
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  // Cadastrar com email e senha
  Future<User?> signUp(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      currentUser.value = result.user;
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  // Fazer logout
  Future<void> signOut() async {
    await _auth.signOut();
    currentUser.value = null;
  }

  // Obter usuário atual
  User? getCurrentUser() => _auth.currentUser;

  // Obter ID do usuário atual com tratamento de erro melhorado
  String getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null) {
      throw 'Usuário não logado';
    }
    return user.uid;
  }

  // Verificar se há usuário logado
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Enviar email de recuperação de senha
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  // Recarregar dados do usuário (útil para verificar alterações)
  Future<void> reloadCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        currentUser.value = _auth.currentUser;
      }
    } catch (e) {
      print('Erro ao recarregar usuário: $e');
    }
  }

  // Mapear erros do Firebase para mensagens amigáveis
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Email inválido.';
      case 'user-disabled':
        return 'Conta desativada.';
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Email já cadastrado.';
      case 'weak-password':
        return 'Senha muito fraca.';
      case 'operation-not-allowed':
        return 'Operação não permitida.';
      case 'account-exists-with-different-credential':
        return 'Já existe uma conta com este email.';
      case 'invalid-credential':
        return 'Credencial inválida.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      default:
        return 'Erro: ${e.message}';
    }
  }
}
