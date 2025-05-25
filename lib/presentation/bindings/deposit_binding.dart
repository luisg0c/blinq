// lib/presentation/bindings/deposit_binding.dart
import 'package:get/get.dart';
import '../../data/account/repositories/account_repository_impl.dart';
import '../../data/transaction/repositories/transaction_repository_impl.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/deposit_usecase.dart';
import '../controllers/deposit_controller.dart';

class DepositBinding extends Bindings {
  @override
  void dependencies() {
    print('🔧 Inicializando DepositBinding...');

    // ✅ ACCOUNT REPOSITORY
    if (!Get.isRegistered<AccountRepository>()) {
      Get.lazyPut<AccountRepository>(
        () => AccountRepositoryImpl(),
        fenix: true,
      );
    }
    
    // ✅ TRANSACTION REPOSITORY  
    if (!Get.isRegistered<TransactionRepository>()) {
      Get.lazyPut<TransactionRepository>(
        () => TransactionRepositoryImpl(),
        fenix: true,
      );
    }

    // ✅ DEPOSIT USE CASE
    Get.lazyPut<DepositUseCase>(
      () => DepositUseCase(
        transactionRepository: Get.find<TransactionRepository>(),
        accountRepository: Get.find<AccountRepository>(),
      ),
      fenix: true,
    );

    // ✅ DEPOSIT CONTROLLER
    Get.lazyPut<DepositController>(
      () => DepositController(
        depositUseCase: Get.find<DepositUseCase>(),
      ),
      fenix: true,
    );

    print('✅ DepositBinding inicializado');
  }
}