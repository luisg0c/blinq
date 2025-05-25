// lib/presentation/bindings/transfer_binding.dart
import 'package:get/get.dart';
import '../../data/transaction/repositories/transaction_repository_impl.dart';
import '../../data/account/repositories/account_repository_impl.dart';
import '../../data/user/repositories/user_repository_impl.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/transfer_usecase.dart';
import '../controllers/transfer_controller.dart';

/// Binding para o fluxo de Transferência.
class TransferBinding extends Bindings {
  @override
  void dependencies() {
    print('🔧 Inicializando TransferBinding...');

    // ✅ TRANSACTION REPOSITORY
    if (!Get.isRegistered<TransactionRepository>()) {
      Get.lazyPut<TransactionRepository>(
        () => TransactionRepositoryImpl(),
        fenix: true,
      );
    }

    // ✅ ACCOUNT REPOSITORY
    if (!Get.isRegistered<AccountRepository>()) {
      Get.lazyPut<AccountRepository>(
        () => AccountRepositoryImpl(),
        fenix: true,
      );
    }

    // ✅ USER REPOSITORY
    if (!Get.isRegistered<UserRepository>()) {
      Get.lazyPut<UserRepository>(
        () => UserRepositoryImpl(),
        fenix: true,
      );
    }

    // ✅ TRANSFER USE CASE
    Get.lazyPut<TransferUseCase>(
      () => TransferUseCase(
        transactionRepository: Get.find<TransactionRepository>(),
        accountRepository: Get.find<AccountRepository>(),
        userRepository: Get.find<UserRepository>(),
      ),
      fenix: true,
    );

    // ✅ TRANSFER CONTROLLER
    Get.lazyPut<TransferController>(
      () => TransferController(
        transferUseCase: Get.find<TransferUseCase>(),
      ),
      fenix: true,
    );

    print('✅ TransferBinding inicializado');
  }
}