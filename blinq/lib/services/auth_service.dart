import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../core/utils/validators.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();

  // Stream de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Método de registro
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    required DateTime birthDate,
    String? phoneNumber,
  }) async {
    try {
      // Validações iniciais
      Validators.validateEmail(email);
      Validators.validatePassword(password);
      Validators.validateFullName(name);

      // Verificar se email já existe
      final existingUser = await _userRepository.getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('Email já cadastrado');
      }

      // Criar usuário no Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (userCredential.user == null) {
        throw Exception('Falha ao criar usuário');
      }

      // Atualizar nome no perfil do Firebase
      await userCredential.user!.updateDisplayName(name);

      // Gerar número de conta único
      String accountNumber;
      do {
        accountNumber = UserModel._generateUniqueAccountNumber();
      } while (!await _userRepository.isAccountNumberAvailable(accountNumber));

      // Criar modelo de usuário
      final user = UserModel.create(
          email: email,
          name: name,
          birthDate: birthDate,
          phoneNumber: phoneNumber,
          accountNumber: accountNumber);

      // Salvar usuário no Firestore
      final savedUser = await _userRepository.createUser(user);

      if (savedUser == null) {
        // Remover usuário do Firebase Auth se falhar no Firestore
        await userCredential.user!.delete();
        throw Exception('Falha ao salvar usuário');
      }

      // Enviar email de verificação
      await userCredential.user!.sendEmailVerification();

      return savedUser;
    } catch (e) {
      print('Erro no cadastro: $e');
      rethrow;
    }
  }

  // Método de login
  Future<UserModel?> signIn(String email, String password) async {
    try {
      // Validações
      Validators.validateEmail(email);

      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (userCredential.user == null) {
        throw Exception('Usuário não encontrado');
      }

      // Buscar usuário completo no Firestore
      return await _userRepository.getUserByEmail(email);
    } catch (e) {
      print('Erro no login: $e');
      rethrow;
    }
  }

  // Método de logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Erro no logout: $e');
      rethrow;
    }
  }

  // Recuperação de senha
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      Validators.validateEmail(email);
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Erro ao enviar email de recuperação: $e');
      rethrow;
    }
  }

  // Atualizar perfil
  Future<UserModel?> updateProfile({
    String? name,
    String? phoneNumber,
  }) async {
    try {
      final currentUser = getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      // Validações
      if (name != null) Validators.validateFullName(name);
      if (phoneNumber != null) Validators.validateBrazilianPhone(phoneNumber);

      // Atualizar no Firebase Auth
      final user = _auth.currentUser;
      if (name != null) await user?.updateDisplayName(name);

      // Atualizar no Firestore
      final updatedUser = currentUser.copyWith(
        name: name,
        phoneNumber: phoneNumber,
      );

      await _userRepository.updateUser(updatedUser);

      return updatedUser;
    } catch (e) {
      print('Erro ao atualizar perfil: $e');
      rethrow;
    }
  }

  // Obter usuário atual
  UserModel? getCurrentUser() {
    final user = _auth.currentUser;
    return user != null
        ? UserModel(
            id: user.uid,
            email: user.email!,
            name: user.displayName ?? '',
            accountNumber: '', // Será buscado do Firestore
            birthDate: DateTime.now(), // Será buscado do Firestore
            isEmailVerified: user.emailVerified)
        : null;
  }

  // Buscar usuário por email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      return await _userRepository.getUserByEmail(email);
    } catch (e) {
      print('Erro ao buscar usuário por email: $e');
      return null;
    }
  }

  // Verificar status de email
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      return user.emailVerified;
    }
    return false;
  }

  // Reenviar email de verificação
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
}
