// lib/presentation/pages/splash/splash_page.dart - CORRIGIDO

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/app_initializer.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
    _initApp();
  }

  void _initAnimations() {
    // Logo animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _logoScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));
    
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _progressValue = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    // Sequência de animações
    _logoController.forward().then((_) {
      _textController.forward();
      _progressController.forward();
    });
  }

  /// ✅ MÉTODO CORRIGIDO - Aguardar GetX estar pronto
  Future<void> _initApp() async {
    try {
      print('🚀 Splash: Iniciando inicialização do app...');
      
      // 1. Aguardar animações principais
      await Future.delayed(const Duration(milliseconds: 3000));
      
      // 2. Aguardar GetX estar completamente pronto
      print('⏳ Splash: Aguardando GetX estar pronto...');
      await AppInitializer.waitForGetXReady();
      
      // 3. Verificar se ainda estamos montados
      if (!mounted) {
        print('⚠️ Splash: Widget não está mais montado');
        return;
      }
      
      // 4. Usar AppInitializer para navegação segura
      print('🧭 Splash: Iniciando navegação segura...');
      await AppInitializer.initializeAndNavigate();
      
    } catch (e) {
      print('❌ Splash: Erro na inicialização: $e');
      
      if (!mounted) return;
      
      // ✅ Fallback manual para navegação de emergência
      try {
        print('🆘 Splash: Tentando fallback...');
        
        // Aguardar mais um pouco
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // Verificar usuário manualmente
        final user = FirebaseAuth.instance.currentUser;
        
        if (AppInitializer.isGetXReady()) {
          // GetX está pronto, usar navegação normal
          if (user != null) {
            Get.offAllNamed(AppRoutes.home);
          } else {
            Get.offAllNamed(AppRoutes.welcome);
          }
        } else {
          // GetX não está pronto, usar Navigator direto
          print('🆘 Splash: Usando Navigator direto');
          
          if (user != null) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.home, 
              (route) => false,
            );
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.welcome, 
              (route) => false,
            );
          }
        }
        
      } catch (fallbackError) {
        print('💥 Splash: Fallback também falhou: $fallbackError');
        
        // Último recurso: aguardar mais e tentar welcome
        await Future.delayed(const Duration(milliseconds: 2000));
        
        if (mounted) {
          try {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.welcome, 
              (route) => false,
            );
          } catch (finalError) {
            print('💀 Splash: Falha total na navegação: $finalError');
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: _getBackgroundColor(isDark),
      body: Container(
        decoration: _getBackgroundDecoration(isDark),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Logo neomorfo animado
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScale.value,
                    child: Opacity(
                      opacity: _logoOpacity.value,
                      child: _buildNeomorphLogo(context, isDark),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Texto flat animado
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: _buildFlatText(context, isDark),
                    ),
                  );
                },
              ),
              
              const Spacer(flex: 3),
              
              // Progress indicator neomorfo
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _textOpacity,
                    child: _buildNeomorphProgress(context, isDark),
                  );
                },
              ),
              
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isDark) {
    return isDark 
        ? const Color(0xFF1A1A1A) 
        : const Color(0xFFF8F9FA);
  }

  BoxDecoration _getBackgroundDecoration(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark ? [
          const Color(0xFF1A1A1A),
          const Color(0xFF2A2A2A),
        ] : [
          const Color(0xFFF8F9FA),
          const Color(0xFFE8F4F8),
        ],
      ),
    );
  }

  Widget _buildNeomorphLogo(BuildContext context, bool isDark) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8F4F8),
        boxShadow: [
          // Sombra escura (bottom-right)
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.1),
            offset: const Offset(8, 8),
            blurRadius: 20,
            spreadRadius: 0,
          ),
          // Sombra clara (top-left)
          BoxShadow(
            color: isDark 
                ? Colors.white.withOpacity(0.05)
                : Colors.white,
            offset: const Offset(-8, -8),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: const Center(
          child: Text(
            'B',
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: -2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlatText(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF2D3748);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF4A5568);
    
    return Column(
      children: [
        Text(
          'Blinq',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Seu dinheiro, simplificado',
          style: TextStyle(
            fontSize: 18,
            color: subtitleColor,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: [
                AppColors.primary,
                Color(0xFF5BC4A8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNeomorphProgress(BuildContext context, bool isDark) {
    return Column(
      children: [
        Text(
          'Carregando...',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white60 : const Color(0xFF718096),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 200,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2E8F0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AnimatedBuilder(
              animation: _progressValue,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressValue.value,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}