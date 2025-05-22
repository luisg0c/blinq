import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Contrato para operações de conta no Firebase.
abstract class AccountRemoteDataSource {
  Future<double> getBalance(String userId);
  Future<void> updateBalance(String userId, double newBalance);
  Future<void> setTransactionPassword(String userId, String password);
  Future<bool> validateTransactionPassword(String userId, String password);
  Future<bool> hasTransactionPassword(String userId);
  Stream<double> watchBalance(String userId);
}

/// Implementação usando Firestore seguindo estrutura YeezyBank.
class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final FirebaseFirestore _firestore;

  AccountRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<double> getBalance(String userId) async {
    final doc = await _firestore.collection('accounts').doc(userId).get();
    if (!doc.exists) throw Exception('Conta não encontrada');
    
    final data = doc.data()!;
    return (data['balance'] as num?)?.toDouble() ?? 0.0;
  }

  @override
  Future<void> updateBalance(String userId, double newBalance) async {
    await _firestore.collection('accounts').doc(userId).update({
      'balance': newBalance,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> setTransactionPassword(String userId, String password) async {
    final hashedPassword = _hashPassword(password);
    await _firestore.collection('accounts').doc(userId).update({
      'transactionPassword': hashedPassword,
      'passwordSetAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<bool> validateTransactionPassword(String userId, String password) async {
    final doc = await _firestore.collection('accounts').doc(userId).get();
    if (!doc.exists) throw Exception('Conta não encontrada');

    final data = doc.data()!;
    final storedHash = data['transactionPassword'] as String?;
    
    if (storedHash == null) return false;

    final inputHash = _hashPassword(password);
    return storedHash == inputHash;
  }

  @override
  Future<bool> hasTransactionPassword(String userId) async {
    final doc = await _firestore.collection('accounts').doc(userId).get();
    if (!doc.exists) return false;

    final data = doc.data()!;
    return data['transactionPassword'] != null;
  }

  @override
  Stream<double> watchBalance(String userId) {
    return _firestore
        .collection('accounts')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return 0.0;
          final data = doc.data()!;
          return (data['balance'] as num?)?.toDouble() ?? 0.0;
        });
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }
}