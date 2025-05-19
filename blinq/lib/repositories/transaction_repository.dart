import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<TransactionModel?> createTransaction(
      TransactionModel transaction) async {
    try {
      final transactionRef =
          _firestore.collection('transactions').doc(transaction.id);
      await transactionRef.set(transaction.toMap());
      return transaction;
    } catch (e) {
      print('Erro ao criar transação: $e');
      return null;
    }
  }

  Future<List<TransactionModel>> getUserTransactions(String userId,
      {int limit = 20}) async {
    try {
      final query = await _firestore
          .collection('transactions')
          .where('senderId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => TransactionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Erro ao buscar transações: $e');
      return [];
    }
  }

  Future<double> getTotalTransactionsByType(String userId, TransactionType type) async {
  try {
    final QuerySnapshot query = await _firestore
        .collection('transactions')
        .where('senderId', isEqualTo: userId)
        .where('type', isEqualTo: type.name)
        .get();

    double total = 0.0;
    for (var doc in query.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = data['amount'] is num ? (data['amount'] as num).toDouble() : 0.0;
      total += amount;
    }

    return total;
  } catch (e) {
    print('Erro ao calcular total de transações: $e');
    return 0.0;
  }
}
}
