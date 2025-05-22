import 'package:get/get.dart';
import 'package:blinq/presentation/controllers/home_controller.dart';
import 'package:blinq/domain/usecases/get_balance_usecase.dart';
import 'package:blinq/domain/usecases/get_recent_transactions_usecase.dart';
import 'transaction_binding.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Inicializa módulo de transações
    TransactionBinding().dependencies();

    // Controller
    Get.lazyPut(() => HomeController(
          getBalanceUseCase: Get.find<GetBalanceUseCase>(),
          getRecentTransactionsUseCase: Get.find<GetRecentTransactionsUseCase>(),
        ));
  }
}
