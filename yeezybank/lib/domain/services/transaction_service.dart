import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String errorSaldoInsuficiente = 'Saldo insuficiente';
  static const String errorDestinatarioNaoEncontrado =
      'Destinatário não encontrado';
  static const String errorValorInvalido = 'Valor inválido';

  Future<double> getUserBalance(String userId) async {
    final doc = await _firestore.collection('accounts').doc(userId).get();
    if (doc.exists && doc.data()!.containsKey('balance')) {
      return (doc['balance'] as num).toDouble();
    } else {
      await _firestore.collection('accounts').doc(userId).set({'balance': 0.0});
      return 0.0;
    }
  }

  Stream<List<TransactionModel>> getUserTransactionsStream(String userId) {
    return _firestore
        .collection('transactions')
        .where('participants', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return TransactionModel.fromMap(data, doc.id);
          }).toList();
        });
  }

  Future<void> deposit(String userId, double amount) async {
    if (amount <= 0) {
      throw Exception(errorValorInvalido);
    }

    final ref = _firestore.collection('accounts').doc(userId);
    final doc = await ref.get();

    if (!doc.exists) {
      await ref.set({'balance': amount});
      print('Conta criada para $userId com saldo: $amount');
    } else {
      final currentBalance = (doc['balance'] as num).toDouble();
      await ref.update({'balance': currentBalance + amount});
      print(
        'Depósito de $amount realizado. Novo saldo: ${currentBalance + amount}',
      );
    }

    final txn = TransactionModel(
      id: '',
      senderId: userId,
      receiverId: userId,
      amount: amount,
      timestamp: DateTime.now(),
      participants: [userId],
      type: 'deposit', // Adicionado
    );

    await _firestore.collection('transactions').add(txn.toMap());
    print('Transação de depósito registrada: $txn');
  }

  Future<void> sendTransaction(
    TransactionModel txn,
    String receiverEmail,
  ) async {
    if (txn.amount <= 0) {
      throw Exception(errorValorInvalido);
    }

    final receiverSnapshot =
        await _firestore
            .collection('accounts')
            .where('email', isEqualTo: receiverEmail)
            .limit(1)
            .get();

    if (receiverSnapshot.docs.isEmpty) {
      throw Exception(errorDestinatarioNaoEncontrado);
    }

    final receiverDoc = receiverSnapshot.docs.first;
    final receiverId = receiverDoc.id;
    final receiverBalance = (receiverDoc['balance'] as num).toDouble();

    if (receiverId == txn.senderId) {
      throw Exception('Não é possível transferir para você mesmo');
    }

    final senderRef = _firestore.collection('accounts').doc(txn.senderId);
    final senderDoc = await senderRef.get();
    final senderBalance = (senderDoc['balance'] as num).toDouble();

    if (senderBalance < txn.amount) {
      throw Exception(errorSaldoInsuficiente);
    }

    await senderRef.update({'balance': senderBalance - txn.amount});
    await _firestore.collection('accounts').doc(receiverId).update({
      'balance': receiverBalance + txn.amount,
    });

    final newTxn = txn.copyWith(
      receiverId: receiverId,
      timestamp: DateTime.now(),
      participants: [txn.senderId, receiverId],
      type: 'transfer', // Adicionado
    );

    await _firestore.collection('transactions').add(newTxn.toMap());
    print(
      'Transferência de ${txn.amount} de ${txn.senderId} para $receiverId concluída.',
    );
  }

  // Senha de transação...
  Future<bool> hasTransactionPassword(String userId) async {
    final doc = await _firestore.collection('accounts').doc(userId).get();
    return doc.exists && doc.data()!.containsKey('txnPassword');
  }

  Future<void> setTransactionPassword(String userId, String password) async {
    await _firestore.collection('accounts').doc(userId).set({
      'txnPassword': password,
    }, SetOptions(merge: true));
  }

  Future<bool> validateTransactionPassword(
    String userId,
    String password,
  ) async {
    final doc = await _firestore.collection('accounts').doc(userId).get();
    if (doc.exists && doc.data()!.containsKey('txnPassword')) {
      return doc['txnPassword'] == password;
    }
    return false;
  }
}
