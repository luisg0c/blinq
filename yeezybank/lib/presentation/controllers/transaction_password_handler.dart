import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/services/transaction_service.dart';
import '../widgets/password_prompt.dart';

class TransactionPasswordHandler {
  final TransactionService transactionService = Get.find<TransactionService>();

  /// Verifica/cadastra senha de transação. Retorna true se a senha for válida.
  Future<bool> ensureValidPassword(BuildContext context, String userId) async {
    final hasPassword = await transactionService.hasTransactionPassword(userId);

    String? password;
    if (!hasPassword) {
      password = await promptPassword(context, isNew: true);
      if (password == null || password.isEmpty) return false;

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
  }
}
