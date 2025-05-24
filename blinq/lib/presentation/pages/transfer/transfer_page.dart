import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/components/custom_money_field.dart';
import '../../../routes/app_routes.dart';

class TransferPage extends StatelessWidget {
  const TransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    final recipientCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Transferir')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: recipientCtrl,
              decoration: const InputDecoration(
                labelText: 'Email ou telefone do destinatário',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            CustomMoneyField(
              controller: amountCtrl,
              onChanged: (val) {
                // opcional: converter de “R$ 1.234,56” para double
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionCtrl,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 1) Navegar para tela de confirmação
                  // 2) Passar recipientCtrl.text, amountCtrl.text, descriptionCtrl.text
                  Get.toNamed(
                    AppRoutes.verifyPin,
                    arguments: {
                      'flow': 'transfer',
                      'recipient': recipientCtrl.text,
                      'amountText': amountCtrl.text,
                      'description': descriptionCtrl.text,
                    },
                  );
                },
                child: const Text('Próximo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
