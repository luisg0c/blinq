import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_data_source.dart';
import '../models/transaction_model.dart';

/// Implementação do repositório de transações.
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> createTransaction(String userId, Transaction transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    await remoteDataSource.addTransaction(userId, model);
  }

  @override
  Future<List<Transaction>> getTransactionsByUser(String userId) {
    return remoteDataSource.getTransactionsByUser(userId);
  }

  @override
  Future<List<Transaction>> getTransactionsBetween({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) {
    return remoteDataSource.getTransactionsBetween(
      userId: userId,
      start: start,
      end: end,
    );
  }

  @override
  Stream<List<Transaction>> watchTransactionsByUser(String userId) {
    return remoteDataSource.watchTransactionsByUser(userId);
  }

  @override
  Future<List<Transaction>> getRecentTransactions(String userId, {int limit = 10}) async {
    final all = await getTransactionsByUser(userId);
    return all.take(limit).toList();
  }
}