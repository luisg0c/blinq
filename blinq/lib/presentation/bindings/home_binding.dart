import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../domain/usecases/get_balance_usecase.dart';
import '../../domain/usecases/get_recent_transactions_usecase.dart';
import 'account_binding.dart';
import 'transaction_binding.dart';

/// Binding para a tela Home.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Inicializar dependências de módulos necessários
    AccountBinding().dependencies();
    TransactionBinding().dependencies();

    // Controller
    Get.lazyPut(() => HomeController(
      getBalanceUseCase: Get.find<GetBalanceUseCase>(),
      getRecentTxUseCase: Get.find<GetRecentTransactionsUseCase>(),
    ));
  }
}