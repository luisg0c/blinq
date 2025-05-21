import 'package:get/get.dart';
import '../../domain/usecases/transfer_usecase.dart';
import '../../domain/usecases/validate_pin_usecase.dart';

class TransferController extends GetxController {
  final TransferUseCase _transferUseCase;
  final ValidatePinUseCase _validatePinUseCase;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();

  TransferController({
    required TransferUseCase transferUseCase,
    required ValidatePinUseCase validatePinUseCase,
  })  : _transferUseCase = transferUseCase,
        _validatePinUseCase = validatePinUseCase;

  /// Executa a transferência após validar o PIN informado.
  Future<void> transfer({
    required String toEmail,
    required double amount,
    required String description,
    required String pin,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;
    successMessage.value = null;

    try {
      final isValid = await _validatePinUseCase.execute(pin);
      if (!isValid) {
        errorMessage.value = 'PIN inválido';
        return;
      }

      await _transferUseCase.execute(
        toEmail: toEmail,
        amount: amount,
        description: description,
      );

      successMessage.value = 'Transferência realizada com sucesso';
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}
