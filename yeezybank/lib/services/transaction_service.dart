import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Busca saldo do usuário
  Future<double> getUserBalance(String userId) async {
    final doc = await _firestore.collection('accounts').doc(userId).get();
    if (doc.exists && doc.data()!.containsKey('balance')) {
      return (doc['balance'] as num).toDouble();
    } else {
      await _firestore.collection('accounts').doc(userId).set({'balance': 0.0});
      return 0.0;
    }
  }

  /// Deposita valor + salva no histórico
  Future<void> deposit(String userId, double amount) async {
    final ref = _firestore.collection('accounts').doc(userId);
    final doc = await ref.get();

    if (!doc.exists) {
      await ref.set({'balance': amount});
    } else {
      double current = (doc['balance'] as num).toDouble();
      await ref.update({'balance': current + amount});
    }

    // Salva transação (tipo depósito)
    final txn = TransactionModel(
      id: '',
      senderId: userId,
      receiverId: userId,
      amount: amount,
      timestamp: DateTime.now(),
    );
    await _firestore.collection('transactions').add(txn.toMap());
  }

  /// Transfere valor entre contas + salva no histórico
  Future<void> sendTransaction(TransactionModel txn, String receiverEmail) async {
    final receiverSnapshot = await _firestore
        .collection('accounts')
        .where('email', isEqualTo: receiverEmail)
        .get();

    if (receiverSnapshot.docs.isEmpty) {
      throw Exception('Destinatário não encontrado');
    }

    final receiverDoc = receiverSnapshot.docs.first;
    final receiverId = receiverDoc.id;
    final receiverBalance = (receiverDoc['balance'] as num).toDouble();

    final senderRef = _firestore.collection('accounts').doc(txn.senderId);
    final senderDoc = await senderRef.get();
    final senderBalance = (senderDoc['balance'] as num).toDouble();

    if (senderBalance < txn.amount) {
      throw Exception('Saldo insuficiente');
    }

    // Atualiza saldos
    await senderRef.update({'balance': senderBalance - txn.amount});
    await _firestore.collection('accounts').doc(receiverId).update({'balance': receiverBalance + txn.amount});

    // Salva transação
    final newTxn = txn.copyWith(receiverId: receiverId, timestamp: DateTime.now());
    await _firestore.collection('transactions').add(newTxn.toMap());
  }

  /// Busca histórico de transações do usuário
  Future<List<TransactionModel>> getUserTransactions(String userId) async {
    final snapshot = await _firestore
        .collection('transactions')
        .where('participants', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return TransactionModel.fromMap(data, doc.id);
    }).toList();
  }

  /// =====================
  /// 🔐 SENHA TRANSACIONAL
  /// =====================

  /// Verifica se o usuário tem senha cadastrada
  Future<bool> hasTransactionPassword(String userId) async {
    final doc = await _firestore.collection('accounts').doc(userId).get();
    return doc.exists && doc.data()!.containsKey('txnPassword');
  }

  /// Cadastra senha
  Future<void> setTransactionPassword(String userId, String password) async {
    await _firestore.collection('accounts').doc(userId).set(
      {'txnPassword': password},
      SetOptions(merge: true),
    );
  }

  /// Valida senha
  Future<bool> validateTransactionPassword(String userId, String password) async {
    final doc = await _firestore.collection('accounts').doc(userId).get();
    if (doc.exists && doc.data()!.containsKey('txnPassword')) {
      return doc['txnPassword'] == password;
    }
    return false;
  }
}
