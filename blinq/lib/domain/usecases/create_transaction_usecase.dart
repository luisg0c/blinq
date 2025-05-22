import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Caso de uso genérico para criação de uma transação no sistema.
class CreateTransactionUseCase {
  final TransactionRepository _repository;

  CreateTransactionUseCase(this._repository);

  Future<void> execute(String userId, Transaction transaction) {
    return _repository.createTransaction(userId, transaction);
  }
}