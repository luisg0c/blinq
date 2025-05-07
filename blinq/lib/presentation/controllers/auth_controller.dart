import 'package:blinq/data/repositories/auth_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

/// Controlador para gerenciar autenticação no aplicativo
class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final AppLogger _logger = AppLogger('AuthController');
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  // Observables
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isAuthenticated = false.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Controladores de texto para os formulários
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();

  // Construtor com injeção do repositório
  AuthController(this._authRepository);

  @override
  void onInit() {
    super.onInit();
    _checkCurrentUser();
    _listenToAuthChanges();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    super.onClose();
  }

  /// Verifica se há um usuário logado
  Future<void> _checkCurrentUser() async {
    try {
      isLoading.value = true;

      // Verificar se existe ID de usuário armazenado no secure storage
      final storedUserId =
          await _secureStorage.read(key: AppConstants.userIdKey);

      if (storedUserId != null) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          currentUser.value = user;
          isAuthenticated.value = true;
          _logger.info('Usuário autenticado: ${user.email}');
        } else {
          // Limpar ID armazenado se não encontrar o usuário
          await _secureStorage.delete(key: AppConstants.userIdKey);
          isAuthenticated.value = false;
        }
      } else {
        isAuthenticated.value = false;
      }
    } catch (e) {
      _logger.error('Erro ao verificar usuário atual', e);
      isAuthenticated.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Escuta alterações no estado de autenticação
  void _listenToAuthChanges() {
    _authRepository.authStateChanges.listen((isLoggedIn) {
      isAuthenticated.value = isLoggedIn;
      if (!isLoggedIn) {
        currentUser.value = null;
      }
    });
  }

  /// Limpa os campos do formulário
  void clearFields() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    error.value = '';
  }

  /// Realiza login com email e senha
  Future<bool> signIn() async {
    try {
      isLoading.value = true;
      error.value = '';

      final email = emailController.text.trim();
      final password = passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        error.value = 'Preencha todos os campos';
        return false;
      }

      final user = await _authRepository.signIn(email, password);

      if (user != null) {
        currentUser.value = user;
        isAuthenticated.value = true;

        // Armazenar ID do usuário de forma segura
        await _secureStorage.write(key: AppConstants.userIdKey, value: user.id);

        _logger.info('Login realizado: ${user.email}');
        clearFields();
        return true;
      } else {
        error.value = 'Erro ao fazer login';
        return false;
      }
    } catch (e) {
      _logger.error('Erro no login', e);
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Realiza registro de novo usuário
  Future<bool> signUp() async {
    try {
      isLoading.value = true;
      error.value = '';

      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text;
      final confirmPassword = confirmPasswordController.text;

      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        error.value = 'Preencha todos os campos';
        return false;
      }

      if (password != confirmPassword) {
        error.value = 'As senhas não conferem';
        return false;
      }

      if (password.length < AppConstants.minPasswordLength) {
        error.value =
            'A senha deve ter pelo menos ${AppConstants.minPasswordLength} caracteres';
        return false;
      }

      // Verificar se o email já está em uso
      final emailInUse = await _authRepository.isEmailInUse(email);
      if (emailInUse) {
        error.value = 'Este email já está em uso';
        return false;
      }

      final user = await _authRepository.signUp(email, password, name);

      if (user != null) {
        currentUser.value = user;
        isAuthenticated.value = true;

        // Armazenar ID do usuário de forma segura
        await _secureStorage.write(key: AppConstants.userIdKey, value: user.id);

        _logger.info('Registro realizado: ${user.email}');
        clearFields();
        return true;
      } else {
        error.value = 'Erro ao registrar usuário';
        return false;
      }
    } catch (e) {
      _logger.error('Erro no registro', e);
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Realiza logout
  Future<void> signOut() async {
    try {
      isLoading.value = true;

      await _authRepository.signOut();

      // Remover ID do usuário do secure storage
      await _secureStorage.delete(key: AppConstants.userIdKey);

      currentUser.value = null;
      isAuthenticated.value = false;

      _logger.info('Logout realizado');

      // Navegar para a tela de login
      Get.offAllNamed('/login');
    } catch (e) {
      _logger.error('Erro no logout', e);
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Envia email de recuperação de senha
  Future<bool> sendPasswordResetEmail() async {
    try {
      isLoading.value = true;
      error.value = '';

      final email = emailController.text.trim();

      if (email.isEmpty) {
        error.value = 'Informe o email';
        return false;
      }

      await _authRepository.sendPasswordResetEmail(email);

      _logger.info('Email de recuperação enviado: $email');
      return true;
    } catch (e) {
      _logger.error('Erro ao enviar email de recuperação', e);
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Atualiza perfil do usuário
  Future<bool> updateProfile({String? name, String? photoUrl}) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _authRepository.updateProfile(
        name: name,
        photoUrl: photoUrl,
      );
      // Recarregar dados do usuário
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
      }
      _logger.info('Perfil atualizado');
      return true;
    } catch (e) {
      _logger.error('Erro ao atualizar perfil', e);
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Recarrega os dados do usuário atual
  Future<void> reloadUser() async {
    try {
      isLoading.value = true;

      await _authRepository.reloadUser();

      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
      }
      _logger.info('Dados do usuário recarregados');
    } catch (e) {
      _logger.error('Erro ao recarregar dados do usuário', e);
    } finally {
      isLoading.value = false;
    }
  }
}
