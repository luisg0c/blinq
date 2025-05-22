import 'package:uuid/uuid.dart';
import '../../data/transaction/models/transaction_model.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/user_repository.dart';

class TransferUseCase {
  final TransactionRepository transactionRepo;
  final UserRepository userRepo;

  TransferUseCase({
    required this.transactionRepo,
    required this.userRepo,
  });

  Future<void> execute({
    required String toEmail,
    required double amount,
    required String description,
  }) async {
    if (amount <= 0) throw Exception('Valor inválido para transferência');

    final sender = await userRepo.getCurrentUser();
    final receiver = await userRepo.getUserByEmail(toEmail);

    if (sender.id == receiver.id) {
      throw Exception('Você não pode transferir para si mesmo');
    }

    final saldo = await transactionRepo.getBalance();
    if (saldo < amount) throw Exception('Saldo insuficiente');

    final timestamp = DateTime.now();
    final txId = const Uuid().v4();

    final outgoing = TransactionModel(
      id: txId,
      amount: -amount,
      date: timestamp,
      description: description,
      type: 'transfer',
      counterparty: receiver.name,
    );

    final incoming = TransactionModel(
      id: const Uuid().v4(),
      amount: amount,
      date: timestamp,
      description: 'Recebido de ${sender.name}',
      type: 'transfer',
      counterparty: sender.name,
    );

    await transactionRepo.createTransaction(outgoing);
    await userRepo.createTransactionForUser(receiver.id, incoming);
  }
}
