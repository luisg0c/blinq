import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../domain/models/account_model.dart';
import '../domain/models/transaction_model.dart';

class FirebaseService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth functions
  User? get currentUser => _auth.currentUser;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUpWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  Future<void> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  // Firestore functions - Accounts
  Future<void> createAccount(String userId, String email) {
    final account = AccountModel(
      id: userId,
      email: email,
      balance: 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    return _firestore.collection('accounts').doc(userId).set(
      account.toMap(),
      SetOptions(merge: true),
    );
  }

  Future<AccountModel?> getAccount(String userId) async {
    final doc = await _firestore.collection('accounts').doc(userId).get();
    if (doc.exists) {
      return AccountModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Stream<AccountModel> getAccountStream(String userId) {
    return _firestore
        .collection('accounts')
        .doc(userId)
        .snapshots()
        .map((snapshot) => AccountModel.fromMap(snapshot.data()!, snapshot.id));
  }

  Future<AccountModel?> getAccountByEmail(String email) async {
    final query = await _firestore
        .collection('accounts')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
        
    if (query.docs.isNotEmpty) {
      return AccountModel.fromMap(query.docs.first.data(), query.docs.first.id);
    }
    return null;
  }

  Future<void> updateAccount(String userId, Map<String, dynamic> data) {
    return _firestore.collection('accounts').doc(userId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Transaction password functions
  Future<bool> hasTransactionPassword(String userId) async {
    final doc = await _firestore.collection('accounts').doc(userId).get();
    return doc.exists && doc.data()!.containsKey('txnPassword');
  }

  Future<void> setTransactionPassword(String userId, String password) {
    return _firestore.collection('accounts').doc(userId).update({
      'txnPassword': password,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> validateTransactionPassword(String userId, String password) async {
    final doc = await _firestore.collection('accounts').doc(userId).get();
    if (doc.exists && doc.data()!.containsKey('txnPassword')) {
      return doc.data()!['txnPassword'] == password;
    }
    return false;
  }

  // Firestore functions - Transactions
  Future<void> addTransaction(TransactionModel transaction) {
    return _firestore.collection('transactions').add(transaction.toMap());
  }

  Stream<List<TransactionModel>> getUserTransactionsStream(String userId) {
    return _firestore
        .collection('transactions')
        .where('participants', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return TransactionModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Balance operations
  Future<void> updateBalance(String userId, double amount) async {
    final account = await getAccount(userId);
    if (account != null) {
      await updateAccount(userId, {'balance': account.balance + amount});
    }
  }
}