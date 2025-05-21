import 'package:get/get.dart';
import 'package:blinq/presentation/controllers/pin_controller.dart';
import '../../../domain/usecases/set_pin_usecase.dart';
import '../../../domain/usecases/validate_pin_usecase.dart';

/// Binding do PinController com os use cases necessários.
class PinControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PinController>(() => PinController(
          setPinUseCase: Get.find<SetPinUseCase>(),
          validatePinUseCase: Get.find<ValidatePinUseCase>(),
        ));
  }
}
