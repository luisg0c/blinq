// lib/presentation/bindings/account_binding.dart
import 'package:get/get.dart';
import '../../data/account/repositories/account_repository_impl.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/usecases/get_balance_usecase.dart';

/// Binding para o módulo de conta.
class AccountBinding extends Bindings {
  @override
  void dependencies() {
    print('🔧 Inicializando AccountBinding...');

    // ✅ ACCOUNT REPOSITORY (direto, sem data source)
    if (!Get.isRegistered<AccountRepository>()) {
      Get.lazyPut<AccountRepository>(
        () => AccountRepositoryImpl(),
        fenix: true,
      );
    }

    // ✅ GET BALANCE USE CASE
    Get.lazyPut<GetBalanceUseCase>(
      () => GetBalanceUseCase(Get.find<AccountRepository>()),
      fenix: true,
    );

    print('✅ AccountBinding inicializado');
  }
}