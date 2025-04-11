import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';
import 'bindings/initial_binding.dart';

import 'presentation/pages/welcome_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/signup_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/transactions_page.dart';
import 'presentation/pages/deposit_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/pages/forgot_password_page.dart';
import 'presentation/pages/change_transaction_password_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const YeezyBankApp());
}

class YeezyBankApp extends StatelessWidget {
  const YeezyBankApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YeezyBank',
      initialBinding: InitialBinding(),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const WelcomePage()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/signup', page: () => const SignupPage()),
        GetPage(name: '/home', page: () => const HomeView()),
        GetPage(name: '/transactions', page: () => const TransactionsPage()),
        GetPage(name: '/deposit', page: () => const DepositPage()),
        GetPage(name: '/profile', page: () => const ProfilePage()),
        GetPage(
          name: '/forgot-password',
          page: () => const ForgotPasswordPage(),
        ),
        GetPage(
          name: '/change-transaction-password',
          page: () => const ChangeTransactionPasswordPage(),
        ),
      ],
    );
  }
}
