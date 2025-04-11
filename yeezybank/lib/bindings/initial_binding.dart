import 'package:get/get.dart';
import 'package:yeezybank/data/firebase_service.dart';
import 'package:yeezybank/data/repositories/account_repository.dart';
import 'package:yeezybank/data/repositories/transaction_repository.dart';
import 'package:yeezybank/domain/services/auth_service.dart';
import 'package:yeezybank/domain/services/transaction_service.dart';
import 'package:yeezybank/domain/services/transaction_validation_service.dart';
import 'package:yeezybank/domain/services/transaction_security_service.dart';
import 'package:yeezybank/presentation/controllers/auth_controller.dart';
import 'package:yeezybank/presentation/controllers/transaction_controller.dart';
import 'package:yeezybank/presentation/controllers/transaction_password_handler.dart';
import 'package:yeezybank/presentation/controllers/home_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Serviço Firebase centralizado
    Get.lazyPut<FirebaseService>(() => FirebaseService(), fenix: true);

    // Repositórios
    Get.lazyPut<AccountRepository>(() => AccountRepository(), fenix: true);
    Get.lazyPut<TransactionRepository>(
      () => TransactionRepository(),
      fenix: true,
    );

    // Serviços de domínio
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<TransactionSecurityService>(
      () => TransactionSecurityService(),
      fenix: true,
    );
    Get.lazyPut<TransactionValidationService>(
      () => TransactionValidationService(),
      fenix: true,
    );
    Get.lazyPut<TransactionService>(() => TransactionService(), fenix: true);

    // Controllers
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<TransactionController>(
      () => TransactionController(),
      fenix: true,
    );
    Get.lazyPut<TransactionPasswordHandler>(
      () => TransactionPasswordHandler(),
      fenix: true,
    );
  }
}
