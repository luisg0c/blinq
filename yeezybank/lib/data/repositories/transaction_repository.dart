// lib/data/repositories/transaction_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
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
      if (!doc.exists) return null;

      // Verificamos se os dados existem e fornecemos um mapa vazio se não existirem
      final data = doc.data() ?? {};
      return TransactionModel.fromMap(data, doc.id);
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
      final Map<String, dynamic> updates = {
        'status': status.toString().split('.').last,
      };

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

        // Se os dados não existirem, fornecemos um mapa vazio
        final senderData = senderSnapshot.data() ?? {};
        if (!senderData.containsKey('balance')) {
          throw Exception('Conta sem saldo definido');
        }

        final currentBalance = (senderData['balance'] as num).toDouble();

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
          // Obter email do destinatário de forma segura
          String receiverEmail = 'usuario@exemplo.com';

          try {
            final accountDoc =
                await _firestore
                    .collection('accounts')
                    .doc(txn.receiverId)
                    .get();
            final accountData = accountDoc.data() ?? {};
            if (accountDoc.exists && accountData.containsKey('email')) {
              receiverEmail = accountData['email'] as String;
            } else if (_firebaseService.currentUser?.uid == txn.receiverId) {
              receiverEmail =
                  _firebaseService.currentUser?.email ?? receiverEmail;
            }
          } catch (e) {
            print('Erro ao buscar email do destinatário: $e');
          }

          // Criar conta para o destinatário se não existir
          transaction.set(receiverDoc, {
            'balance': txn.amount,
            'email': receiverEmail,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Atualizar saldo existente
          final receiverData = receiverSnapshot.data() ?? {};
          final receiverBalance =
              receiverData.containsKey('balance')
                  ? (receiverData['balance'] as num).toDouble()
                  : 0.0;

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
          String email =
              _firebaseService.currentUser?.email?.toLowerCase() ??
              'usuario@exemplo.com';

          transaction.set(userDoc, {
            'balance': txn.amount,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Atualizar saldo
          final userData = userSnapshot.data() ?? {};
          final currentBalance =
              userData.containsKey('balance')
                  ? (userData['balance'] as num).toDouble()
                  : 0.0;

          transaction.update(userDoc, {
            'balance': currentBalance + txn.amount,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        // Registrar transação
        // Criamos uma cópia segura do mapa
        final Map<String, dynamic> txnData = Map<String, dynamic>.from(
          txn.toMap(),
        );
        txnData['status'] =
            TransactionStatus.completed.toString().split('.').last;

        if (txn.id.isEmpty) {
          // Se não tem ID, criar novo documento
          final txnRef = _firestore.collection('transactions').doc();
          transaction.set(txnRef, txnData);
        } else {
          // Se já tem ID, atualizar
          transaction.set(
            _firestore.collection('transactions').doc(txn.id),
            txnData,
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
          // Usamos um mapa vazio como fallback se os dados forem nulos
          Map<String, dynamic> data = doc.data() ?? {};
          return TransactionModel.fromMap(data, doc.id);
        }).toList();
      });
    } catch (e) {
      print('Erro ao obter stream de transações: $e');
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
              // Usamos um mapa vazio como fallback
              Map<String, dynamic> data = doc.data() ?? {};
              return TransactionModel.fromMap(data, doc.id);
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
      return snapshot.docs.map((doc) {
        // Fornecemos um mapa vazio se os dados forem nulos
        Map<String, dynamic> data = doc.data() ?? {};
        return TransactionModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print('Erro ao obter transações por período: $e');
      return [];
    }
  }
}
