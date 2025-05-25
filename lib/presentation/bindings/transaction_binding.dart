// lib/presentation/bindings/transaction_binding.dart
import 'package:get/get.dart';
import '../../data/transaction/repositories/transaction_repository_impl.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/get_recent_transactions_usecase.dart';
import '../../domain/usecases/create_transaction_usecase.dart';

/// Binding simplificado para o módulo de transações.
class TransactionBinding extends Bindings {
  @override
  void dependencies() {
    print('🔧 Inicializando TransactionBinding...');

    // ✅ REPOSITORY DIRETO (sem data source)
    Get.lazyPut<TransactionRepository>(
      () => TransactionRepositoryImpl(),
      fenix: true,
    );

    // ✅ USE CASES
    Get.lazyPut<GetRecentTransactionsUseCase>(
      () => GetRecentTransactionsUseCase(Get.find<TransactionRepository>()),
      fenix: true,
    );

    Get.lazyPut<CreateTransactionUseCase>(
      () => CreateTransactionUseCase(Get.find<TransactionRepository>()),
      fenix: true,
    );

    print('✅ TransactionBinding inicializado');
  }
}