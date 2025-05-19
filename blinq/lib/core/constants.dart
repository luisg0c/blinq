class AppConstants {
<<<<<<< Updated upstream
  // Evitar instanciação
  AppConstants._();

  // Informações do aplicativo
  static const String appName = 'Blinq';
  static const String appVersion = '1.0.0';

=======
  // App info
  static const String appName = 'Blinq';
  static const String appVersion = '1.0.0';
  
>>>>>>> Stashed changes
  // Limites de transação
  static const double minTransferAmount = 0.01;
  static const double maxTransferAmount = 10000.00;
  static const double minDepositAmount = 0.01;
  static const double maxDepositAmount = 10000.00;
  static const double dailyTransferLimit = 5000.00;
<<<<<<< Updated upstream

  // Validação
  static const int minPasswordLength = 6;
  static const int minTransactionPasswordLength = 4;
  static const int maxTransactionPasswordLength = 6;

  // Formatos
=======
  
  // Validação
  static const int minPasswordLength = 6;
  static const int minTransactionPasswordLength = 4;
  
  // Formatação
>>>>>>> Stashed changes
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String currencySymbol = 'R\$';
<<<<<<< Updated upstream

=======
  
>>>>>>> Stashed changes
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String accountsCollection = 'accounts';
  static const String transactionsCollection = 'transactions';
<<<<<<< Updated upstream
}
=======
}
>>>>>>> Stashed changes
