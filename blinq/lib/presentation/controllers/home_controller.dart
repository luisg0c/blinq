import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/get_balance_usecase.dart';
import '../../domain/usecases/get_recent_transactions_usecase.dart';

class HomeController extends GetxController {
  final GetBalanceUseCase getBalanceUseCase;
  final GetRecentTransactionsUseCase getRecentTxUseCase;

  HomeController({
    required this.getBalanceUseCase,
    required this.getRecentTxUseCase,
  });

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

      // Carregar saldo
      try {
        final balanceValue = await getBalanceUseCase.execute(currentUser.uid);
        balance.value = balanceValue;
      } catch (e) {
        error.value = 'Erro ao carregar saldo: $e';
      }

      // Carregar transações recentes
      try {
        final transactions = await getRecentTxUseCase.execute(currentUser.uid, limit: 5);
        recentTransactions.value = transactions;
      } catch (e) {
        error.value = 'Erro ao carregar transações: $e';
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