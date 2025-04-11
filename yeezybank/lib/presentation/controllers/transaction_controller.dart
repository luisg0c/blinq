import 'package:get/get.dart';
import '../../domain/services/transaction_service.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/models/transaction_model.dart';
import '../theme/app_colors.dart';
import 'package:flutter/material.dart';

class TransactionController extends GetxController {
  final TransactionService _transactionService = Get.find<TransactionService>();
  final AuthService _authService = Get.find<AuthService>();

  var balance = 0.0.obs;
  var transactions = <TransactionModel>[].obs;
  var pendingTransactions = <TransactionModel>[].obs;
  var isLoading = false.obs;
  var lastTransactionDoc;

  String get currentUserId => _authService.getCurrentUserId();

  @override
  void onInit() {
    super.onInit();
    try {
      final _ = _authService.getCurrentUserId(); // dispara erro se não logado
      _loadBalance();
      _listenTransactions();
      _listenPendingTransactions();
    } catch (e) {
      showError('Usuário não autenticado.');
    }
  }

  Future<void> _loadBalance() async {
    try {
      final userId = _authService.getCurrentUserId();
      final currentBalance = await _transactionService.getUserBalance(userId);
      balance.value = currentBalance;
    } catch (e) {
      showError('Falha ao carregar saldo.');
    }
  }

  void _listenTransactions() {
    final userId = _authService.getCurrentUserId();
    _transactionService.getUserTransactionsStream(userId).listen((txnList) {
      transactions.assignAll(txnList);
    });
  }

  void _listenPendingTransactions() {
    final userId = _authService.getCurrentUserId();
    _transactionService.getPendingTransactionsStream(userId).listen((txnList) {
      pendingTransactions.assignAll(txnList);
    });
  }

  Future<bool> _validatePassword(String userId, String password) async {
    try {
      return await _transactionService.validateTransactionPassword(
        userId,
        password,
      );
    } catch (e) {
      showError('Erro ao validar senha: $e');
      return false;
    }
  }

  Future<void> deposit(
    double amount,
    String password, {
    String? description,
  }) async {
    isLoading.value = true;
    final userId = _authService.getCurrentUserId();
    try {
      final hasPassword = await _transactionService.hasTransactionPassword(
        userId,
      );
      if (!hasPassword) {
        await _transactionService.setTransactionPassword(userId, password);
      } else {
        final valid = await _validatePassword(userId, password);
        if (!valid) throw Exception('Senha incorreta');
      }

      await _transactionService.deposit(
        userId,
        amount,
        description: description,
      );
      await _loadBalance();
      showSuccess('Depósito realizado com sucesso!');
    } catch (e) {
      showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> transfer(
    double amount,
    String receiverEmail,
    String password, {
    String? description,
  }) async {
    isLoading.value = true;
    final userId = _authService.getCurrentUserId();
    try {
      // Validar senha primeiro
      final valid = await _validatePassword(userId, password);
      if (!valid) throw Exception('Senha incorreta');

      // Criar transação usando factory constructor
      final txn = TransactionModel.transfer(
        senderId: userId,
        receiverId: '', // Será preenchido pelo serviço
        amount: amount,
        description: description,
      );

      // Executar transferência
      await _transactionService.sendTransaction(txn, receiverEmail);
      await _loadBalance();
      showSuccess('Transferência realizada com sucesso!');
    } catch (e) {
      showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Confirmar transação pendente
  Future<void> confirmTransaction(
    String transactionId,
    String confirmationCode,
  ) async {
    isLoading.value = true;
    try {
      await _transactionService.confirmTransaction(
        transactionId,
        confirmationCode,
      );
      await _loadBalance();
      showSuccess('Transação confirmada com sucesso!');
    } catch (e) {
      showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Carregar mais transações (paginação)
  Future<void> loadMoreTransactions() async {
    if (isLoading.value || transactions.isEmpty) return;

    isLoading.value = true;
    try {
      final userId = _authService.getCurrentUserId();
      final moreTxns =
          await _transactionService
              .getUserTransactionsStream(
                userId,
                limit: 20,
                startAfterDoc: lastTransactionDoc,
              )
              .first;

      if (moreTxns.isNotEmpty) {
        transactions.addAll(moreTxns);
        lastTransactionDoc = moreTxns.last;
      }
    } catch (e) {
      showError('Erro ao carregar mais transações: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Nova função para obter relatório
  Future<Map<String, double>> getFinancialReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    isLoading.value = true;
    try {
      final userId = _authService.getCurrentUserId();
      final report = await _transactionService.getFinancialSummary(
        userId,
        startDate: startDate,
        endDate: endDate,
      );
      return report;
    } catch (e) {
      showError('Erro ao gerar relatório: $e');
      return {'deposits': 0, 'sent': 0, 'received': 0, 'balance': 0};
    } finally {
      isLoading.value = false;
    }
  }

  void showError(String msg) {
    Get.snackbar(
      'Erro',
      msg,
      backgroundColor: AppColors.error.withOpacity(0.1),
      colorText: AppColors.error,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(8),
      icon: const Icon(Icons.error_outline, color: AppColors.error),
    );
  }

  void showSuccess(String msg, {String? details}) {
    Get.snackbar(
      'Sucesso',
      msg,
      backgroundColor: AppColors.success.withOpacity(0.1),
      colorText: AppColors.success,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(8),
      icon: const Icon(Icons.check_circle, color: AppColors.success),
      mainButton:
          details != null
              ? TextButton(
                onPressed:
                    () => Get.dialog(
                      AlertDialog(
                        title: const Text('Detalhes da Transação'),
                        content: Text(details),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Fechar'),
                          ),
                        ],
                      ),
                    ),
                child: const Text(
                  'Ver Detalhes',
                  style: TextStyle(color: AppColors.primaryColor),
                ),
              )
              : null,
    );
  }
}
