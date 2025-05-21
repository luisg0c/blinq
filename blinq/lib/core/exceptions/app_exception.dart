/// Exceção base para os erros controlados da aplicação.
class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => 'AppException: $message';
}

/// Exceção para PIN incorreto.
class InvalidPinException extends AppException {
  const InvalidPinException() : super('PIN inválido');
}

/// Exceção para saldo insuficiente.
class InsufficientBalanceException extends AppException {
  const InsufficientBalanceException() : super('Saldo insuficiente');
}

/// Exceção para usuários ou ações proibidas.
class UnauthorizedActionException extends AppException {
  const UnauthorizedActionException() : super('Ação não permitida');
}
