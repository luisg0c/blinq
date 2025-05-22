import 'package:blinq/data/transaction/datasources/transaction_remote_data_source.dart';
import 'package:blinq/data/transaction/models/transaction_model.dart';
import 'package:blinq/domain/entities/transaction.dart';
import 'package:blinq/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> createTransaction(Transaction transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    await remoteDataSource.createTransaction(model);
  }

  @override
  Future<List<Transaction>> getTransactions() async {
    final models = await remoteDataSource.getTransactions();
    return models;
  }

  @override
  Future<List<Transaction>> getTransactionsBetween({
    required DateTime start,
    required DateTime end,
  }) async {
    final models = await remoteDataSource.getTransactionsBetween(start: start, end: end);
    return models;
  }

  @override
  Future<List<Transaction>> getRecentTransactions({int limit = 10}) async {
    return await remoteDataSource.getRecentTransactions(limit: limit);
  }

  @override
  Future<double> getBalance() async {
    return await remoteDataSource.getBalance();
  }
}
