import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<double> getBalance();
  Future<List<TransactionModel>> getRecentTransactions({int? limit});

  /// Adiciona uma nova transação no Firestore
  Future<void> addTransaction(TransactionModel transaction);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final fs.FirebaseFirestore _firestore;
  final fb.FirebaseAuth _firebaseAuth;

  TransactionRemoteDataSourceImpl({
    fs.FirebaseFirestore? firestore,
    fb.FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? fs.FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;

  @override
  Future<double> getBalance() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');

    final snapshot = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.fold(0.0, (sum, doc) {
      return sum + (doc.get('amount') as num).toDouble();
    });
  }

  @override
  Future<List<TransactionModel>> getRecentTransactions({int? limit}) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');

    var query = _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true);

    if (limit != null) query = query.limit(limit);

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return TransactionModel(
        id: doc.id,
        amount: (data['amount'] as num).toDouble(),
        date: (data['date'] as fs.Timestamp).toDate(),
        description: data['description'] as String,
        type: data['type'] as String,
        counterparty: data['counterparty'] as String?,
        status: data['status'] as String? ?? 'completed',
      );
    }).toList();
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');

    final data = transaction.toDocument();
    data['userId'] = userId;

    await _firestore.collection('transactions').add(data);
  }
}
