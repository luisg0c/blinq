import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../models/transaction.dart';
import 'account_service.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AccountService _accountService = AccountService();

  // Criar e processar um depósito
  Future<TransactionModel> deposit({
    required String userId,
    required double amount,
    String? description,
  }) async {
    try {
      // Validar valor
      if (amount <= 0) {
        throw Exception('Valor de depósito inválido.');
      }

      if (amount < AppConstants.minDepositAmount) {
        throw Exception(
            'Valor mínimo para depósito: ${AppConstants.minDepositAmount}');
      }

      if (amount > AppConstants.maxDepositAmount) {
        throw Exception(
            'Valor máximo para depósito: ${AppConstants.maxDepositAmount}');
      }

      // Gerar ID único para a transação
      final docRef =
          _firestore.collection(AppConstants.transactionsCollection).doc();

      // Criar transação
      final transaction = TransactionModel(
        id: docRef.id,
        senderId: userId,
        receiverId: userId, // Em depósito, sender e receiver são a mesma pessoa
        amount: amount,
        type: TransactionType.deposit,
        status: TransactionStatus.pending,
        description: description,
      );

      // Buscar a conta do usuário
      final account = await _accountService.getAccount(userId);
      if (account == null) {
        throw Exception('Conta não encontrada.');
      }

      // Executar em lote para atualizar a conta e criar a transação
      final batch = _firestore.batch();

      // Atualizar saldo da conta
      final newBalance = account.balance + amount;
      batch.update(
          _firestore
              .collection(AppConstants.accountsCollection)
              .doc(account.id),
          {
            'balance': newBalance,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Salvar a transação com status completo
      final transactionData = transaction.toMap();
      transactionData['status'] =
          TransactionStatus.completed.toString().split('.').last;
      batch.set(docRef, transactionData);

      // Executar as operações em batch
      await batch.commit();

      // Retornar transação atualizada com status completo
      return TransactionModel(
        id: transaction.id,
        senderId: transaction.senderId,
        receiverId: transaction.receiverId,
        amount: transaction.amount,
        type: transaction.type,
        status: TransactionStatus.completed,
        description: transaction.description,
        timestamp: transaction.timestamp,
      );
    } catch (e) {
      debugPrint('Erro ao processar depósito: $e');
      throw Exception(e.toString());
    }
  }

  // Criar e processar uma transferência
  Future<TransactionModel> transfer({
    required String senderId,
    required String receiverEmail,
    required double amount,
    String? description,
  }) async {
    try {
      // Validar valor
      if (amount <= 0) {
        throw Exception('Valor de transferência inválido.');
      }

      if (amount < AppConstants.minTransferAmount) {
        throw Exception(
            'Valor mínimo para transferência: ${AppConstants.minTransferAmount}');
      }

      if (amount > AppConstants.maxTransferAmount) {
        throw Exception(
            'Valor máximo para transferência: ${AppConstants.maxTransferAmount}');
      }

      // Verificar saldo suficiente
      final senderAccount = await _accountService.getAccount(senderId);
      if (senderAccount == null) {
        throw Exception('Conta de origem não encontrada.');
      }

      if (senderAccount.balance < amount) {
        throw Exception('Saldo insuficiente para realizar esta transferência.');
      }

      // Buscar usuário destinatário pelo email
      final receiverQuery = await _firestore
          .collection(AppConstants.usersCollection)
          .where('email', isEqualTo: receiverEmail)
          .limit(1)
          .get();

      if (receiverQuery.docs.isEmpty) {
        throw Exception('Destinatário não encontrado.');
      }

      final receiverId = receiverQuery.docs.first.id;

      // Verificar se o destinatário tem uma conta
      final receiverAccount = await _accountService.getAccount(receiverId);
      if (receiverAccount == null) {
        throw Exception('Conta de destino não encontrada.');
      }

      // Gerar ID único para a transação
      final docRef =
          _firestore.collection(AppConstants.transactionsCollection).doc();

      // Criar transação
      final transaction = TransactionModel(
        id: docRef.id,
        senderId: senderId,
        receiverId: receiverId,
        amount: amount,
        type: TransactionType.transfer,
        status: TransactionStatus.pending,
        participants: [senderId, receiverId],
        description: description,
      );

      // Executar em batch para atualizar as contas e criar a transação
      final batch = _firestore.batch();

      // Atualizar saldo da conta do remetente
      batch.update(
          _firestore
              .collection(AppConstants.accountsCollection)
              .doc(senderAccount.id),
          {
            'balance': senderAccount.balance - amount,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Atualizar saldo da conta do destinatário
      batch.update(
          _firestore
              .collection(AppConstants.accountsCollection)
              .doc(receiverAccount.id),
          {
            'balance': receiverAccount.balance + amount,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Salvar a transação com status completo
      final transactionData = transaction.toMap();
      transactionData['status'] =
          TransactionStatus.completed.toString().split('.').last;
      batch.set(docRef, transactionData);

      // Executar as operações em batch
      await batch.commit();

      // Retornar transação atualizada com status completo
      return TransactionModel(
        id: transaction.id,
        senderId: transaction.senderId,
        receiverId: transaction.receiverId,
        amount: transaction.amount,
        type: transaction.type,
        status: TransactionStatus.completed,
        participants: transaction.participants,
        description: transaction.description,
        timestamp: transaction.timestamp,
      );
    } catch (e) {
      debugPrint('Erro ao processar transferência: $e');
      throw Exception(e.toString());
    }
  }

  // Verificar limite diário de transferências
  Future<bool> checkDailyTransferLimit(String userId, double newAmount) async {
    try {
      // Obter data de início do dia
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      // Buscar transferências do dia
      final query = await _firestore
          .collection(AppConstants.transactionsCollection)
          .where('senderId', isEqualTo: userId)
          .where('type',
              isEqualTo: TransactionType.transfer.toString().split('.').last)
          .where('status',
              isEqualTo: TransactionStatus.completed.toString().split('.').last)
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();

      // Calcular total já transferido
      double totalTransferred = 0;
      for (final doc in query.docs) {
        totalTransferred += (doc.data()['amount'] as num).toDouble();
      }

      // Verificar se o novo valor excederia o limite
      return (totalTransferred + newAmount) <= AppConstants.dailyTransferLimit;
    } catch (e) {
      debugPrint('Erro ao verificar limite diário: $e');
      return false;
    }
  }

  // Buscar transações recentes
  Future<List<TransactionModel>> getRecentTransactions(
      String userId, int limit) async {
    try {
      final query = await _firestore
          .collection(AppConstants.transactionsCollection)
          .where('participants', arrayContains: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar transações recentes: $e');
      return [];
    }
  }

  // Buscar todas as transações de um usuário
  Future<List<TransactionModel>> getAllTransactions(String userId) async {
    try {
      final query = await _firestore
          .collection(AppConstants.transactionsCollection)
          .where('participants', arrayContains: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return query.docs
          .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar transações: $e');
      return [];
    }
  }

  // Buscar transações por tipo
  Future<List<TransactionModel>> getTransactionsByType(
    String userId,
    TransactionType type,
  ) async {
    try {
      final typeString = type.toString().split('.').last;

      final query = await _firestore
          .collection(AppConstants.transactionsCollection)
          .where('participants', arrayContains: userId)
          .where('type', isEqualTo: typeString)
          .orderBy('timestamp', descending: true)
          .get();

      return query.docs
          .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar transações por tipo: $e');
      return [];
    }
  }

  // Buscar transferências enviadas
  Future<List<TransactionModel>> getSentTransfers(String userId) async {
    try {
      final query = await _firestore
          .collection(AppConstants.transactionsCollection)
          .where('senderId', isEqualTo: userId)
          .where('type',
              isEqualTo: TransactionType.transfer.toString().split('.').last)
          .orderBy('timestamp', descending: true)
          .get();

      return query.docs
          .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar transferências enviadas: $e');
      return [];
    }
  }

  // Buscar transferências recebidas
  Future<List<TransactionModel>> getReceivedTransfers(String userId) async {
    try {
      final query = await _firestore
          .collection(AppConstants.transactionsCollection)
          .where('receiverId', isEqualTo: userId)
          .where('type',
              isEqualTo: TransactionType.transfer.toString().split('.').last)
          .orderBy('timestamp', descending: true)
          .get();

      return query.docs
          .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar transferências recebidas: $e');
      return [];
    }
  }

  // Obter detalhes de uma transação específica
  Future<TransactionModel?> getTransactionById(String transactionId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.transactionsCollection)
          .doc(transactionId)
          .get();

      if (doc.exists) {
        return TransactionModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar detalhes da transação: $e');
      return null;
    }
  }
}
