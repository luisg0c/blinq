import 'package:get/get.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/usecases/get_balance_usecase.dart';
import '../../../domain/usecases/get_recent_transactions_usecase.dart';
import '../../../routes/app_routes.dart';

/// Controller da HomePage: carrega saldo e transações recentes,
/// além de navegar para outras telas.
class HomeController extends GetxController {
  final GetBalanceUseCase _getBalanceUseCase;
  final GetRecentTransactionsUseCase _getRecentTxUseCase;

  /// Saldo atual do usuário.
  final RxDouble balance = 0.0.obs;

  /// Lista de transações recentes.
  final RxList<Transaction> recentTransactions = <Transaction>[].obs;

  /// Estado de carregamento.
  final RxBool isLoading = false.obs;

  /// Mensagem de erro (se houver).
  final Rxn<String> errorMessage = Rxn<String>();

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
      // Busca o saldo
      final b = await _getBalanceUseCase.execute();
      balance.value = b;

      // Busca as 5 transações mais recentes
      final txs = await _getRecentTxUseCase.execute(limit: 5);
      recentTransactions.assignAll(txs);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Navega para a tela de depósito.
  void goToDeposit() => Get.toNamed(AppRoutes.deposit);

  /// Navega para a tela de transferência.
  void goToTransfer() => Get.toNamed(AppRoutes.transfer);

  /// Navega para a tela de histórico completo.
  void goToHistory() => Get.toNamed(AppRoutes.history);
}
