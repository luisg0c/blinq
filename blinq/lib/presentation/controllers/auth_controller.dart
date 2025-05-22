import 'package:flutter/material.dart'; // ✅ Adicionar este import
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../routes/app_routes.dart';

/// Controller de autenticação, faz a ponte entre UI e casos de uso.
class AuthController extends GetxController {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  /// Usuário autenticado (ou null se não estiver logado).
  final Rxn<domain.User> user = Rxn<domain.User>();

  /// Estado de carregamento para chamadas async.
  final RxBool isLoading = false.obs;

  /// Mensagem de erro (null se não houver).
  final RxnString errorMessage = RxnString();

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.resetPasswordUseCase,
  });

  /// Executa o fluxo de login.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    
    try {
      final result = await loginUseCase.execute(
        email: email,
        password: password,
      );
      user.value = result;
      
      // Navegar para Home após login
      Get.offAllNamed(AppRoutes.home);
      
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Executa o fluxo de registro.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    
    try {
      final result = await registerUseCase.execute(
        name: name,
        email: email,
        password: password,
      );
      user.value = result;
      
      // Após registro, ir para configuração de PIN
      Get.offAllNamed(AppRoutes.setupPin);
      
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Executa o envio de e-mail para reset de senha.
  Future<void> resetPassword({
    required String email,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    
    try {
      await resetPasswordUseCase.execute(email: email);
      Get.snackbar(
        'Sucesso',
        'E-mail de recuperação enviado!',
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
      );
      Get.back(); // Voltar para login
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout do usuário.
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    user.value = null;
    Get.offAllNamed(AppRoutes.welcome);
  }
}