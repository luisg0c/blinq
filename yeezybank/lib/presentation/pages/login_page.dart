import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Image.asset('assets/images/logo_text.png', height: 80),
              const SizedBox(height: 40),
              Text(
                'Bem-vindo de volta!',
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Entre para continuar usando o YeezyBank.',
                style: AppTextStyles.body.copyWith(color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildTextField(
                controller: authController.emailController,
                labelText: 'Email',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: authController.passwordController,
                labelText: 'Senha',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  authController.login();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: AppTextStyles.button,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Entrar'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.toNamed('/signup'),
                child: Text(
                  'Não tem conta? Cadastre-se',
                  style: AppTextStyles.link,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
