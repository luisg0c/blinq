// lib/data/repositories/transaction_repository.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/transaction_model.dart';
import '../firebase_service.dart';

class TransactionRepository extends GetxService {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Adicionar transação
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    try {
      final docRef = await _firestore
          .collection('transactions')
          .add(transaction.toMap());

      // Retornar com o ID atualizado
      return transaction.copyWith(id: docRef.id);
    } catch (e) {
      print('Erro ao adicionar transação: $e');
      rethrow;
    }
  }

  // Obter transação por ID
  Future<TransactionModel?> getTransaction(String transactionId) async {
    try {
      final doc =
          await _firestore.collection('transactions').doc(transactionId).get();

      if (!doc.exists || doc.data() == null) return null;

      return TransactionModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('Erro ao buscar transação: $e');
      return null;
    }
  }

  // Atualizar status da transação
  Future<void> updateTransactionStatus(
    String transactionId,
    TransactionStatus status, {
    bool confirmed = false,
  }) async {
    try {
      final updates = {'status': status.toString().split('.').last};

      if (confirmed) {
        updates['confirmedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore
          .collection('transactions')
          .doc(transactionId)
          .update(updates);
    } catch (e) {
      print('Erro ao atualizar status da transação: $e');
      rethrow;
    }
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
          // Criar conta para o destinatário com valor default
          transaction.set(receiverDoc, {
            'balance': txn.amount,
            'email':
                await _getReceiverEmail(txn.receiverId) ?? 'email_not_found',
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
      // Marcar transação como falha se tiver ID
      if (txn.id.isNotEmpty) {
        try {
          await _firestore.collection('transactions').doc(txn.id).update({
            'status': TransactionStatus.failed.toString().split('.').last,
          });
        } catch (updateError) {
          print('Erro ao marcar transação como falha: $updateError');
        }
      }

      print('Erro ao executar transferência: $e');
      rethrow;
    }
  }

  // Obter email do destinatário - método simplificado para evitar dependência de getUserByUid
  Future<String?> _getReceiverEmail(String userId) async {
    try {
      // Tentamos buscar a conta no Firestore primeiro
      final accountDoc =
          await _firestore.collection('accounts').doc(userId).get();
      if (accountDoc.exists &&
          accountDoc.data() != null &&
          accountDoc.data()!.containsKey('email')) {
        return accountDoc.data()!['email'] as String?;
      }

      // Se não encontrou, verificamos se é o usuário atual
      if (_firebaseService.currentUser?.uid == userId) {
        return _firebaseService.currentUser?.email;
      }

      return null;
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
          final email =
              _firebaseService.currentUser?.email?.toLowerCase() ?? '';
          transaction.set(userDoc, {
            'balance': txn.amount,
            'email': email,
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
        final Map<String, dynamic> txnData = txn.toMap();

        if (txn.id.isEmpty) {
          // Se não tem ID, criar novo documento
          final txnRef = _firestore.collection('transactions').doc();
          transaction.set(txnRef, {
            ...txnData,
            'status': TransactionStatus.completed.toString().split('.').last,
          });
        } else {
          // Se já tem ID, atualizar
          transaction.set(_firestore.collection('transactions').doc(txn.id), {
            ...txnData,
            'status': TransactionStatus.completed.toString().split('.').last,
          });
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
    try {
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
          final data = doc.data();
          return TransactionModel.fromMap(data, doc.id);
        }).toList();
      });
    } catch (e) {
      print('Erro ao obter stream de transações: $e');
      // Retornar stream vazio em caso de erro
      return Stream.value([]);
    }
  }

  // Stream de transações pendentes
  Stream<List<TransactionModel>> getPendingTransactionsStream(String userId) {
    try {
      final pendingStatus =
          TransactionStatus.pending.toString().split('.').last;

      return _firestore
          .collection('transactions')
          .where('senderId', isEqualTo: userId)
          .where('status', isEqualTo: pendingStatus)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return TransactionModel.fromMap(doc.data(), doc.id);
            }).toList();
          });
    } catch (e) {
      print('Erro ao obter transações pendentes: $e');
      return Stream.value([]);
    }
  }

  // Obter transações por período
  Future<List<TransactionModel>> getTransactionsByPeriod(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
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
    } catch (e) {
      print('Erro ao obter transações por período: $e');
      return [];
    }
  }
}
