import 'package:get/get.dart';
import 'package:blinq/data/transaction/datasources/transaction_remote_data_source.dart';
import 'package:blinq/data/transaction/repositories/transaction_repository_impl.dart';
import 'package:blinq/domain/repositories/transaction_repository.dart';
import 'package:blinq/domain/usecases/get_balance_usecase.dart';
import 'package:blinq/domain/usecases/get_recent_transactions_usecase.dart';

class TransactionBinding extends Bindings {
  @override
  void dependencies() {
    // Data
    Get.lazyPut<TransactionRemoteDataSource>(
      () => TransactionRemoteDataSourceImpl(),
    );

    // Repository
    Get.lazyPut<TransactionRepository>(
      () => TransactionRepositoryImpl(
        remoteDataSource: Get.find<TransactionRemoteDataSource>(),
      ),
    );

    // Use Cases
    Get.lazyPut<GetBalanceUseCase>(
      () => GetBalanceUseCase(Get.find<TransactionRepository>()),
    );

    Get.lazyPut<GetRecentTransactionsUseCase>(
      () => GetRecentTransactionsUseCase(Get.find<TransactionRepository>()),
    );
  }
}
