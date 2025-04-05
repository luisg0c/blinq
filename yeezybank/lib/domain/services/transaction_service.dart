// lib/domain/services/transaction_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/account_model.dart';
import '../../data/firebase_service.dart';
import 'dart:math';

class TransactionService extends GetxService {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const String errorSaldoInsuficiente = 'Saldo insuficiente';
  static const String errorDestinatarioNaoEncontrado = 'Destinatário não encontrado';
  static const String errorValorInvalido = 'Valor inválido';
  static const String errorUsuarioNaoLogado = 'Usuário não logado';
  static const String errorMesmoUsuario = 'Não é possível transferir para você mesmo';
  static const String errorTransacaoDuplicada = 'Possível transação duplicada detectada';
  static const String errorTransacaoNaoEncontrada = 'Transação não encontrada';
  static const String errorCodigoInvalido = 'Código de confirmação inválido';
  static const double LIMITE_ALERTA = 5000.0;
  
  // Cache para controle de duplicidade
  final Map<String, DateTime> _recentTransactions = {};

  // Obter saldo do usuário
  Future<double> getUserBalance(String userId) async {
    final account = await _firebaseService.getAccount(userId);
    if (account != null) {
      return account.balance;
    } else {
      // Criar conta se não existir
      await _firebaseService.createAccount(userId, _firebaseService.currentUser!.email!);
      return 0.0;
    }
  }

  // Stream de transações do usuário
  Stream<List<TransactionModel>> getUserTransactionsStream(String userId) {
    return _firebaseService.getUserTransactionsStream(userId);
  }

  // Stream da conta do usuário (para saldo em tempo real)
  Stream<AccountModel> getUserAccountStream(String userId) {
    return _firebaseService.getAccountStream(userId);
  }

  // NOVO: Método para obter informações do destinatário
  Future<AccountModel?> getReceiverInfo(String receiverId) async {
    return await _firebaseService.getAccount(receiverId);
  }

  // NOVO: Método para obter informações do remetente
  Future<AccountModel?> getSenderInfo(String senderId) async {
    return await _firebaseService.getAccount(senderId);
  }

  // NOVO: Método para enviar transação (usado na UI)
  Future<void> sendTransaction(TransactionModel txn, String receiverEmail) async {
    // Primeiro iniciamos a transação
    final initiatedTransaction = await initiateTransaction(
      txn.senderId, 
      receiverEmail, 
      txn.amount
    );
    
    // Como não estamos usando o fluxo de confirmação na UI atual,
    // podemos prosseguir diretamente para executar a transação
    await _executeTransaction(initiatedTransaction);
  }

  // ETAPA 1: Iniciar uma transferência (pendente de confirmação)
  Future<TransactionModel> initiateTransaction(String senderId, String receiverEmail, double amount) async {
    if (amount <= 0) {
      throw Exception(errorValorInvalido);
    }

    // Validação adicional para valores altos
    if (amount > LIMITE_ALERTA) {
      print('ALERTA: Transferência acima do limite de alerta: $amount');
    }
    
    // Verificar possível duplicação
    final duplicateKey = '$senderId-${receiverEmail.toLowerCase()}-$amount';
    if (_isRecentDuplicate(duplicateKey)) {
      throw Exception(errorTransacaoDuplicada);
    }

    // Verificação preliminar de transferência para si mesmo
    final currentUser = _firebaseService.currentUser;
    if (currentUser != null && currentUser.email != null) {
      final normalizedCurrentEmail = currentUser.email!.toLowerCase().trim();
      final normalizedReceiverEmail = receiverEmail.toLowerCase().trim();
      
      if (normalizedCurrentEmail == normalizedReceiverEmail) {
        throw Exception(errorMesmoUsuario);
      }
    }

    // Obter conta do destinatário
    final receiver = await _firebaseService.getAccountByEmail(receiverEmail);
    if (receiver == null) {
      throw Exception(errorDestinatarioNaoEncontrado);
    }

    // Verificação adicional por ID
    if (receiver.id == senderId) {
      throw Exception(errorMesmoUsuario);
    }
    
    // Obter conta do remetente
    final sender = await _firebaseService.getAccount(senderId);
    if (sender == null) {
      throw Exception(errorUsuarioNaoLogado);
    }

    // Verificar saldo suficiente
    if (sender.balance < amount) {
      throw Exception(errorSaldoInsuficiente);
    }
    
    // Gerar um ID de dispositivo simplificado
    final deviceId = _generateSimpleDeviceId();
    
    // Criar transação pendente
    TransactionModel txn = TransactionModel(
      id: '',
      senderId: senderId,
      receiverId: receiver.id,
      amount: amount,
      timestamp: DateTime.now(),
      participants: [senderId, receiver.id],
      type: 'transfer',
      status: TransactionStatus.pending,
      deviceId: deviceId,
    );
    
    // Gerar token único e código de confirmação
    final token = txn.generateToken();
    final confirmationCode = txn.generateConfirmationCode();
    
    // Atualizar transação com token e código
    txn = txn.copyWith(
      transactionToken: token,
      confirmationCode: confirmationCode,
    );
    
    // Salvar transação pendente
    try {
      final txnRef = await _firestore.collection('transactions').add(txn.toMap());
      
      // Registrar no cache de transações recentes
      _markTransactionAsProcessed(duplicateKey);
      
      // Retornar transação com ID
      return txn.copyWith(id: txnRef.id);
    } catch (e) {
      print('Erro ao iniciar transação: $e');
      rethrow;
    }
  }
  
  // ETAPA 2: Confirmar e executar a transferência
  Future<void> confirmTransaction(String transactionId, String confirmationCode) async {
    try {
      // Buscar transação pendente
      final txnDoc = await _firestore.collection('transactions').doc(transactionId).get();
      if (!txnDoc.exists) {
        throw Exception(errorTransacaoNaoEncontrada);
      }
      
      // Converter para modelo
      final txn = TransactionModel.fromMap(txnDoc.data()!, txnDoc.id);
      
      // Verificar status
      if (txn.status != TransactionStatus.pending) {
        throw Exception('Esta transação não está pendente de confirmação');
      }
      
      // Verificar código de confirmação
      if (!txn.validateConfirmationCode(confirmationCode)) {
        throw Exception(errorCodigoInvalido);
      }
      
      // Atualizar status para confirmado
      await _firestore.collection('transactions').doc(transactionId).update({
        'status': TransactionStatus.confirmed.toString().split('.').last,
        'confirmedAt': FieldValue.serverTimestamp(),
      });
      
      // Executar a transferência confirmada
      await _executeTransaction(txn);
    } catch (e) {
      // Marcar como falha em caso de erro
      try {
        await _firestore.collection('transactions').doc(transactionId).update({
          'status': TransactionStatus.failed.toString().split('.').last,
        });
      } catch (_) {
        // Ignorar erro ao atualizar status
      }
      
      print('Erro ao confirmar transação: $e');
      rethrow;
    }
  }
  
  // Executar a transferência após confirmação
  Future<void> _executeTransaction(TransactionModel txn) async {
    try {
      // Executar transação em modo atômico
      await _firestore.runTransaction((transaction) async {
        // Verificar saldo novamente
        final senderDoc = _firestore.collection('accounts').doc(txn.senderId);
        final senderSnapshot = await transaction.get(senderDoc);
        
        if (!senderSnapshot.exists) {
          throw Exception(errorUsuarioNaoLogado);
        }
        
        final currentBalance = (senderSnapshot.data()!['balance'] as num).toDouble();
        if (currentBalance < txn.amount) {
          throw Exception(errorSaldoInsuficiente);
        }
        
        // Atualizar saldo do remetente (débito)
        transaction.update(senderDoc, {
          'balance': currentBalance - txn.amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Atualizar saldo do destinatário (crédito)
        final receiverDoc = _firestore.collection('accounts').doc(txn.receiverId!);
        final receiverSnapshot = await transaction.get(receiverDoc);
        
        if (!receiverSnapshot.exists) {
          // Criar conta para o destinatário se não existir
          transaction.set(receiverDoc, {
            'balance': txn.amount,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Atualizar saldo existente
          final receiverBalance = (receiverSnapshot.data()!['balance'] as num).toDouble();
          transaction.update(receiverDoc, {
            'balance': receiverBalance + txn.amount,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        
        // Atualizar status da transação para completada
        transaction.update(_firestore.collection('transactions').doc(txn.id), {
          'status': TransactionStatus.completed.toString().split('.').last,
        });
      });
      
      print('Transferência de ${txn.amount} executada com sucesso');
    } catch (e) {
      // Marcar transação como falha
      await _firestore.collection('transactions').doc(txn.id).update({
        'status': TransactionStatus.failed.toString().split('.').last,
      });
      
      print('Erro ao executar transferência: $e');
      rethrow;
    }
  }
  
  // Depósito (simplificado - sem confirmação)
  Future<void> deposit(String userId, double amount) async {
    if (amount <= 0) {
      throw Exception(errorValorInvalido);
    }
    
    // Validação adicional para valores altos
    if (amount > LIMITE_ALERTA) {
      print('ALERTA: Depósito acima do limite de alerta: $amount');
    }
    
    // Verificar duplicidade
    final duplicateKey = '$userId-deposit-$amount';
    if (_isRecentDuplicate(duplicateKey)) {
      throw Exception(errorTransacaoDuplicada);
    }
    
    // Gerar um ID de dispositivo simplificado
    final deviceId = _generateSimpleDeviceId();
    
    // Criar transação
    TransactionModel txn = TransactionModel(
      id: '',
      senderId: userId,
      receiverId: userId,
      amount: amount,
      timestamp: DateTime.now(),
      participants: [userId],
      type: 'deposit',
      status: TransactionStatus.completed, // Depósitos são completados imediatamente
      deviceId: deviceId,
    );
    
    // Gerar token único
    final token = txn.generateToken();
    txn = txn.copyWith(transactionToken: token);
    
    try {
      // Executar transação atômica
      await _firestore.runTransaction((transaction) async {
        // Verificar conta
        final userDoc = _firestore.collection('accounts').doc(userId);
        final userSnapshot = await transaction.get(userDoc);
        
        if (!userSnapshot.exists) {
          // Criar conta se não existir
          transaction.set(userDoc, {
            'balance': amount,
            'email': _firebaseService.currentUser?.email?.toLowerCase(),
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Atualizar saldo
          final currentBalance = (userSnapshot.data()!['balance'] as num).toDouble();
          transaction.update(userDoc, {
            'balance': currentBalance + amount,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        
        // Registrar transação
        final txnRef = _firestore.collection('transactions').doc();
        transaction.set(txnRef, txn.toMap());
      });
      
      // Registrar no cache
      _markTransactionAsProcessed(duplicateKey);
      
      print('Depósito de $amount realizado com sucesso');
    } catch (e) {
      print('Erro ao processar depósito: $e');
      rethrow;
    }
  }
  
  // Gerenciamento de senha de transação
  Future<bool> hasTransactionPassword(String userId) {
    return _firebaseService.hasTransactionPassword(userId);
  }

  Future<void> setTransactionPassword(String userId, String password) {
    return _firebaseService.setTransactionPassword(userId, password);
  }

  Future<bool> validateTransactionPassword(String userId, String password) {
    return _firebaseService.validateTransactionPassword(userId, password);
  }
  
  // Alterar senha de transação
  Future<void> changeTransactionPassword(String userId, String oldPassword, String newPassword) async {
    final isValid = await validateTransactionPassword(userId, oldPassword);
    if (!isValid) {
      throw Exception('Senha atual incorreta');
    }
    await setTransactionPassword(userId, newPassword);
  }
  
  // Verificar transação duplicada
  bool _isRecentDuplicate(String key) {
    if (_recentTransactions.containsKey(key)) {
      final lastProcess = _recentTransactions[key]!;
      return DateTime.now().difference(lastProcess).inSeconds < 30;
    }
    return false;
  }
  
  // Registrar transação processada recentemente
  void _markTransactionAsProcessed(String key) {
    _recentTransactions[key] = DateTime.now();
    // Limpar entradas antigas periodicamente
    _cleanupOldEntries();
  }
  
  // Limpar entradas antigas do cache
  void _cleanupOldEntries() {
    final now = DateTime.now();
    _recentTransactions.removeWhere((key, timestamp) {
      return now.difference(timestamp).inMinutes > 10;
    });
  }
  
  // Gerar um ID de dispositivo simples sem usar device_info_plus
  String _generateSimpleDeviceId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final buffer = StringBuffer();
    
    for (var i = 0; i < 12; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }
    
    return 'yeezybank_${buffer.toString()}_${DateTime.now().millisecondsSinceEpoch}';
  }
  
  // Buscar transações pendentes do usuário
  Stream<List<TransactionModel>> getPendingTransactionsStream(String userId) {
    return _firestore
        .collection('transactions')
        .where('senderId', isEqualTo: userId)
        .where('status', isEqualTo: TransactionStatus.pending.toString().split('.').last)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return TransactionModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }
}