import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeezybank/presentation/theme/app_colors.dart';
import 'package:yeezybank/presentation/theme/app_text_styles.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo (assuming a white or purple version exists)
            Image.asset(
              'assets/images/logo_text.png', // Replace with appropriate logo
              height: 100,
            ),
            const SizedBox(height: 40),
            // Main text
            Text(
              'Yeezy',
              style: AppTextStyles.title.copyWith(fontSize: 32),
              textAlign: TextAlign.center,
            ),
            Text(
              'Bank & Co',
              style: AppTextStyles.title.copyWith(fontSize: 32),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Subtitle or description (optional)
            Text(
              'Seu banco digital, simples e fácil.', // Add a suitable description
              style: AppTextStyles.body.copyWith(fontSize: 18, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            // Navigation button
            ElevatedButton(
              onPressed: () => Get.toNamed('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
