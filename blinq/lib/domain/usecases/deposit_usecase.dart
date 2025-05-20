import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';
import 'package:uuid/uuid.dart';

/// Caso de uso para simular um depósito na conta do usuário.
///
/// Apenas cria uma transação positiva do tipo 'deposit'.
class DepositUseCase {
  final TransactionRepository repository;

  DepositUseCase(this.repository);

  Future<void> execute({
    required double amount,
    required String description,
  }) async {
    if (amount <= 0) throw Exception('O valor do depósito deve ser maior que zero');

    final tx = Transaction(
      id: const Uuid().v4(),
      amount: amount,
      date: DateTime.now(),
      description: description,
      type: 'deposit',
      counterparty: null,
    );

    await repository.createTransaction(tx);
  }
}
