import 'dart:async'; // Necessário para Completer e TimeoutException se usar 'until'

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
    _checkCurrentUser(); // Já é chamado aqui
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
      final storedUserId = await _secureStorage.read(
        key: AppConstants.userIdKey,
      );

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
        // Poderia também limpar o secure storage aqui se o backend/firebase
        // indicar um logout definitivo.
      } else {
        // Se tornou logado, talvez recarregar os dados do usuário
        // se não for feito automaticamente pelo getCurrentUser no _checkCurrentUser
        // ou se o user.id não estiver no secure storage ainda.
        if (currentUser.value == null) {
          _checkCurrentUser(); // Garante que os dados do usuário sejam carregados
        }
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

  // --- INÍCIO DO NOVO MÉTODO ---
  /// Verifica o status de autenticação e navega para a tela apropriada.
  /// Este método é tipicamente chamado pela SplashPage.
  Future<void> checkAuthStatus() async {
    _logger.info('checkAuthStatus: Verificando status para navegação inicial.');

    // O método _checkCurrentUser() é chamado no onInit e define isLoading e isAuthenticated.
    // A SplashPage idealmente deveria observar isLoading e mostrar uma UI de carregamento.
    // Quando isLoading se torna false, isAuthenticated.value estará atualizado.
    // Esta função assume que será chamada quando o estado inicial já foi determinado
    // ou que a UI da SplashPage já lidou com o estado de carregamento.

    // Se, por algum motivo, quisermos garantir que _checkCurrentUser tenha sido concluído
    // antes de prosseguir (embora já seja chamado no onInit):
    if (isLoading.value) {
      // Espera um curto período para permitir que _checkCurrentUser (que está no onInit)
      // possivelmente complete ou use um sistema de Completer se precisar de uma espera mais robusta.
      // Para uma solução mais robusta, _checkCurrentUser poderia retornar um Future
      // que é armazenado e awaited aqui, ou a SplashPage deveria ser reativa a isLoading.
      _logger.info(
        'checkAuthStatus: Aguardando conclusão do carregamento inicial...',
      );
      // Loop simples de espera (não ideal para produção sem timeout, mas para ilustração)
      // Em um app real, a SplashPage deveria ser reativa a `isLoading`
      while (isLoading.value) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      _logger.info('checkAuthStatus: Carregamento inicial concluído.');
    }

    if (isAuthenticated.value) {
      _logger.info(
        'checkAuthStatus: Usuário autenticado. Navegando para home.',
      );
      Get.offAllNamed('/home'); // Substitua '/home' pela sua rota principal
    } else {
      _logger.info(
        'checkAuthStatus: Usuário NÃO autenticado. Navegando para login.',
      );
      Get.offAllNamed('/login'); // Substitua '/login' pela sua rota de login
    }
  }
  // --- FIM DO NOVO MÉTODO ---

  /// Realiza login com email e senha
  Future<bool> signIn() async {
    try {
      isLoading.value = true;
      error.value = '';

      final email = emailController.text.trim();
      final password = passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        error.value = 'Preencha todos os campos';
        isLoading.value = false; // Certifique-se de resetar isLoading
        return false;
      }

      final user = await _authRepository.signIn(email, password);

      if (user != null) {
        currentUser.value = user;
        isAuthenticated.value = true;

        await _secureStorage.write(key: AppConstants.userIdKey, value: user.id);

        _logger.info('Login realizado: ${user.email}');
        clearFields();
        isLoading.value = false;
        return true;
      } else {
        error.value = 'Email ou senha inválidos.'; // Mensagem mais específica
        isAuthenticated.value = false; // Garante que está falso
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      _logger.error('Erro no login', e);
      error.value =
          'Ocorreu um erro ao tentar fazer login.'; // Mensagem genérica
      isAuthenticated.value = false;
      isLoading.value = false;
      return false;
    }
    // Removido o finally para isLoading, pois já é tratado nos caminhos de retorno.
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
        isLoading.value = false;
        return false;
      }

      if (password != confirmPassword) {
        error.value = 'As senhas não conferem';
        isLoading.value = false;
        return false;
      }

      if (password.length < AppConstants.minPasswordLength) {
        error.value =
            'A senha deve ter pelo menos ${AppConstants.minPasswordLength} caracteres';
        isLoading.value = false;
        return false;
      }

      final emailInUse = await _authRepository.isEmailInUse(email);
      if (emailInUse) {
        error.value = 'Este email já está em uso';
        isLoading.value = false;
        return false;
      }

      final user = await _authRepository.signUp(email, password, name);

      if (user != null) {
        currentUser.value = user;
        isAuthenticated.value = true;
        await _secureStorage.write(key: AppConstants.userIdKey, value: user.id);
        _logger.info('Registro realizado: ${user.email}');
        clearFields();
        isLoading.value = false;
        return true;
      } else {
        error.value = 'Erro ao registrar usuário';
        isAuthenticated.value = false;
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      _logger.error('Erro no registro', e);
      error.value = 'Ocorreu um erro ao tentar registrar.';
      isAuthenticated.value = false;
      isLoading.value = false;
      return false;
    }
  }

  /// Realiza logout
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authRepository.signOut();
      await _secureStorage.delete(key: AppConstants.userIdKey);
      currentUser.value = null;
      isAuthenticated.value = false;
      _logger.info('Logout realizado');
      Get.offAllNamed('/login'); // Navega para a tela de login
    } catch (e) {
      _logger.error('Erro no logout', e);
      error.value = 'Erro ao fazer logout.';
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
        isLoading.value = false;
        return false;
      }
      await _authRepository.sendPasswordResetEmail(email);
      _logger.info('Email de recuperação enviado: $email');
      isLoading.value = false;
      return true;
    } catch (e) {
      _logger.error('Erro ao enviar email de recuperação', e);
      error.value = 'Erro ao enviar email de recuperação.';
      isLoading.value = false;
      return false;
    }
  }

  /// Atualiza perfil do usuário
  Future<bool> updateProfile({String? name, String? photoUrl}) async {
    try {
      isLoading.value = true;
      error.value = '';
      // Garante que o usuário atual exista e tenha um ID
      if (currentUser.value == null || currentUser.value!.id.isEmpty) {
        error.value = 'Usuário não autenticado para atualizar perfil.';
        isLoading.value = false;
        return false;
      }
      await _authRepository.updateProfile(
        userId:
            currentUser.value!.id, // Supondo que updateProfile precise do ID
        name: name,
        photoUrl: photoUrl,
      );
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
      }
      _logger.info('Perfil atualizado');
      isLoading.value = false;
      return true;
    } catch (e) {
      _logger.error('Erro ao atualizar perfil', e);
      error.value = 'Erro ao atualizar perfil.';
      isLoading.value = false;
      return false;
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
      error.value = 'Erro ao recarregar dados do usuário.';
    } finally {
      isLoading.value = false;
    }
  }
}
