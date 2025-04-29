import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../core/constants/app_constants.dart';
import '../../core/constants/colors.dart';
import '../controllers/auth_controller.dart';

/// Página inicial de splash que verifica autenticação e direciona o usuário
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  
  late AuthController _authController;
  
  @override
  void initState() {
    super.initState();
    
    // Inicializar controlador de autenticação
    _authController = Get.find<AuthController>();
    
    // Configurar animações
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );
    
    // Iniciar animação
    _animationController.forward();
    
    // Configurar navegação após delay
    Timer(
      AppConstants.splashDuration,
      () => _handleNavigation(),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  /// Decide para qual tela navegar com base no estado de autenticação
  Future<void> _handleNavigation() async {
    // Observar mudanças no estado de autenticação
    _authController.isAuthenticated.listen((isLoggedIn) {
      if (isLoggedIn) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/login');
      }
    });
    
    // Forçar verificação (para caso a stream não tenha mudado)
    await _authController.checkAuthStatus();
    
    // Navegação de fallback se o listener não for acionado
    Timer(
      const Duration(milliseconds: 1000),
      () {
        if (Get.currentRoute == '/splash') {
          if (_authController.isAuthenticated.value) {
            Get.offAllNamed('/home');
          } else {
            Get.offAllNamed('/login');
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'B',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Nome do app
              Text(
                AppConstants.appName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Slogan
              const Text(
                'Seu dinheiro, simplificado',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Indicador de carregamento
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}