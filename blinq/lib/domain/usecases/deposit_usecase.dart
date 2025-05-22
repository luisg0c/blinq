import 'package:uuid/uuid.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/account_repository.dart';

/// Caso de uso para realizar depósito na conta do usuário.
class DepositUseCase {
  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;

  DepositUseCase({
    required TransactionRepository transactionRepository,
    required AccountRepository accountRepository,
  }) : _transactionRepository = transactionRepository,
       _accountRepository = accountRepository;

  Future<void> execute({
    required String userId,
    required double amount,
    String? description,
  }) async {
    if (amount <= 0) {
      throw Exception('Valor do depósito deve ser maior que zero');
    }

    // 1. Obter saldo atual
    final currentBalance = await _accountRepository.getBalance(userId);
    
    // 2. Calcular novo saldo
    final newBalance = currentBalance + amount;
    
    // 3. Atualizar saldo na conta
    await _accountRepository.updateBalance(userId, newBalance);
    
    // 4. Criar registro da transação
    final transaction = Transaction.deposit(
      id: const Uuid().v4(),
      amount: amount,
      description: description ?? 'Depósito',
    );
    
    await _transactionRepository.createTransaction(userId, transaction);
  }
}