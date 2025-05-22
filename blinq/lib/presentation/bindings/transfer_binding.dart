import 'package:get/get.dart';
import '../../data/user/datasources/user_remote_data_source.dart';
import '../../data/user/repositories/user_repository_impl.dart';
import '../../data/account/datasources/account_remote_data_source.dart';
import '../../data/account/repositories/account_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/transfer_usecase.dart';

/// Binding para transferências.
class TransferBinding extends Bindings {
  @override
  void dependencies() {
    // User Data Source
    Get.lazyPut<UserRemoteDataSource>(() => UserRemoteDataSourceImpl());

    // Account Data Source
    Get.lazyPut<AccountRemoteDataSource>(() => AccountRemoteDataSourceImpl());

    // User Repository
    Get.lazyPut<UserRepository>(
      () => UserRepositoryImpl(remoteDataSource: Get.find()),
    );

    // Account Repository
    Get.lazyPut<AccountRepository>(
      () => AccountRepositoryImpl(remoteDataSource: Get.find()),
    );

    // Use case
    Get.lazyPut(() => TransferUseCase(
      transactionRepository: Get.find<TransactionRepository>(),
      accountRepository: Get.find<AccountRepository>(),
      userRepository: Get.find<UserRepository>(),
    ));
  }
}