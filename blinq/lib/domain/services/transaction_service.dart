import '../repositories/transaction_repository.dart';
import '../repositories/account_repository.dart';
import '../entities/transaction.dart';

class TransactionService {
  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;

  TransactionService(this._transactionRepository, this._accountRepository);

  Future<TransactionModel> createDeposit(String userId, double amount) async {
    // Lógica de validação de depósito
    if (amount <= 0) {
      throw Exception('Valor de depósito inválido');
    }

    final transaction = TransactionModel(
      senderId: userId,
      receiverId: userId,
      amount: amount,
      type: TransactionType.deposit
    );

    return await _transactionRepository.createTransaction(transaction);
  }

  Future<TransactionModel> createTransfer(
    String senderId, 
    String receiverEmail, 
    double amount
  ) async {
    // Lógica de validação de transferência
    if (amount <= 0) {
      throw Exception('Valor de transferência inválido');
    }

    // Verificações adicionais podem ser incluídas aqui
    final transaction = TransactionModel(
      senderId: senderId,
      amount: amount,
      type: TransactionType.transfer
    );

    return await _transactionRepository.createTransaction(transaction);
  }
}