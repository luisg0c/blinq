import 'package:get/get.dart';
import '../../data/transaction/datasources/transaction_remote_data_source.dart';
import '../../data/transaction/repositories/transaction_repository_impl.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/get_recent_transactions_usecase.dart';
import '../../domain/usecases/create_transaction_usecase.dart';

/// Binding para o módulo de transações.
class TransactionBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
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
    Get.lazyPut<GetRecentTransactionsUseCase>(
      () => GetRecentTransactionsUseCase(Get.find<TransactionRepository>()),
    );

    Get.lazyPut<CreateTransactionUseCase>(
      () => CreateTransactionUseCase(Get.find<TransactionRepository>()),
    );
  }
}