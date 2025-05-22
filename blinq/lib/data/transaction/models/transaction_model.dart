import '../../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required String id,
    required double amount,
    required DateTime date,
    required String description,
    required String type,
    String? counterparty,
    String? status,
  }) : super(
          id: id,
          amount: amount,
          date: date,
          description: description,
          type: type,
          counterparty: counterparty ?? '',
          status: status ?? '',
        );

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      description: map['description'] as String? ?? '',
      type: map['type'] as String? ?? '',
      counterparty: map['counterparty'] as String?,
      status: map['status'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'type': type,
      'counterparty': counterparty,
      'status': status,
    };
  }

  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      amount: transaction.amount,
      date: transaction.date,
      description: transaction.description,
      type: transaction.type,
      counterparty: transaction.counterparty,
      status: transaction.status,
    );
  }
}
