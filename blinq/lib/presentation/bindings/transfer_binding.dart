import 'package:get/get.dart';
import '../../../data/user/repositories/user_repository_impl.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../../domain/usecases/transfer_usecase.dart';

/// Binding para a tela ou módulo de transferência.
class TransferBinding extends Bindings {
  @override
  void dependencies() {
    // Repositório de usuários
    Get.lazyPut<UserRepository>(() => UserRepositoryImpl());

    // Use case de transferência
    Get.lazyPut(() => TransferUseCase(
          transactionRepo: Get.find<TransactionRepository>(),
          userRepo: Get.find<UserRepository>(),
        ));
  }
}
