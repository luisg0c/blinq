<<<<<<< HEAD
import 'package:blinq/data/repositories/auth_repository_impl.dart';
=======
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
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
<<<<<<< HEAD

=======
  
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
  // Observables
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isAuthenticated = false.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
<<<<<<< HEAD

  // Controladores de texto para os formulários
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();

  // Construtor com injeção do repositório
  AuthController(this._authRepository);

=======
  
  // Controladores de texto para os formulários
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  
  // Construtor com injeção do repositório
  AuthController(this._authRepository);
  
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
  @override
  void onInit() {
    super.onInit();
    _checkCurrentUser();
    _listenToAuthChanges();
  }
<<<<<<< HEAD

=======
  
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    super.onClose();
  }
<<<<<<< HEAD

=======
  
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
  /// Verifica se há um usuário logado
  Future<void> _checkCurrentUser() async {
    try {
      isLoading.value = true;
<<<<<<< HEAD

      // Verificar se existe ID de usuário armazenado no secure storage
      final storedUserId =
          await _secureStorage.read(key: AppConstants.userIdKey);

=======
      
      // Verificar se existe ID de usuário armazenado no secure storage
      final storedUserId = await _secureStorage.read(key: AppConstants.userIdKey);
      
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
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
<<<<<<< HEAD

=======
  
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
  /// Escuta alterações no estado de autenticação
  void _listenToAuthChanges() {
    _authRepository.authStateChanges.listen((isLoggedIn) {
      isAuthenticated.value = isLoggedIn;
      if (!isLoggedIn) {
        currentUser.value = null;
      }
    });
  }
<<<<<<< HEAD

=======
  
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
  /// Limpa os campos do formulário
  void clearFields() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    error.value = '';
  }
<<<<<<< HEAD

=======
  
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
  /// Realiza login com email e senha
  Future<bool> signIn() async {
    try {
      isLoading.value = true;
      error.value = '';
<<<<<<< HEAD

      final email = emailController.text.trim();
      final password = passwordController.text;

=======
      
      final email = emailController.text.trim();
      final password = passwordController.text;
      
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
      if (email.isEmpty || password.isEmpty) {
        error.value = 'Preencha todos os campos';
        return false;
      }
<<<<<<< HEAD

      final user = await _authRepository.signIn(email, password);

      if (user != null) {
        currentUser.value = user;
        isAuthenticated.value = true;

        // Armazenar ID do usuário de forma segura
        await _secureStorage.write(key: AppConstants.userIdKey, value: user.id);

=======
      
      final user = await _authRepository.signIn(email, password);
      
      if (user != null) {
        currentUser.value = user;
        isAuthenticated.value = true;
        
        // Armazenar ID do usuário de forma segura
        await _secureStorage.write(key: AppConstants.userIdKey, value: user.id);
        
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
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
<<<<<<< HEAD

=======
  
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
  /// Realiza registro de novo usuário
  Future<bool> signUp() async {
    try {
      isLoading.value = true;
      error.value = '';
<<<<<<< HEAD

=======
      
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text;
      final confirmPassword = confirmPasswordController.text;
<<<<<<< HEAD

=======
      
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        error.value = 'Preencha todos os campos';
        return false;
      }
<<<<<<< HEAD

=======
      
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
      if (password != confirmPassword) {
        error.value = 'As senhas não conferem';
        return false;
      }
<<<<<<< HEAD

      if (password.length < AppConstants.minPasswordLength) {
        error.value =
            'A senha deve ter pelo menos ${AppConstants.minPasswordLength} caracteres';
        return false;
      }

=======
      
      if (password.length < AppConstants.minPasswordLength) {
        error.value = 'A senha deve ter pelo menos ${AppConstants.minPasswordLength} caracteres';
        return false;
      }
      
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
      // Verificar se o email já está em uso
      final emailInUse = await _authRepository.isEmailInUse(email);
      if (emailInUse) {
        error.value = 'Este email já está em uso';
        return false;
      }
<<<<<<< HEAD

      final user = await _authRepository.signUp(email, password, name);

      if (user != null) {
        currentUser.value = user;
        isAuthenticated.value = true;

        // Armazenar ID do usuário de forma segura
        await _secureStorage.write(key: AppConstants.userIdKey, value: user.id);

=======
      
      final user = await _authRepository.signUp(email, password, name);
      
      if (user != null) {
        currentUser.value = user;
        isAuthenticated.value = true;
        
        // Armazenar ID do usuário de forma segura
        await _secureStorage.write(key: AppConstants.userIdKey, value: user.id);
        
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
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
<<<<<<< HEAD

=======
  
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
  /// Realiza logout
  Future<void> signOut() async {
    try {
      isLoading.value = true;
<<<<<<< HEAD

      await _authRepository.signOut();

      // Remover ID do usuário do secure storage
      await _secureStorage.delete(key: AppConstants.userIdKey);

      currentUser.value = null;
      isAuthenticated.value = false;

      _logger.info('Logout realizado');

=======
      
      await _authRepository.signOut();
      
      // Remover ID do usuário do secure storage
      await _secureStorage.delete(key: AppConstants.userIdKey);
      
      currentUser.value = null;
      isAuthenticated.value = false;
      
      _logger.info('Logout realizado');
      
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
      // Navegar para a tela de login
      Get.offAllNamed('/login');
    } catch (e) {
      _logger.error('Erro no logout', e);
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
<<<<<<< HEAD

=======
  
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
  /// Envia email de recuperação de senha
  Future<bool> sendPasswordResetEmail() async {
    try {
      isLoading.value = true;
      error.value = '';
<<<<<<< HEAD

      final email = emailController.text.trim();

=======
      
      final email = emailController.text.trim();
      
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
      if (email.isEmpty) {
        error.value = 'Informe o email';
        return false;
      }
<<<<<<< HEAD

      await _authRepository.sendPasswordResetEmail(email);

=======
      
      await _authRepository.sendPasswordResetEmail(email);
      
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
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
<<<<<<< HEAD

=======
  
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
  /// Atualiza perfil do usuário
  Future<bool> updateProfile({String? name, String? photoUrl}) async {
    try {
      isLoading.value = true;
      error.value = '';
<<<<<<< HEAD

=======
      
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
      await _authRepository.updateProfile(
        name: name,
        photoUrl: photoUrl,
      );
<<<<<<< HEAD

=======
      
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
      // Recarregar dados do usuário
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
      }
<<<<<<< HEAD

=======
      
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
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
<<<<<<< HEAD

=======
  
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
  /// Recarrega os dados do usuário atual
  Future<void> reloadUser() async {
    try {
      isLoading.value = true;
<<<<<<< HEAD

      await _authRepository.reloadUser();

=======
      
      await _authRepository.reloadUser();
      
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
      }
<<<<<<< HEAD

=======
      
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
      _logger.info('Dados do usuário recarregados');
    } catch (e) {
      _logger.error('Erro ao recarregar dados do usuário', e);
    } finally {
      isLoading.value = false;
    }
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> ffa49ab2c1fa4a3b6c7f91b5797bf82cb828d29d
