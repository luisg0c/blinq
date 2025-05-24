import 'package:get/get.dart';

// Transaction
import '../../../data/transaction/datasources/transaction_remote_data_source.dart';
import '../../../data/transaction/repositories/transaction_repository_impl.dart';
import '../../../domain/repositories/transaction_repository.dart';

// Account
import '../../../data/account/datasources/account_remote_data_source.dart';
import '../../../data/account/repositories/account_repository_impl.dart';
import '../../../domain/repositories/account_repository.dart';

// User
import '../../../data/user/datasources/user_remote_data_source.dart';
import '../../../data/user/repositories/user_repository_impl.dart';
import '../../../domain/repositories/user_repository.dart';

// UseCase & Controller
import '../../../domain/usecases/transfer_usecase.dart';
import '../controllers/transfer_controller.dart';

/// Binding do TransferController com todas as dependências necessárias.
class TransferControllerBinding extends Bindings {
  @override
  void dependencies() {
    // 1) Data source para chamadas de transação
    Get.lazyPut<TransactionRemoteDataSource>(
      () => TransactionRemoteDataSourceImpl(),
    );
    // 2) Repositório de transação
    Get.lazyPut<TransactionRepository>(
      () => TransactionRepositoryImpl(
        remoteDataSource: Get.find<TransactionRemoteDataSource>(),
      ),
    );

    // 3) Data source para conta
    Get.lazyPut<AccountRemoteDataSource>(
      () => AccountRemoteDataSourceImpl(),
    );
    // 4) Repositório de conta
    Get.lazyPut<AccountRepository>(
      () => AccountRepositoryImpl(
        remoteDataSource: Get.find<AccountRemoteDataSource>(),
      ),
    );

    // 5) Data source para usuário
    Get.lazyPut<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl(),
    );
    // 6) Repositório de usuário
    Get.lazyPut<UserRepository>(
      () => UserRepositoryImpl(
        remoteDataSource: Get.find<UserRemoteDataSource>(),
      ),
    );

    // 7) Caso de uso de transferência, com todos os repositórios
    Get.lazyPut<TransferUseCase>(
      () => TransferUseCase(
        transactionRepository: Get.find<TransactionRepository>(),
        accountRepository:     Get.find<AccountRepository>(),
        userRepository:        Get.find<UserRepository>(),
      ),
    );

    // 8) Controller de transferência
    Get.lazyPut<TransferController>(
      () => TransferController(
        transferUseCase: Get.find<TransferUseCase>(),
      ),
    );
  }
}
