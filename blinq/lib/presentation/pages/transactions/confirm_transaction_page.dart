// lib/presentation/pages/transactions/confirm_transaction_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/transfer_controller.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../pin/pin_verification_page.dart';
import '../../../routes/app_routes.dart';

class ConfirmTransactionPage extends StatelessWidget {
  const ConfirmTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TransferController controller = Get.find<TransferController>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Transferência'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.errorMessage.value != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro na transferência',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Voltar'),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card de confirmação
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confirme os dados da transferência:',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildInfoRow('Destinatário:', controller.recipientEmail.value),
                    const SizedBox(height: 12),
                    
                    _buildInfoRow(
                      'Valor:', 
                      'R\$ ${controller.amount.value.toStringAsFixed(2).replaceAll('.', ',')}',
                    ),
                    const SizedBox(height: 12),
                    
                    _buildInfoRow('Status:', 'Aguardando confirmação'),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Aviso de segurança
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.security,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Você será solicitado a inserir seu PIN para confirmar',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
            ],
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () => _confirmTransfer(controller),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Confirmar Transferência',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmTransfer(TransferController controller) {
    Get.to(
      () => const PinVerificationPage(),
      arguments: {
        'flow': 'transfer',
        'recipient': controller.recipientEmail.value,
        'amountText': 'R\$ ${controller.amount.value.toStringAsFixed(2)}',
        'description': 'Transferência PIX',
      },
    );
  }
}