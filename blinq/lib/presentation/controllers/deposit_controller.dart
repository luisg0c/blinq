// lib/presentation/controllers/deposit_controller.dart
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../domain/usecases/deposit_usecase.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class DepositController extends GetxController {
  final DepositUseCase _depositUseCase;

  DepositController({required DepositUseCase depositUseCase})
      : _depositUseCase = depositUseCase;

  // Observables
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxDouble amount = 0.0.obs;
  final RxString description = ''.obs;

  /// Configura dados do depósito
  void setDepositData({required double value, String? desc}) {
    amount.value = value;
    description.value = desc ?? 'Depósito PIX';
    
    print('💰 DepositController - Dados configurados:');
    print('   Valor: R\$ ${value.toStringAsFixed(2)}');
    print('   Descrição: ${description.value}');
  }

  /// Executa o depósito após PIN validado
  Future<void> executeDeposit() async {
    print('💰 DepositController - Iniciando execução...');
    
    // Validações
    if (!_validateData()) {
      return;
    }
    
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw const AppException('Usuário não autenticado');
      }

      print('💰 Executando depósito:');
      print('   Usuário: ${user.email}');
      print('   Valor: R\$ ${amount.value}');
      print('   Descrição: ${description.value}');

      await _depositUseCase.execute(
        userId: user.uid,
        amount: amount.value,
        description: description.value,
      );

      print('✅ Depósito executado com sucesso!');

      // Limpar dados
      _clearData();

      // Navegar para home
      Get.offAllNamed(AppRoutes.home);

      // Mostrar sucesso após navegar
      await Future.delayed(const Duration(milliseconds: 800));
      
      Get.snackbar(
        'Depósito Realizado! 💰',
        'R\$ ${amount.value.toStringAsFixed(2)} foram adicionados à sua conta',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
      );

    } on AppException catch (e) {
      print('❌ Erro de negócio: ${e.message}');
      errorMessage.value = e.message;
      _showErrorSnackbar(e.message);
      rethrow;
      
    } catch (e) {
      print('❌ Erro técnico: $e');
      final errorMsg = 'Erro ao realizar depósito: $e';
      errorMessage.value = errorMsg;
      _showErrorSnackbar(errorMsg);
      rethrow;
      
    } finally {
      isLoading.value = false;
    }
  }

  /// Valida dados do depósito
  bool _validateData() {
    print('🔍 Validando dados do depósito...');
    
    if (amount.value <= 0) {
      errorMessage.value = 'Informe um valor maior que zero';
      print('❌ Valor inválido: ${amount.value}');
      return false;
    }

    if (amount.value > 50000) {
      errorMessage.value = 'Valor máximo por depósito: R\$ 50.000,00';
      print('❌ Valor muito alto: ${amount.value}');
      return false;
    }

    if (amount.value < 1) {
      errorMessage.value = 'Valor mínimo para depósito: R\$ 1,00';
      print('❌ Valor muito baixo: ${amount.value}');
      return false;
    }

    print('✅ Dados válidos');
    return true;
  }

  /// Converte texto formatado em valor numérico
  double parseAmountFromText(String formattedText) {
    print('🔄 Convertendo texto: "$formattedText"');
    
    if (formattedText.trim().isEmpty) {
      print('❌ Texto vazio');
      return 0.0;
    }
    
    // Remove formatação brasileira: "R$ 1.234,56" -> 1234.56
    final cleanText = formattedText
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    
    final amount = double.tryParse(cleanText) ?? 0.0;
    print('💰 Valor convertido: R\$ ${amount.toStringAsFixed(2)}');
    return amount;
  }

  /// Formata valor para exibição
  String formatAmountForDisplay(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Limpa dados internos
  void _clearData() {
    amount.value = 0.0;
    description.value = '';
    errorMessage.value = null;
    print('🧹 Dados do depósito limpos');
  }

  /// Mostra snackbar de erro
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Erro no Depósito',
      message,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
    );
  }

  /// Limpa apenas mensagens de erro
  void clearError() {
    errorMessage.value = null;
  }

  /// Verifica se há dados válidos para depósito
  bool get hasValidData => amount.value > 0;

  /// Obter resumo do depósito para confirmação
  Map<String, dynamic> getDepositSummary() {
    return {
      'amount': amount.value,
      'formattedAmount': formatAmountForDisplay(amount.value),
      'description': description.value,
      'isValid': _validateData(),
    };
  }
}