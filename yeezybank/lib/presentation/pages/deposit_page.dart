import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/transaction_service.dart';
import '../widgets/password_prompt.dart';
import '../controllers/transaction_password_handler.dart';
import '../widgets/money_input_field.dart';

class DepositPage extends StatelessWidget {
  const DepositPage({super.key});

  @override
  Widget build(BuildContext context) {
    final amountController = TextEditingController();
    final authService = Get.find<AuthService>();
    final transactionService = Get.find<TransactionService>();
    
    // Duas opções de inicialização:
    // 1. Usar o Get.find se registrado no InitialBinding
    final passwordHandler = Get.isRegistered<TransactionPasswordHandler>() 
        ? Get.find<TransactionPasswordHandler>() 
        : TransactionPasswordHandler(); // 2. Instanciar diretamente se não registrado

    return Scaffold(
      appBar: AppBar(title: const Text('Depositar')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Valor do Depósito', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            MoneyInputField(
              controller: amountController,
              icon: Icons.attach_money,
              label: 'Valor do depósito (R\$)',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, informe um valor';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Valor inválido';
                }
                return null;
              },
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