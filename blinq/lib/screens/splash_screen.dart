import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../core/routes.dart';
import '../core/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Simular um tempo de carregamento para a splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
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
            const SizedBox(height: 24),
            Text(
              'Blinq',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seu dinheiro simplificado',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
