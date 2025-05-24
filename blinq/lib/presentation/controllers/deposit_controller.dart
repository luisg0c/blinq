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
<<<<<<< Updated upstream
    description.value = desc ?? 'Depósito PIX';
    print('💰 DepositController - Dados configurados:');
    print('   Valor: R\$ $value');
    print('   Descrição: ${description.value}');
  }

  Future<void> executeDeposit() async {
    print('🔄 DepositController - Iniciando execução do depósito...');
    print('   Valor atual: R\$ ${amount.value}');
    print('   Descrição atual: ${description.value}');
    
    if (amount.value <= 0) {
      print('❌ Valor inválido: ${amount.value}');
      throw const AppException('Valor deve ser maior que zero');
    }
    
=======
    description.value = desc ?? 'Depósito';
    print('💰 Dados do depósito configurados: R\$ $value');
  }

  Future<void> executeDeposit() async {
    print('🔄 Iniciando execução do depósito...');
>>>>>>> Stashed changes
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw const AppException('Usuário não autenticado');
      }

<<<<<<< Updated upstream
      print('💰 Executando depósito de R\$ ${amount.value} para ${user.uid}');
      print('   Email: ${user.email}');
=======
      if (amount.value <= 0) {
        throw const AppException('Valor deve ser maior que zero');
      }
>>>>>>> Stashed changes

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
        'Depósito de R\$ ${amount.value.toStringAsFixed(2)} realizado com sucesso',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
<<<<<<< Updated upstream
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
      );

      // Limpar dados após sucesso
      clearData();

      // Aguardar um pouco para mostrar o snackbar, depois voltar para home
      await Future.delayed(const Duration(milliseconds: 500));
=======
        duration: const Duration(seconds: 3),
      );

      // Voltar para home após sucesso
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
=======
>>>>>>> Stashed changes
      );
      
      rethrow;
    } catch (e) {
      print('❌ Erro técnico: $e');
<<<<<<< Updated upstream
      final errorMsg = 'Não foi possível realizar o depósito: $e';
=======
      final errorMsg = 'Não foi possível realizar o depósito';
>>>>>>> Stashed changes
      errorMessage.value = errorMsg;
      
      Get.snackbar(
        'Erro técnico',
        errorMsg,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
<<<<<<< Updated upstream
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
=======
>>>>>>> Stashed changes
      );
      
      rethrow;
    } finally {
      isLoading.value = false;
      print('🔄 Execução do depósito finalizada');
    }
  }

<<<<<<< Updated upstream
=======
  /// Limpar dados do depósito
>>>>>>> Stashed changes
  void clearData() {
    amount.value = 0.0;
    description.value = '';
    errorMessage.value = null;
<<<<<<< Updated upstream
    print('🧹 Dados do depósito limpos');
  }

  bool validateData() {
    print('🔍 Validando dados do depósito...');
    print('   Valor: R\$ ${amount.value}');
    
    if (amount.value <= 0) {
      errorMessage.value = 'Informe um valor maior que zero';
      print('❌ Valor inválido: ${amount.value}');
=======
  }

  /// Validar dados antes de prosseguir
  bool validateData() {
    if (amount.value <= 0) {
      errorMessage.value = 'Informe um valor maior que zero';
>>>>>>> Stashed changes
      return false;
    }

    if (amount.value > 50000) {
      errorMessage.value = 'Valor máximo por depósito: R\$ 50.000,00';
<<<<<<< Updated upstream
      print('❌ Valor muito alto: ${amount.value}');
      return false;
    }

    print('✅ Dados válidos');
    return true;
  }

  // Método para converter texto formatado em valor numérico
  double parseAmountFromText(String formattedText) {
    print('🔄 Convertendo texto: "$formattedText"');
    
    // Remove formatação brasileira: "R$ 1.234,56" -> 1234.56
    final cleanText = formattedText
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    
    final amount = double.tryParse(cleanText) ?? 0.0;
    print('💰 Valor convertido: R\$ $amount');
    return amount;
  }
=======
      return false;
    }

    return true;
  }
>>>>>>> Stashed changes
}