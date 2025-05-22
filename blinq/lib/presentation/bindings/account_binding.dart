import 'package:get/get.dart';
import '../../data/account/datasources/account_remote_data_source.dart';
import '../../data/account/repositories/account_repository_impl.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/usecases/deposit_usecase.dart';
import '../../domain/usecases/get_balance_usecase.dart';

/// Binding para o módulo de conta.
class AccountBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<AccountRemoteDataSource>(
      () => AccountRemoteDataSourceImpl(),
    );

    // Repository
    Get.lazyPut<AccountRepository>(
      () => AccountRepositoryImpl(
        remoteDataSource: Get.find<AccountRemoteDataSource>(),
      ),
    );

    // Use Cases
    Get.lazyPut<GetBalanceUseCase>(
      () => GetBalanceUseCase(Get.find<AccountRepository>()),
    );

    Get.lazyPut<DepositUseCase>(
      () => DepositUseCase(
        transactionRepository: Get.find(),
        accountRepository: Get.find<AccountRepository>(),
      ),
    );
  }
}