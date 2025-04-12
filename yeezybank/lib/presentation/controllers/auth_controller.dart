import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/services/auth_service.dart';
import '../../data/firebase_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Verificar estado de autenticação atual
    checkAuthStatus();
    // Escutar mudanças de autenticação
    _firebaseService.authStateChanges.listen((user) {
      isAuthenticated.value = user != null;
    });
  }

  // Verificar se o usuário está autenticado
  void checkAuthStatus() {
    isAuthenticated.value = _authService.getCurrentUser() != null;
  }

  // Login
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Preencha todos os campos');
      return;
    }

    isLoading.value = true;
    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        // Garantir que o email está corretamente armazenado no Firestore
        await _ensureAccountExists(user.uid, email);
        isAuthenticated.value = true;
      }
      clearFields();
      Get.offAllNamed('/home');
    } catch (e) {
      _showError(e.toString());
      isAuthenticated.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  // Cadastro
  Future<void> signup() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Preencha todos os campos');
      return;
    }

    isLoading.value = true;
    try {
      final user = await _authService.signUp(email, password);
      if (user != null) {
        // Criar conta no Firestore com email
        await _firebaseService.createAccount(user.uid, email);
        isAuthenticated.value = true;
      }
      clearFields();
      Get.offAllNamed('/home');
    } catch (e) {
      _showError(e.toString());
      isAuthenticated.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  // Garantir que a conta do usuário existe no Firestore
  Future<void> _ensureAccountExists(String userId, String email) async {
    try {
      final account = await _firebaseService.getAccount(userId);
      if (account == null) {
        // Se não existe, criar conta
        await _firebaseService.createAccount(userId, email);
      } else if (account.email.isEmpty) {
        // Se existe mas email está vazio, atualizar
        await _firebaseService.updateAccount(userId, {
          'email': email.toLowerCase().trim(),
        });
      }
    } catch (e) {
      print('Erro ao verificar/criar conta: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.signOut();
      isAuthenticated.value = false;
      Get.offAllNamed('/');
    } catch (e) {
      _showError('Erro ao fazer logout: $e');
    }
  }

  void clearFields() {
    emailController.clear();
    passwordController.clear();
  }

  void _showError(String message) {
    Get.snackbar(
      'Erro',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
