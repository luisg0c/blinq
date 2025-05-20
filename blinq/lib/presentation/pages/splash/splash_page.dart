import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

/// Tela de splash, exibe logo e navega automaticamente.
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Aguarda 2s e vai para login (ou home, quando houver)
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed(AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6EE1C6),
      body: Center(
        child: Text(
          'B',
          style: TextStyle(
            fontSize: 72,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
