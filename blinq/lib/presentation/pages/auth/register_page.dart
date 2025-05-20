import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/components/custom_text_field.dart';
import '../../../core/components/custom_button.dart';
import '../../../core/utils/validators.dart';

/// Página de registro de novo usuário no Blinq.
class RegisterPage extends StatelessWidget {
  final AuthController _authCtrl = Get.find<AuthController>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  RegisterPage({Key? key}) : super(key: key);

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      _authCtrl.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
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
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Nome completo',
                  validator: Validators.required('Informe seu nome'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'E-mail',
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Senha',
                  validator: Validators.minLength(6),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmController,
                  labelText: 'Confirme a senha',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirme sua senha';
                    }
                    if (value != _passwordController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                Obx(() {
                  return CustomButton(
                    label:
                        _authCtrl.isLoading.value ? 'Cadastrando...' : 'Cadastrar',
                    isLoading: _authCtrl.isLoading.value,
                    onPressed: _authCtrl.isLoading.value ? null : _onRegister,
                  );
                }),
                const SizedBox(height: 12),
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
                  child: const Text('Já tenho conta, fazer login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
