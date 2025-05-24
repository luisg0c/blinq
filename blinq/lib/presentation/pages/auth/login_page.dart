import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../theme/app_theme.dart';

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
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return Scaffold(
      backgroundColor: neomorphTheme.backgroundColor,
      appBar: _buildNeomorphAppBar(context),
      body: _buildBody(context, authController),
    );
  }

  PreferredSizeWidget _buildNeomorphAppBar(BuildContext context) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return AppBar(
      backgroundColor: neomorphTheme.backgroundColor,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: neomorphTheme.surfaceColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: neomorphTheme.highlightColor.withOpacity(0.7),
                offset: const Offset(-2, -2),
                blurRadius: 6,
              ),
              BoxShadow(
                color: neomorphTheme.shadowDarkColor.withOpacity(0.5),
                offset: const Offset(2, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back,
            color: neomorphTheme.textPrimaryColor,
            size: 20,
          ),
        ),
      ),
      title: Text(
        'Entrar',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: neomorphTheme.textPrimaryColor,
        ),
      ),
      centerTitle: true,
      actions: [
        // Toggle tema
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
                color: neomorphTheme.surfaceColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: neomorphTheme.highlightColor.withOpacity(0.7),
                    offset: const Offset(-2, -2),
                    blurRadius: 6,
                  ),
                  BoxShadow(
                    color: neomorphTheme.shadowDarkColor.withOpacity(0.5),
                    offset: const Offset(2, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Icon(
                Get.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: neomorphTheme.textSecondaryColor,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, AuthController authController) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // Logo principal
            _buildLogo(context),
            
            const SizedBox(height: 40),
            
            // Título de boas-vindas
            _buildWelcomeCard(context),
            
            const SizedBox(height: 32),
            
            // Campo de email
            _buildNeomorphTextField(
              context,
              controller: emailController,
              hintText: 'Seu email',
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
            
            // Campo de senha
            _buildPasswordField(context),
            
            const SizedBox(height: 24),
            
            // Botão de login
            Obx(() => _buildLoginButton(context, authController)),
            
            const SizedBox(height: 20),
            
            // Link esqueci a senha
            _buildForgotPasswordLink(context),
            
            const SizedBox(height: 32),
            
            // Divider
            _buildDivider(context),
            
            const SizedBox(height: 20),
            
            // Link para criar conta
            _buildSignupLink(context),
            
            const SizedBox(height: 20),
            
            // Mostrar erro se houver
            Obx(() => _buildErrorMessage(context, authController)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: neomorphTheme.surfaceColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: neomorphTheme.highlightColor.withOpacity(0.7),
            offset: const Offset(-6, -6),
            blurRadius: 12,
          ),
          BoxShadow(
            color: neomorphTheme.shadowDarkColor.withOpacity(0.5),
            offset: const Offset(6, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'B',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: neomorphTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: neomorphTheme.highlightColor.withOpacity(0.7),
            offset: const Offset(-6, -6),
            blurRadius: 12,
          ),
          BoxShadow(
            color: neomorphTheme.shadowDarkColor.withOpacity(0.5),
            offset: const Offset(6, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Bem-vindo de volta!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: neomorphTheme.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Entre na sua conta Blinq\npara continuar',
            style: TextStyle(
              fontSize: 16,
              color: neomorphTheme.textSecondaryColor,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNeomorphTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return Container(
      decoration: BoxDecoration(
        color: neomorphTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // Inner shadow effect
          BoxShadow(
            color: neomorphTheme.shadowDarkColor.withOpacity(0.3),
            offset: const Offset(2, 2),
            blurRadius: 4,
            inset: true,
          ),
          BoxShadow(
            color: neomorphTheme.highlightColor.withOpacity(0.7),
            offset: const Offset(-2, -2),
            blurRadius: 4,
            inset: true,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(
          color: neomorphTheme.textPrimaryColor,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: neomorphTheme.textSecondaryColor,
            fontSize: 16,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: neomorphTheme.surfaceColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: neomorphTheme.highlightColor.withOpacity(0.7),
                  offset: const Offset(-2, -2),
                  blurRadius: 4,
                ),
                BoxShadow(
                  color: neomorphTheme.shadowDarkColor.withOpacity(0.5),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return _buildNeomorphTextField(
      context,
      controller: passwordController,
      hintText: 'Sua senha',
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
      suffixIcon: GestureDetector(
        onTap: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: neomorphTheme.surfaceColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: neomorphTheme.highlightColor.withOpacity(0.7),
                offset: const Offset(-2, -2),
                blurRadius: 4,
              ),
              BoxShadow(
                color: neomorphTheme.shadowDarkColor.withOpacity(0.5),
                offset: const Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: neomorphTheme.textSecondaryColor,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, AuthController authController) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
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
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                  BoxShadow(
                    color: neomorphTheme.highlightColor.withOpacity(0.7),
                    offset: const Offset(-2, -2),
                    blurRadius: 6,
                  ),
                  BoxShadow(
                    color: neomorphTheme.shadowDarkColor.withOpacity(0.5),
                    offset: const Offset(2, 2),
                    blurRadius: 6,
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

  Widget _buildForgotPasswordLink(BuildContext context) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.resetPassword),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: neomorphTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: neomorphTheme.highlightColor.withOpacity(0.5),
              offset: const Offset(-2, -2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: neomorphTheme.shadowDarkColor.withOpacity(0.3),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          'Esqueci minha senha',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  neomorphTheme.shadowDarkColor.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ou',
            style: TextStyle(
              color: neomorphTheme.textSecondaryColor,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  neomorphTheme.shadowDarkColor.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupLink(BuildContext context) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.signup),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: neomorphTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: neomorphTheme.highlightColor.withOpacity(0.5),
              offset: const Offset(-3, -3),
              blurRadius: 6,
            ),
            BoxShadow(
              color: neomorphTheme.shadowDarkColor.withOpacity(0.3),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Text(
          'Criar conta',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, AuthController authController) {
    if (authController.errorMessage.value == null) {
      return const SizedBox.shrink();
    }
    
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
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
          Icon(
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