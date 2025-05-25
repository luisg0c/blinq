// blinq/lib/data/account/datasources/account_remote_data_source.dart
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

/// Implementação usando Firestore com estrutura corrigida.
class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final FirebaseFirestore _firestore;

  AccountRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<double> getBalance(String userId) async {
    try {
      print('💰 Buscando saldo para $userId');
      final doc = await _firestore.collection('accounts').doc(userId).get();
      if (!doc.exists) {
        print('⚠️ Conta não encontrada para $userId, retornando saldo 0');
        return 0.0;
      }
      
      final data = doc.data()!;
      final balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
      print('💰 Saldo obtido: R\$ $balance para $userId');
      return balance;
    } catch (e) {
      print('❌ Erro ao obter saldo: $e');
      throw Exception('Erro ao obter saldo: $e');
    }
  }

  @override
  Future<void> updateBalance(String userId, double newBalance) async {
    try {
      print('💰 Atualizando saldo para $userId: R\$ $newBalance');
      
      await _firestore.collection('accounts').doc(userId).update({
        'balance': newBalance,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Saldo atualizado com sucesso');
    } catch (e) {
      print('❌ Erro ao atualizar saldo: $e');
      throw Exception('Erro ao atualizar saldo: $e');
    }
  }

  @override
  Future<void> setTransactionPassword(String userId, String password) async {
    try {
      final hashedPassword = _hashPassword(password);
      await _firestore.collection('accounts').doc(userId).update({
        'transactionPassword': hashedPassword,
        'passwordSetAt': FieldValue.serverTimestamp(),
      });
      print('🔒 Senha de transação definida para $userId');
    } catch (e) {
      print('❌ Erro ao definir senha: $e');
      throw Exception('Erro ao definir senha de transação: $e');
    }
  }

  @override
  Future<bool> validateTransactionPassword(String userId, String password) async {
    try {
      final doc = await _firestore.collection('accounts').doc(userId).get();
      if (!doc.exists) throw Exception('Conta não encontrada');

      final data = doc.data()!;
      final storedHash = data['transactionPassword'] as String?;
      
      if (storedHash == null) return false;

      final inputHash = _hashPassword(password);
      return storedHash == inputHash;
    } catch (e) {
      print('❌ Erro ao validar senha: $e');
      return false;
    }
  }

  @override
  Future<bool> hasTransactionPassword(String userId) async {
    try {
      final doc = await _firestore.collection('accounts').doc(userId).get();
      if (!doc.exists) return false;

      final data = doc.data()!;
      return data['transactionPassword'] != null;
    } catch (e) {
      print('❌ Erro ao verificar senha: $e');
      return false;
    }
  }

  @override
  Stream<double> watchBalance(String userId) {
    print('👀 Iniciando watch do saldo para $userId');
    
    return _firestore
        .collection('accounts')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            print('⚠️ Documento não existe, retornando saldo 0');
            return 0.0;
          }
          
          final data = doc.data()!;
          final balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
          print('👀 Stream saldo: R\$ $balance');
          return balance;
        })
        .handleError((e) {
          print('❌ Erro no stream do saldo: $e');
          throw Exception('Erro ao monitorar saldo: $e');
        });
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }
}