import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blinq/data/transaction/models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<void> createTransaction(TransactionModel transaction);
  Future<List<TransactionModel>> getTransactions();
  Future<List<TransactionModel>> getTransactionsBetween({
    required DateTime start,
    required DateTime end,
  });
  Future<double> getBalance();
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final FirebaseFirestore _firestore;

  TransactionRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createTransaction(TransactionModel transaction) async {
    await _firestore
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toMap());
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final snapshot = await _firestore
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<List<TransactionModel>> getTransactionsBetween({
    required DateTime start,
    required DateTime end,
  }) async {
    final snapshot = await _firestore
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThanOrEqualTo: end.toIso8601String())
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<double> getBalance() async {
    final snapshot = await _firestore.collection('transactions').get();

    double total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final amount = (data['amount'] ?? 0).toDouble();
      final type = data['type'];
      if (type == 'deposit') {
        total += amount;
      } else if (type == 'withdraw' || type == 'transfer') {
        total -= amount;
      }
    }

    return total;
  }
}
