import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

/// Página de login do aplicativo
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late final AuthController _controller;
  bool _obscurePassword = true;
  
  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthController>();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 48),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 8),
                    _buildForgotPassword(),
                    const SizedBox(height: 32),
                    _buildLoginButton(),
                    const SizedBox(height: 24),
                    _buildRegisterLink(),
                    const SizedBox(height: 24),
                    _buildErrorMessage(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// Constrói o cabeçalho da tela
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'B',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Título
        Text(
          'Bem-vindo ao Blinq',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        
        // Subtítulo
        Text(
          'Faça login para continuar',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textMedium,
          ),
        ),
      ],
    );
  }
  
  /// Constrói o campo de email
  Widget _buildEmailField() {
    return CustomTextField(
      label: 'Email',
      hint: 'Digite seu email',
      controller: _controller.emailController,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email_outlined,
      validator: Validators.validateEmail,
      textInputAction: TextInputAction.next,
    );
  }
  
  /// Constrói o campo de senha
  Widget _buildPasswordField() {
    return CustomTextField(
      label: 'Senha',
      hint: 'Digite sua senha',
      controller: _controller.passwordController,
      obscureText: _obscurePassword,
      prefixIcon: Icons.lock_outline,
      suffixIcon: _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      onSuffixIconTap: () {
        setState(() {
          _obscurePassword = !_obscurePassword;
        });
      },
      validator: Validators.validatePassword,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _login(),
    );
  }
  
  /// Constrói o link de esqueceu a senha
  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _goToForgotPassword,
        child: Text(
          'Esqueceu a senha?',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
  
  /// Constrói o botão de login
  Widget _buildLoginButton() {
    return Obx(() => CustomButton(
      text: 'Entrar',
      isLoading: _controller.isLoading.value,
      isFullWidth: true,
      size: ButtonSize.large,
      onPressed: _login,
    ));
  }
  
  /// Constrói o link para registro
  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Não tem uma conta?',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textMedium,
          ),
        ),
        TextButton(
          onPressed: _goToRegister,
          child: Text(
            'Cadastre-se',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
  
  /// Constrói a mensagem de erro
  Widget _buildErrorMessage() {
    return Obx(() {
      final errorMessage = _controller.error.value;
      if (errorMessage.isEmpty) return const SizedBox.shrink();
      
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                errorMessage,
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
  
  /// Realiza o login
  void _login() async {
    if (_controller.isLoading.value) return;
    
    // Esconder o teclado
    FocusScope.of(context).unfocus();
    
    // Validar o formulário
    if (_formKey.currentState?.validate() ?? false) {
      final success = await _controller.signIn();
      
      if (success) {
        Get.offAllNamed('/home');
      }
    }
  }
  
  /// Navega para a tela de registro
  void _goToRegister() {
    _controller.clearFields();
    Get.toNamed('/signup');
  }
  
  /// Navega para a tela de recuperação de senha
  void _goToForgotPassword() {
    _controller.clearFields();
    Get.toNamed('/forgot-password');
  }
}