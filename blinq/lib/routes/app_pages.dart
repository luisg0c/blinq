// lib/routes/app_pages.dart
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
import '../presentation/pages/profile/profile_page.dart';
import '../presentation/pages/exchange/exchange_rates_page.dart';

// Bindings
import '../presentation/bindings/auth_binding.dart';
import '../presentation/bindings/home_binding.dart';
import '../presentation/bindings/pin_binding.dart';
import '../presentation/bindings/transfer_binding.dart';
import '../presentation/bindings/deposit_binding.dart';
import '../presentation/bindings/splash_binding.dart';

// Routes
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    // Splash & Onboarding
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingPage(),
    ),
    
    GetPage(
      name: AppRoutes.welcome,
      page: () => const WelcomePage(),
    ),

    // Authentication
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    
    GetPage(
      name: AppRoutes.signup,
      page: () => const RegisterPage(),
      binding: AuthBinding(),
    ),
    
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordPage(),
      binding: AuthBinding(),
    ),

    // PIN Security
    GetPage(
      name: AppRoutes.setupPin,
      page: () => const PinSetupPage(),
      binding: PinBinding(),
    ),
    
    GetPage(
      name: AppRoutes.verifyPin,
      page: () => const PinVerificationPage(),
      bindings: [
        PinBinding(),
        DepositBinding(),
        TransferBinding(),
      ],
    ),

    // Main App
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),

    // Transactions
    GetPage(
      name: AppRoutes.deposit,
      page: () => const DepositPage(),
      bindings: [
        DepositBinding(),
        PinBinding(),
      ],
    ),
    
    GetPage(
      name: AppRoutes.transfer,
      page: () => const TransferPage(),
      bindings: [
        TransferBinding(),
        PinBinding(),
      ],
    ),
    
    GetPage(
      name: AppRoutes.transactions,
      page: () => const TransactionsPage(),
      binding: HomeBinding(),
    ),

    // Profile & Settings
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
    ),
    
    GetPage(
      name: AppRoutes.exchangeRates,
      page: () => const ExchangeRatesPage(),
    ),
  ];
}