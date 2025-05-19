import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../services/transaction_service.dart';
import '../services/auth_service.dart';

class TransactionController extends GetxController {
  final TransactionService _transactionService = TransactionService();
  final AuthService _authService = AuthService();

  // Controladores de texto para formulários
  final amountController = TextEditingController();
  final receiverEmailController = TextEditingController();
  final descriptionController = TextEditingController();

  // Observables para estado
  final isLoading = false.obs;
  final error = ''.obs;
  final transactions = <TransactionModel>[].obs;
  final balance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Carregar transações do usuário atual quando o controlador for inicializado
    final currentUser = _authService.getCurrentUser();
    if (currentUser != null) {
      fetchUserTransactions(currentUser.id);
      fetchUserBalance(currentUser.id);
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    receiverEmailController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<bool> deposit() async {
    try {
      isLoading.value = true;
      error.value = '';

      final currentUser = _authService.getCurrentUser();
      if (currentUser == null) {
        error.value = 'Usuário não autenticado';
        return false;
      }

      final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0.0;
      
      if (amount <= 0) {
        error.value = 'Valor de depósito inválido';
        return false;
      }

      final transaction = await _transactionService.deposit(
        userId: currentUser.id, 
        amount: amount
      );

      if (transaction != null) {
        await fetchUserTransactions(currentUser.id);
        await fetchUserBalance(currentUser.id);
        clearFields();
        return true;
      }

      error.value = 'Falha no depósito';
      return false;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> transfer() async {
    try {
      isLoading.value = true;
      error.value = '';

      final currentUser = _authService.getCurrentUser();
      if (currentUser == null) {
        error.value = 'Usuário não autenticado';
        return false;
      }

      final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0.0;
      final receiverEmail = receiverEmailController.text.trim();
      
      if (amount <= 0) {
        error.value = 'Valor de transferência inválido';
        return false;
      }

      // Encontrar destinatário
      final receiverUser = await _authService.getUserByEmail(receiverEmail);
      if (receiverUser == null) {
        error.value = 'Destinatário não encontrado';
        return false;
      }

      final transaction = await _transactionService.transfer(
        senderId: currentUser.id, 
        receiverId: receiverUser.id, 
        amount: amount
      );

      if (transaction != null) {
        await fetchUserTransactions(currentUser.id);
        await fetchUserBalance(currentUser.id);
        clearFields();
        return true;
      }

      error.value = 'Falha na transferência';
      return false;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserTransactions(String userId) async {
    try {
      isLoading.value = true;
      transactions.value = await _transactionService.getUserTransactions(userId);
    } catch (e) {
      error.value = 'Erro ao buscar transações';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserBalance(String userId) async {
    try {
      isLoading.value = true;
      final userBalance = await _transactionService.getUserBalance(userId);
      balance.value = userBalance;
    } catch (e) {
      error.value = 'Erro ao buscar saldo';
      balance.value = 0.0;
    } finally {
      isLoading.value = false;
    }
  }

  // Resumo financeiro
  Future<Map<String, double>> getFinancialSummary(String userId) async {
    try {
      final deposits = await _transactionService.getTotalDeposits(userId);
      final transfers = await _transactionService.getTotalTransfers(userId);

      return {
        'deposits': deposits,
        'transfers': transfers,
        'total': deposits - transfers
      };
    } catch (e) {
      return {'deposits': 0.0, 'transfers': 0.0, 'total': 0.0};
    }
  }

  void clearFields() {
    amountController.clear();
    receiverEmailController.clear();
    descriptionController.clear();
  }
}