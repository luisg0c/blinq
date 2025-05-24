import 'package:get/get.dart';
import '../../domain/usecases/set_pin_usecase.dart';
import '../../domain/usecases/validate_pin_usecase.dart';

class PinController extends GetxController {
  final SetPinUseCase _setPinUseCase;
  final ValidatePinUseCase _validatePinUseCase;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();

  PinController({
    required SetPinUseCase setPinUseCase,
    required ValidatePinUseCase validatePinUseCase,
  })  : _setPinUseCase = setPinUseCase,
        _validatePinUseCase = validatePinUseCase;

  /// Define ou atualiza o PIN.
  Future<void> setPin(String pin) async {
    isLoading.value = true;
    errorMessage.value = null;
    successMessage.value = null;

    try {
      await _setPinUseCase.execute(pin);
      successMessage.value = 'PIN salvo com sucesso';
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Valida se o PIN digitado corresponde ao salvo.
  Future<bool> validatePin(String pin) async {
    try {
      return await _validatePinUseCase.execute(pin);
    } catch (_) {
      return false;
    }
  }
}