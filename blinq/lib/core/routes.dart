import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/forgot_password.dart';
import '../screens/home_screen.dart';
import '../screens/deposit_screen.dart';
import '../screens/transfer_screen.dart';
import '../screens/transaction_history_screen.dart';
import '../screens/transaction_details_screen.dart';
import '../screens/my_profile.dart';
import '../screens/complete_profile.dart';

class AppRoutes {
  // Nomes das rotas
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot_password';
  static const String home = '/home';
  static const String deposit = '/deposit';
  static const String transfer = '/transfer';
  static const String history = '/history';
  static const String transactionDetails = '/transaction_details';
  static const String profile = '/profile';
  static const String completeProfile = '/complete_profile';

  // Mapa de rotas
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        forgotPassword: (context) => const ForgotPasswordScreen(),
        home: (context) => const HomeScreen(),
        deposit: (context) => const DepositScreen(),
        transfer: (context) => const TransferScreen(),
        history: (context) => const TransactionHistoryScreen(),
        profile: (context) => const MyProfileScreen(),
        completeProfile: (context) => const CompleteProfileScreen(),
        // TransactionDetails precisa de parâmetros, então é tratado especialmente
      };
}
