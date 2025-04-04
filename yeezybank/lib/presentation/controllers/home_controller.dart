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