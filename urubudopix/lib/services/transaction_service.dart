import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final _transactions = FirebaseFirestore.instance.collection('transactions');

  Future<void> sendTransaction(TransactionModel txn) async {
    await _transactions.add(txn.toMap());
  }

  Stream<List<TransactionModel>> getUserTransactions(String userId) {
    return _transactions
        .where('senderId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
