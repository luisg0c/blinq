import 'package:get/get.dart';
import '../../../data/transaction/datasources/transaction_remote_data_source.dart';
import '../../../data/transaction/repositories/transaction_repository_impl.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../../domain/usecases/get_balance_usecase.dart';
import '../../../domain/usecases/get_recent_transactions_usecase.dart';

/// Binding do módulo de transações: injeta data source, repositório e use cases.
class TransactionBinding extends Bindings {
  @override
  void dependencies() {
    // Data source
    Get.lazyPut<TransactionRemoteDataSource>(
      () => TransactionRemoteDataSourceImpl(),
    );

    // Repositório
    Get.lazyPut<TransactionRepository>(
      () => TransactionRepositoryImpl(
        remoteDataSource: Get.find<TransactionRemoteDataSource>(),
      ),
    );

    // Use cases
    Get.lazyPut<GetBalanceUseCase>(
      () => GetBalanceUseCase(Get.find<TransactionRepository>()),
    );
    Get.lazyPut<GetRecentTransactionsUseCase>(
      () => GetRecentTransactionsUseCase(Get.find<TransactionRepository>()),
    );
  }
}
