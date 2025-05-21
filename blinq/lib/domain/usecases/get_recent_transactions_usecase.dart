import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetRecentTransactionsUseCase {
  final TransactionRepository _repository;

  GetRecentTransactionsUseCase(this._repository);

  Future<List<Transaction>> execute({int? limit}) async {
    return _repository.getRecentTransactions(limit: limit ?? 10);
  }
}
