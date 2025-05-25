// lib/presentation/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../routes/app_routes.dart';
import '../../core/theme/app_colors.dart';

class AuthController extends GetxController {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.resetPasswordUseCase,
  });

  // Observables
  final Rxn<domain.User> user = Rxn<domain.User>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
  }

  void _checkAuthState() {
    // Verificar se há usuário logado
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      print('👤 Usuário já logado: ${currentUser.email}');
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      errorMessage.value = 'Preencha todos os campos';
      return;
    }

    if (!GetUtils.isEmail(email.trim())) {
      errorMessage.value = 'Email inválido';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    
    try {
      print('🔐 Tentando login para: $email');
      
      final result = await loginUseCase.execute(
        email: email.trim(),
        password: password.trim(),
      );
      
      user.value = result;
      
      print('✅ Login realizado com sucesso: ${result.email}');
      
      // Mostrar sucesso
      Get.snackbar(
        'Bem-vindo! 👋',
        'Login realizado com sucesso',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      
      // Navegar para home
      Get.offAllNamed(AppRoutes.home);
      
    } catch (e) {
      print('❌ Erro no login: $e');
      errorMessage.value = _formatErrorMessage(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.trim().isEmpty) {
      errorMessage.value = 'Preencha todos os campos';
      return;
    }

    if (!GetUtils.isEmail(email.trim())) {
      errorMessage.value = 'Email inválido';
      return;
    }

    if (password.length < 6) {
      errorMessage.value = 'Senha deve ter pelo menos 6 caracteres';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    
    try {
      print('📝 Tentando registro para: $email');
      
      final result = await registerUseCase.execute(
        name: name.trim(),
        email: email.trim(),
        password: password.trim(),
      );
      
      user.value = result;
      
      print('✅ Registro realizado com sucesso: ${result.email}');
      
      // Mostrar sucesso
      Get.snackbar(
        'Conta criada! 🎉',
        'Bem-vindo ao Blinq! Configure seu PIN',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      
      // Navegar para configuração de PIN
      Get.offAllNamed(AppRoutes.setupPin);
      
    } catch (e) {
      print('❌ Erro no registro: $e');
      errorMessage.value = _formatErrorMessage(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    if (email.trim().isEmpty) {
      errorMessage.value = 'Informe o email';
      return;
    }

    if (!GetUtils.isEmail(email.trim())) {
      errorMessage.value = 'Email inválido';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    
    try {
      print('📧 Enviando reset de senha para: $email');
      
      await resetPasswordUseCase.execute(email: email.trim());
      
      print('✅ Email de reset enviado');
      
      // Mostrar sucesso
      Get.snackbar(
        'Email enviado! 📧',
        'Verifique sua caixa de entrada',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      
      // Voltar para login
      Get.back();
      
    } catch (e) {
      print('❌ Erro no reset de senha: $e');
      errorMessage.value = _formatErrorMessage(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      print('👋 Fazendo logout...');
      
      await FirebaseAuth.instance.signOut();
      user.value = null;
      
      print('✅ Logout realizado');
      
      Get.offAllNamed(AppRoutes.welcome);
      
    } catch (e) {
      print('❌ Erro no logout: $e');
    }
  }

  void clearError() {
    errorMessage.value = null;
  }

  String _formatErrorMessage(String error) {
    // Remover prefixos técnicos
    String formatted = error
        .replaceAll('Exception: ', '')
        .replaceAll('FirebaseAuthException: ', '')
        .replaceAll('[firebase_auth/', '')
        .replaceAll(']', '');

    // Traduzir erros comuns do Firebase
    if (formatted.contains('user-not-found')) {
      return 'Email não cadastrado';
    } else if (formatted.contains('wrong-password')) {
      return 'Senha incorreta';
    } else if (formatted.contains('email-already-in-use')) {
      return 'Email já está em uso';
    } else if (formatted.contains('weak-password')) {
      return 'Senha muito fraca';
    } else if (formatted.contains('invalid-email')) {
      return 'Email inválido';
    } else if (formatted.contains('too-many-requests')) {
      return 'Muitas tentativas. Tente novamente mais tarde';
    } else if (formatted.contains('network-request-failed')) {
      return 'Erro de conexão. Verifique sua internet';
    }

    return formatted;
  }
}