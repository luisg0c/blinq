import '../entities/transaction.dart';

/// Contrato da camada de domínio para operações de transação.
abstract class TransactionRepository {
  /// Cria uma nova transação para um usuário específico.
  Future<void> createTransaction(String userId, Transaction transaction);
  
  /// Obtém todas as transações de um usuário.
  Future<List<Transaction>> getTransactionsByUser(String userId);
  
  /// Obtém transações de um usuário em um período específico.
  Future<List<Transaction>> getTransactionsBetween({
    required String userId,
    required DateTime start,
    required DateTime end,
  });
  
  /// Obtém as transações mais recentes de um usuário.
  Future<List<Transaction>> getRecentTransactions(String userId, {int limit = 10});
  
  /// Stream para observar transações em tempo real.
  Stream<List<Transaction>> watchTransactionsByUser(String userId);
}