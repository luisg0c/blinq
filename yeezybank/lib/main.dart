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

import 'domain/services/auth_service.dart';
import 'domain/services/transaction_service.dart';
import 'presentation/controllers/transaction_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put(AuthService());
  Get.put(TransactionService());
  Get.put(TransactionController());

  runApp(const YeezyBankApp());
}

class YeezyBankApp extends StatelessWidget {
  const YeezyBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YeezyBank',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const WelcomePage()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/signup', page: () => const SignupPage()),
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/transfer', page: () => const TransferPage()),
        GetPage(name: '/transactions', page: () => const TransactionsPage()),
        GetPage(name: '/deposit', page: () => const DepositPage()),
        GetPage(name: '/profile', page: () => const ProfilePage()),
      ],
    );
  }
}
