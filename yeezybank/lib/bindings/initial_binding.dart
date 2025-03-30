import 'package:get/get.dart';
import 'package:yeezybank/domain/services/auth_service.dart';
import 'package:yeezybank/domain/services/transaction_service.dart';
import 'package:yeezybank/presentation/controllers/auth_controller.dart';
import 'package:yeezybank/presentation/controllers/transaction_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<TransactionService>(() => TransactionService(), fenix: true);

    // Controllers
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<TransactionController>(
      () => TransactionController(),
      fenix: true,
    );
  }
}
