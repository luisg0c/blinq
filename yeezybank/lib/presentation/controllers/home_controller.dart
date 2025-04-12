import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/transaction_service.dart';
import '../../domain/models/transaction_model.dart';
import '../widgets/password_prompt.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final AuthService _authService = Get.find<AuthService>();
  final TransactionService _transactionService = Get.find<TransactionService>();

  late AnimationController animationController;
  late Animation<double> scaleAnimation;

  final RxBool isHistoryVisible = false.obs;
  final RxBool isLoading = false.obs;
  final RxString currentUserEmail = ''.obs;
  final RxDouble balance = 0.0.obs;
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxBool hasAuthError = false.obs;

  String? _userId;

  String get userId {
    if (_userId == null) {
      try {
        _userId = _authService.getCurrentUserId();
      } catch (e) {
        _handleAuthError(e);
        return ''; // Retornar string vazia em caso de erro
      }
    }
    return _userId!;
  }

  Stream<List<TransactionModel>> get transactionsStream {
    try {
      if (userId.isEmpty) return Stream.value([]);
      return _transactionService.getUserTransactionsStream(userId);
    } catch (e) {
      _handleAuthError(e);
      return Stream.value([]);
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Inicializar animação
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutBack),
    );
    animationController.forward();

    // Carregar dados do usuário de forma segura
    _loadUserData();
  }

  // Método seguro para carregar dados do usuário
  Future<void> _loadUserData() async {
    try {
      // Carregar email do usuário
      final user = _authService.getCurrentUser();
      if (user != null) {
        currentUserEmail.value = user.email ?? 'Usuário';
        _userId = user.uid;
      } else {
        // Se não há usuário, redirecionar para login
        _handleAuthError('Usuário não logado');
        return;
      }

      // Carregar saldo
      await _loadBalance();

      // Escutar transações
      _listenToTransactions();

      hasAuthError.value = false;
    } catch (e) {
      _handleAuthError(e);
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  // Reset state (chamado ao fazer refresh)
  void resetState() {
    isHistoryVisible.value = false;
    // Tentar recarregar dados
    _loadUserData();
  }

  // Métodos de carregamento
  Future<void> _loadBalance() async {
    try {
      if (userId.isEmpty) return;
      final currentBalance = await _transactionService.getUserBalance(userId);
      balance.value = currentBalance;
    } catch (e) {
      print('Erro ao carregar saldo: $e');
      _checkAuthError(e);
    }
  }

  void _listenToTransactions() {
    try {
      if (userId.isEmpty) return;

      transactionsStream.listen(
        (txns) {
          transactions.assignAll(txns);
          _loadBalance(); // Recarrega saldo ao detectar nova transação
        },
        onError: (e) {
          print('Erro ao escutar transações: $e');
          _checkAuthError(e);
        },
      );
    } catch (e) {
      print('Erro ao configurar listener: $e');
      _checkAuthError(e);
    }
  }

  // Tratamento de erros de autenticação
  void _checkAuthError(dynamic error) {
    String errorStr = error.toString().toLowerCase();
    if (errorStr.contains('usuário não logado') ||
        errorStr.contains('user not logged in') ||
        errorStr.contains('permission') ||
        errorStr.contains('não autenticado') ||
        errorStr.contains('not authenticated') ||
        errorStr.contains('token') ||
        errorStr.contains('permission-denied')) {
      _handleAuthError(error);
    }
  }

  void _handleAuthError(dynamic error) {
    print('Erro de autenticação: $error');
    hasAuthError.value = true;

    // Limpar dados sensíveis
    _userId = null;
    balance.value = 0.0;
    transactions.clear();

    // Redirecionar para login
    Future.delayed(Duration.zero, () {
      if (Get.currentRoute != '/login') {
        Get.offAllNamed('/login');
        Get.snackbar(
          'Sessão expirada',
          'Por favor, faça login novamente',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    });
  }

  // Solicitar e validar senha para visualizar histórico
  Future<void> promptForPassword(BuildContext context) async {
    isLoading.value = true;

    try {
      if (userId.isEmpty) {
        _handleAuthError('Usuário não logado');
        return;
      }

      final hasPassword = await _transactionService.hasTransactionPassword(
        userId,
      );

      if (!hasPassword) {
        Get.snackbar(
          'Senha Necessária',
          'Você precisa cadastrar uma senha de transação primeiro. Faça um depósito ou transferência para cadastrar.',
          duration: const Duration(seconds: 4),
        );
        isLoading.value = false;
        return;
      }

      final password = await promptPassword(context);
      if (password == null || password.isEmpty) {
        isLoading.value = false;
        return;
      }

      final isValid = await _transactionService.validateTransactionPassword(
        userId,
        password,
      );

      if (isValid) {
        isHistoryVisible.value = true;
      } else {
        Get.snackbar('Erro', 'Senha incorreta');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao verificar senha: $e');
      _checkAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.signOut();
      Get.offAllNamed('/');
    } catch (e) {
      print('Erro ao fazer logout: $e');
      // Em caso de erro no logout, tentar redirecionar para a tela inicial
      Get.offAllNamed('/');
    }
  }
}
