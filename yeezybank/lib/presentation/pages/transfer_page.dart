import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/transaction_service.dart';
import '../../domain/models/transaction_model.dart';
import '../widgets/password_prompt.dart';
import '../controllers/transaction_password_handler.dart';
import '../widgets/money_input_field.dart';

class TransferPage extends StatelessWidget {
  const TransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    final recipientController = TextEditingController();
    final amountController = TextEditingController();
    final authService = Get.find<AuthService>();
    final transactionService = Get.find<TransactionService>();
    
    // Duas opções de inicialização:
    // 1. Usar o Get.find se registrado no InitialBinding
    final passwordHandler = Get.isRegistered<TransactionPasswordHandler>() 
        ? Get.find<TransactionPasswordHandler>()
        : TransactionPasswordHandler(); // 2. Instanciar diretamente se não registrado

    // Obter email do usuário atual
    final currentUserEmail = authService.getCurrentUser()?.email;

    return Scaffold(
      appBar: AppBar(title: const Text('Enviar Pix')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Realizar Transferência',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: recipientController,
              decoration: const InputDecoration(
                prefixIcon: Icon(LineIcons.user),
                labelText: 'Email do destinatário',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Validar se não é o mesmo email
                if (currentUserEmail != null && 
                    value.toLowerCase().trim() == currentUserEmail.toLowerCase().trim()) {
                  Get.snackbar(
                    'Atenção', 
                    'Não é possível transferir para sua própria conta',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 3),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            MoneyInputField(
              controller: amountController,
              icon: LineIcons.dollarSign,
              label: 'Valor da transferência (R\$)',
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
                icon: const Icon(LineIcons.paperPlane),
                label: const Text('Enviar Pix'),
                onPressed: () async {
                  String email = recipientController.text.trim();
                  double? amount = double.tryParse(amountController.text.trim());

                  if (email.isEmpty || amount == null || amount <= 0) {
                    Get.snackbar('Erro', 'Preencha todos os campos corretamente');
                    return;
                  }

                  // Validação do lado do cliente para evitar transferência para si mesmo
                  if (currentUserEmail != null && 
                      email.toLowerCase() == currentUserEmail.toLowerCase()) {
                    Get.snackbar('Erro', 'Não é possível transferir para você mesmo');
                    return;
                  }

                  try {
                    String senderId = authService.getCurrentUserId();
                    bool allowed = await passwordHandler.ensureValidPassword(context, senderId);
                    if (!allowed) return;

                    // Criar transação com participantes temporários
                    TransactionModel txn = TransactionModel(
                      id: '',
                      senderId: senderId,
                      receiverId: '', // será atribuído no service
                      amount: amount,
                      timestamp: DateTime.now(),
                      participants: [senderId], // será atualizado
                      type: 'transfer', // alterado para 'transfer'
                    );

                    await transactionService.sendTransaction(txn, email);

                    Get.snackbar('Pix Enviado', 'R\$ ${amount.toStringAsFixed(2)} para $email');
                    Get.back(result: true); // Refresh saldo na Home
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