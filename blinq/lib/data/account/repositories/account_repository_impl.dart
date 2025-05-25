// lib/data/account/repositories/account_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../../domain/entities/account.dart';
import '../../../domain/repositories/account_repository.dart';

/// Implementação do repositório de conta usando Firestore direto.
class AccountRepositoryImpl implements AccountRepository {
  final FirebaseFirestore _firestore;

  AccountRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Account> getAccount(String userId) async {
    try {
      print('💰 Buscando conta para $userId');
      final doc = await _firestore.collection('accounts').doc(userId).get();
      
      if (!doc.exists) {
        print('⚠️ Conta não encontrada para $userId, retornando conta padrão');
        return Account(
          userId: userId,
          balance: 0.0,
          hasTransactionPassword: false,
        );
      }
      
      final data = doc.data()!;
      final balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
      final hasPassword = data['transactionPassword'] != null;
      
      print('💰 Conta encontrada: saldo R\$ $balance');
      
      return Account(
        userId: userId,
        balance: balance,
        hasTransactionPassword: hasPassword,
      );
    } catch (e) {
      print('❌ Erro ao obter conta: $e');
      throw Exception('Erro ao obter conta: $e');
    }
  }

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
      print('🔒 Definindo senha de transação para $userId');
      final hashedPassword = _hashPassword(password);
      
      await _firestore.collection('accounts').doc(userId).update({
        'transactionPassword': hashedPassword,
        'passwordSetAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Senha de transação definida');
    } catch (e) {
      print('❌ Erro ao definir senha: $e');
      throw Exception('Erro ao definir senha de transação: $e');
    }
  }

  @override
  Future<bool> validateTransactionPassword(String userId, String password) async {
    try {
      print('🔐 Validando senha de transação para $userId');
      final doc = await _firestore.collection('accounts').doc(userId).get();
      
      if (!doc.exists) {
        print('❌ Conta não encontrada');
        return false;
      }

      final data = doc.data()!;
      final storedHash = data['transactionPassword'] as String?;
      
      if (storedHash == null) {
        print('⚠️ Senha não configurada');
        return false;
      }

      final inputHash = _hashPassword(password);
      final isValid = storedHash == inputHash;
      
      print(isValid ? '✅ Senha válida' : '❌ Senha inválida');
      return isValid;
    } catch (e) {
      print('❌ Erro ao validar senha: $e');
      return false;
    }
  }

  @override
  Future<bool> hasTransactionPassword(String userId) async {
    try {
      print('🔍 Verificando se $userId tem senha configurada');
      final doc = await _firestore.collection('accounts').doc(userId).get();
      
      if (!doc.exists) {
        print('❌ Conta não encontrada');
        return false;
      }

      final data = doc.data()!;
      final hasPassword = data['transactionPassword'] != null;
      
      print(hasPassword ? '✅ Senha configurada' : '⚠️ Senha não configurada');
      return hasPassword;
    } catch (e) {
      print('❌ Erro ao verificar senha: $e');
      return false;
    }
  }

  @override
  Stream<double> watchBalance(String userId) {
    print('👀 Iniciando stream do saldo para $userId');
    
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

  /// ✅ MÉTODO HELPER PARA HASH DE SENHA
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  /// ✅ MÉTODO HELPER PARA VERIFICAR SE CONTA EXISTE
  Future<bool> accountExists(String userId) async {
    try {
      final doc = await _firestore.collection('accounts').doc(userId).get();
      return doc.exists;
    } catch (e) {
      print('❌ Erro ao verificar existência da conta: $e');
      return false;
    }
  }
}