import 'package:uuid/uuid.dart';
import '../entities/transaction.dart';
import '../entities/user.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/account_repository.dart';
import '../repositories/user_repository.dart';

/// Caso de uso para realizar transferência entre usuários.
class TransferUseCase {
  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;
  final UserRepository _userRepository;

  TransferUseCase({
    required TransactionRepository transactionRepository,
    required AccountRepository accountRepository,
    required UserRepository userRepository,
  }) : _transactionRepository = transactionRepository,
       _accountRepository = accountRepository,
       _userRepository = userRepository;

  Future<void> execute({
    required String senderId,
    required String receiverEmail,
    required double amount,
    String? description,
  }) async {
    if (amount <= 0) {
      throw Exception('Valor da transferência deve ser maior que zero');
    }

    // 1. Verificar se o remetente tem saldo suficiente
    final senderBalance = await _accountRepository.getBalance(senderId);
    if (senderBalance < amount) {
      throw Exception('Saldo insuficiente');
    }

    // 2. Obter dados do destinatário
    final receiver = await _userRepository.getUserByEmail(receiverEmail);
    
    if (senderId == receiver.id) {
      throw Exception('Você não pode transferir para si mesmo');
    }

    // 3. Atualizar saldos
    final newSenderBalance = senderBalance - amount;
    final receiverBalance = await _accountRepository.getBalance(receiver.id);
    final newReceiverBalance = receiverBalance + amount;

    await _accountRepository.updateBalance(senderId, newSenderBalance);
    await _accountRepository.updateBalance(receiver.id, newReceiverBalance);

    // 4. Criar transação de saída (remetente)
    final outgoingTransaction = Transaction.transfer(
      id: const Uuid().v4(),
      amount: -amount, // Negativo para o remetente
      counterparty: receiver.name,
      description: description ?? 'Transferência PIX',
    );

    // 5. Criar transação de entrada (destinátário)
    final incomingTransaction = Transaction.transfer(
      id: const Uuid().v4(),
      amount: amount, // Positivo para o destinatário
      counterparty: 'Recebido via PIX',
      description: description ?? 'Transferência PIX recebida',
    );

    await _transactionRepository.createTransaction(senderId, outgoingTransaction);
    await _transactionRepository.createTransaction(receiver.id, incomingTransaction);
  }
}