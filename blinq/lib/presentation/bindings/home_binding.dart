// lib/presentation/bindings/home_binding.dart

import 'package:get/get.dart';
import 'package:blinq/presentation/controllers/home_controller.dart';
import '../../../domain/usecases/get_balance_usecase.dart';
import '../../../domain/usecases/get_recent_transactions_usecase.dart';
import 'transaction_binding.dart';

/// Binding da HomePage: garante que o módulo de transações
/// esteja inicializado e injeta o HomeController.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Inicializa o módulo de transações (data source, repo e use cases)
    TransactionBinding().dependencies();

    // Injeta o HomeController, que depende dos use cases de transações
    Get.lazyPut<HomeController>(
      () => HomeController(
        getBalanceUseCase: Get.find<GetBalanceUseCase>(),
        getRecentTransactionsUseCase: Get.find<GetRecentTransactionsUseCase>(),
      ),
    );
  }
}
