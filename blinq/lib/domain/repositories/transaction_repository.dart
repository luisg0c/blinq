import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<TransactionModel>> getUserTransactions(String userId);
  Future<TransactionModel> createTransaction(TransactionModel transaction);
  Future<void> processTransaction(TransactionModel transaction);
  Future<List<TransactionModel>> getPendingTransactions(String userId);
  Future<bool> checkDailyTransferLimit(String userId, double amount);
}