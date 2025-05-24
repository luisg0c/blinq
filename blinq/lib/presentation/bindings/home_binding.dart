import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../data/account/datasources/account_remote_data_source.dart';
import '../../data/account/repositories/account_repository_impl.dart';
import '../../data/transaction/datasources/transaction_remote_data_source.dart';
import '../../data/transaction/repositories/transaction_repository_impl.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/transaction_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    print('🔧 Inicializando HomeBinding...');

    // Data Sources
    Get.lazyPut<AccountRemoteDataSource>(
      () => AccountRemoteDataSourceImpl(),
      fenix: true,
    );

    Get.lazyPut<TransactionRemoteDataSource>(
      () => TransactionRemoteDataSourceImpl(),
      fenix: true,
    );

    // Repositories
    Get.lazyPut<AccountRepository>(
      () => AccountRepositoryImpl(
        remoteDataSource: Get.find<AccountRemoteDataSource>(),
      ),
      fenix: true,
    );

    Get.lazyPut<TransactionRepository>(
      () => TransactionRepositoryImpl(
        remoteDataSource: Get.find<TransactionRemoteDataSource>(),
      ),
      fenix: true,
    );

    // Controller
    Get.lazyPut<HomeController>(
      () => HomeController(
        accountRepository: Get.find<AccountRepository>(),
        transactionRepository: Get.find<TransactionRepository>(),
      ),
      fenix: true,
    );

    print('✅ HomeBinding inicializado');
  }
}