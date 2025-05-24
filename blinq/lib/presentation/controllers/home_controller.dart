import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/transaction_repository.dart';

class HomeController extends GetxController {
  final AccountRepository _accountRepository;
  final TransactionRepository _transactionRepository;

  HomeController({
    required AccountRepository accountRepository,
    required TransactionRepository transactionRepository,
  }) : _accountRepository = accountRepository,
       _transactionRepository = transactionRepository;

  // Observables
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxDouble balance = 0.0.obs;
  final RxList<Transaction> recentTransactions = <Transaction>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      error.value = '';

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        error.value = 'Usuário não autenticado';
        return;
      }

      // Carregar saldo (direto do repository - sem use case desnecessário)
      try {
        final balanceValue = await _accountRepository.getBalance(currentUser.uid);
        balance.value = balanceValue;
      } catch (e) {
        print('Erro ao carregar saldo: $e');
        // Continuar mesmo com erro no saldo
      }

      // Carregar transações recentes (direto do repository)
      try {
        final transactions = await _transactionRepository.getRecentTransactions(currentUser.uid, limit: 5);
        recentTransactions.value = transactions;
      } catch (e) {
        print('Erro ao carregar transações: $e');
        // Continuar mesmo com erro nas transações
      }
    } catch (e) {
      error.value = 'Erro inesperado: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadData();
  }
}