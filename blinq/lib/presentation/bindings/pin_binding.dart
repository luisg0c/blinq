import 'package:get/get.dart';
import '../../../data/pin/repositories/pin_repository_impl.dart';
import '../../../domain/repositories/pin_repository.dart';
import '../../../domain/usecases/set_pin_usecase.dart';
import '../../../domain/usecases/validate_pin_usecase.dart';

/// Binding para o módulo de segurança com PIN.
class PinBinding extends Bindings {
  @override
  void dependencies() {
    // Repositório seguro
    Get.lazyPut<PinRepository>(() => PinRepositoryImpl());

    // Use cases
    Get.lazyPut(() => SetPinUseCase(Get.find<PinRepository>()));
    Get.lazyPut(() => ValidatePinUseCase(Get.find<PinRepository>()));
  }
}
