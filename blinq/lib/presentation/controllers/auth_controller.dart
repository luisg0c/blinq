import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../routes/app_routes.dart';
import '../../core/theme/app_colors.dart';

/// ✅ CONTROLLER DE AUTENTICAÇÃO - FIX PARA APRESENTAÇÃO
class AuthController extends GetxController {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.resetPasswordUseCase,
  });

  // ✅ OBSERVABLES SIMPLES
  final Rxn<domain.User> user = Rxn<domain.User>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    _checkCurrentUser();
    // ❌ REMOVER LISTENER AUTOMÁTICO PARA EVITAR CONFLITOS
    // _setupAuthListener();
  }

  /// ✅ VERIFICAR USUÁRIO ATUAL NA INICIALIZAÇÃO
  void _checkCurrentUser() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      user.value = domain.User(
        id: currentUser.uid,
        name: currentUser.displayName ?? 'Usuário',
        email: currentUser.email ?? '',
        token: '',
      );
      print('👤 Usuário já logado: ${currentUser.email}');
    }
  }

  /// ✅ LOGIN SIMPLES E DIRETO
  Future<void> login({
    required String email,
    required String password,
  }) async {
    // Validações básicas
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
      print('🔐 Fazendo login: $email');
      
      final result = await loginUseCase.execute(
        email: email.trim(),
        password: password.trim(),
      );
      
      print('✅ Login bem-sucedido: ${result.email}');
      
      // ✅ DEFINIR USUÁRIO LOCALMENTE
      user.value = result;
      
      // ✅ NAVEGAÇÃO DIRETA E FORÇADA
      print('🧭 Navegando para home...');
      
      // Tentar diferentes métodos de navegação
      try {
        Get.offAllNamed(AppRoutes.home);
        print('✅ Navegação Get.offAllNamed executada');
      } catch (e) {
        print('❌ Falha Get.offAllNamed: $e');
        
        // Fallback 1: Get.toNamed
        try {
          Get.toNamed(AppRoutes.home);
          print('✅ Navegação Get.toNamed executada');
        } catch (e2) {
          print('❌ Falha Get.toNamed: $e2');
          
          // Fallback 2: Delay + navegação
          Future.delayed(const Duration(milliseconds: 500), () {
            try {
              Get.offAllNamed(AppRoutes.home);
              print('✅ Navegação com delay executada');
            } catch (e3) {
              print('❌ Falha navegação com delay: $e3');
            }
          });
        }
      }
      
      // Mostrar feedback positivo
      Get.snackbar(
        'Bem-vindo! 👋',
        'Login realizado com sucesso',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      
    } catch (e) {
      print('❌ Erro no login: $e');
      
      final errorMsg = _formatErrorMessage(e.toString());
      errorMessage.value = errorMsg;
      
      Get.snackbar(
        'Erro no Login',
        errorMsg,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ REGISTRO SIMPLES E DIRETO
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Validações básicas
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
      print('📝 Registrando usuário: $email');
      
      final result = await registerUseCase.execute(
        name: name.trim(),
        email: email.trim(),
        password: password.trim(),
      );
      
      print('✅ Registro bem-sucedido: ${result.email}');
      
      // ✅ DEFINIR USUÁRIO LOCALMENTE
      user.value = result;
      
      Get.snackbar(
        'Conta Criada! 🎉',
        'Bem-vindo ao Blinq, ${name.trim()}!',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      
      // ✅ NAVEGAÇÃO DIRETA
      print('🧭 Navegando para home após registro...');
      
      Future.delayed(const Duration(milliseconds: 1000), () {
        try {
          Get.offAllNamed(AppRoutes.home);
          print('✅ Navegação pós-registro executada');
        } catch (e) {
          print('❌ Falha navegação pós-registro: $e');
        }
      });
      
    } catch (e) {
      print('❌ Erro no registro: $e');
      
      final errorMsg = _formatErrorMessage(e.toString());
      errorMessage.value = errorMsg;
      
      Get.snackbar(
        'Erro no Registro',
        errorMsg,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ MÉTODO MANUAL PARA FORÇAR NAVEGAÇÃO
  void forceNavigateToHome() {
    print('🚀 Forçando navegação para home...');
    
    try {
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      print('❌ Erro ao forçar navegação: $e');
      
      // Tentar múltiplas vezes
      for (int i = 0; i < 3; i++) {
        Future.delayed(Duration(milliseconds: 500 * (i + 1)), () {
          try {
            Get.offAllNamed(AppRoutes.home);
            print('✅ Navegação forçada #${i + 1} executada');
          } catch (e) {
            print('❌ Tentativa #${i + 1} falhou: $e');
          }
        });
      }
    }
  }

  /// ✅ RESET DE SENHA
  Future<void> resetPassword({required String email}) async {
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
      
      Get.snackbar(
        'Email Enviado! 📧',
        'Verifique sua caixa de entrada para redefinir sua senha',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      
      // Voltar para login após sucesso
      Get.back();
      
    } catch (e) {
      print('❌ Erro no reset: $e');
      
      final errorMsg = _formatErrorMessage(e.toString());
      errorMessage.value = errorMsg;
      
      Get.snackbar(
        'Erro no Reset',
        errorMsg,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ LOGOUT SIMPLES
  Future<void> logout() async {
    try {
      print('👋 Fazendo logout...');
      
      isLoading.value = true;
      
      await FirebaseAuth.instance.signOut();
      
      user.value = null;
      errorMessage.value = null;
      
      print('✅ Logout realizado');
      
      // Navegação direta para welcome
      Get.offAllNamed(AppRoutes.welcome);
      
      Get.snackbar(
        'Até logo! 👋',
        'Logout realizado com sucesso',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      
    } catch (e) {
      print('❌ Erro no logout: $e');
      
      // Forçar limpeza mesmo com erro
      user.value = null;
      Get.offAllNamed(AppRoutes.welcome);
      
      Get.snackbar(
        'Logout realizado',
        'Você foi desconectado',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ LIMPAR ERRO
  void clearError() {
    errorMessage.value = null;
  }

  /// ✅ VERIFICAR SE USUÁRIO ESTÁ LOGADO
  bool get isLoggedIn => user.value != null;

  /// ✅ OBTER USUÁRIO ATUAL
  domain.User? get currentUser => user.value;

  /// ✅ FORMATAR MENSAGENS DE ERRO
  String _formatErrorMessage(String error) {
    String cleaned = error
        .replaceAll('Exception: ', '')
        .replaceAll('FirebaseAuthException: ', '')
        .replaceAll('[firebase_auth/user-not-found]', '')
        .replaceAll('[firebase_auth/wrong-password]', '')
        .replaceAll('[firebase_auth/email-already-in-use]', '')
        .replaceAll('[firebase_auth/weak-password]', '')
        .replaceAll('[firebase_auth/invalid-email]', '')
        .replaceAll('[firebase_auth/user-disabled]', '')
        .replaceAll('[firebase_auth/too-many-requests]', '');

    // Traduzir erros comuns
    if (cleaned.toLowerCase().contains('user-not-found') || 
        cleaned.toLowerCase().contains('user not found')) {
      return 'Email não cadastrado';
    }
    
    if (cleaned.toLowerCase().contains('wrong-password') || 
        cleaned.toLowerCase().contains('invalid-credential')) {
      return 'Senha incorreta';
    }
    
    if (cleaned.toLowerCase().contains('email-already-in-use')) {
      return 'Este email já está em uso';
    }
    
    if (cleaned.toLowerCase().contains('weak-password')) {
      return 'Senha muito fraca (mínimo 6 caracteres)';
    }
    
    if (cleaned.toLowerCase().contains('invalid-email')) {
      return 'Formato de email inválido';
    }
    
    if (cleaned.toLowerCase().contains('user-disabled')) {
      return 'Esta conta foi desabilitada';
    }
    
    if (cleaned.toLowerCase().contains('too-many-requests')) {
      return 'Muitas tentativas. Tente novamente mais tarde';
    }

    // Se não reconheceu o erro, retornar versão limpa
    return cleaned.isNotEmpty ? cleaned : 'Erro desconhecido';
  }

  /// ✅ OBTER STATUS DE DEBUG
  Map<String, dynamic> getDebugInfo() {
    return {
      'isLoggedIn': isLoggedIn,
      'currentUserId': currentUser?.id,
      'currentUserEmail': currentUser?.email,
      'isLoading': isLoading.value,
      'hasError': errorMessage.value != null,
      'errorMessage': errorMessage.value,
      'currentRoute': Get.currentRoute,
      'firebaseUser': FirebaseAuth.instance.currentUser?.email,
    };
  }
}
