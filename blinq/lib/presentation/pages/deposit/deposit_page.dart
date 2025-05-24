  // lib/presentation/pages/deposit/deposit_page.dart

  import 'package:flutter/material.dart';
  import 'package:get/get.dart';

  import '../../../core/components/custom_money_field.dart';
  import '../../../routes/app_routes.dart';

  class DepositPage extends StatelessWidget {
    const DepositPage({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      final amountController = TextEditingController();
      final descriptionController = TextEditingController();

      return Scaffold(
        appBar: AppBar(
          title: const Text('Depositar'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Campo de valor formatado
              CustomMoneyField(
                controller: amountController,
                label: 'Valor (R\$)',
              ),

              const SizedBox(height: 16),

              // Campo de descrição opcional
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 32),

              // Botão que leva à verificação de PIN
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final amtText = amountController.text;
                    final desc   = descriptionController.text;

                    // Navega para PIN verification, passando fluxo e dados
                    Get.toNamed(
                      AppRoutes.verifyPin,
                      arguments: {
                        'flow': 'deposit',
                        'amountText': amtText,
                        'description': desc,
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
