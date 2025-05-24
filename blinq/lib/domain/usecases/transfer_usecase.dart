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
<<<<<<< Updated upstream
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
=======
    print('🔄 Iniciando transferência...');
    print('   Remetente: $senderId');
    print('   Destinatário: $receiverEmail');
    print('   Valor: R\$ $amount');

    // ✅ Validações de entrada
    await _validateInputs(senderId, receiverEmail, amount);

    try {
      // 1. Verificar saldo do remetente
      final senderBalance = await _accountRepository.getBalance(senderId);
      print('💰 Saldo do remetente: R\$ $senderBalance');
      
      if (senderBalance < amount) {
        throw const AppException('Saldo insuficiente para esta transferência');
      }

      // 2. ✅ Buscar destinatário por email
      User receiver;
      try {
        receiver = await _userRepository.getUserByEmail(receiverEmail);
        print('👤 Destinatário encontrado: ${receiver.name} (${receiver.id})');
      } catch (e) {
        print('❌ Destinatário não encontrado: $e');
        throw AppException('Usuário com email $receiverEmail não encontrado no Blinq');
      }
      
      // 3. ✅ Verificar auto-transferência
      if (senderId == receiver.id) {
        throw const AppException('Você não pode transferir dinheiro para si mesmo');
      }

      // 4. ✅ Verificar limites
      const maxTransferAmount = 5000.0;
      if (amount > maxTransferAmount) {
        throw AppException('Valor máximo por transferência: R\$ ${maxTransferAmount.toStringAsFixed(2)}');
      }

      // 5. Executar transferência
      await _executeTransfer(senderId, receiver, amount, description);
      
      print('✅ Transferência concluída com sucesso!');

    } catch (e) {
      print('❌ Erro na transferência: $e');
      if (e is AppException) {
        rethrow;
      }
      throw const AppException('Erro inesperado durante a transferência. Tente novamente.');
    }
  }

  Future<void> _validateInputs(String senderId, String receiverEmail, double amount) async {
    if (senderId.trim().isEmpty) {
      throw const AppException('ID do remetente é obrigatório');
    }

    if (amount <= 0) {
      throw const AppException('Valor da transferência deve ser maior que zero');
    }

    if (receiverEmail.trim().isEmpty) {
      throw const AppException('Email do destinatário é obrigatório');
    }

    // Regex mais simples e eficaz para email
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(receiverEmail.trim())) {
      throw const AppException('Email do destinatário é inválido');
    }
  }

  Future<void> _executeTransfer(
    String senderId, 
    User receiver, 
    double amount, 
    String? description,
  ) async {
    print('💸 Executando transferência...');

    // 1. Obter saldos atuais
    final senderBalance = await _accountRepository.getBalance(senderId);
    final receiverBalance = await _accountRepository.getBalance(receiver.id);

    // 2. Calcular novos saldos
    final newSenderBalance = senderBalance - amount;
    final newReceiverBalance = receiverBalance + amount;

    print('   Novo saldo remetente: R\$ $newSenderBalance');
    print('   Novo saldo destinatário: R\$ $newReceiverBalance');

    // 3. Atualizar saldos
    await _accountRepository.updateBalance(senderId, newSenderBalance);
    await _accountRepository.updateBalance(receiver.id, newReceiverBalance);

    // 4. Obter nome do remetente
    final senderName = await _getSenderName(senderId);

    // 5. Criar transações
    await _createTransactions(senderId, receiver, amount, description, senderName);

    // 6. ✅ Enviar notificação
    await _sendNotificationToReceiver(receiver, amount, senderName);
  }

  Future<void> _createTransactions(
    String senderId,
    User receiver,
    double amount,
    String? description,
    String senderName,
  ) async {
    final transactionId = const Uuid().v4();
    final now = DateTime.now();

    // Transação de saída (remetente)
    final outgoingTransaction = Transaction(
      id: '${transactionId}_out',
      amount: -amount, // Negativo para o remetente
      date: now,
      description: description ?? 'Transferência para ${receiver.name}',
      type: 'transfer',
      counterparty: receiver.name,
      status: 'completed',
    );

    // Transação de entrada (destinatário)
    final incomingTransaction = Transaction(
      id: '${transactionId}_in',
      amount: amount, // Positivo para o destinatário
      date: now,
      description: description ?? 'Transferência recebida',
      type: 'transfer',
      counterparty: 'Recebido de $senderName',
      status: 'completed',
    );

    // Salvar transações
    await _transactionRepository.createTransaction(senderId, outgoingTransaction);
    await _transactionRepository.createTransaction(receiver.id, incomingTransaction);

    print('📝 Transações criadas com sucesso');
  }

  Future<String> _getSenderName(String senderId) async {
    try {
      final sender = await _userRepository.getUserById(senderId);
      return sender.name;
    } catch (e) {
      print('⚠️  Não foi possível obter nome do remetente: $e');
      return 'Usuário Blinq';
    }
  }

  Future<void> _sendNotificationToReceiver(User receiver, double amount, String senderName) async {
    try {
      print('📱 Enviando notificação para ${receiver.email}');
      
      // TODO: Implementar notificação push real via NotificationService
      // await NotificationService.sendTransferReceivedNotification(
      //   receiverUserId: receiver.id,
      //   amount: amount,
      //   senderName: senderName,
      // );

      print('📱 Notificação simulada enviada: R\$ ${amount.toStringAsFixed(2)} de $senderName');

    } catch (e) {
      // Não falhar a transferência por causa da notificação
      print('⚠️  Erro ao enviar notificação: $e');
    }
>>>>>>> Stashed changes
  }
}