// lib/presentation/bindings/transfer_binding.dart

import 'package:get/get.dart';

// Remote data sources
import '../../../data/transaction/datasources/transaction_remote_data_source.dart';
import '../../../data/account/datasources/account_remote_data_source.dart';
import '../../../data/user/datasources/user_remote_data_source.dart';

// Repository implementations
import '../../../data/transaction/repositories/transaction_repository_impl.dart';
import '../../../data/account/repositories/account_repository_impl.dart';
import '../../../data/user/repositories/user_repository_impl.dart';

// Domain abstractions
import '../../../domain/repositories/transaction_repository.dart';
import '../../../domain/repositories/account_repository.dart';
import '../../../domain/repositories/user_repository.dart';

// Use case & Controller
import '../../../domain/usecases/transfer_usecase.dart';
import '../controllers/transfer_controller.dart';

/// Binding completo para o fluxo de Transferência.
class TransferBinding extends Bindings {
  @override
  void dependencies() {
    // 1) Transaction
    Get.lazyPut<TransactionRemoteDataSource>(
      () => TransactionRemoteDataSourceImpl(),
    );
    Get.lazyPut<TransactionRepository>(
      () => TransactionRepositoryImpl(
        remoteDataSource: Get.find<TransactionRemoteDataSource>(),
      ),
    );

    // 2) Account
    Get.lazyPut<AccountRemoteDataSource>(
      () => AccountRemoteDataSourceImpl(),
    );
    Get.lazyPut<AccountRepository>(
      () => AccountRepositoryImpl(
        remoteDataSource: Get.find<AccountRemoteDataSource>(),
      ),
    );

    // 3) User
    Get.lazyPut<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl(),
    );
    Get.lazyPut<UserRepository>(
      () => UserRepositoryImpl(
        remoteDataSource: Get.find<UserRemoteDataSource>(),
      ),
    );

    // 4) Caso de uso
    Get.lazyPut<TransferUseCase>(
      () => TransferUseCase(
        transactionRepository: Get.find<TransactionRepository>(),
        accountRepository:     Get.find<AccountRepository>(),
        userRepository:        Get.find<UserRepository>(),
      ),
    );

    // 5) Controller
    Get.lazyPut<TransferController>(
      () => TransferController(
        transferUseCase: Get.find<TransferUseCase>(),
      ),
    );
  }
}
