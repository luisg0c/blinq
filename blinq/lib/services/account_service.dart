import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../core/constants.dart';
import '../models/account.dart';

class AccountService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtém a conta do usuário
  Future<Account?> getAccount(String userId) async {
    try {
      final query = await _firestore
          .collection(AppConstants.accountsCollection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return Account.fromMap(query.docs.first.data(), query.docs.first.id);
      } else {
        // Auto-criar conta se não existir
        return createAccount(userId);
      }
    } catch (e) {
      debugPrint('Erro ao obter conta: $e');
      return null;
    }
  }

  // Stream para atualizações em tempo real da conta
  Stream<Account?> getAccountStream(String userId) {
    return _firestore
        .collection(AppConstants.accountsCollection)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return Account.fromMap(
            snapshot.docs.first.data(), snapshot.docs.first.id);
      }
      return null;
    });
  }

  // Criar uma nova conta
  Future<Account> createAccount(String userId) async {
    try {
      final docRef =
          _firestore.collection(AppConstants.accountsCollection).doc();
      final account = Account(
        id: docRef.id,
        userId: userId,
        balance: 0.0,
        isActive: true,
      );

      await docRef.set(account.toMap());
      return account;
    } catch (e) {
      debugPrint('Erro ao criar conta: $e');
      throw Exception('Não foi possível criar uma conta.');
    }
  }

  // Definir senha de transação
  Future<void> setTransactionPassword(String userId, String password) async {
    try {
      final account = await getAccount(userId);
      if (account == null) throw Exception('Conta não encontrada');

      // Hash da senha para segurança
      final hashedPassword = _hashPassword(password);

      await _firestore
          .collection(AppConstants.accountsCollection)
          .doc(account.id)
          .update({
        'transactionPassword': hashedPassword,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Erro ao definir senha de transação: $e');
      throw Exception('Erro ao definir senha de transação.');
    }
  }

  // Verificar se o usuário tem senha de transação
  Future<bool> hasTransactionPassword(String userId) async {
    try {
      final account = await getAccount(userId);
      return account?.transactionPassword != null;
    } catch (e) {
      return false;
    }
  }

  // Validar senha de transação
  Future<bool> validateTransactionPassword(
      String userId, String password) async {
    try {
      final account = await getAccount(userId);
      if (account == null || account.transactionPassword == null) {
        return false;
      }

      final hashedPassword = _hashPassword(password);
      return hashedPassword == account.transactionPassword;
    } catch (e) {
      debugPrint('Erro ao validar senha de transação: $e');
      return false;
    }
  }

  // Atualizar saldo
  Future<void> updateBalance(String userId, double newBalance) async {
    try {
      final account = await getAccount(userId);
      if (account == null) throw Exception('Conta não encontrada');

      await _firestore
          .collection(AppConstants.accountsCollection)
          .doc(account.id)
          .update({
        'balance': newBalance,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Erro ao atualizar saldo: $e');
      throw Exception('Erro ao atualizar saldo.');
    }
  }

  // Método simples de hash para senhas
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
