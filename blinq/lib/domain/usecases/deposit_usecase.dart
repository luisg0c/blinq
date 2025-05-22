import 'package:uuid/uuid.dart';
import '../../../data/transaction/models/transaction_model.dart';
import 'package:blinq/domain/repositories/transaction_repository.dart';

class DepositUseCase {
  final TransactionRepository repository;

  DepositUseCase(this.repository);

  Future<void> execute({
    required double amount,
    required String description,
  }) async {
    if (amount <= 0) throw Exception('Valor do depósito inválido');

    final transaction = TransactionModel(
      id: const Uuid().v4(),
      amount: amount,
      date: DateTime.now(),
      description: description,
      type: 'deposit',
      counterparty: 'Você',
    );

    await repository.createTransaction(transaction);
  }
}
