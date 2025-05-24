import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/pin/repositories/pin_repository_impl.dart';
import '../../domain/repositories/pin_repository.dart';
import '../../domain/usecases/set_pin_usecase.dart';
import '../../domain/usecases/validate_pin_usecase.dart';
import '../controllers/pin_controller.dart';

/// Binding para o módulo de segurança com PIN.
class PinBinding extends Bindings {
  @override
  void dependencies() {
    // Secure Storage
    Get.lazyPut<FlutterSecureStorage>(
      () => const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
        iOptions: IOSOptions(
          accessibility: IOSAccessibility.first_unlock_this_device,
        ),
      ),
    );

    // Repositório seguro
    Get.lazyPut<PinRepository>(
      () => PinRepositoryImpl(storage: Get.find<FlutterSecureStorage>()),
    );

    // Use cases
    Get.lazyPut<SetPinUseCase>(
      () => SetPinUseCase(Get.find<PinRepository>()),
    );
    
    Get.lazyPut<ValidatePinUseCase>(
      () => ValidatePinUseCase(Get.find<PinRepository>()),
    );

    // Controller
    Get.lazyPut<PinController>(
      () => PinController(
        setPinUseCase: Get.find<SetPinUseCase>(),
        validatePinUseCase: Get.find<ValidatePinUseCase>(),
      ),
    );
  }
}