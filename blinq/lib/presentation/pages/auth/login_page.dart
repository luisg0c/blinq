import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrar'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 32),
              Text(
                'Acesse sua conta Blinq',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o email';
                  }
                  if (!GetUtils.isEmail(value)) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a senha';
                  }
                  if (value.length < 6) {
                    return 'Senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authController.isLoading.value
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            authController.login(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            );
                          }
                        },
                  child: authController.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Entrar'),
                ),
              )),

              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.resetPassword),
                child: const Text('Esqueci minha senha'),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.signup),
                child: const Text('Criar conta'),
              ),

              // Mostrar erro se houver
              Obx(() => authController.errorMessage.value != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        authController.errorMessage.value!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}