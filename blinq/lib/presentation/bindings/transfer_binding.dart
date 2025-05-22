import 'package:get/get.dart';
import '../../../data/user/datasources/user_remote_data_source.dart';
import '../../../data/user/repositories/user_repository_impl.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../../domain/usecases/transfer_usecase.dart';

class TransferBinding extends Bindings {
  @override
  void dependencies() {
    // Data source
    Get.lazyPut<UserRemoteDataSource>(() => UserRemoteDataSourceImpl());

    // Repositório
    Get.lazyPut<UserRepository>(
      () => UserRepositoryImpl(remoteDataSource: Get.find()),
    );

    // Use case
    Get.lazyPut(() => TransferUseCase(
          transactionRepo: Get.find<TransactionRepository>(),
          userRepo: Get.find<UserRepository>(),
        ));
  }
}
