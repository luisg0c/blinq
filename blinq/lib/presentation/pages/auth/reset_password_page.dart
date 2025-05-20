// lib/presentation/pages/auth/reset_password_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/components/custom_text_field.dart';
import '../../../core/components/custom_button.dart';
import '../../../core/utils/validators.dart';

/// Página para recuperação de senha via e-mail.
class ResetPasswordPage extends StatelessWidget {
  final AuthController _authCtrl = Get.find<AuthController>();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  ResetPasswordPage({Key? key}) : super(key: key);

  void _onReset() {
    if (_formKey.currentState!.validate()) {
      _authCtrl
          .resetPassword(email: _emailController.text.trim())
          .then((_) {
        Get.snackbar(
          'Sucesso',
          'E-mail de recuperação enviado. Verifique sua caixa de entrada.',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Senha'),
        backgroundColor: const Color(0xFF6EE1C6),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Informe seu e-mail para enviar o link de recuperação',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'E-mail',
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                Obx(() {
                  return CustomButton(
                    label: _authCtrl.isLoading.value
                        ? 'Enviando...'
                        : 'Enviar',
                    isLoading: _authCtrl.isLoading.value,
                    onPressed:
                        _authCtrl.isLoading.value ? null : _onReset,
                  );
                }),
                const SizedBox(height: 16),
                Obx(() {
                  if (_authCtrl.errorMessage.value != null) {
                    return Text(
                      _authCtrl.errorMessage.value!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    );
                  }
                  return const SizedBox.shrink();
                }),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Voltar ao login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
