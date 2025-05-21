import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/components/custom_text_field.dart';
import '../../../core/components/custom_button.dart';
import '../../../core/utils/validators.dart';
import '../../controllers/transfer_controller.dart';

class TransferPage extends StatelessWidget {
  final TransferController controller = Get.find<TransferController>();

  final _formKey = GlobalKey<FormState>();
  final _emailC = TextEditingController();
  final _amountC = TextEditingController();
  final _descC = TextEditingController();
  final _pinC = TextEditingController();

  TransferPage({super.key});

  void _onTransfer() {
    if (_formKey.currentState!.validate()) {
      controller.transfer(
        toEmail: _emailC.text.trim(),
        amount: double.parse(_amountC.text),
        description: _descC.text,
        pin: _pinC.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transferência'),
        backgroundColor: const Color(0xFF6EE1C6),
      ),
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                CustomTextField(
                  controller: _emailC,
                  labelText: 'E-mail do destinatário',
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _amountC,
                  labelText: 'Valor (R\$)',
                  validator: Validators.required('Informe o valor'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descC,
                  labelText: 'Descrição (opcional)',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _pinC,
                  labelText: 'PIN de transação',
                  validator: Validators.minLength(4),
                  obscureText: true,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: controller.isLoading.value
                      ? 'Enviando...'
                      : 'Confirmar transferência',
                  isLoading: controller.isLoading.value,
                  onPressed: controller.isLoading.value ? null : _onTransfer,
                ),
                const SizedBox(height: 16),
                if (controller.errorMessage.value != null)
                  Text(
                    controller.errorMessage.value!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                if (controller.successMessage.value != null)
                  Text(
                    controller.successMessage.value!,
                    style: const TextStyle(color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
