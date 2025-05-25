import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../../domain/entities/account.dart';
import '../../../domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AccountRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  void _validateUserId(String userId) {
    if (userId.trim().isEmpty) {
      throw Exception('ID do usuário não pode estar vazio');
    }

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Usuário não autenticado');
    }

    if (currentUser.uid != userId) {
      throw Exception('Acesso negado');
    }
  }

  @override
  Future<Account> getAccount(String userId) async {
    try {
      _validateUserId(userId);
      
      final doc = await _firestore.collection('accounts').doc(userId).get();
      
      if (!doc.exists) {
        return Account(
          userId: userId,
          balance: 0.0,
          hasTransactionPassword: false,
        );
      }
      
      final data = doc.data()!;
      return Account(
        userId: userId,
        balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
        hasTransactionPassword: data['transactionPassword'] != null,
      );
    } catch (e) {
      print('❌ Erro ao obter conta: $e');
      rethrow;
    }
  }

  @override
  Future<double> getBalance(String userId) async {
    try {
      _validateUserId(userId);
      
      final doc = await _firestore.collection('accounts').doc(userId).get();
      
      if (!doc.exists) {
        return 0.0;
      }
      
      return (doc.data()!['balance'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      print('❌ Erro ao obter saldo: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateBalance(String userId, double newBalance) async {
    try {
      _validateUserId(userId);
      
      await _firestore.collection('accounts').doc(userId).update({
        'balance': newBalance,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Erro ao atualizar saldo: $e');
      rethrow;
    }
  }

  @override
  Future<void> setTransactionPassword(String userId, String password) async {
    try {
      _validateUserId(userId);
      
      final hashedPassword = _hashPassword(password);
      await _firestore.collection('accounts').doc(userId).update({
        'transactionPassword': hashedPassword,
        'passwordSetAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Erro ao definir senha: $e');
      rethrow;
    }
  }

  @override
  Future<bool> validateTransactionPassword(String userId, String password) async {
    try {
      _validateUserId(userId);
      
      final doc = await _firestore.collection('accounts').doc(userId).get();
      if (!doc.exists) return false;

      final data = doc.data()!;
      final storedHash = data['transactionPassword'] as String?;
      if (storedHash == null) return false;

      return storedHash == _hashPassword(password);
    } catch (e) {
      print('❌ Erro ao validar senha: $e');
      return false;
    }
  }

  @override
  Future<bool> hasTransactionPassword(String userId) async {
    try {
      _validateUserId(userId);
      
      final doc = await _firestore.collection('accounts').doc(userId).get();
      if (!doc.exists) return false;

      return doc.data()!['transactionPassword'] != null;
    } catch (e) {
      print('❌ Erro ao verificar senha: $e');
      return false;
    }
  }

  @override
  Stream<double> watchBalance(String userId) {
    try {
      _validateUserId(userId);
      
      return _firestore
          .collection('accounts')
          .doc(userId)
          .snapshots()
          .map((doc) {
            if (!doc.exists) return 0.0;
            return (doc.data()!['balance'] as num?)?.toDouble() ?? 0.0;
          })
          .handleError((e) {
            print('❌ Erro no stream do saldo: $e');
            return 0.0;
          });
    } catch (e) {
      print('❌ Erro ao configurar stream: $e');
      return Stream.value(0.0);
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }
}