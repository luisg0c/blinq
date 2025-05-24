// lib/presentation/bindings/pin_binding.dart

import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../data/pin/repositories/pin_repository_impl.dart';
import '../../../domain/repositories/pin_repository.dart';
import '../../../domain/usecases/set_pin_usecase.dart';
import '../../../domain/usecases/validate_pin_usecase.dart';
import '../controllers/pin_controller.dart';

class PinBinding extends Bindings {
  @override
  void dependencies() {
    // 1) Registra o armazenamento seguro
    Get.lazyPut<FlutterSecureStorage>(() => const FlutterSecureStorage());

    // 2) Repositório de PIN
    Get.lazyPut<PinRepository>(
      () => PinRepositoryImpl(
        storage: Get.find<FlutterSecureStorage>(),
      ),
    );

    // 3) Use cases
    Get.lazyPut<SetPinUseCase>(
      () => SetPinUseCase(Get.find<PinRepository>()),
    );
    Get.lazyPut<ValidatePinUseCase>(
      () => ValidatePinUseCase(Get.find<PinRepository>()),
    );

    // 4) Controller de PIN
    Get.lazyPut<PinController>(
      () => PinController(
        setPinUseCase: Get.find<SetPinUseCase>(),
        validatePinUseCase: Get.find<ValidatePinUseCase>(),
      ),
    );
  }
}
