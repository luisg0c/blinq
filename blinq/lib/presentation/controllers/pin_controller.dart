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
    print('🔧 PinController: Iniciando setPin...');
    isLoading.value = true;
    errorMessage.value = null;
    successMessage.value = null;

    try {
      print('🔧 Chamando use case...');
      await _setPinUseCase.execute(pin);
      print('✅ Use case executado com sucesso');
      successMessage.value = 'PIN salvo com sucesso';
    } catch (e) {
      print('❌ Erro no use case: $e');
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      errorMessage.value = errorMsg;
    } finally {
      isLoading.value = false;
      print('🔧 PinController: Finalizando setPin');
      print('🔧 Success: ${successMessage.value}');
      print('🔧 Error: ${errorMessage.value}');
    }
  }

  /// Valida se o PIN digitado corresponde ao salvo.
  Future<bool> validatePin(String pin) async {
    try {
      return await _validatePinUseCase.execute(pin);
    } catch (e) {
      errorMessage.value = 'Erro ao validar PIN: ${e.toString()}';
      return false;
    }
  }

  /// Limpa mensagens de erro e sucesso
  void clearMessages() {
    errorMessage.value = null;
    successMessage.value = null;
  }
}