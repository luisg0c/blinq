import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD600), // Amarelo EZ-Bank
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Image.asset('assets/images/logo_text_black.png', height: 60),
                const SizedBox(height: 60),
                // Imagem do cartão
                Center(
                  child: Image.asset('assets/images/cards.png', height: 250),
                ),
                const SizedBox(height: 60),
                const Text(
                  'Urubu Do',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'PIX Bank & Co',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Botão de seta
          Positioned(
            bottom: 40,
            right: 30,
            child: GestureDetector(
              onTap: () {
                Get.toNamed('/login');
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
