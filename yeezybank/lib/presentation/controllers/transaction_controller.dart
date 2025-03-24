import 'package:get/get.dart';
import '../../domain/services/transaction_service.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/models/transaction_model.dart';

class TransactionController extends GetxController {
  final TransactionService _transactionService = Get.find<TransactionService>();
  final AuthService _authService = Get.find<AuthService>();

  var balance = 0.0.obs;
  var transactions = <TransactionModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadBalance();
    _listenTransactions();
  }

  Future<void> _loadBalance() async {
    try {
      final userId = _authService.getCurrentUserId();
      final currentBalance = await _transactionService.getUserBalance(userId);
      balance.value = currentBalance;
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar saldo.');
    }
  }

  void _listenTransactions() {
    final userId = _authService.getCurrentUserId();
    _transactionService.getUserTransactionsStream(userId).listen((txnList) {
      transactions.assignAll(txnList);
    });
  }

  Future<void> deposit(double amount, String password) async {
    isLoading.value = true;
    final userId = _authService.getCurrentUserId();
    try {
      final hasPassword = await _transactionService.hasTransactionPassword(userId);
      if (!hasPassword) {
        await _transactionService.setTransactionPassword(userId, password);
      } else {
        final valid = await _transactionService.validateTransactionPassword(userId, password);
        if (!valid) throw Exception('Senha incorreta');
      }

      await _transactionService.deposit(userId, amount);
      await _loadBalance();
      Get.snackbar('Sucesso', 'Depósito realizado.');
    } catch (e) {
      Get.snackbar('Erro', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> transfer(double amount, String receiverEmail, String password) async {
    isLoading.value = true;
    final userId = _authService.getCurrentUserId();
    try {
      final valid = await _transactionService.validateTransactionPassword(userId, password);
      if (!valid) throw Exception('Senha incorreta');

      final txn = TransactionModel(
        id: '',
        senderId: userId,
        receiverId: '',
        amount: amount,
        timestamp: DateTime.now(),
        participants: [],
        type: 'transfer',
      );

      await _transactionService.sendTransaction(txn, receiverEmail);
      await _loadBalance();
      Get.snackbar('Sucesso', 'Transferência realizada.');
    } catch (e) {
      Get.snackbar('Erro', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
