// lib/domain/services/transaction_service.dart
import 'package:get/get.dart';
import '../models/transaction_model.dart';
import '../models/account_model.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import 'transaction_validation_service.dart';
import 'transaction_security_service.dart';

class TransactionService extends GetxService {
  final AccountRepository _accountRepository = Get.find<AccountRepository>();
  final TransactionRepository _transactionRepository =
      Get.find<TransactionRepository>();
  final TransactionValidationService _validationService =
      Get.find<TransactionValidationService>();
  final TransactionSecurityService _securityService =
      Get.find<TransactionSecurityService>();

  // Obter saldo do usuário
  Future<double> getUserBalance(String userId) async {
    return await _accountRepository.getBalance(userId);
  }

  // Stream de transações do usuário
  Stream<List<TransactionModel>> getUserTransactionsStream(
    String userId, {
    int limit = 20,
    dynamic startAfterDoc,
  }) {
    return _transactionRepository.getUserTransactionsStream(
      userId,
      limit: limit,
      startAfterDoc: startAfterDoc,
    );
  }

  // Stream da conta do usuário (para saldo em tempo real)
  Stream<AccountModel> getUserAccountStream(String userId) {
    return _accountRepository.getAccountStream(userId);
  }

  // Obter informações do destinatário
  Future<AccountModel?> getReceiverInfo(String receiverId) async {
    return await _accountRepository.getAccount(receiverId);
  }

  // Obter informações do remetente
  Future<AccountModel?> getSenderInfo(String senderId) async {
    return await _accountRepository.getAccount(senderId);
  }

  // Verificar limite diário de transferências
  Future<bool> checkDailyTransferLimit(String userId, double amount) async {
    return await _validationService.checkDailyTransferLimit(userId, amount);
  }

  // Método para enviar transação (usado na UI)
  Future<void> sendTransaction(
    TransactionModel txn,
    String receiverEmail,
  ) async {
    // Primeiro iniciamos a transação
    final initiatedTransaction = await initiateTransaction(
      txn.senderId,
      receiverEmail,
      txn.amount,
      description: txn.description,
    );

    // Executar a transação
    await _executeTransaction(initiatedTransaction);
  }

  // Iniciar uma transferência (pendente de confirmação)
  Future<TransactionModel> initiateTransaction(
    String senderId,
    String receiverEmail,
    double amount, {
    String? description,
  }) async {
    // Validar pré-condições
    await _validationService.validateTransferPreconditions(
      senderId,
      receiverEmail,
      amount,
    );

    // Obter conta do destinatário
    final receiver = await _accountRepository.getAccountByEmail(receiverEmail);

    // Criar transação pendente
    final txn = TransactionModel.transfer(
      senderId: senderId,
      receiverId: receiver!.id,
      amount: amount,
      deviceId: _securityService.generateDeviceId(),
      description: description,
    );

    // Salvar transação pendente
    final savedTxn = await _transactionRepository.addTransaction(txn);

    // Marcar como processada para evitar duplicidade
    _securityService.markTransactionAsProcessed(
      '$senderId-${receiverEmail.toLowerCase()}-$amount',
    );

    // Retornar transação com ID
    return savedTxn;
  }

  // Confirmar transação pendente
  Future<void> confirmTransaction(
    String transactionId,
    String confirmationCode,
  ) async {
    final txn = await _transactionRepository.getTransaction(transactionId);

    if (txn == null) {
      throw Exception('Transação não encontrada');
    }

    await _validationService.validateConfirmation(txn, confirmationCode);

    // Atualizar status para confirmado
    await _transactionRepository.updateTransactionStatus(
      transactionId,
      TransactionStatus.confirmed,
      confirmed: true,
    );

    // Executar a transferência confirmada
    await _executeTransaction(txn);
  }

  // Executar a transferência (atualizar saldos)
  Future<void> _executeTransaction(TransactionModel txn) async {
    await _transactionRepository.processTransaction(txn);
  }

  // Depósito
  Future<void> deposit(
    String userId,
    double amount, {
    String? description,
  }) async {
    await _validationService.validateDeposit(userId, amount);

    // Criar transação
    final txn = TransactionModel.deposit(
      userId: userId,
      amount: amount,
      deviceId: _securityService.generateDeviceId(),
      description: description,
    );

    // Processar depósito
    await _transactionRepository.processDeposit(txn);

    // Marcar como processada
    _securityService.markTransactionAsProcessed('$userId-deposit-$amount');
  }

  // Gerenciamento de senha de transação
  Future<bool> hasTransactionPassword(String userId) {
    return _securityService.hasTransactionPassword(userId);
  }

  Future<void> setTransactionPassword(String userId, String password) {
    return _securityService.setTransactionPassword(userId, password);
  }

  Future<bool> validateTransactionPassword(String userId, String password) {
    return _securityService.validateTransactionPassword(userId, password);
  }

  // Alterar senha de transação
  Future<void> changeTransactionPassword(
    String userId,
    String oldPassword,
    String newPassword,
  ) async {
    await _securityService.changeTransactionPassword(
      userId,
      oldPassword,
      newPassword,
    );
  }

  // Obter histórico de transações por período
  Future<List<TransactionModel>> getTransactionsByPeriod(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    return await _transactionRepository.getTransactionsByPeriod(
      userId,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }

  // Obter resumo financeiro
  Future<Map<String, double>> getFinancialSummary(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final transactions = await getTransactionsByPeriod(
      userId,
      startDate: startDate,
      endDate: endDate,
    );

    double totalDeposits = 0;
    double totalSent = 0;
    double totalReceived = 0;

    for (final txn in transactions) {
      if (txn.type == 'deposit') {
        totalDeposits += txn.amount;
      } else if (txn.type == 'transfer') {
        if (txn.senderId == userId) {
          totalSent += txn.amount;
        } else if (txn.receiverId == userId) {
          totalReceived += txn.amount;
        }
      }
    }

    return {
      'deposits': totalDeposits,
      'sent': totalSent,
      'received': totalReceived,
      'balance': totalDeposits + totalReceived - totalSent,
    };
  }

  Stream<List<TransactionModel>> getPendingTransactionsStream(String userId) {
    return _transactionRepository.getPendingTransactionsStream(userId);
  }
}
