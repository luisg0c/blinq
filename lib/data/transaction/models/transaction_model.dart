// blinq/lib/data/transaction/models/transaction_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/transaction.dart' as domain;

/// Modelo de transação compatível com Firestore.
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
    try {
      // Conversão segura da data
      final timestamp = data['date'];
      DateTime transactionDate;
      
      if (timestamp is Timestamp) {
        transactionDate = timestamp.toDate();
      } else if (timestamp is String) {
        transactionDate = DateTime.tryParse(timestamp) ?? DateTime.now();
      } else if (timestamp is int) {
        transactionDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        print('⚠️ Formato de data desconhecido: $timestamp, usando DateTime.now()');
        transactionDate = DateTime.now();
      }

      // Conversão segura do valor
      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      
      final model = TransactionModel(
        id: id,
        amount: amount,
        date: transactionDate,
        description: data['description']?.toString() ?? '',
        type: data['type']?.toString() ?? 'unknown',
        counterparty: data['counterparty']?.toString() ?? '',
        status: data['status']?.toString() ?? 'completed',
      );

      // Log para debug
      print('✅ Transação convertida: ${model.type} - R\$ ${model.amount}');
      
      return model;
    } catch (e) {
      print('❌ Erro ao converter dados do Firestore: $e');
      print('   ID: $id');
      print('   Dados: $data');
      
      // Retornar um modelo padrão em caso de erro
      return TransactionModel(
        id: id,
        amount: 0.0,
        date: DateTime.now(),
        description: 'Transação com erro',
        type: 'error',
        counterparty: '',
        status: 'error',
      );
    }
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
    final data = {
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'description': description,
      'type': type,
      'counterparty': counterparty,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };

    print('📤 Dados para Firestore: $data');
    return data;
  }

  /// Método para debug
  @override
  String toString() {
    return 'TransactionModel(id: $id, type: $type, amount: $amount, date: $date, description: $description)';
  }
}