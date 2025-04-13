import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';
import 'bindings/initial_binding.dart';
import 'bindings/home_binding.dart';
import 'bindings/login_binding.dart';

import 'domain/services/auth_service.dart';
import 'presentation/pages/welcome_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/signup_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/transfer_page.dart';
import 'presentation/pages/transactions_page.dart';
import 'presentation/pages/deposit_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/pages/forgot_password_page.dart';
import 'presentation/pages/change_transaction_password_page.dart';
import 'presentation/controllers/auth_controller.dart';

// Handler de erro global para evitar crashes
void errorHandler(FlutterErrorDetails details) {
  FlutterError.dumpErrorToConsole(details);
  // Você pode adicionar logging para serviços como Firebase Crashlytics aqui
  print('ERRO CAPTURADO: ${details.exception}');
}

void main() async {
  // Configurar o tratamento de erros
  FlutterError.onError = errorHandler;

  // Inicializar Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Executar o app
  runApp(const BlinqApp());
}

// Middleware para verificar autenticação
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    try {
      final authService = Get.find<AuthService>();
      if (!authService.isLoggedIn()) {
        return RouteSettings(name: '/login');
      }
    } catch (e) {
      print('Erro no middleware: $e');
      return RouteSettings(name: '/login');
    }
    return null;
  }
}

class BlinqApp extends StatelessWidget {
  const BlinqApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blinq',
      initialBinding: InitialBinding(),
      initialRoute: '/',
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
      getPages: [
        GetPage(
          name: '/',
          page: () => const WelcomePage(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/login',
          page: () => const LoginPage(),
          binding: LoginBinding(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/signup',
          page: () => const SignupPage(),
          binding: LoginBinding(),
        ),
        GetPage(
          name: '/home',
          page: () => const HomeView(),
          binding: HomeBinding(),
          transition: Transition.fadeIn,
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/transactions',
          page: () => const TransactionsPage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/deposit',
          page: () => const DepositPage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/transfer',
          page: () => const TransferPage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/profile',
          page: () => const ProfilePage(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/forgot-password',
          page: () => const ForgotPasswordPage(),
        ),
        GetPage(
          name: '/change-transaction-password',
          page: () => const ChangeTransactionPasswordPage(),
          middlewares: [AuthMiddleware()],
        ),
      ],
      theme: ThemeData(
        primaryColor: Color(0xFF556B2F),
        scaffoldBackgroundColor: Color(0xFFF5F5DC),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFF5F5DC),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF333333)),
          titleTextStyle: TextStyle(
            color: Color(0xFF333333),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
