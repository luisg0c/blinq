import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/usecases/set_pin_usecase.dart';
import '../../domain/usecases/validate_pin_usecase.dart';
import '../../domain/repositories/pin_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class PinController extends GetxController {
  final SetPinUseCase _setPinUseCase;
  final ValidatePinUseCase _validatePinUseCase;
  final PinRepository _pinRepository;

  PinController({
    required SetPinUseCase setPinUseCase,
    required ValidatePinUseCase validatePinUseCase,
    required PinRepository pinRepository,
  }) : _setPinUseCase = setPinUseCase,
       _validatePinUseCase = validatePinUseCase,
       _pinRepository = pinRepository;

  // Observables
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();

  /// ✅ VERIFICAR SE PIN JÁ ESTÁ CONFIGURADO
  Future<bool> isPinConfigured() async {
    try {
      print('🔍 Verificando se PIN está configurado...');
      final hasPin = await _pinRepository.hasPin();
      print('📍 PIN configurado: $hasPin');
      return hasPin;
    } catch (e) {
      print('❌ Erro ao verificar PIN: $e');
      return false;
    }
  }

  /// ✅ MÉTODO CENTRALIZADO PARA SOLICITAR PIN
  static Future<bool> requestPinForAction({
    required String action,
    String? title,
    String? description,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      print('🔐 Solicitando PIN para ação: $action');

      // Verificar se PinController está registrado
      if (!Get.isRegistered<PinController>()) {
        print('❌ PinController não registrado');
        Get.snackbar(
          'Erro',
          'Sistema de PIN não disponível',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return false;
      }

      final pinController = Get.find<PinController>();
      final hasPin = await pinController.isPinConfigured();

      if (!hasPin) {
        // PIN não configurado, redirecionar para criação
        print('⚠️ PIN não configurado, solicitando criação');
        
        Get.snackbar(
          'PIN Necessário 🔒',
          'Configure um PIN de segurança primeiro',
          backgroundColor: AppColors.warning,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        final setupResult = await Get.toNamed(AppRoutes.setupPin);
        if (setupResult != true) {
          return false;
        }
      }

      // PIN configurado, solicitar verificação
      final verifyResult = await Get.toNamed(
        AppRoutes.verifyPin,
        arguments: {
          'flow': action,
          'title': title ?? 'Verificação de Segurança',
          'description': description ?? 'Digite seu PIN para continuar',
          ...?additionalData,
        },
      );

      return verifyResult == true;
    } catch (e) {
      print('❌ Erro ao solicitar PIN: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível verificar o PIN',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return false;
    }
  }

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
}