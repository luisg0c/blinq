import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../models/transaction_model.dart';

class TransferPage extends StatelessWidget {
  const TransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    final recipientController = TextEditingController();
    final amountController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Enviar Pix')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transferência P2P',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: recipientController,
              decoration: const InputDecoration(
                prefixIcon: Icon(LineIcons.user),
                labelText: 'Chave Pix ou Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                prefixIcon: Icon(LineIcons.dollarSign),
                labelText: 'Valor (R\$)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(LineIcons.paperPlane),
                label: const Text('Enviar Pix'),
                onPressed: () async {
                  String recipient = recipientController.text.trim();
                  double? amount = double.tryParse(amountController.text.trim());

                  if (recipient.isEmpty || amount == null || amount <= 0) {
                    Get.snackbar('Erro', 'Preencha todos os campos corretamente');
                    return;
                  }

                  try {
                    final authService = AuthService();
                    final transactionService = TransactionService();

                    String senderId = authService.getCurrentUserId();

                    TransactionModel txn = TransactionModel(
                      id: '',
                      senderId: senderId,
                      receiverId: recipient,
                      amount: amount,
                      timestamp: DateTime.now(),
                    );

                    await transactionService.sendTransaction(txn);

                    Get.snackbar('Pix Enviado',
                        'R\$ ${amount.toStringAsFixed(2)} para $recipient');
                    Get.back();
                  } catch (e) {
                    Get.snackbar('Erro ao enviar', e.toString());
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
