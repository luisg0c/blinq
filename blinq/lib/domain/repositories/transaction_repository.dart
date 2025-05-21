import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<double> getBalance();
  Future<List<Transaction>> getRecentTransactions({int limit});

  /// Cria uma nova transação no sistema.
  Future<void> createTransaction(Transaction transaction);

  /// Retorna as transações dentro de um intervalo de tempo.
  Future<List<Transaction>> getTransactionsBetween({
    required DateTime start,
    required DateTime end,
  });
}
