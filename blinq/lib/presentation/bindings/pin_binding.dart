import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/pin/repositories/pin_repository_impl.dart';
import '../../domain/repositories/pin_repository.dart';
import '../../domain/usecases/set_pin_usecase.dart';
import '../../domain/usecases/validate_pin_usecase.dart';
import '../controllers/pin_controller.dart';

class PinBinding extends Bindings {
  @override
  void dependencies() {
    print('🔧 Inicializando PinBinding...');

    // Secure Storage
    Get.lazyPut<FlutterSecureStorage>(() => const FlutterSecureStorage());

    // Repository
    Get.lazyPut<PinRepository>(
      () => PinRepositoryImpl(
        storage: Get.find<FlutterSecureStorage>(),
      ),
      fenix: true,
    );

    // Use Cases
    Get.lazyPut<SetPinUseCase>(
      () => SetPinUseCase(Get.find<PinRepository>()),
      fenix: true,
    );
    
    Get.lazyPut<ValidatePinUseCase>(
      () => ValidatePinUseCase(Get.find<PinRepository>()),
      fenix: true,
    );

    // Controller
    Get.lazyPut<PinController>(
      () => PinController(
        setPinUseCase: Get.find<SetPinUseCase>(),
        validatePinUseCase: Get.find<ValidatePinUseCase>(),
      ),
      fenix: true,
    );

    print('✅ PinBinding inicializado');
  }
}
