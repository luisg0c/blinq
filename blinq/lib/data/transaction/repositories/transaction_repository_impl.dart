import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_data_source.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<double> getBalance() {
    return remoteDataSource.getBalance();
  }

  @override
  Future<List<Transaction>> getRecentTransactions({int? limit}) async {
    final models = await remoteDataSource.getRecentTransactions(limit: limit);
    return models;
  }

  @override
  Future<void> createTransaction(Transaction transaction) async {
    if (transaction is! TransactionModel) {
      throw Exception('A transação deve ser TransactionModel');
    }
    await remoteDataSource.addTransaction(transaction);
  }
}
