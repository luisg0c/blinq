import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/transaction_service.dart';
import '../../domain/models/transaction_model.dart';
import '../widgets/password_prompt.dart';

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  final AuthService _authService = Get.find<AuthService>();
  final TransactionService _transactionService = Get.find<TransactionService>();
  
  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  
  final RxBool isHistoryVisible = false.obs;
  final RxBool isLoading = false.obs;
  final RxString currentUserEmail = ''.obs;
  final RxDouble balance = 0.0.obs;
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  
  String get userId => _authService.getCurrentUserId();
  
  Stream<List<TransactionModel>> get transactionsStream => 
      _transactionService.getUserTransactionsStream(userId);
  
  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    scaleAnimation = Tween<double>(begin: 0.95, end: 1.0)
      .animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutBack,
      ));
    animationController.forward();
    
    // Carregar dados do usuário
    final user = _authService.getCurrentUser();
    if (user != null) {
      currentUserEmail.value = user.email ?? 'Usuário';
    }
    
    // Carregar saldo
    _loadBalance();
    
    // Escutar transações
    _listenToTransactions();
  }
  
  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
  
  // Reset state (chamado ao fazer refresh)
  void resetState() {
    isHistoryVisible.value = false;
  }
  
  // Métodos de carregamento
  Future<void> _loadBalance() async {
    try {
      final currentBalance = await _transactionService.getUserBalance(userId);
      balance.value = currentBalance;
    } catch (e) {
      print('Erro ao carregar saldo: $e');
    }
  }
  
  void _listenToTransactions() {
    transactionsStream.listen((txns) {
      transactions.assignAll(txns);
    });
  }
  
  // Solicitar e validar senha para visualizar histórico
  Future<void> promptForPassword(BuildContext context) async {
    isLoading.value = true;
    
    try {
      final hasPassword = await _transactionService.hasTransactionPassword(userId);
      
      if (!hasPassword) {
        Get.snackbar(
          'Senha Necessária', 
          'Você precisa cadastrar uma senha de transação primeiro. Faça um depósito ou transferência para cadastrar.',
          duration: const Duration(seconds: 4),
        );
        return;
      }
      
      final password = await promptPassword(context);
      if (password == null || password.isEmpty) return;
      
      final isValid = await _transactionService.validateTransactionPassword(userId, password);
      if (isValid) {
        isHistoryVisible.value = true;
      } else {
        Get.snackbar('Erro', 'Senha incorreta');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao verificar senha: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    await _authService.signOut();
    Get.offAllNamed('/');
  }
}