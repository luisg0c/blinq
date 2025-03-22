import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:urubudopix/pages/transactions_page.dart';
import 'package:urubudopix/pages/transfer_page.dart';
import 'firebase_options.dart';
import 'pages/deposit_page.dart';
import 'pages/profile_page.dart';
import 'utils/theme.dart';
import 'utils/theme_manager.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/home_page.dart';
import 'pages/welcome_page.dart'; // Import da nova WelcomePage
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const UrubuDoPixApp());
}

class UrubuDoPixApp extends StatefulWidget {
  const UrubuDoPixApp({super.key});

  @override
  State<UrubuDoPixApp> createState() => _UrubuDoPixAppState();
}

class _UrubuDoPixAppState extends State<UrubuDoPixApp> {
  final ThemeManager _themeManager = ThemeManager();

  @override
  void initState() {
    _themeManager.addListener(themeListener);
    super.initState();
  }

  @override
  void dispose() {
    _themeManager.removeListener(themeListener);
    super.dispose();
  }

  void themeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Urubu do Pix',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeManager.themeMode,
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
