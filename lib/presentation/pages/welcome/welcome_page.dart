import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 400), () {
      _fadeController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 600), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: _getBackgroundColor(isDark),
      appBar: _buildNeomorphAppBar(context, isDark),
      body: Container(
        decoration: _getBackgroundDecoration(isDark),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Logo e branding - NEOMORFO
                AnimatedBuilder(
                  animation: _scaleController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: _buildNeomorphBranding(context, isDark),
                    );
                  },
                ),
                
                const Spacer(flex: 2),
                
                // Texto de boas-vindas - FLAT
                AnimatedBuilder(
                  animation: _fadeController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildFlatWelcomeText(context, isDark),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                const Spacer(flex: 3),
                
                // Botões de ação - HÍBRIDO
                AnimatedBuilder(
                  animation: _slideController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _slideAnimation,
                      child: _buildActionButtons(context, isDark),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
              ],
            ),
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
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark ? [
          const Color(0xFF1A1A1A),
          const Color(0xFF2A2A2A),
          const Color(0xFF1A1A1A),
        ] : [
          const Color(0xFFF8F9FA),
          const Color(0xFFE8F4F8),
          const Color(0xFFF8F9FA),
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
    );
  }

  PreferredSizeWidget _buildNeomorphAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
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
                color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8F4F8),
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

  Widget _buildNeomorphBranding(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Logo neomorfo principal
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8F4F8),
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
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: -2,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Nome da marca - flat
        Text(
          'Blinq',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF2D3748),
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }

  Widget _buildFlatWelcomeText(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF2D3748);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF4A5568);
    
    return Column(
      children: [
        Text(
          'Bem-vindo ao futuro\ndos pagamentos',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textColor,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Transfira, receba e gerencie seu dinheiro\nde forma simples e segura',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: subtitleColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }



  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Botão principal - NEOMORFO
        _buildNeomorphButton(
          context,
          isDark,
          text: 'Entrar',
          isPrimary: true,
          onTap: () => Get.toNamed(AppRoutes.login),
        ),
        
        const SizedBox(height: 16),
        
        // Botão secundário - FLAT
        _buildFlatButton(
          context,
          isDark,
          text: 'Criar conta',
          onTap: () => Get.toNamed(AppRoutes.signup),
        ),
        
        const SizedBox(height: 24),
        
        // Footer - FLAT
        _buildFlatFooter(context, isDark),
      ],
    );
  }

  Widget _buildNeomorphButton(
    BuildContext context,
    bool isDark, {
    required String text,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              Color(0xFF5BC4A8),
            ],
          ),
          boxShadow: [
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
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlatButton(
    BuildContext context,
    bool isDark, {
    required String text,
    required VoidCallback onTap,
  }) {
    final borderColor = isDark ? Colors.white24 : Colors.black12;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3748);
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFlatFooter(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white54 : const Color(0xFF718096);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 16,
              color: textColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Seus dados estão protegidos',
              style: TextStyle(
                fontSize: 14,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Banco Central do Brasil • Resolução 4.658',
          style: TextStyle(
            fontSize: 12,
            color: textColor,
          ),
        ),
      ],
    );
  }
}