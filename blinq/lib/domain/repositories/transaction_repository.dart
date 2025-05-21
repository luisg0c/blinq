import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<double> getBalance();
  Future<List<Transaction>> getRecentTransactions({int limit});
  Future<void> createTransaction(Transaction transaction);
  Future<List<Transaction>> getTransactionsBetween({
    required DateTime start,
    required DateTime end,
  });
}
