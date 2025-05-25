// lib/presentation/controllers/pin_controller.dart - VERSÃO FUNCIONAL

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

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();

  Future<bool> isPinConfigured() async {
    try {
      return await _pinRepository.hasPin();
    } catch (e) {
      print('❌ Erro ao verificar PIN: $e');
      return false;
    }
  }

  static Future<bool> requestPinForAction({
    required String action,
    String? title,
    String? description,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      print('🔐 Solicitando PIN para: $action');

      if (!Get.isRegistered<PinController>()) {
        Get.snackbar('Erro', 'Sistema de PIN não disponível');
        return false;
      }

      final pinController = Get.find<PinController>();
      final hasPin = await pinController.isPinConfigured();

      if (!hasPin) {
        print('⚠️ PIN não configurado');
        Get.snackbar(
          'PIN Necessário',
          'Configure um PIN primeiro',
          backgroundColor: AppColors.warning,
          colorText: Colors.white,
        );

        final result = await Get.toNamed(AppRoutes.setupPin);
        if (result != true) return false;
      }

      // Sempre solicitar verificação
      final verifyResult = await Get.toNamed(
        AppRoutes.verifyPin,
        arguments: {
          'flow': action,
          'title': title ?? 'Verificação',
          'description': description ?? 'Digite seu PIN',
          ...?additionalData,
        },
      );

      return verifyResult == true;
    } catch (e) {
      print('❌ Erro: $e');
      return false;
    }
  }

  Future<void> setPin(String pin) async {
    if (!_isValidPin(pin)) {
      errorMessage.value = 'PIN deve ter 4-6 dígitos';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _setPinUseCase.execute(pin);
      
      // Verificar se salvou
      await Future.delayed(const Duration(milliseconds: 200));
      final saved = await _pinRepository.hasPin();
      
      if (!saved) {
        throw Exception('PIN não foi salvo');
      }

      Get.snackbar(
        'Sucesso!',
        'PIN configurado com segurança',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

      await Future.delayed(const Duration(milliseconds: 1000));
      Get.offAllNamed(AppRoutes.home);

    } catch (e) {
      print('❌ Erro ao salvar PIN: $e');
      errorMessage.value = 'Erro ao configurar PIN';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> validatePin(String pin) async {
    if (!_isValidPin(pin)) {
      errorMessage.value = 'PIN inválido';
      return false;
    }

    try {
      final isValid = await _validatePinUseCase.execute(pin);
      if (!isValid) {
        errorMessage.value = 'PIN incorreto';
      }
      return isValid;
    } catch (e) {
      print('❌ Erro na validação: $e');
      errorMessage.value = 'Erro ao validar PIN';
      return false;
    }
  }

  void clearMessages() {
    errorMessage.value = null;
    successMessage.value = null;
  }

  bool _isValidPin(String pin) {
    return RegExp(r'^\d{4,6}$').hasMatch(pin.trim());
  }
}