import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/account_model.dart';

class AccountRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AccountModel?> createAccount(AccountModel account) async {
    try {
      final docRef = _firestore.collection('accounts').doc(account.id);
      await docRef.set(account.toMap());
      return account;
    } catch (e) {
      print('Erro ao criar conta: $e');
      return null;
    }
  }

  Future<AccountModel?> getAccountByUserId(String userId) async {
    try {
      final query = await _firestore
        .collection('accounts')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

      return query.docs.isNotEmpty 
        ? AccountModel.fromMap(query.docs.first.data(), query.docs.first.id)
        : null;
    } catch (e) {
      print('Erro ao buscar conta: $e');
      return null;
    }
  }

  Future<bool> updateBalance(String accountId, double amount) async {
    try {
      await _firestore.collection('accounts').doc(accountId).update({
        'balance': FieldValue.increment(amount),
        'updatedAt': Timestamp.now()
      });
      return true;
    } catch (e) {
      print('Erro ao atualizar saldo: $e');
      return false;
    }
  }

  Future<bool> setTransactionPassword(String accountId, String password) async {
    try {
      await _firestore.collection('accounts').doc(accountId).update({
        'transactionPassword': password,
        'updatedAt': Timestamp.now()
      });
      return true;
    } catch (e) {
      print('Erro ao definir senha de transação: $e');
      return false;
    }
  }

  Future<bool> validateTransactionPassword(String accountId, String password) async {
    try {
      final account = await getAccountById(accountId);
      return account?.transactionPassword == password;
    } catch (e) {
      print('Erro ao validar senha de transação: $e');
      return false;
    }
  }

  Future<AccountModel?> getAccountById(String accountId) async {
    try {
      final doc = await _firestore.collection('accounts').doc(accountId).get();
      return doc.exists 
        ? AccountModel.fromMap(doc.data()!, doc.id)
        : null;
    } catch (e) {
      print('Erro ao buscar conta por ID: $e');
      return null;
    }
  }
}