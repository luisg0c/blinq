import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/transaction.dart' as domain; // ✅ ALIAS PARA EVITAR CONFLITO
import '../../../domain/repositories/transaction_repository.dart';

/// Implementação do repositório de transações usando Firestore.
class TransactionRepositoryImpl implements TransactionRepository {
  final FirebaseFirestore _firestore;

  TransactionRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createTransaction(String userId, domain.Transaction transaction) async {
    try {
      print('📝 Criando transação: ${transaction.id} para $userId');
      
      // ✅ SALVAR NA COLLECTION GLOBAL DE TRANSAÇÕES
      await _firestore
          .collection('transactions')
          .doc(transaction.id)
          .set({
        'userId': userId,
        'amount': transaction.amount,
        'date': Timestamp.fromDate(transaction.date),
        'description': transaction.description,
        'type': transaction.type,
        'counterparty': transaction.counterparty,
        'status': transaction.status,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Transação criada com sucesso: ${transaction.id}');
    } catch (e) {
      print('❌ Erro ao criar transação: $e');
      throw Exception('Erro ao criar transação: $e');
    }
  }

  @override
  Future<List<domain.Transaction>> getTransactionsByUser(String userId) async {
    try {
      print('📋 Buscando todas as transações para $userId');
      
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      final transactions = <domain.Transaction>[];
      
      for (var doc in snapshot.docs) {
        try {
          final transaction = _convertDocToTransaction(doc);
          transactions.add(transaction);
        } catch (e) {
          print('❌ Erro ao converter transação ${doc.id}: $e');
        }
      }
      
      print('📋 ${transactions.length} transações encontradas');
      return transactions;
      
    } catch (e) {
      print('❌ Erro ao buscar transações: $e');
      return [];
    }
  }

  @override
  Future<List<domain.Transaction>> getTransactionsBetween({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      print('📅 Buscando transações entre $start e $end para $userId');
      
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('date', descending: true)
          .get();

      final transactions = <domain.Transaction>[];
      
      for (var doc in snapshot.docs) {
        try {
          final transaction = _convertDocToTransaction(doc);
          transactions.add(transaction);
        } catch (e) {
          print('❌ Erro ao converter transação ${doc.id}: $e');
        }
      }
      
      print('📅 ${transactions.length} transações encontradas no período');
      return transactions;
      
    } catch (e) {
      print('❌ Erro ao buscar transações por período: $e');
      return [];
    }
  }

  @override
  Stream<List<domain.Transaction>> watchTransactionsByUser(String userId) {
    print('👀 Iniciando stream de transações para $userId');
    
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          final transactions = <domain.Transaction>[];
          
          for (var doc in snapshot.docs) {
            try {
              final transaction = _convertDocToTransaction(doc);
              transactions.add(transaction);
            } catch (e) {
              print('❌ Erro ao converter transação ${doc.id}: $e');
            }
          }
          
          print('👀 Stream: ${transactions.length} transações encontradas');
          return transactions;
        })
        .handleError((e) {
          print('❌ Erro no stream das transações: $e');
          return <domain.Transaction>[];
        });
  }

  @override
  Future<List<domain.Transaction>> getRecentTransactions(String userId, {int limit = 10}) async {
    try {
      print('📋 Buscando $limit transações mais recentes para $userId');
      
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      final transactions = <domain.Transaction>[];
      
      for (var doc in snapshot.docs) {
        try {
          final transaction = _convertDocToTransaction(doc);
          transactions.add(transaction);
        } catch (e) {
          print('❌ Erro ao converter transação ${doc.id}: $e');
        }
      }
      
      print('📋 ${transactions.length} transações recentes obtidas');
      return transactions;
      
    } catch (e) {
      print('❌ Erro ao buscar transações recentes: $e');
      return [];
    }
  }

  /// ✅ MÉTODO HELPER PARA CONVERTER DOCUMENTO EM TRANSAÇÃO
  domain.Transaction _convertDocToTransaction(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    
    // Converter Timestamp para DateTime
    final timestamp = data['date'];
    DateTime date;
    
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is String) {
      date = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      date = DateTime.now();
    }
    
    return domain.Transaction(
      id: doc.id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      date: date,
      description: data['description']?.toString() ?? '',
      type: data['type']?.toString() ?? 'unknown',
      counterparty: data['counterparty']?.toString() ?? '',
      status: data['status']?.toString() ?? 'completed',
    );
  }
}