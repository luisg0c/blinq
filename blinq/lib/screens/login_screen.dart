import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../core/theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signIn(
          _emailController.text, _passwordController.text);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _errorMessage = 'Falha ao realizar login. Verifique suas credenciais.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),

                  // Logo
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'B',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Título
                  Text(
                    'Bem-vindo ao Blinq',
                    style: GoogleFonts.lexend(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Subtítulo
                  Text(
                    'Faça login para acessar sua conta',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      color: AppColors.textLight,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Campo de Email
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Digite seu email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu email';
                      }
                      if (!value.contains('@')) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Campo de Senha
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Senha',
                    hint: 'Digite sua senha',
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    onSuffixIconTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira sua senha';
                      }
                      return null;
                    },
                  ),

                  // Link para Esqueci Senha
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot_password');
                      },
                      child: Text(
                        'Esqueceu a senha?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Mensagem de Erro
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Botão de Login
                  CustomButton(
                    text: 'Entrar',
                    onPressed: _isLoading ? null : _login,
                    isLoading: _isLoading,
                    isFullWidth: true,
                  ),

                  const SizedBox(height: 24),

                  // Link para Cadastro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Não tem uma conta?',
                        style: TextStyle(
                          color: AppColors.textLight,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text(
                          'Cadastre-se',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
