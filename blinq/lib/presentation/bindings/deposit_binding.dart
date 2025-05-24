import 'package:get/get.dart';
import '../../data/account/datasources/account_remote_data_source.dart';
import '../../data/account/repositories/account_repository_impl.dart';
import '../../data/transaction/datasources/transaction_remote_data_source.dart';
import '../../data/transaction/repositories/transaction_repository_impl.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/deposit_usecase.dart';
import '../controllers/deposit_controller.dart';

/// Binding para o módulo de depósito.
class DepositBinding extends Bindings {
  @override
  void dependencies() {
    // Data Sources
    Get.lazyPut<AccountRemoteDataSource>(
      () => AccountRemoteDataSourceImpl(),
    );
    
    Get.lazyPut<TransactionRemoteDataSource>(
      () => TransactionRemoteDataSourceImpl(),
    );

    // Repositories
    Get.lazyPut<AccountRepository>(
      () => AccountRepositoryImpl(
        remoteDataSource: Get.find<AccountRemoteDataSource>(),
      ),
    );
    
    Get.lazyPut<TransactionRepository>(
      () => TransactionRepositoryImpl(
        remoteDataSource: Get.find<TransactionRemoteDataSource>(),
      ),
    );

    // Use Case
    Get.lazyPut<DepositUseCase>(
      () => DepositUseCase(
        transactionRepository: Get.find<TransactionRepository>(),
        accountRepository: Get.find<AccountRepository>(),
      ),
    );

    // Controller
    Get.lazyPut<DepositController>(
      () => DepositController(
        depositUseCase: Get.find<DepositUseCase>(),
      ),
    );
  }
}