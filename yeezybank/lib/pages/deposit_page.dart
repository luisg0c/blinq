import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../widgets/password_prompt.dart';
import '../utils/transaction_password_handler.dart';

class DepositPage extends StatelessWidget {
  const DepositPage({super.key});

  @override
  Widget build(BuildContext context) {
    final amountController = TextEditingController();
    final authService = AuthService();
    final transactionService = TransactionService();
    final passwordHandler = TransactionPasswordHandler();

    return Scaffold(
      appBar: AppBar(title: const Text('Depositar')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Valor do Depósito', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.attach_money),
                labelText: 'Valor (R\$)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Depositar'),
                onPressed: () async {
                  double? amount = double.tryParse(amountController.text.trim());
                  if (amount == null || amount <= 0) {
                    Get.snackbar('Erro', 'Informe um valor válido');
                    return;
                  }

                  try {
                    String userId = authService.getCurrentUserId();
                    bool allowed = await passwordHandler.ensureValidPassword(context, userId);
                    if (!allowed) return;

                    await transactionService.deposit(userId, amount);
                    Get.snackbar('Sucesso', 'Depósito de R\$ ${amount.toStringAsFixed(2)} realizado!');
                    Get.back(result: true); // Refresh saldo
                  } catch (e) {
                    Get.snackbar('Erro ao depositar', e.toString());
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
