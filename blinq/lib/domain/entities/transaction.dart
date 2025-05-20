class Transaction {
  /// Identificador único da transação.
  final String id;

  /// Valor da transação. Positivo para entrada, negativo para saída.
  final double amount;

  /// Data e hora em que a transação ocorreu.
  final DateTime date;

  /// Descrição ou categoria da operação.
  final String description;

  /// Tipo da transação: 'deposit', 'transfer', 'payment', 'recharge' etc.
  final String type;

  /// Conta ou usuário de contraparte (por ex., e-mail ou nome) – opcional.
  final String? counterparty;

  /// Status da transação: 'completed', 'pending', 'failed' etc.
  final String status;

  const Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.description,
    required this.type,
    this.counterparty,
    this.status = 'completed',
  });

  @override
  String toString() =>
      'Transaction(id: $id, amount: $amount, date: $date, '
      'description: $description, type: $type, '
      'counterparty: $counterparty, status: $status)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.amount == amount &&
        other.date == date &&
        other.description == description &&
        other.type == type &&
        other.counterparty == counterparty &&
        other.status == status;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      amount.hashCode ^
      date.hashCode ^
      description.hashCode ^
      type.hashCode ^
      (counterparty?.hashCode ?? 0) ^
      status.hashCode;
}
