import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/transaction.dart' as domain;
import '../models/transaction_model.dart';

/// Contrato para operações de transação no Firebase.
abstract class TransactionRemoteDataSource {
  Future<void> addTransaction(String userId, TransactionModel transaction);
  Future<List<domain.Transaction>> getTransactionsByUser(String userId);
  Future<List<domain.Transaction>> getTransactionsBetween({
    required String userId,
    required DateTime start,
    required DateTime end,
  });
  Stream<List<domain.Transaction>> watchTransactionsByUser(String userId);
}

/// Implementação usando Firestore seguindo estrutura Blinq.
class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final FirebaseFirestore _firestore;

  TransactionRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> addTransaction(String userId, TransactionModel transaction) async {
    await _firestore
        .collection('accounts')
        .doc(userId)
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toFirestore());
  }

  @override
  Future<List<domain.Transaction>> getTransactionsByUser(String userId) async {
    final snapshot = await _firestore
        .collection('accounts')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<domain.Transaction>> getTransactionsBetween({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    final snapshot = await _firestore
        .collection('accounts')
        .doc(userId)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  @override
  Stream<List<domain.Transaction>> watchTransactionsByUser(String userId) {
    return _firestore
        .collection('accounts')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc.id, doc.data()))
            .toList());
  }
}