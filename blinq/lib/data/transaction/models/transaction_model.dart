import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/transaction.dart' as domain;

/// Modelo de transação compatível com a estrutura Blinq.
class TransactionModel extends domain.Transaction {
  const TransactionModel({
    required String id,
    required double amount,
    required DateTime date,
    required String description,
    required String type,
    required String counterparty,
    required String status,
  }) : super(
          id: id,
          amount: amount,
          date: date,
          description: description,
          type: type,
          counterparty: counterparty,
          status: status,
        );

  /// Cria um [TransactionModel] a partir de dados do Firestore.
  factory TransactionModel.fromFirestore(String id, Map<String, dynamic> data) {
    final timestamp = data['date'] as Timestamp?;

    return TransactionModel(
      id: id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      date: timestamp?.toDate() ?? DateTime.now(),
      description: data['description'] ?? '',
      type: data['type'] ?? '',
      counterparty: data['counterparty'] ?? '',
      status: data['status'] ?? 'completed',
    );
  }

  /// Cria um [TransactionModel] a partir de uma entidade de domínio.
  factory TransactionModel.fromEntity(domain.Transaction transaction) {
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

  /// Converte para Map do Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'description': description,
      'type': type,
      'counterparty': counterparty,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}