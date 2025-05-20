import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/components/custom_text_field.dart';
import '../../../core/components/custom_button.dart';
import '../../../core/utils/validators.dart';

/// Página de login do Blinq.
class LoginPage extends StatelessWidget {
  final AuthController _authCtrl = Get.find<AuthController>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  LoginPage({Key? key}) : super(key: key);

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      _authCtrl.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Bem-vindo ao Blinq',
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // E-mail
                CustomTextField(
                  controller: _emailController,
                  labelText: 'E-mail',
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Senha
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Senha',
                  validator: Validators.minLength(6),
                  obscureText: true,
                ),
                const SizedBox(height: 24),

                // Botão Entrar com loading
                Obx(() {
                  return CustomButton(
                    label: _authCtrl.isLoading.value ? 'Entrando...' : 'Entrar',
                    isLoading: _authCtrl.isLoading.value,
                    onPressed: _authCtrl.isLoading.value ? null : _onLogin,
                  );
                }),
                const SizedBox(height: 12),

                // Esqueceu a senha
                TextButton(
                  onPressed: () => Get.toNamed('/reset-password'),
                  child: const Text('Esqueceu a senha?'),
                ),
                const SizedBox(height: 16),

                // Mensagem de erro
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

                // Link para cadastro
                TextButton(
                  onPressed: () => Get.toNamed('/register'),
                  child: const Text('Não tem conta? Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
