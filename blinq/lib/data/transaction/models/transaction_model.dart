import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import '../../../domain/entities/transaction.dart';

/// Modelo de dados que representa uma transação no Data layer,
/// estendendo a entidade de domínio.
class TransactionModel extends Transaction {
  const TransactionModel({
    required String id,
    required double amount,
    required DateTime date,
    required String description,
    required String type,
    String? counterparty,
    String status = 'completed',
  }) : super(
          id: id,
          amount: amount,
          date: date,
          description: description,
          type: type,
          counterparty: counterparty,
          status: status,
        );

  /// Constrói um modelo a partir de um Map (ex.: JSON ou Firestore).
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      type: json['type'] as String,
      counterparty: json['counterparty'] as String?,
      status: json['status'] as String? ?? 'completed',
    );
  }

  /// Converte o modelo em Map (ex.: para JSON).
  Map<String, dynamic> toJson() {
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

  /// Constrói um modelo a partir de um DocumentSnapshot do Firestore.
  factory TransactionModel.fromDocument(fs.DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as fs.Timestamp).toDate(),
      description: data['description'] as String,
      type: data['type'] as String,
      counterparty: data['counterparty'] as String?,
      status: data['status'] as String? ?? 'completed',
    );
  }

  /// Converte o modelo em Map para salvar no Firestore.
  Map<String, dynamic> toDocument() {
    return {
      'amount': amount,
      'date': fs.Timestamp.fromDate(date),
      'description': description,
      'type': type,
      'counterparty': counterparty,
      'status': status,
    };
  }
}
