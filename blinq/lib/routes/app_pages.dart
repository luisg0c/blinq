import 'package:get/get.dart';

// Pages
import '../presentation/pages/splash/splash_page.dart';
import '../presentation/pages/onboarding/onboarding_page.dart';
import '../presentation/pages/welcome/welcome_page.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/register_page.dart';
import '../presentation/pages/auth/reset_password_page.dart';
import '../presentation/pages/pin/pin_setup_page.dart';
import '../presentation/pages/pin/pin_verification_page.dart';
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/deposit/deposit_page.dart';
import '../presentation/pages/transfer/transfer_page.dart';
import '../presentation/pages/transactions/transactions_page.dart';

// Routes
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingPage()),
    GetPage(name: AppRoutes.welcome, page: () => const WelcomePage()),
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(name: AppRoutes.signup, page: () => const RegisterPage()),
    GetPage(name: AppRoutes.resetPassword, page: () => const ResetPasswordPage()),
    GetPage(name: AppRoutes.setupPin, page: () => const PinSetupPage()),
    GetPage(name: AppRoutes.verifyPin, page: () => const PinVerificationPage()),
    GetPage(name: AppRoutes.home, page: () => const HomePage()),
    GetPage(name: AppRoutes.deposit, page: () => const DepositPage()),
    GetPage(name: AppRoutes.transfer, page: () => const TransferPage()),
    GetPage(name: AppRoutes.transactions, page: () => const TransactionsPage()),
  ];
}
