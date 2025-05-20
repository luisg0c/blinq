// lib/presentation/controllers/auth_controller.dart

import 'package:get/get.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';

/// Controller de autenticação, faz a ponte entre UI e casos de uso.
class AuthController extends GetxController {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  /// Usuário autenticado (ou null se não estiver logado).
  final Rxn<User> user = Rxn<User>();

  /// Estado de carregamento para chamadas async.
  final RxBool isLoading = false.obs;

  /// Mensagem de erro (null se não houver).
  final Rxn<String> errorMessage = Rxn<String>();

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
    } catch (e) {
      errorMessage.value = e.toString();
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
    } catch (e) {
      errorMessage.value = e.toString();
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
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
