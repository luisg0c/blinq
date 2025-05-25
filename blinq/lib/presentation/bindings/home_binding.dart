// lib/presentation/bindings/home_binding.dart
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../data/account/repositories/account_repository_impl.dart';
import '../../data/transaction/repositories/transaction_repository_impl.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/transaction_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    print('🔧 Inicializando HomeBinding...');

    // ✅ REPOSITORIES (sem data sources)
    if (!Get.isRegistered<AccountRepository>()) {
      Get.lazyPut<AccountRepository>(
        () => AccountRepositoryImpl(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<TransactionRepository>()) {
      Get.lazyPut<TransactionRepository>(
        () => TransactionRepositoryImpl(),
        fenix: true,
      );
    }

    // ✅ CONTROLLER
    Get.lazyPut<HomeController>(
      () => HomeController(
        accountRepository: Get.find<AccountRepository>(),
        transactionRepository: Get.find<TransactionRepository>(),
      ),
      fenix: true,
    );

    print('✅ HomeBinding inicializado');
  }
}