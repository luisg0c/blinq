// lib/presentation/controllers/deposit_controller.dart

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/usecases/deposit_usecase.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import 'package:flutter/material.dart';

class DepositController extends GetxController {
  final DepositUseCase _depositUseCase;

  DepositController({required DepositUseCase depositUseCase})
      : _depositUseCase = depositUseCase;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxDouble amount = 0.0.obs;
  final RxString description = ''.obs;

  void setDepositData({required double value, String? desc}) {
    amount.value = value;
    description.value = desc ?? 'Depósito';
    print('💰 Dados do depósito configurados: R\$ $value');
  }

  Future<void> executeDeposit() async {
    print('🔄 Iniciando execução do depósito...');
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw const AppException('Usuário não autenticado');
      }

      if (amount.value <= 0) {
        throw const AppException('Valor deve ser maior que zero');
      }

      print('💰 Executando depósito de R\$ ${amount.value} para ${user.uid}');

      await _depositUseCase.execute(
        userId: user.uid,
        amount: amount.value,
        description: description.value,
      );

      print('✅ Depósito executado com sucesso!');

      // Mostrar notificação de sucesso
      Get.snackbar(
        'Sucesso! 💰',
        'Depósito de R\$ ${amount.value.toStringAsFixed(2)} realizado',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      // Voltar para home após sucesso
      Get.offAllNamed(AppRoutes.home);

    } on AppException catch (e) {
      print('❌ Erro de negócio: ${e.message}');
      errorMessage.value = e.message;
      
      Get.snackbar(
        'Erro no depósito',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      rethrow;
    } catch (e) {
      print('❌ Erro técnico: $e');
      final errorMsg = 'Não foi possível realizar o depósito';
      errorMessage.value = errorMsg;
      
      Get.snackbar(
        'Erro técnico',
        errorMsg,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      rethrow;
    } finally {
      isLoading.value = false;
      print('🔄 Execução do depósito finalizada');
    }
  }

  /// Limpar dados do depósito
  void clearData() {
    amount.value = 0.0;
    description.value = '';
    errorMessage.value = null;
  }

  /// Validar dados antes de prosseguir
  bool validateData() {
    if (amount.value <= 0) {
      errorMessage.value = 'Informe um valor maior que zero';
      return false;
    }

    if (amount.value > 50000) {
      errorMessage.value = 'Valor máximo por depósito: R\$ 50.000,00';
      return false;
    }

    return true;
  }
}