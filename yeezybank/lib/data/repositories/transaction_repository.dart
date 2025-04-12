import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../domain/models/transaction_model.dart';
import '../firebase_service.dart';

class TransactionRepository extends GetxService {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Referências de coleções para evitar strings duplicadas
  CollectionReference get _transactionsCollection =>
      _firestore.collection('transactions');
  CollectionReference get _accountsCollection =>
      _firestore.collection('accounts');

  // MARK: - Métodos públicos

  /// Adiciona uma nova transação no Firestore
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    try {
      final docRef = await _transactionsCollection.add(transaction.toMap());
      return transaction.copyWith(id: docRef.id);
    } catch (e) {
      _logError('adicionar transação', e);
      rethrow;
    }
  }

  /// Busca uma transação específica pelo ID
  Future<TransactionModel?> getTransaction(String transactionId) async {
    try {
      final doc = await _transactionsCollection.doc(transactionId).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>? ?? {};
      return TransactionModel.fromMap(data, doc.id);
    } catch (e) {
      _logError('buscar transação', e);
      return null;
    }
  }

  /// Atualiza o status de uma transação existente
  Future<void> updateTransactionStatus(
    String transactionId,
    TransactionStatus status, {
    bool confirmed = false,
  }) async {
    try {
      final Map<String, dynamic> updates = {'status': _getStatusString(status)};

      if (confirmed) {
        updates['confirmedAt'] = FieldValue.serverTimestamp();
      }

      await _transactionsCollection.doc(transactionId).update(updates);
    } catch (e) {
      _logError('atualizar status da transação', e);
      rethrow;
    }
  }

  /// Processa uma transação de transferência entre contas
  Future<void> processTransaction(TransactionModel txn) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Verificação e atualização da conta do remetente
        final senderDoc = _accountsCollection.doc(txn.senderId);
        final senderSnapshot = await transaction.get(senderDoc);

        _validateSenderAccount(senderSnapshot);
        final senderData = senderSnapshot.data() as Map<String, dynamic>? ?? {};
        final currentBalance = _getBalanceFromData(senderData);

        // Valida se há saldo suficiente
        if (currentBalance < txn.amount) {
          throw Exception('Saldo insuficiente');
        }

        // Atualiza o saldo do remetente
        transaction.update(senderDoc, {
          'balance': currentBalance - txn.amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Atualiza a conta do destinatário
        await _updateReceiverAccount(transaction, txn);

        // Atualiza o status da transação
        if (txn.id.isNotEmpty) {
          transaction.update(_transactionsCollection.doc(txn.id), {
            'status': _getStatusString(TransactionStatus.completed),
          });
        }
      });

      print('Transferência de ${txn.amount} executada com sucesso');
    } catch (e) {
      await _handleTransactionFailure(txn, e);
      rethrow;
    }
  }

  /// Processa um depósito na conta do usuário
  Future<void> processDeposit(TransactionModel txn) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userDoc = _accountsCollection.doc(txn.senderId);
        final userSnapshot = await transaction.get(userDoc);

        if (!userSnapshot.exists) {
          // Criar conta se não existir
          _createNewAccount(transaction, userDoc, txn.amount);
        } else {
          // Atualizar saldo existente
          _updateExistingAccount(transaction, userSnapshot, txn.amount);
        }

        // Registrar a transação
        await _registerCompletedTransaction(transaction, txn);
      });

      print('Depósito de ${txn.amount} realizado com sucesso');
    } catch (e) {
      _logError('processar depósito', e);
      rethrow;
    }
  }

  /// Obtém um stream de transações do usuário
  Stream<List<TransactionModel>> getUserTransactionsStream(
    String userId, {
    int limit = 20,
    DocumentSnapshot? startAfterDoc,
  }) {
    try {
      Query query = _transactionsCollection
          .where('participants', arrayContains: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (startAfterDoc != null) {
        query = query.startAfterDocument(startAfterDoc);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
          return TransactionModel.fromMap(data, doc.id);
        }).toList();
      });
    } catch (e) {
      _logError('obter stream de transações', e);
      return Stream.value([]);
    }
  }

  /// Obtém as transações pendentes do usuário
  Stream<List<TransactionModel>> getPendingTransactionsStream(String userId) {
    try {
      final pendingStatus = _getStatusString(TransactionStatus.pending);

      return _transactionsCollection
          .where('senderId', isEqualTo: userId)
          .where('status', isEqualTo: pendingStatus)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              Map<String, dynamic> data =
                  doc.data() as Map<String, dynamic>? ?? {};
              return TransactionModel.fromMap(data, doc.id);
            }).toList();
          });
    } catch (e) {
      _logError('obter transações pendentes', e);
      return Stream.value([]);
    }
  }

  /// Obtém transações em um período específico
  Future<List<TransactionModel>> getTransactionsByPeriod(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      Query query = _transactionsCollection
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
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
        return TransactionModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      _logError('obter transações por período', e);
      return [];
    }
  }

  // MARK: - Métodos privados de suporte

  /// Obtém a representação string de um status de transação
  String _getStatusString(TransactionStatus status) {
    return status.toString().split('.').last;
  }

  /// Valida se a conta do remetente é válida para a transação
  void _validateSenderAccount(DocumentSnapshot senderSnapshot) {
    if (!senderSnapshot.exists) {
      throw Exception('Usuário não logado');
    }

    final senderData = senderSnapshot.data() as Map<String, dynamic>? ?? {};
    if (!senderData.containsKey('balance')) {
      throw Exception('Conta sem saldo definido');
    }
  }

  /// Obtém o saldo atual do usuário a partir dos dados da conta
  double _getBalanceFromData(Map<String, dynamic> data) {
    return data.containsKey('balance')
        ? (data['balance'] as num).toDouble()
        : 0.0;
  }

  /// Atualiza a conta do destinatário durante uma transferência
  Future<void> _updateReceiverAccount(
    Transaction transaction,
    TransactionModel txn,
  ) async {
    final receiverDoc = _accountsCollection.doc(txn.receiverId);
    final receiverSnapshot = await transaction.get(receiverDoc);

    if (!receiverSnapshot.exists) {
      // Criar conta para o destinatário
      String receiverEmail = await _getReceiverEmail(txn.receiverId);

      transaction.set(receiverDoc, {
        'balance': txn.amount,
        'email': receiverEmail,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Atualizar saldo existente
      final receiverData =
          receiverSnapshot.data() as Map<String, dynamic>? ?? {};
      final receiverBalance = _getBalanceFromData(receiverData);

      transaction.update(receiverDoc, {
        'balance': receiverBalance + txn.amount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Busca o email do destinatário
  Future<String> _getReceiverEmail(String receiverId) async {
    String defaultEmail = 'usuario@exemplo.com';

    try {
      final accountDoc = await _accountsCollection.doc(receiverId).get();
      final accountData = accountDoc.data() as Map<String, dynamic>? ?? {};

      if (accountDoc.exists && accountData.containsKey('email')) {
        return accountData['email'] as String;
      } else if (_firebaseService.currentUser?.uid == receiverId) {
        return _firebaseService.currentUser?.email ?? defaultEmail;
      }
    } catch (e) {
      _logError('buscar email do destinatário', e);
    }

    return defaultEmail;
  }

  /// Trata falha na transação
  Future<void> _handleTransactionFailure(
    TransactionModel txn,
    dynamic error,
  ) async {
    if (txn.id.isNotEmpty) {
      try {
        await _transactionsCollection.doc(txn.id).update({
          'status': _getStatusString(TransactionStatus.failed),
        });
      } catch (updateError) {
        _logError('marcar transação como falha', updateError);
      }
    }

    _logError('executar transferência', error);
  }

  /// Cria uma nova conta para o usuário durante depósito
  void _createNewAccount(
    Transaction transaction,
    DocumentReference userDoc,
    double amount,
  ) {
    String email =
        _firebaseService.currentUser?.email?.toLowerCase() ??
        'usuario@exemplo.com';

    transaction.set(userDoc, {
      'balance': amount,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Atualiza uma conta existente durante depósito
  void _updateExistingAccount(
    Transaction transaction,
    DocumentSnapshot userSnapshot,
    double amount,
  ) {
    final userData = userSnapshot.data() as Map<String, dynamic>? ?? {};
    final currentBalance = _getBalanceFromData(userData);

    transaction.update(userSnapshot.reference, {
      'balance': currentBalance + amount,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Registra uma transação completa
  Future<void> _registerCompletedTransaction(
    Transaction transaction,
    TransactionModel txn,
  ) async {
    final Map<String, dynamic> txnData = Map<String, dynamic>.from(txn.toMap());
    txnData['status'] = _getStatusString(TransactionStatus.completed);

    if (txn.id.isEmpty) {
      // Se não tem ID, criar novo documento
      final txnRef = _transactionsCollection.doc();
      transaction.set(txnRef, txnData);
    } else {
      // Se já tem ID, atualizar
      transaction.set(_transactionsCollection.doc(txn.id), txnData);
    }
  }

  /// Registra erros no console de forma padronizada
  void _logError(String operacao, dynamic erro) {
    print('Erro ao $operacao: $erro');
  }
}
