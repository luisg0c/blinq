import '../../data/models/transaction_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface para o repositório de transações
abstract class TransactionRepository {
  /// Adiciona uma nova transação
  Future<TransactionModel> addTransaction(TransactionModel transaction);
  
  /// Obtém uma transação pelo ID
  Future<TransactionModel?> getTransaction(String transactionId);
  
  /// Atualiza o status de uma transação
  Future<void> updateTransactionStatus(
    String transactionId,
    TransactionStatus status, {
    bool confirmed = false,
  });
  
  /// Processa uma transação (transferência)
  Future<void> processTransaction(TransactionModel transaction);
  
  /// Processa um depósito
  Future<void> processDeposit(TransactionModel transaction);
  
  /// Obtém um stream das transações do usuário
  Stream<List<TransactionModel>> getUserTransactionsStream(
    String userId, {
    int limit = 20,
    DocumentSnapshot? startAfterDoc,
  });
  
  /// Obtém um stream das transações pendentes do usuário
  Stream<List<TransactionModel>> getPendingTransactionsStream(String userId);
  
  /// Obtém as transações do usuário em um período específico
  Future<List<TransactionModel>> getTransactionsByPeriod(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  });
  
  /// Confirma uma transação pendente
  Future<void> confirmTransaction(
    String transactionId,
    String confirmationCode,
  );
  
  /// Cancela uma transação pendente
  Future<void> cancelTransaction(String transactionId);
  
  /// Obtém o total de transações por tipo em um período
  Future<Map<String, double>> getTransactionTotalsByType(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// Verifica limite diário de transações
  Future<bool> checkDailyTransferLimit(String userId, double amount);
}