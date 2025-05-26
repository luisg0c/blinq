// lib/data/transaction/repositories/transaction_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/transaction.dart' as domain;
import '../../../domain/repositories/transaction_repository.dart';

/// Implementação segura e funcional do repositório de transações
class TransactionRepositoryImpl implements TransactionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TransactionRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  /// ✅ VERIFICAÇÃO DE SEGURANÇA SIMPLIFICADA
  void _validateUserId(String userId) {
    if (userId.trim().isEmpty) {
      throw Exception('ID do usuário não pode estar vazio');
    }

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Usuário não autenticado');
    }

    if (currentUser.uid != userId) {
      throw Exception('Acesso negado: usuário não autorizado');
    }
  }

  /// ✅ SANITIZAR STRINGS
  String _sanitizeString(dynamic value, [String defaultValue = '']) {
    if (value == null) return defaultValue;
    return value.toString().trim();
  }

  /// ✅ CONVERTER DOCUMENTO COM SEGURANÇA
  domain.Transaction _convertDocToTransaction(QueryDocumentSnapshot<Map<String, dynamic>> doc, String expectedUserId) {
    final data = doc.data();
    
    // Verificar userId
    final docUserId = data['userId']?.toString().trim();
    if (docUserId != expectedUserId) {
      throw Exception('UserId não confere');
    }

    // Converter data
    DateTime transactionDate;
    final timestamp = data['date'];
    
    if (timestamp is Timestamp) {
      transactionDate = timestamp.toDate();
    } else if (timestamp is String) {
      transactionDate = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      transactionDate = DateTime.now();
    }

    // Converter valor
    final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;

    return domain.Transaction(
      id: doc.id,
      amount: amount,
      date: transactionDate,
      description: _sanitizeString(data['description']),
      type: _sanitizeString(data['type']),
      counterparty: _sanitizeString(data['counterparty']),
      status: _sanitizeString(data['status'], 'completed'),
    );
  }

  @override
  Future<void> createTransaction(String userId, domain.Transaction transaction) async {
    try {
      print('📝 Criando transação: ${transaction.id} para $userId');
      
      _validateUserId(userId);

      final transactionData = {
        'userId': userId,
        'amount': transaction.amount,
        'date': Timestamp.fromDate(transaction.date),
        'description': transaction.description,
        'type': transaction.type,
        'counterparty': transaction.counterparty,
        'status': transaction.status,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('transactions')
          .doc(transaction.id)
          .set(transactionData);
      
      print('✅ Transação criada: ${transaction.id}');
    } catch (e) {
      print('❌ Erro ao criar transação: $e');
      rethrow;
    }
  }

  @override
  Future<List<domain.Transaction>> getTransactionsByUser(String userId) async {
    try {
      print('📋 Buscando transações para $userId');
      
      _validateUserId(userId);

      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      final transactions = <domain.Transaction>[];
      
      for (var doc in snapshot.docs) {
        try {
          final transaction = _convertDocToTransaction(doc, userId);
          transactions.add(transaction);
        } catch (e) {
          print('⚠️ Documento ${doc.id} ignorado: $e');
        }
      }
      
      print('✅ ${transactions.length} transações encontradas para $userId');
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
      
      _validateUserId(userId);

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
          final transaction = _convertDocToTransaction(doc, userId);
          transactions.add(transaction);
        } catch (e) {
          print('⚠️ Documento ${doc.id} ignorado: $e');
        }
      }
      
      print('✅ ${transactions.length} transações no período para $userId');
      return transactions;
      
    } catch (e) {
      print('❌ Erro ao buscar transações por período: $e');
      return [];
    }
  }

  @override
  Stream<List<domain.Transaction>> watchTransactionsByUser(String userId) {
    print('👀 Iniciando stream para $userId');
    
    try {
      _validateUserId(userId);

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
                final transaction = _convertDocToTransaction(doc, userId);
                transactions.add(transaction);
              } catch (e) {
                print('⚠️ Stream: Documento ${doc.id} ignorado: $e');
              }
            }
            
            print('👀 Stream: ${transactions.length} transações para $userId');
            return transactions;
          })
          .handleError((error) {
            print('❌ Erro no stream: $error');
            return <domain.Transaction>[];
          });
          
    } catch (e) {
      print('❌ Erro ao configurar stream: $e');
      return Stream.value(<domain.Transaction>[]);
    }
  }

  @override
  Future<List<domain.Transaction>> getRecentTransactions(String userId, {int limit = 10}) async {
    try {
      print('📋 Buscando $limit transações recentes para $userId');
      
      _validateUserId(userId);

      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      final transactions = <domain.Transaction>[];
      
      for (var doc in snapshot.docs) {
        try {
          final transaction = _convertDocToTransaction(doc, userId);
          transactions.add(transaction);
        } catch (e) {
          print('⚠️ Documento ${doc.id} ignorado: $e');
        }
      }
      
      print('✅ ${transactions.length} transações recentes para $userId');
      return transactions;
      
    } catch (e) {
      print('❌ Erro ao buscar transações recentes: $e');
      return [];
    }
  }
}