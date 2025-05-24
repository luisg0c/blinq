// blinq/lib/presentation/bindings/deposit_binding.dart
import 'package:get/get.dart';
import '../../data/account/datasources/account_remote_data_source.dart';
import '../../data/account/repositories/account_repository_impl.dart';
import '../../data/transaction/datasources/transaction_remote_data_source.dart';
import '../../data/transaction/repositories/transaction_repository_impl.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/deposit_usecase.dart';
import '../controllers/deposit_controller.dart';

/// Binding para o módulo de depósito.
class DepositBinding extends Bindings {
  @override
  void dependencies() {
    print('🔧 Inicializando DepositBinding...');

    // Data Sources (se ainda não existirem)
    if (!Get.isRegistered<AccountRemoteDataSource>()) {
      Get.lazyPut<AccountRemoteDataSource>(
        () {
          print('📡 Criando AccountRemoteDataSource para Deposit');
          return AccountRemoteDataSourceImpl();
        },
        fenix: true,
      );
    }
    
    if (!Get.isRegistered<TransactionRemoteDataSource>()) {
      Get.lazyPut<TransactionRemoteDataSource>(
        () {
          print('📡 Criando TransactionRemoteDataSource para Deposit');
          return TransactionRemoteDataSourceImpl();
        },
        fenix: true,
      );
    }

    // Repositories (se ainda não existirem)
    if (!Get.isRegistered<AccountRepository>()) {
      Get.lazyPut<AccountRepository>(
        () {
          print('🗄️ Criando AccountRepository para Deposit');
          return AccountRepositoryImpl(
            remoteDataSource: Get.find<AccountRemoteDataSource>(),
          );
        },
        fenix: true,
      );
    }
    
    if (!Get.isRegistered<TransactionRepository>()) {
      Get.lazyPut<TransactionRepository>(
        () {
          print('🗄️ Criando TransactionRepository para Deposit');
          return TransactionRepositoryImpl(
            remoteDataSource: Get.find<TransactionRemoteDataSource>(),
          );
        },
        fenix: true,
      );
    }

    // Use Case - sempre criar novo para evitar conflitos
    Get.lazyPut<DepositUseCase>(
      () {
        print('⚙️ Criando DepositUseCase');
        return DepositUseCase(
          transactionRepository: Get.find<TransactionRepository>(),
          accountRepository: Get.find<AccountRepository>(),
        );
      },
      fenix: true,
    );

    // Controller - sempre criar novo
    Get.lazyPut<DepositController>(
      () {
        print('🎮 Criando DepositController');
        return DepositController(
          depositUseCase: Get.find<DepositUseCase>(),
        );
      },
      fenix: true,
    );

    print('✅ DepositBinding inicializado com sucesso');
    print('🔍 Dependências registradas:');
    print('   - AccountRemoteDataSource: ${Get.isRegistered<AccountRemoteDataSource>()}');
    print('   - TransactionRemoteDataSource: ${Get.isRegistered<TransactionRemoteDataSource>()}');
    print('   - AccountRepository: ${Get.isRegistered<AccountRepository>()}');
    print('   - TransactionRepository: ${Get.isRegistered<TransactionRepository>()}');
    print('   - DepositUseCase: ${Get.isRegistered<DepositUseCase>()}');
    print('   - DepositController: ${Get.isRegistered<DepositController>()}');
  }
}