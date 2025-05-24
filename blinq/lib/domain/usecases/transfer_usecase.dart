import 'package:uuid/uuid.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/account_repository.dart';
import '../repositories/user_repository.dart';
import '../../core/exceptions/app_exception.dart';

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
    // ✅ Validações aprimoradas
    if (amount <= 0) {
      throw AppException('Valor da transferência deve ser maior que zero');
    }

    if (receiverEmail.trim().isEmpty) {
      throw AppException('Email do destinatário é obrigatório');
    }

    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(receiverEmail)) {
      throw AppException('Email do destinatário é inválido');
    }

    try {
      // 1. Verificar se o remetente tem saldo suficiente
      final senderBalance = await _accountRepository.getBalance(senderId);
      if (senderBalance < amount) {
        throw AppException('Saldo insuficiente para esta transferência');
      }

      // 2. ✅ Validar se o destinatário existe
      User receiver;
      try {
        receiver = await _userRepository.getUserByEmail(receiverEmail);
      } catch (e) {
        throw AppException('Usuário com email $receiverEmail não encontrado no Blinq');
      }
      
      // 3. ✅ Verificar se não é auto-transferência
      if (senderId == receiver.id) {
        throw AppException('Você não pode transferir dinheiro para si mesmo');
      }

      // 4. ✅ Verificar limites de transferência (exemplo: R$ 5.000 por transação)
      const maxTransferAmount = 5000.0;
      if (amount > maxTransferAmount) {
        throw AppException('Valor máximo por transferência: R\$ ${maxTransferAmount.toStringAsFixed(2)}');
      }

      // 5. Atualizar saldos
      final newSenderBalance = senderBalance - amount;
      final receiverBalance = await _accountRepository.getBalance(receiver.id);
      final newReceiverBalance = receiverBalance + amount;

      await _accountRepository.updateBalance(senderId, newSenderBalance);
      await _accountRepository.updateBalance(receiver.id, newReceiverBalance);

      // 6. Criar transação de saída (remetente)
      final outgoingTransaction = Transaction.transfer(
        id: const Uuid().v4(),
        amount: -amount, // Negativo para o remetente
        counterparty: receiver.name,
        description: description ?? 'Transferência para ${receiver.name}',
      );

      // 7. Criar transação de entrada (destinatário)
      final incomingTransaction = Transaction.transfer(
        id: const Uuid().v4(),
        amount: amount, // Positivo para o destinatário
        counterparty: 'Recebido de ${await _getSenderName(senderId)}',
        description: description ?? 'Transferência recebida',
      );

      await _transactionRepository.createTransaction(senderId, outgoingTransaction);
      await _transactionRepository.createTransaction(receiver.id, incomingTransaction);

      // 8. ✅ Trigger notificação push para o destinatário
      await _sendNotificationToReceiver(receiver, amount);

    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Erro inesperado durante a transferência. Tente novamente.');
    }
  }

  Future<String> _getSenderName(String senderId) async {
    try {
      final sender = await _userRepository.getUserById(senderId);
      return sender.name;
    } catch (e) {
      return 'Usuário Blinq';
    }
  }

  Future<void> _sendNotificationToReceiver(User receiver, double amount) async {
    try {
      // TODO: Implementar notificação push real
      print('📱 Notificação enviada para ${receiver.email}: Você recebeu R\$ ${amount.toStringAsFixed(2)}');
      
      // Simulação de push notification
      // await NotificationService.send(
      //   userId: receiver.id,
      //   title: '💰 Dinheiro recebido!',
      //   body: 'Você recebeu R\$ ${amount.toStringAsFixed(2)} no seu Blinq',
      //   data: {
      //     'type': 'transfer_received',
      //     'amount': amount.toString(),
      //   },
      // );
    } catch (e) {
      // Não falhar a transferência por causa da notificação
      print('⚠️  Erro ao enviar notificação: $e');
    }
  }
}