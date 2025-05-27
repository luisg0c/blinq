class Account {
  final String userId;
  final double balance;
  final bool hasTransactionPassword;

  const Account({
    required this.userId,
    required this.balance,
    required this.hasTransactionPassword,
  });

  /// Verifica se a conta tem saldo suficiente para uma operação.
  bool hasSufficientBalance(double amount) {
    return balance >= amount;
  }

  /// Cria uma cópia da conta com novo saldo.
  Account copyWith({
    String? userId,
    double? balance,
    bool? hasTransactionPassword,
  }) {
    return Account(
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      hasTransactionPassword: hasTransactionPassword ?? this.hasTransactionPassword,
    );
  }

  @override
  String toString() {
    return 'Account(userId: $userId, balance: $balance, hasTransactionPassword: $hasTransactionPassword)';
  }
}
