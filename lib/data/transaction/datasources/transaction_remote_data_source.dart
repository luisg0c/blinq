// blinq/lib/data/transaction/datasources/transaction_remote_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/transaction.dart' as domain;
import '../models/transaction_model.dart';

/// Contrato para operações de transação no Firebase.
abstract class TransactionRemoteDataSource {
  Future<void> addTransaction(String userId, TransactionModel transaction);
  Future<List<domain.Transaction>> getTransactionsByUser(String userId);
  Future<List<domain.Transaction>> getTransactionsBetween({
    required String userId,
    required DateTime start,
    required DateTime end,
  });
  Stream<List<domain.Transaction>> watchTransactionsByUser(String userId);
}

/// Implementação usando Firestore com estrutura corrigida.
class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final FirebaseFirestore _firestore;

  TransactionRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> addTransaction(String userId, TransactionModel transaction) async {
    try {
      print('📝 Adicionando transação: ${transaction.id} para $userId');
      print('   Tipo: ${transaction.type}');
      print('   Valor: R\$ ${transaction.amount}');
      print('   Descrição: ${transaction.description}');
      
      await _firestore
          .collection('accounts')
          .doc(userId)
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toFirestore());
      
      print('✅ Transação adicionada com sucesso');
    } catch (e) {
      print('❌ Erro ao adicionar transação: $e');
      throw Exception('Erro ao adicionar transação: $e');
    }
  }

  @override
  Future<List<domain.Transaction>> getTransactionsByUser(String userId) async {
    try {
      print('📋 Buscando transações para $userId');
      
      final snapshot = await _firestore
          .collection('accounts')
          .doc(userId)
          .collection('transactions')
          .orderBy('date', descending: true)
          .get();

      final transactions = snapshot.docs
          .map((doc) {
            try {
              return TransactionModel.fromFirestore(doc.id, doc.data());
            } catch (e) {
              print('❌ Erro ao converter transação ${doc.id}: $e');
              return null;
            }
          })
          .where((tx) => tx != null)
          .cast<domain.Transaction>()
          .toList();
      
      print('📋 ${transactions.length} transações encontradas');
      return transactions;
    } catch (e) {
      print('❌ Erro ao buscar transações: $e');
      throw Exception('Erro ao buscar transações: $e');
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
          .collection('accounts')
          .doc(userId)
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('date', descending: true)
          .get();

      final transactions = snapshot.docs
          .map((doc) {
            try {
              return TransactionModel.fromFirestore(doc.id, doc.data());
            } catch (e) {
              print('❌ Erro ao converter transação ${doc.id}: $e');
              return null;
            }
          })
          .where((tx) => tx != null)
          .cast<domain.Transaction>()
          .toList();
      
      print('📅 ${transactions.length} transações encontradas no período');
      return transactions;
    } catch (e) {
      print('❌ Erro ao buscar transações por período: $e');
      throw Exception('Erro ao buscar transações por período: $e');
    }
  }

  @override
  Stream<List<domain.Transaction>> watchTransactionsByUser(String userId) {
    print('👀 Iniciando watch das transações para $userId');
    
    return _firestore
        .collection('accounts')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          final transactions = snapshot.docs
              .map((doc) {
                try {
                  return TransactionModel.fromFirestore(doc.id, doc.data());
                } catch (e) {
                  print('❌ Erro ao converter transação ${doc.id}: $e');
                  return null;
                }
              })
              .where((tx) => tx != null)
              .cast<domain.Transaction>()
              .toList();
          
          print('👀 Stream transações: ${transactions.length} encontradas');
          
          // Log das primeiras transações para debug
          for (var tx in transactions.take(3)) {
            print('  📄 ${tx.type}: R\$ ${tx.amount} - ${tx.description}');
          }
          
          return transactions;
        })
        .handleError((e) {
          print('❌ Erro no stream das transações: $e');
          throw Exception('Erro ao monitorar transações: $e');
        });
  }
}