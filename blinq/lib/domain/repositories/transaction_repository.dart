import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<double> getBalance();
  Future<List<Transaction>> getRecentTransactions({int limit});

  /// Cria uma nova transação no sistema.
  Future<void> createTransaction(Transaction transaction);
}
