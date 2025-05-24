class AppRoutes {
  // Inicial
  static const String splash = '/splash';
  
  // Onboarding
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  
  // Autenticação
  static const String login = '/login';
  static const String signup = '/signup';
  static const String resetPassword = '/reset-password';
  
  // PIN
  static const String setupPin = '/setup-pin';
  static const String verifyPin = '/verify-pin';
  static const String pinSetup = '/pin-setup';     // Alias
  static const String pinVerification = '/pin-verification'; // Alias
  
  // App Principal
  static const String home = '/home';
  
  // Transações
  static const String deposit = '/deposit';
  static const String transfer = '/transfer';
  static const String transactions = '/transactions';
  
  // Outros
  static const String profile = '/profile';
  static const String exchangeRates = '/exchange-rates';
  static const String qrCode = '/qr-code';
  
  // Utilitários
  static const List<String> publicRoutes = [
    splash,
    onboarding,
    welcome,
    login,
    signup,
    resetPassword,
  ];
  
  static const List<String> protectedRoutes = [
    home,
    deposit,
    transfer,
    transactions,
    profile,
    exchangeRates,
    setupPin,
    verifyPin,
  ];
  
  static bool isPublicRoute(String route) {
    return publicRoutes.contains(route);
  }
  
  static bool isProtectedRoute(String route) {
    return protectedRoutes.contains(route);
  }
}