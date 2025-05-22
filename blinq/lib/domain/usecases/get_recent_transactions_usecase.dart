import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Caso de uso para obter as transações mais recentes de um usuário.
class GetRecentTransactionsUseCase {
  final TransactionRepository _repository;

  GetRecentTransactionsUseCase(this._repository);

  Future<List<Transaction>> execute(String userId, {int limit = 5}) {
    return _repository.getRecentTransactions(userId, limit: limit);
  }
}