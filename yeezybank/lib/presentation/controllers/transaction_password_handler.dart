import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/services/transaction_service.dart';
import '../widgets/password_prompt.dart';

// Convertido para GetxController para permitir injeção de dependência
class TransactionPasswordHandler extends GetxController {
  final TransactionService transactionService = Get.find<TransactionService>();

  /// Verifica/cadastra senha de transação. Retorna true se a senha for válida.
  Future<bool> ensureValidPassword(BuildContext context, String userId) async {
    try {
      final hasPassword = await transactionService.hasTransactionPassword(
        userId,
      );

      String? password;
      if (!hasPassword) {
        password = await promptPassword(context, isNew: true);
        if (password == null || password.isEmpty) return false;

        // Aplicar validações mais fortes para a senha
        if (password.length < 4) {
          Get.snackbar('Erro', 'A senha deve ter pelo menos 4 dígitos');
          return false;
        }

        await transactionService.setTransactionPassword(userId, password);
        return true;
      } else {
        password = await promptPassword(context);
        if (password == null || password.isEmpty) return false;

        final valid = await transactionService.validateTransactionPassword(
          userId,
          password,
        );
        if (!valid) {
          Get.snackbar('Erro', 'Senha incorreta');
          return false;
        }
        return true;
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao processar senha: $e');
      return false;
    }
  }

  /// Método para alterar a senha com validação adicional
  Future<bool> changePassword(BuildContext context, String userId) async {
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
      Get.snackbar('Erro', 'Falha ao alterar senha: $e');
      return false;
    }
  }
}
