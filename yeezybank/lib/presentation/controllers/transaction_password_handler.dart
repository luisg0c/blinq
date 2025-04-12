import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/services/transaction_service.dart';
import '../widgets/password_prompt.dart';

// Convertido para GetxController para permitir injeção de dependência
class TransactionPasswordHandler extends GetxController {
  final TransactionService transactionService = Get.find<TransactionService>();
  final RxBool isProcessing = false.obs;

  /// Verifica/cadastra senha de transação. Retorna true se a senha for válida.
  Future<String?> ensureValidPassword(
    BuildContext context,
    String userId,
  ) async {
    if (isProcessing.value) return null;

    isProcessing.value = true;
    try {
      // Verificar se a sessão está válida
      if (userId.isEmpty) {
        Get.snackbar(
          'Erro',
          'Sessão expirada. Por favor, faça login novamente.',
        );
        await Future.delayed(Duration(seconds: 2));
        Get.offAllNamed('/login');
        return null;
      }

      final hasPassword = await transactionService.hasTransactionPassword(
        userId,
      );

      if (!hasPassword) {
        // Se não tem senha, solicitar criação
        final newPassword = await promptPassword(context, isNew: true);
        if (newPassword == null || newPassword.isEmpty) {
          return null;
        }

        // Aplicar validações mais fortes para a senha
        if (newPassword.length < 4) {
          Get.snackbar('Erro', 'A senha deve ter pelo menos 4 dígitos');
          return null;
        }

        await transactionService.setTransactionPassword(userId, newPassword);
        return newPassword;
      } else {
        // Se já tem senha, solicitar validação
        final password = await promptPassword(context);
        if (password == null || password.isEmpty) {
          return null;
        }

        final valid = await transactionService.validateTransactionPassword(
          userId,
          password,
        );

        if (!valid) {
          Get.snackbar('Erro', 'Senha incorreta');
          return null;
        }

        return password;
      }
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Método para alterar a senha com validação adicional
  Future<bool> changePassword(BuildContext context, String userId) async {
    if (isProcessing.value) return false;

    isProcessing.value = true;
    try {
      // Primeiro validar a senha atual
      final oldPassword = await promptPassword(
        context,
        title: "Digite sua senha atual",
      );

      if (oldPassword == null || oldPassword.isEmpty) return false;

      final isValid = await transactionService.validateTransactionPassword(
        userId,
        oldPassword,
      );

      if (!isValid) {
        Get.snackbar('Erro', 'Senha atual incorreta');
        return false;
      }

      // Solicitar nova senha
      final newPassword = await promptPassword(
        context,
        isNew: true,
        title: "Digite sua nova senha",
      );

      if (newPassword == null || newPassword.isEmpty) return false;

      // Validar complexidade
      if (newPassword.length < 4) {
        Get.snackbar('Erro', 'A senha deve ter pelo menos 4 dígitos');
        return false;
      }

      // Solicitar confirmação
      final confirmPassword = await promptPassword(
        context,
        title: "Confirme sua nova senha",
      );

      if (confirmPassword != newPassword) {
        Get.snackbar('Erro', 'As senhas não conferem');
        return false;
      }

      // Alterar a senha
      await transactionService.changeTransactionPassword(
        userId,
        oldPassword,
        newPassword,
      );

      Get.snackbar('Sucesso', 'Senha alterada com sucesso');
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  void _handleError(dynamic error) {
    String errorMessage = error.toString();
    Get.snackbar('Erro', 'Falha ao processar senha: $errorMessage');

    // Verificar se é um erro de autenticação
    String errorLower = errorMessage.toLowerCase();
    if (errorLower.contains('usuário não logado') ||
        errorLower.contains('não autenticado') ||
        errorLower.contains('sessão expirada') ||
        errorLower.contains('token') ||
        errorLower.contains('permission')) {
      // Atrasar um pouco para permitir que o snackbar seja visto
      Future.delayed(Duration(seconds: 2), () {
        Get.offAllNamed('/login');
      });
    }
  }
}
