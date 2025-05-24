// lib/presentation/pages/confirm_transaction_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/transfer_controller.dart';
import '../../../core/exceptions/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../pin/pin_verification_page.dart';
import '../../../routes/app_routes.dart';

class ConfirmTransactionPage extends StatelessWidget {
  const ConfirmTransactionPage({Key? key}) : super(key: key);

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
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null) {
          return Center(
            child: Text(
              controller.errorMessage.value!,
              style: TextStyle(color: AppColors.error, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Destinatário:',
                style: textTheme.titleMedium, // antes: subtitle1
              ),
              const SizedBox(height: 4),
              Text(
                controller.recipientEmail.value,
                style: textTheme.bodyLarge, // antes: bodyText1
              ),
              const SizedBox(height: 24),
              Text(
                'Valor:',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'R\$ ${controller.amount.value.toStringAsFixed(2)}',
                style: textTheme.bodyLarge,
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Get.to(() => PinVerificationPage(onSuccess: () async {
                    try {
                      await controller.executeTransfer();
                      Get.offAllNamed(AppRoutes.transactions);
                      Get.snackbar(
                        'Sucesso',
                        'Transferência realizada com sucesso!',
                        backgroundColor: AppColors.success,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    } on AppException catch (e) {
                      Get.back();
                      Get.snackbar(
                        'Erro',
                        e.message,
                        backgroundColor: AppColors.error,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    } catch (_) {
                      Get.back();
                      Get.snackbar(
                        'Erro',
                        'Não foi possível completar a transferência.',
                        backgroundColor: AppColors.error,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  }));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Confirmar Transferência',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
