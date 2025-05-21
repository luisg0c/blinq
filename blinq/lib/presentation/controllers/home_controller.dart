import 'package:get/get.dart';
import '../../../domain/usecases/get_balance_usecase.dart';
import '../../../domain/usecases/get_recent_transactions_usecase.dart';
import '../../../domain/entities/transaction.dart';
import '../../../routes/app_routes.dart';

class HomeController extends GetxController {
  final GetBalanceUseCase _getBalanceUseCase;
  final GetRecentTransactionsUseCase _getRecentTxUseCase;

  final RxDouble balance = 0.0.obs;
  final RxList<Transaction> recentTransactions = <Transaction>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  HomeController({
    required GetBalanceUseCase getBalanceUseCase,
    required GetRecentTransactionsUseCase getRecentTransactionsUseCase,
  })  : _getBalanceUseCase = getBalanceUseCase,
        _getRecentTxUseCase = getRecentTransactionsUseCase;

  @override
  void onInit() {
    super.onInit();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final b = await _getBalanceUseCase.execute();
      balance.value = b;

      final txs = await _getRecentTxUseCase.execute(limit: 5);
      recentTransactions.assignAll(txs);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void goToDeposit() => Get.toNamed(AppRoutes.deposit);
  void goToTransfer() => Get.toNamed(AppRoutes.transfer);
  void goToHistory() => Get.toNamed(AppRoutes.history); //
}
