class TransactionException implements Exception {
  final String message;
  final TransactionErrorType type;

  TransactionException(this.message, this.type);

  @override
  String toString() => message;
}

enum TransactionErrorType {
  insufficientFunds,
  accountNotFound,
  invalidAmount,
  transactionFailed,
  limitExceeded,
  authenticationFailed
}