import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<void> createTransaction(Transaction transaction);
  Future<double> getBalance();
  Future<List<Transaction>> getRecentTransactions({int? limit});
  Future<List<Transaction>> getTransactionsBetween({
    required DateTime start,
    required DateTime end,
  });
}
