// blinq/lib/presentation/bindings/home_binding.dart
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../data/account/datasources/account_remote_data_source.dart';
import '../../data/account/repositories/account_repository_impl.dart';
import '../../data/transaction/datasources/transaction_remote_data_source.dart';
import '../../data/transaction/repositories/transaction_repository_impl.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/transaction_repository.dart';

/// Binding para a tela Home com todas as dependências necessárias.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    print('🔧 Inicializando HomeBinding...');

    // 1. Data Sources
    Get.lazyPut<AccountRemoteDataSource>(
      () {
        print('📡 Criando AccountRemoteDataSource');
        return AccountRemoteDataSourceImpl();
      },
      fenix: true, // Permite recriar se necessário
    );

    Get.lazyPut<TransactionRemoteDataSource>(
      () {
        print('📡 Criando TransactionRemoteDataSource');
        return TransactionRemoteDataSourceImpl();
      },
      fenix: true,
    );

    // 2. Repositories
    Get.lazyPut<AccountRepository>(
      () {
        print('🗄️ Criando AccountRepository');
        return AccountRepositoryImpl(
          remoteDataSource: Get.find<AccountRemoteDataSource>(),
        );
      },
      fenix: true,
    );

    Get.lazyPut<TransactionRepository>(
      () {
        print('🗄️ Criando TransactionRepository');
        return TransactionRepositoryImpl(
          remoteDataSource: Get.find<TransactionRemoteDataSource>(),
        );
      },
      fenix: true,
    );

    // 3. Controller
    Get.lazyPut<HomeController>(
      () {
        print('🎮 Criando HomeController');
        return HomeController(
          accountRepository: Get.find<AccountRepository>(),
          transactionRepository: Get.find<TransactionRepository>(),
        );
      },
      fenix: true,
    );

    print('✅ HomeBinding inicializado com sucesso');
  }
}