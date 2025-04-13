import 'package:get/get.dart';
import 'package:blinq/data/firebase_service.dart';
import 'package:blinq/data/repositories/account_repository.dart';
import 'package:blinq/data/repositories/transaction_repository.dart';
import 'package:blinq/domain/services/auth_service.dart';
import 'package:blinq/domain/services/transaction_service.dart';
import 'package:blinq/domain/services/transaction_validation_service.dart';
import 'package:blinq/domain/services/transaction_security_service.dart';
import 'package:blinq/presentation/controllers/auth_controller.dart';
import 'package:blinq/presentation/controllers/transaction_controller.dart';
import 'package:blinq/presentation/controllers/transaction_password_handler.dart';
import 'package:blinq/presentation/controllers/home_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Serviço Firebase centralizado - precisa ser permanente
    Get.put<FirebaseService>(FirebaseService(), permanent: true);

    // Repositórios - também permanentes para manter estado
    Get.put<AccountRepository>(AccountRepository(), permanent: true);
    Get.put<TransactionRepository>(TransactionRepository(), permanent: true);

    // Serviços de domínio - permanentes
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<TransactionSecurityService>(
      TransactionSecurityService(),
      permanent: true,
    );
    Get.put<TransactionValidationService>(
      TransactionValidationService(),
      permanent: true,
    );
    Get.put<TransactionService>(TransactionService(), permanent: true);

    // Controllers - usando lazyPut com parameter permanent para manter instância quando necessário
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
