/// Entidade que representa uma transação no sistema.
class Transaction {
  final String id;
  final double amount;
  final DateTime date;
  final String description;
  final String type; // 'deposit', 'transfer', etc.
  final String counterparty; // nome ou id da outra parte envolvida
  final String status; // estados como "pendente", "concluído"

  const Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.description,
    required this.type,
    required this.counterparty,
    required this.status,
  });

  /// Cria uma transação de depósito.
  factory Transaction.deposit({
    required String id,
    required double amount,
    String? description,
  }) {
    return Transaction(
      id: id,
      amount: amount,
      date: DateTime.now(),
      description: description ?? 'Depósito',
      type: 'deposit',
      counterparty: '',
      status: 'completed',
    );
  }

  /// Cria uma transação de transferência.
  factory Transaction.transfer({
    required String id,
    required double amount,
    required String counterparty,
    String? description,
  }) {
    return Transaction(
      id: id,
      amount: amount,
      date: DateTime.now(),
      description: description ?? 'Transferência PIX',
      type: 'transfer',
      counterparty: counterparty,
      status: 'completed',
    );
  }

  /// Verifica se a transação é um depósito.
  bool get isDeposit => type == 'deposit';

  /// Verifica se a transação é uma transferência.
  bool get isTransfer => type == 'transfer';

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
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        date.hashCode ^
        description.hashCode ^
        type.hashCode ^
        counterparty.hashCode ^
        status.hashCode;
  }

  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, type: $type, date: $date)';
  }
}