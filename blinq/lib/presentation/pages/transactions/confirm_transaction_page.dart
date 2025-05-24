import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../../../domain/repositories/transaction_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/usecases/deposit_usecase.dart';
import '../../../domain/usecases/transfer_usecase.dart';
import '../../../routes/app_routes.dart';

class ConfirmTransactionPage extends StatelessWidget {
  const ConfirmTransactionPage({Key? key}) : super(key: key);

  double _parseAmount(String text) {
    final digits = text.replaceAll(RegExp(r'[^\d]'), '');
    return digits.isEmpty ? 0.0 : double.parse(digits) / 100;
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final flow        = args['flow'] as String;
    final amountText  = args['amountText'] as String;
    final description = args['description'] as String? ?? '';
    final recipient   = args['recipient'] as String? ?? '';

    final amount = _parseAmount(amountText);
    final formattedAmount = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(amount);

    // resumo do fluxo
    final title = flow == 'deposit'
        ? 'Confirmar Depósito'
        : 'Confirmar Transferência';
    final subtitle = flow == 'deposit'
        ? 'Você vai depositar $formattedAmount'
        : 'Você vai transferir $formattedAmount para $recipient';

    // instanciar use cases
    final txRepo   = Get.find<TransactionRepository>();
    final userRepo = Get.find<UserRepository>();
    final depositUC  = DepositUseCase(txRepo);
    final transferUC = TransferUseCase(txRepo, userRepo);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            if (description.isNotEmpty)
              Text('Descrição: $description',
                  style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: ElevatedButton(
          onPressed: () {
            Get.to(() => PinVerificationPage(onSuccess: () async {
              if (flow == 'deposit') {
                await depositUC.execute(
                  amount: amount,
                  description: description,
                );
                Get.snackbar('Sucesso', 'Depósito realizado');
              } else {
                await transferUC.execute(
                  toEmail: recipient,
                  amount: amount,
                  description: description,
                );
                Get.snackbar('Sucesso', 'Transferência enviada');
              }
              // volta para a Home após a operação
              Get.offAllNamed(AppRoutes.home);
            }));
          },
          child: const Text('Confirmar'),
        ),
      ),
    );
  }
}
