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

  final RxDouble balance = 0.0.obs;
  final RxList<Transaction> recentTransactions = <Transaction>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    error.value = null;

    try {
      // Obter ID do usuário atual
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final userId = user.uid;

      // Carregar saldo e transações em paralelo
      final results = await Future.wait([
        getBalanceUseCase.execute(userId),
        getRecentTxUseCase.execute(userId, limit: 5),
      ]);

      balance.value = results[0] as double;
      recentTransactions.assignAll(results[1] as List<Transaction>);
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadDashboard();
  }
}