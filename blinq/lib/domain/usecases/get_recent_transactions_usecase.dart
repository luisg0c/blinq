import '../entities/transaction.dart';
import 'package:blinq/domain/repositories/transaction_repository.dart';

/// Caso de uso para obter as transações mais recentes.
///
/// Retorna uma lista com até [limit] itens; se [limit] não for informado,
/// retorna todas as transações.
class GetRecentTransactionsUseCase {
  final TransactionRepository _repository;

  GetRecentTransactionsUseCase(this._repository);

  /// Executa a busca pelas transações mais recentes.
  Future<List<Transaction>> execute({int? limit}) {
    return _repository.getRecentTransactions(limit: limit);
  }
}
