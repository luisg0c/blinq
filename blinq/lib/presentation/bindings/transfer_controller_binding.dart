import 'package:get/get.dart';
import 'package:blinq/presentation/controllers/transfer_controller.dart';
import '../../../domain/usecases/transfer_usecase.dart';
import '../../../domain/usecases/validate_pin_usecase.dart';

/// Binding do TransferController com os use cases necessários.
class TransferControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransferController>(() => TransferController(
          transferUseCase: Get.find<TransferUseCase>(),
          validatePinUseCase: Get.find<ValidatePinUseCase>(),
        ));
  }
}
