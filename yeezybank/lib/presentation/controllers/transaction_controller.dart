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
  var hasValidAuth = true.obs; // Indica se a autenticação está válida
  var lastTransactionDoc;

  String? get currentUserId {
    try {
      return _authService.getCurrentUserId();
    } catch (e) {
      hasValidAuth.value = false;
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  // Inicializar dados com tratamento de erro
  void _initData() {
    try {
      final userId = currentUserId;
      if (userId != null) {
        _loadBalance();
        _listenTransactions();
        _listenPendingTransactions();
        hasValidAuth.value = true;
      }
    } catch (e) {
      hasValidAuth.value = false;
      showError('Usuário não autenticado. Por favor, faça login novamente.');
      _redirectToLogin();
    }
  }

  // Recarregar dados (útil após reconexão)
  void refreshData() {
    _initData();
  }

  Future<void> _loadBalance() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        _handleAuthError();
        return;
      }

      final currentBalance = await _transactionService.getUserBalance(userId);
      balance.value = currentBalance;
    } catch (e) {
      showError('Falha ao carregar saldo: $e');
      _checkAuthError(e);
    }
  }

  void _listenTransactions() {
    final userId = currentUserId;
    if (userId == null) {
      _handleAuthError();
      return;
    }

    _transactionService
        .getUserTransactionsStream(userId)
        .listen(
          (txnList) {
            transactions.assignAll(txnList);
          },
          onError: (e) {
            print('Erro ao carregar transações: $e');
            _checkAuthError(e);
          },
        );
  }

  void _listenPendingTransactions() {
    final userId = currentUserId;
    if (userId == null) {
      _handleAuthError();
      return;
    }

    _transactionService
        .getPendingTransactionsStream(userId)
        .listen(
          (txnList) {
            pendingTransactions.assignAll(txnList);
          },
          onError: (e) {
            print('Erro ao carregar transações pendentes: $e');
            _checkAuthError(e);
          },
        );
  }

  Future<bool> _validatePassword(String userId, String password) async {
    try {
      return await _transactionService.validateTransactionPassword(
        userId,
        password,
      );
    } catch (e) {
      showError('Erro ao validar senha: $e');
      _checkAuthError(e);
      return false;
    }
  }

  Future<void> deposit(
    double amount,
    String password, {
    String? description,
  }) async {
    isLoading.value = true;
    final userId = currentUserId;
    if (userId == null) {
      _handleAuthError();
      isLoading.value = false;
      return;
    }

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
      _checkAuthError(e);
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
    final userId = currentUserId;
    if (userId == null) {
      _handleAuthError();
      isLoading.value = false;
      return;
    }

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
      _checkAuthError(e);
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
      _checkAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Carregar mais transações (paginação)
  Future<void> loadMoreTransactions() async {
    if (isLoading.value || transactions.isEmpty) return;

    final userId = currentUserId;
    if (userId == null) {
      _handleAuthError();
      return;
    }

    isLoading.value = true;
    try {
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
      _checkAuthError(e);
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

    final userId = currentUserId;
    if (userId == null) {
      _handleAuthError();
      isLoading.value = false;
      return {'deposits': 0, 'sent': 0, 'received': 0, 'balance': 0};
    }

    try {
      final report = await _transactionService.getFinancialSummary(
        userId,
        startDate: startDate,
        endDate: endDate,
      );
      return report;
    } catch (e) {
      showError('Erro ao gerar relatório: $e');
      _checkAuthError(e);
      return {'deposits': 0, 'sent': 0, 'received': 0, 'balance': 0};
    } finally {
      isLoading.value = false;
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
      _handleAuthError();
    }
  }

  void _handleAuthError() {
    hasValidAuth.value = false;
    _redirectToLogin();
  }

  void _redirectToLogin() {
    // Evita múltiplas chamadas de redirect com um delayed call
    Future.delayed(Duration.zero, () {
      if (!hasValidAuth.value && Get.currentRoute != '/login') {
        Get.offAllNamed('/login');
        showError('Sua sessão expirou. Por favor, faça login novamente.');
      }
    });
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
