// lib/presentation/controllers/auth_controller.dart
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/user_session_manager.dart';

/// Controller de autenticação com gerenciamento seguro de sessão
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
    _setupAuthListener();
  }

  /// ✅ LISTENER DE MUDANÇAS DE AUTENTICAÇÃO
  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        print('👤 Usuário deslogado - limpando sessão');
        await _handleUserLoggedOut();
      } else {
        print('👤 Usuário logado: ${firebaseUser.email}');
        await _handleUserLoggedIn(firebaseUser);
      }
    });
  }

  /// ✅ LIDAR COM USUÁRIO LOGADO
  Future<void> _handleUserLoggedIn(User firebaseUser) async {
    try {
      // Verificar se é um novo usuário
      final currentUserId = user.value?.id;
      
      if (currentUserId != null && currentUserId != firebaseUser.uid) {
        print('🔄 Novo usuário detectado - limpando sessão anterior');
        await UserSessionManager.clearPreviousSession();
      }

      // Atualizar usuário atual
      user.value = domain.User(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'Usuário Blinq',
        email: firebaseUser.email!,
        token: await firebaseUser.getIdToken(),
      );

      // Inicializar nova sessão
      await UserSessionManager.initializeUserSession(firebaseUser.uid);
      
    } catch (e) {
      print('❌ Erro ao processar login: $e');
      errorMessage.value = 'Erro ao inicializar sessão';
    }
  }

  /// ✅ LIDAR COM USUÁRIO DESLOGADO
  Future<void> _handleUserLoggedOut() async {
    try {
      await UserSessionManager.clearAllUserData();
      user.value = null;
      errorMessage.value = null;
    } catch (e) {
      print('❌ Erro ao processar logout: $e');
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

    isLoading.value = true;
    errorMessage.value = null;
    
    try {
      print('🔐 Executando login para: $email');
      
      final result = await loginUseCase.execute(
        email: email.trim(),
        password: password.trim(),
      );
      
      print('✅ Login bem-sucedido: ${result.email}');
      
      Get.snackbar(
        'Bem-vindo! 👋',
        'Login realizado com sucesso',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // A navegação será tratada pelo listener de auth state
      
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

    isLoading.value = true;
    errorMessage.value = null;
    
    try {
      print('📝 Executando registro para: $email');
      
      final result = await registerUseCase.execute(
        name: name.trim(),
        email: email.trim(),
        password: password.trim(),
      );
      
      print('✅ Registro bem-sucedido: ${result.email}');
      
      Get.snackbar(
        'Conta criada! 🎉',
        'Bem-vindo ao Blinq!',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // A navegação será tratada pelo listener de auth state
      
    } catch (e) {
      print('❌ Erro no registro: $e');
      errorMessage.value = _formatErrorMessage(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ LOGOUT SEGURO COMPLETO
  Future<void> logout() async {
    try {
      print('👋 Iniciando logout seguro...');
      
      isLoading.value = true;
      
      // 1. Limpar sessão do usuário atual
      await UserSessionManager.clearAllUserData();
      
      // 2. Firebase logout
      await FirebaseAuth.instance.signOut();
      
      // 3. Limpar estado local
      user.value = null;
      errorMessage.value = null;
      
      print('✅ Logout seguro concluído');
      
    } catch (e) {
      print('❌ Erro no logout: $e');
      // Forçar limpeza mesmo com erro
      user.value = null;
      await UserSessionManager.clearAllUserData();
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    errorMessage.value = null;
  }

  String _formatErrorMessage(String error) {
    String formatted = error
        .replaceAll('Exception: ', '')
        .replaceAll('FirebaseAuthException: ', '');

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
    }

    return formatted;
  }
}