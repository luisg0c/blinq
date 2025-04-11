// lib/data/repositories/transaction_repository.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/firebase_service.dart';

class TransactionRepository extends GetxService {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Adicionar transação
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    final docRef = await _firestore
        .collection('transactions')
        .add(transaction.toMap());
    return transaction.copyWith(id: docRef.id);
  }

  // Obter transação por ID
  Future<TransactionModel?> getTransaction(String transactionId) async {
    final doc =
        await _firestore.collection('transactions').doc(transactionId).get();
    if (!doc.exists) return null;
    return TransactionModel.fromMap(doc.data()!, doc.id);
  }

  // Atualizar status da transação
  Future<void> updateTransactionStatus(
    String transactionId,
    TransactionStatus status, {
    bool confirmed = false,
  }) async {
    final updates = {'status': status.toString().split('.').last};

    if (confirmed) {
      updates['confirmedAt'] = FieldValue.serverTimestamp();
    }

    await _firestore
        .collection('transactions')
        .doc(transactionId)
        .update(updates);
  }

  // Processar transação (transferência)
  Future<void> processTransaction(TransactionModel txn) async {
    try {
      // Executar transação em modo atômico
      await _firestore.runTransaction((transaction) async {
        // Verificar saldo do remetente
        final senderDoc = _firestore.collection('accounts').doc(txn.senderId);
        final senderSnapshot = await transaction.get(senderDoc);

        if (!senderSnapshot.exists) {
          throw Exception('Usuário não logado');
        }

        final currentBalance =
            (senderSnapshot.data()!['balance'] as num).toDouble();
        if (currentBalance < txn.amount) {
          throw Exception('Saldo insuficiente');
        }

        // Atualizar saldo do remetente (débito)
        transaction.update(senderDoc, {
          'balance': currentBalance - txn.amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Atualizar saldo do destinatário (crédito)
        final receiverDoc = _firestore
            .collection('accounts')
            .doc(txn.receiverId);
        final receiverSnapshot = await transaction.get(receiverDoc);

        if (!receiverSnapshot.exists) {
          // Criar conta para o destinatário se não existir
          final receiverEmail = await _getReceiverEmail(txn.receiverId);
          transaction.set(receiverDoc, {
            'balance': txn.amount,
            'email': receiverEmail,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Atualizar saldo existente
          final receiverBalance =
              (receiverSnapshot.data()!['balance'] as num).toDouble();
          transaction.update(receiverDoc, {
            'balance': receiverBalance + txn.amount,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        // Atualizar status da transação para completada
        if (txn.id.isNotEmpty) {
          transaction.update(
            _firestore.collection('transactions').doc(txn.id),
            {'status': TransactionStatus.completed.toString().split('.').last},
          );
        }
      });

      print('Transferência de ${txn.amount} executada com sucesso');
    } catch (e) {
      // Marcar transação como falha
      if (txn.id.isNotEmpty) {
        await _firestore.collection('transactions').doc(txn.id).update({
          'status': TransactionStatus.failed.toString().split('.').last,
        });
      }

      print('Erro ao executar transferência: $e');
      rethrow;
    }
  }

  // Obter email do destinatário
  Future<String?> _getReceiverEmail(String userId) async {
    try {
      final userAuth = await _firebaseService.getAuth().getUserByUid(userId);
      return userAuth?.email;
    } catch (e) {
      print('Erro ao obter email do destinatário: $e');
      return null;
    }
  }

  // Processar depósito
  Future<void> processDeposit(TransactionModel txn) async {
    try {
      // Executar transação atômica
      await _firestore.runTransaction((transaction) async {
        // Verificar conta
        final userDoc = _firestore.collection('accounts').doc(txn.senderId);
        final userSnapshot = await transaction.get(userDoc);

        if (!userSnapshot.exists) {
          // Criar conta se não existir
          transaction.set(userDoc, {
            'balance': txn.amount,
            'email': _firebaseService.currentUser?.email?.toLowerCase(),
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Atualizar saldo
          final currentBalance =
              (userSnapshot.data()!['balance'] as num).toDouble();
          transaction.update(userDoc, {
            'balance': currentBalance + txn.amount,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        // Registrar transação
        if (txn.id.isEmpty) {
          // Se não tem ID, criar novo documento
          final txnRef = _firestore.collection('transactions').doc();
          transaction.set(txnRef, {...txn.toMap(), 'id': txnRef.id});
        } else {
          // Se já tem ID, atualizar
          transaction.set(
            _firestore.collection('transactions').doc(txn.id),
            txn.toMap(),
          );
        }
      });

      print('Depósito de ${txn.amount} realizado com sucesso');
    } catch (e) {
      print('Erro ao processar depósito: $e');
      rethrow;
    }
  }

  // Stream de transações do usuário
  Stream<List<TransactionModel>> getUserTransactionsStream(
    String userId, {
    int limit = 20,
    DocumentSnapshot? startAfterDoc,
  }) {
    Query query = _firestore
        .collection('transactions')
        .where('participants', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (startAfterDoc != null) {
      query = query.startAfterDocument(startAfterDoc);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TransactionModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Stream de transações pendentes
  Stream<List<TransactionModel>> getPendingTransactionsStream(String userId) {
    return _firestore
        .collection('transactions')
        .where('senderId', isEqualTo: userId)
        .where(
          'status',
          isEqualTo: TransactionStatus.pending.toString().split('.').last,
        )
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return TransactionModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Obter transações por período
  Future<List<TransactionModel>> getTransactionsByPeriod(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    Query query = _firestore
        .collection('transactions')
        .where('participants', arrayContains: userId)
        .orderBy('timestamp', descending: true);

    if (startDate != null) {
      query = query.where(
        'timestamp',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }

    if (endDate != null) {
      query = query.where(
        'timestamp',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    query = query.limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
