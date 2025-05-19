import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../services/transaction_service.dart';
import '../services/auth_service.dart';

class TransactionController extends GetxController {
  final TransactionService _transactionService;
  final AuthService _authService;

  TransactionController({
    TransactionService? transactionService,
    AuthService? authService,
  })  : _transactionService = transactionService ?? TransactionService(),
        _authService = authService ?? AuthService();

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
    _initializeUserData();
  }

  @override
  void onClose() {
    amountController.dispose();
    receiverEmailController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void _initializeUserData() {
    final currentUser = _authService.getCurrentUser();
    if (currentUser != null) {
      fetchUserTransactions();
    }
  }

  // Método de depósito
  Future<bool> deposit() async {
    try {
      isLoading.value = true;
      error.value = '';

      final amount = _parseAmount();

      final transaction = await _transactionService.deposit(
          amount: amount, description: descriptionController.text.trim());

      if (transaction != null) {
        await fetchUserTransactions();
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

  // Método de transferência
  Future<bool> transfer() async {
    try {
      isLoading.value = true;
      error.value = '';

      final amount = _parseAmount();
      final receiverEmail = receiverEmailController.text.trim();

      final transaction = await _transactionService.transfer(
          receiverEmail: receiverEmail,
          amount: amount,
          description: descriptionController.text.trim());

      if (transaction != null) {
        await fetchUserTransactions();
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

  // Buscar transações do usuário
  Future<void> fetchUserTransactions() async {
    try {
      isLoading.value = true;
      transactions.value = await _transactionService.getUserTransactions();
    } catch (e) {
      error.value = 'Erro ao buscar transações';
      transactions.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // Converter valor do campo de texto para double
  double _parseAmount() {
    return double.tryParse(
            amountController.text.replaceAll('.', '').replaceAll(',', '.')) ??
        0.0;
  }

  // Limpar campos de formulário
  void clearFields() {
    amountController.clear();
    receiverEmailController.clear();
    descriptionController.clear();
  }

  // Obter resumo financeiro
  Future<Map<String, double>> getFinancialSummary() async {
    try {
      return await _transactionService.getFinancialSummary();
    } catch (e) {
      error.value = 'Erro ao buscar resumo financeiro';
      return {'deposits': 0.0, 'transfers': 0.0, 'total': 0.0};
    }
  }

  // Gerar comprovante de transação
  Future<void> generateTransactionReceipt(TransactionModel transaction) async {
    try {
      await _transactionService.generateTransactionReceipt(transaction);
    } catch (e) {
      error.value = 'Erro ao gerar comprovante';
    }
  }

  // Compartilhar comprovante de transação
  Future<void> shareTransactionReceipt(TransactionModel transaction) async {
    try {
      await _transactionService.shareTransactionReceipt(transaction);
    } catch (e) {
      error.value = 'Erro ao compartilhar comprovante';
    }
  }
}
