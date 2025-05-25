import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Controllers
import '../controllers/home_controller.dart';
import '../controllers/pin_controller.dart';

// Domain
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/pin_repository.dart';
import '../../domain/usecases/set_pin_usecase.dart';
import '../../domain/usecases/validate_pin_usecase.dart';

// Data
import '../../data/account/repositories/account_repository_impl.dart';
import '../../data/transaction/repositories/transaction_repository_impl.dart';
import '../../data/pin/repositories/pin_repository_impl.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    print('🔧 HomeBinding: Inicializando...');
    
    _registerDependenciesRobustly();
  }

  void _registerDependenciesRobustly() {
    try {
      // ✅ ETAPA 1: Core dependencies
      _ensureFlutterSecureStorage();
      
      // ✅ ETAPA 2: Repositories
      _ensureRepositories();
      
      // ✅ ETAPA 3: Use Cases
      _ensureUseCases();
      
      // ✅ ETAPA 4: Controllers
      _ensureControllers();
      
      print('✅ HomeBinding: Todas as dependências registradas');
      
    } catch (e) {
      print('❌ HomeBinding: Erro: $e');
      _fallbackRegistration();
    }
  }

  void _ensureFlutterSecureStorage() {
    if (!Get.isRegistered<FlutterSecureStorage>()) {
      Get.put<FlutterSecureStorage>(
        const FlutterSecureStorage(),
        permanent: true,
      );
      print('  ✓ FlutterSecureStorage registrado');
    }
  }

  void _ensureRepositories() {
    // Account Repository
    if (!Get.isRegistered<AccountRepository>()) {
      Get.put<AccountRepository>(
        AccountRepositoryImpl(),
        permanent: true,
      );
      print('  ✓ AccountRepository registrado');
    }

    // Transaction Repository
    if (!Get.isRegistered<TransactionRepository>()) {
      Get.put<TransactionRepository>(
        TransactionRepositoryImpl(),
        permanent: true,
      );
      print('  ✓ TransactionRepository registrado');
    }

    // PIN Repository
    if (!Get.isRegistered<PinRepository>()) {
      Get.put<PinRepository>(
        PinRepositoryImpl(storage: Get.find<FlutterSecureStorage>()),
        permanent: true,
      );
      print('  ✓ PinRepository registrado');
    }
  }

  void _ensureUseCases() {
    if (!Get.isRegistered<SetPinUseCase>()) {
      Get.put<SetPinUseCase>(
        SetPinUseCase(Get.find<PinRepository>()),
        permanent: true,
      );
      print('  ✓ SetPinUseCase registrado');
    }

    if (!Get.isRegistered<ValidatePinUseCase>()) {
      Get.put<ValidatePinUseCase>(
        ValidatePinUseCase(Get.find<PinRepository>()),
        permanent: true,
      );
      print('  ✓ ValidatePinUseCase registrado');
    }
  }

  void _ensureControllers() {
    // PIN Controller - CRÍTICO
    if (!Get.isRegistered<PinController>()) {
      Get.put<PinController>(
        PinController(
          setPinUseCase: Get.find<SetPinUseCase>(),
          validatePinUseCase: Get.find<ValidatePinUseCase>(),
          pinRepository: Get.find<PinRepository>(),
        ),
        permanent: true, // ✅ PERMANENTE!
      );
      print('  ✓ PinController registrado (PERMANENTE)');
    }

    // Home Controller
    if (!Get.isRegistered<HomeController>()) {
      Get.put<HomeController>(
        HomeController(
          accountRepository: Get.find<AccountRepository>(),
          transactionRepository: Get.find<TransactionRepository>(),
        ),
      );
      print('  ✓ HomeController registrado');
    }
  }

  void _fallbackRegistration() {
    print('🚨 Executando registro de emergência...');
    
    try {
      // Criar tudo manualmente sem Get.find
      const storage = FlutterSecureStorage();
      final pinRepo = PinRepositoryImpl(storage: storage);
      final accountRepo = AccountRepositoryImpl();
      final transactionRepo = TransactionRepositoryImpl();
      
      final setPinUseCase = SetPinUseCase(pinRepo);
      final validatePinUseCase = ValidatePinUseCase(pinRepo);
      
      // Registrar diretamente
      Get.put<FlutterSecureStorage>(storage);
      Get.put<PinRepository>(pinRepo);
      Get.put<AccountRepository>(accountRepo);
      Get.put<TransactionRepository>(transactionRepo);
      Get.put<SetPinUseCase>(setPinUseCase);
      Get.put<ValidatePinUseCase>(validatePinUseCase);
      
      Get.put<PinController>(PinController(
        setPinUseCase: setPinUseCase,
        validatePinUseCase: validatePinUseCase,
        pinRepository: pinRepo,
      ));
      
      Get.put<HomeController>(HomeController(
        accountRepository: accountRepo,
        transactionRepository: transactionRepo,
      ));
      
      print('✅ Registro de emergência concluído');
    } catch (e) {
      print('💥 Fallback falhou: $e');
    }
  }

  // ✅ MÉTODO ESTÁTICO PARA VERIFICAR SAÚDE
  static bool isHealthy() {
    try {
      Get.find<PinController>();
      Get.find<HomeController>();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ✅ MÉTODO ESTÁTICO PARA REPARAR
  static void repair() {
    final binding = HomeBinding();
    binding._fallbackRegistration();
  }
}