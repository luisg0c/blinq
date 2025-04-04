import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';

import 'presentation/pages/welcome_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/signup_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/deposit_page.dart';
import 'presentation/pages/transfer_page.dart';
import 'presentation/pages/transactions_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/pages/forgot_password_page.dart';
import 'presentation/pages/change_transaction_password_page.dart'; // Nova página

import 'domain/services/auth_service.dart';
import 'domain/services/transaction_service.dart';
import 'presentation/controllers/transaction_controller.dart';
import 'package:yeezybank/bindings/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    GetMaterialApp(
      initialBinding: InitialBinding(),
      debugShowCheckedModeBanner: false,
      title: 'YeezyBank',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        // Melhorando consistência de UI
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const WelcomePage()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/forgot-password', page: () => ForgotPasswordPage()),
        GetPage(name: '/signup', page: () => const SignupPage()),
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/transfer', page: () => const TransferPage()),
        GetPage(name: '/transactions', page: () => const TransactionsPage()),
        GetPage(name: '/deposit', page: () => const DepositPage()),
        GetPage(name: '/profile', page: () => const ProfilePage()),
        // Nova rota para alteração de senha de transação
        GetPage(
          name: '/change-transaction-password', 
          page: () => const ChangeTransactionPasswordPage()
        ),
      ],
    ),
  );
}