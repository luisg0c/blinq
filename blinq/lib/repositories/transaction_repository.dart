import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../services/auth_service.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Criar transação com validações
  Future<TransactionModel?> createTransaction(
      TransactionModel transaction) async {
    try {
      // Validar usuário autenticado
      final currentUser = _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      // Verificar se o usuário tem permissão para realizar a transação
      if (transaction.senderId != currentUser.id) {
        throw Exception('Usuário não autorizado a realizar esta transação');
      }

      // Referência para a coleção de transações
      final transactionRef =
          _firestore.collection('transactions').doc(transaction.id);

      // Salvar transação
      await transactionRef.set(transaction.toMap());

      return transaction;
    } catch (e) {
      print('Erro ao criar transação: $e');
      rethrow;
    }
  }

  // Buscar transações do usuário
  Future<List<TransactionModel>> getUserTransactions(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('transactions')
          .where('senderId', isEqualTo: userId);

      // Filtros opcionais
      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: endDate);
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      query = query.orderBy('timestamp', descending: true).limit(limit);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) =>
              TransactionModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao buscar transações: $e');
      return [];
    }
  }

  // Calcular total de transações por tipo
  Future<double> getTotalTransactionsByType(
    String userId,
    TransactionType type, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection('transactions')
          .where('senderId', isEqualTo: userId)
          .where('type', isEqualTo: type.name);

      // Filtros de data opcionais
      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: endDate);
      }

      final snapshot = await query.get();

      return snapshot.docs.fold(0.0, (total, doc) {
        final transaction =
            TransactionModel.fromMap(doc.data() as Map<String, dynamic>);
        return total + transaction.amount;
      });
    } catch (e) {
      print('Erro ao calcular total de transações: $e');
      return 0.0;
    }
  }

  // Buscar transação por ID
  Future<TransactionModel?> getTransactionById(String transactionId) async {
    try {
      final doc =
          await _firestore.collection('transactions').doc(transactionId).get();

      return doc.exists ? TransactionModel.fromMap(doc.data()!) : null;
    } catch (e) {
      print('Erro ao buscar transação: $e');
      return null;
    }
  }

  // Atualizar status da transação
  Future<bool> updateTransactionStatus(
      String transactionId, TransactionStatus newStatus) async {
    try {
      await _firestore.collection('transactions').doc(transactionId).update({
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp()
      });
      return true;
    } catch (e) {
      print('Erro ao atualizar status da transação: $e');
      return false;
    }
  }
}
