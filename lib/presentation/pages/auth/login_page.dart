import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      appBar: _buildFlatAppBar(context, isDark),
      body: _buildBody(context, authController, isDark),
    );
  }

  PreferredSizeWidget _buildFlatAppBar(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(
          Icons.arrow_back_ios,
          color: textColor,
          size: 20,
        ),
      ),
      actions: [
        // Toggle tema - único elemento neomorfo na AppBar
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              Get.changeThemeMode(
                Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isDark 
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    offset: const Offset(2, 2),
                    blurRadius: 6,
                  ),
                  BoxShadow(
                    color: isDark 
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white,
                    offset: const Offset(-2, -2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Icon(
                Get.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? Colors.white70 : Colors.black54,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, AuthController authController, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            
            // Logo principal - NEOMORFO
            _buildNeomorphLogo(context, isDark),
            
            const SizedBox(height: 48),
            
            // Título - FLAT
            Text(
              'Bem-vindo de volta!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Entre na sua conta para continuar',
              style: TextStyle(
                fontSize: 16,
                color: secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // Campos - FLAT com bordas simples
            _buildFlatTextField(
              context,
              isDark,
              controller: emailController,
              hintText: 'Email',
              icon: Icons.email_outlined,
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
            
            const SizedBox(height: 20),
            
            _buildFlatPasswordField(context, isDark),
            
            const SizedBox(height: 32),
            
            // Botão principal - NEOMORFO
            Obx(() => _buildNeomorphButton(context, authController, isDark)),
            
            const SizedBox(height: 24),
            
            // Link - FLAT
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.resetPassword),
              child: Text(
                'Esqueci minha senha',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Divider - FLAT
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: isDark ? Colors.white24 : Colors.black12,
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'ou',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: isDark ? Colors.white24 : Colors.black12,
                    thickness: 1,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Botão secundário - FLAT
            _buildFlatOutlineButton(context, isDark),
            
            const SizedBox(height: 20),
            
            // Mensagem de erro - FLAT
            Obx(() => _buildErrorMessage(context, authController, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildNeomorphLogo(BuildContext context, bool isDark) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.1),
            offset: const Offset(6, 6),
            blurRadius: 15,
          ),
          BoxShadow(
            color: isDark 
                ? Colors.white.withOpacity(0.05)
                : Colors.white,
            offset: const Offset(-6, -6),
            blurRadius: 15,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'B',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildFlatTextField(
    BuildContext context,
    bool isDark, {
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white54 : Colors.black54;
    final borderColor = isDark ? Colors.white24 : Colors.black12;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(
        color: textColor,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: hintColor,
          fontSize: 16,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildFlatPasswordField(BuildContext context, bool isDark) {
    final iconColor = isDark ? Colors.white54 : Colors.black54;
    
    return _buildFlatTextField(
      context,
      isDark,
      controller: passwordController,
      hintText: 'Senha',
      icon: Icons.lock_outline,
      obscureText: !_isPasswordVisible,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Informe a senha';
        }
        if (value.length < 6) {
          return 'Senha deve ter pelo menos 6 caracteres';
        }
        return null;
      },
      suffixIcon: IconButton(
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
        icon: Icon(
          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          color: iconColor,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildNeomorphButton(BuildContext context, AuthController authController, bool isDark) {
    return GestureDetector(
      onTap: authController.isLoading.value
          ? null
          : () {
              if (formKey.currentState!.validate()) {
                authController.login(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                );
              }
            },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: authController.isLoading.value
              ? LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.5),
                    const Color(0xFF5BC4A8).withOpacity(0.5),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    Color(0xFF5BC4A8),
                  ],
                ),
          boxShadow: authController.isLoading.value
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    offset: const Offset(0, 6),
                    blurRadius: 20,
                  ),
                  BoxShadow(
                    color: isDark 
                        ? Colors.black.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
        ),
        child: Center(
          child: authController.isLoading.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Text(
                  'Entrar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildFlatOutlineButton(BuildContext context, bool isDark) {
    final borderColor = isDark ? Colors.white24 : Colors.black12;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () => Get.toNamed(AppRoutes.signup),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: Text(
          'Criar conta',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, AuthController authController, bool isDark) {
    if (authController.errorMessage.value == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              authController.errorMessage.value!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}