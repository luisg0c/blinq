import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'account_binding.dart';
import 'transaction_binding.dart';

/// Binding para a tela Home (sem use cases desnecessários).
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Inicializar dependências de módulos necessários
    AccountBinding().dependencies();
    TransactionBinding().dependencies();

    // Controller simplificado (sem use cases de passthrough)
    Get.lazyPut(() => HomeController(
      accountRepository: Get.find(),
      transactionRepository: Get.find(),
    ));
  }
}