/// Classe com as constantes do aplicativo
class AppConstants {
  // Evitar instanciação
  AppConstants._();
  
  // Informações do aplicativo
  static const String appName = 'Blinq';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // URLs
  static const String termsUrl = 'https://blinq.app/terms';
  static const String privacyUrl = 'https://blinq.app/privacy';
  static const String helpUrl = 'https://blinq.app/help';
  static const String supportEmail = 'support@blinq.app';
  
  // Tamanhos de animação e duração
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration toastDuration = Duration(seconds: 3);
  
  // Limites do aplicativo
  static const double minTransferAmount = 0.01;
  static const double maxTransferAmount = 10000.00;
  static const double minDepositAmount = 0.01;
  static const double maxDepositAmount = 10000.00;
  static const double dailyTransferLimit = 5000.00;
  
  // Validação
  static const int minPasswordLength = 6;
  static const int minTransactionPasswordLength = 4;
  static const int maxTransactionPasswordLength = 6;
  
  // Chaves de cache
  static const String themeModeKey = 'theme_mode';
  static const String userIdKey = 'user_id';
  static const String languageKey = 'language';
  
  // Formatos
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String currencyFormat = 'R\$';
  
  // Paginação
  static const int transactionsPerPage = 20;
  static const int searchResultsPerPage = 15;
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String accountsCollection = 'accounts';
  static const String transactionsCollection = 'transactions';
  
  // Tipos de Transação
  static const String depositType = 'deposit';
  static const String transferType = 'transfer';
  
  // Status de Transação
  static const String pendingStatus = 'pending';
  static const String completedStatus = 'completed';
  static const String failedStatus = 'failed';
  static const String canceledStatus = 'canceled';
  
  // Valores padrão
  static const List<String> defaultCategories = [
    'Alimentação',
    'Transporte',
    'Educação',
    'Saúde',
    'Lazer',
    'Outros',
  ];
}