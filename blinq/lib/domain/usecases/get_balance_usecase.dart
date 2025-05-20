import 'package:blinq/domain/repositories/transaction_repository.dart';

/// Caso de uso para obter o saldo atual do usuário.
///
/// Retorna a soma de todas as transações (positivas e negativas).
class GetBalanceUseCase {
  final TransactionRepository _repository;

  GetBalanceUseCase(this._repository);

  /// Executa a busca do saldo.
  Future<double> execute() {
    return _repository.getBalance();
  }
}
