import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore;

  TransactionRepository(this._firestore);

  Future<DocumentSnapshot> getAccount(String userId) {
    return _firestore.collection('accounts').doc(userId).get();
  }

  Future<void> setAccount(String userId, Map<String, dynamic> data) {
    return _firestore.collection('accounts').doc(userId).set(data, SetOptions(merge: true));
  }

  Future<void> updateAccount(String userId, Map<String, dynamic> data) {
    return _firestore.collection('accounts').doc(userId).update(data);
  }

  Future<QuerySnapshot> getAccountByEmail(String email) {
    return _firestore.collection('accounts').where('email', isEqualTo: email).limit(1).get();
  }

  Future<void> addTransaction(TransactionModel txn) {
    return _firestore.collection('transactions').add(txn.toMap());
  }

  Stream<List<TransactionModel>> getUserTransactionsStream(String userId) {
    return _firestore
        .collection('transactions')
        .where('participants', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return TransactionModel.fromMap(data, doc.id);
          }).toList();
        });
  }
}
