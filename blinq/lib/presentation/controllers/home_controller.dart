import 'package:get/get.dart';
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
  final RxString? error = RxString('');

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    error?.value = '';

    try {
      final saldo = await getBalanceUseCase.execute();
      final txs = await getRecentTxUseCase.execute(limit: 5);

      balance.value = saldo;
      recentTransactions.assignAll(txs);
    } catch (e) {
      error?.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
