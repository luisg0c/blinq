// lib/routes/app_pages.dart

import 'package:get/get.dart';
import 'app_routes.dart';
import '../presentation/bindings/splash_binding.dart';
import '../presentation/bindings/auth_binding.dart';
import '../presentation/bindings/home_binding.dart';
import '../presentation/pages/splash/splash_page.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/register_page.dart';
import '../presentation/pages/auth/reset_password_page.dart';
import '../presentation/pages/home/home_page.dart';

/// Lista de páginas e bindings usados pelo GetMaterialApp.
class AppPages {
  static final pages = <GetPage>[
    // Splash
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),

    // Auth
    GetPage(
      name: AppRoutes.login,
      page: () => LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => ResetPasswordPage(),
      binding: AuthBinding(),
    ),

    // Home
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),

    // TODO: adicionar outras rotas e bindings (transferências, perfil etc.)
  ];
}
