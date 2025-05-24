import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/usecases/set_pin_usecase.dart';
import '../../domain/usecases/validate_pin_usecase.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class PinController extends GetxController {
  final SetPinUseCase _setPinUseCase;
  final ValidatePinUseCase _validatePinUseCase;

  PinController({
    required SetPinUseCase setPinUseCase,
    required ValidatePinUseCase validatePinUseCase,
  }) : _setPinUseCase = setPinUseCase,
       _validatePinUseCase = validatePinUseCase;

  // Observables
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();

  /// Define ou atualiza o PIN
  Future<void> setPin(String pin) async {
    if (pin.trim().isEmpty) {
      errorMessage.value = 'Digite um PIN';
      return;
    }

    if (!_isValidPin(pin)) {
      errorMessage.value = 'O PIN deve conter de 4 a 6 dígitos numéricos';
      return;
    }

    print('🔐 PinController: Definindo PIN...');
    isLoading.value = true;
    errorMessage.value = null;
    successMessage.value = null;

    try {
      await _setPinUseCase.execute(pin);
      
      print('✅ PIN definido com sucesso');
      successMessage.value = 'PIN configurado com segurança! 🔒';
      
      // Mostrar feedback de sucesso
      Get.snackbar(
        'PIN Configurado! 🔒',
        'Seu PIN foi salvo com segurança',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      
      // Aguardar um pouco e navegar para home
      await Future.delayed(const Duration(milliseconds: 1500));
      Get.offAllNamed(AppRoutes.home);
      
    } catch (e) {
      print('❌ Erro ao definir PIN: $e');
      errorMessage.value = _formatErrorMessage(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Valida se o PIN digitado corresponde ao salvo
  Future<bool> validatePin(String pin) async {
    if (pin.trim().isEmpty) {
      errorMessage.value = 'Digite o PIN';
      return false;
    }

    if (!_isValidPin(pin)) {
      errorMessage.value = 'PIN inválido';
      return false;
    }

    try {
      print('🔐 Validando PIN...');
      final isValid = await _validatePinUseCase.execute(pin);
      
      if (!isValid) {
        errorMessage.value = 'PIN incorreto';
        return false;
      }
      
      print('✅ PIN válido');
      return true;
      
    } catch (e) {
      print('❌ Erro ao validar PIN: $e');
      errorMessage.value = 'Erro ao validar PIN';
      return false;
    }
  }

  /// Limpa mensagens de erro e sucesso
  void clearMessages() {
    errorMessage.value = null;
    successMessage.value = null;
  }

  /// Valida formato do PIN
  bool _isValidPin(String pin) {
    final regex = RegExp(r'^\d{4,6}$');
    return regex.hasMatch(pin.trim());
  }

  /// Formata mensagens de erro
  String _formatErrorMessage(String error) {
    return error
        .replaceAll('Exception: ', '')
        .replaceAll('PinException: ', '');
  }

  /// Verifica se PIN já foi configurado
  Future<bool> isPinConfigured() async {
    try {
      // Tenta validar com PIN vazio - se der erro, provavelmente não está configurado
      return await _validatePinUseCase.execute('');
    } catch (e) {
      return false;
    }
  }

  /// Método para teste de PIN (desenvolvimento)
  void testPin(String pin) {
    print('🧪 Testando PIN: $pin');
    validatePin(pin).then((isValid) {
      print('🧪 Resultado: ${isValid ? "VÁLIDO" : "INVÁLIDO"}');
    });
  }
}