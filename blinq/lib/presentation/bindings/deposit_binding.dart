import 'package:get/get.dart';
import '../../data/account/datasources/account_remote_data_source.dart';
import '../../data/account/repositories/account_repository_impl.dart';
import '../../data/transaction/datasources/transaction_remote_data_source.dart';
import '../../data/transaction/repositories/transaction_repository_impl.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/deposit_usecase.dart';
import '../controllers/deposit_controller.dart';

class DepositBinding extends Bindings {
  @override
  void dependencies() {
    print('🔧 Inicializando DepositBinding...');

    // Data Sources (reutilizar se já existem)
    if (!Get.isRegistered<AccountRemoteDataSource>()) {
      Get.lazyPut<AccountRemoteDataSource>(
        () => AccountRemoteDataSourceImpl(),
        fenix: true,
      );
    }
    
    if (!Get.isRegistered<TransactionRemoteDataSource>()) {
      Get.lazyPut<TransactionRemoteDataSource>(
        () => TransactionRemoteDataSourceImpl(),
        fenix: true,
      );
    }

    // Repositories (reutilizar se já existem)
    if (!Get.isRegistered<AccountRepository>()) {
      Get.lazyPut<AccountRepository>(
        () => AccountRepositoryImpl(
          remoteDataSource: Get.find<AccountRemoteDataSource>(),
        ),
        fenix: true,
      );
    }
    
    if (!Get.isRegistered<TransactionRepository>()) {
      Get.lazyPut<TransactionRepository>(
        () => TransactionRepositoryImpl(
          remoteDataSource: Get.find<TransactionRemoteDataSource>(),
        ),
        fenix: true,
      );
    }

    // Use Case
    Get.lazyPut<DepositUseCase>(
      () => DepositUseCase(
        transactionRepository: Get.find<TransactionRepository>(),
        accountRepository: Get.find<AccountRepository>(),
      ),
      fenix: true,
    );

    // Controller
    Get.lazyPut<DepositController>(
      () => DepositController(
        depositUseCase: Get.find<DepositUseCase>(),
      ),
      fenix: true,
    );

    print('✅ DepositBinding inicializado');
  }
}