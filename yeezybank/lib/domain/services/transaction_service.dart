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

  // Obter saldo do usuário com tratamento de erro melhorado
  Future<double> getUserBalance(String userId) async {
    try {
      return await _accountRepository.getBalance(userId);
    } catch (e) {
      print('Erro ao obter saldo: $e');
      _checkAuthError(e);
      return 0.0;
    }
  }

  // Stream de transações do usuário com tratamento de erro
  Stream<List<TransactionModel>> getUserTransactionsStream(
    String userId, {
    int limit = 20,
    dynamic startAfterDoc,
  }) {
    try {
      return _transactionRepository.getUserTransactionsStream(
        userId,
        limit: limit,
        startAfterDoc: startAfterDoc,
      );
    } catch (e) {
      print('Erro ao obter stream de transações: $e');
      _checkAuthError(e);
      return Stream.value([]);
    }
  }

  // Stream da conta do usuário (para saldo em tempo real)
  Stream<AccountModel> getUserAccountStream(String userId) {
    try {
      return _accountRepository.getAccountStream(userId);
    } catch (e) {
      print('Erro ao obter stream da conta: $e');
      _checkAuthError(e);
      // Retornar stream com account "vazia" para evitar erros
      return Stream.value(
        AccountModel(
          id: userId,
          email: '',
          balance: 0.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  // Obter informações do destinatário
  Future<AccountModel?> getReceiverInfo(String receiverId) async {
    try {
      return await _accountRepository.getAccount(receiverId);
    } catch (e) {
      print('Erro ao obter info do destinatário: $e');
      _checkAuthError(e);
      return null;
    }
  }

  // Obter informações do remetente
  Future<AccountModel?> getSenderInfo(String senderId) async {
    try {
      return await _accountRepository.getAccount(senderId);
    } catch (e) {
      print('Erro ao obter info do remetente: $e');
      _checkAuthError(e);
      return null;
    }
  }

  // Verificar limite diário de transferências
  Future<bool> checkDailyTransferLimit(String userId, double amount) async {
    try {
      return await _validationService.checkDailyTransferLimit(userId, amount);
    } catch (e) {
      print('Erro ao verificar limite diário: $e');
      _checkAuthError(e);
      // Retornar false para evitar transferências em caso de erro
      return false;
    }
  }

  // Método para enviar transação (usado na UI)
  Future<void> sendTransaction(
    TransactionModel txn,
    String receiverEmail,
  ) async {
    // Validar que temos um ID de remetente
    if (txn.senderId.isEmpty) {
      throw Exception('Usuário não autenticado');
    }

    try {
      // Primeiro iniciamos a transação
      final initiatedTransaction = await initiateTransaction(
        txn.senderId,
        receiverEmail,
        txn.amount,
        description: txn.description,
      );

      // Executar a transação
      await _executeTransaction(initiatedTransaction);
    } catch (e) {
      print('Erro ao enviar transação: $e');
      _checkAuthError(e);
      rethrow;
    }
  }

  // Iniciar uma transferência (pendente de confirmação)
  Future<TransactionModel> initiateTransaction(
    String senderId,
    String receiverEmail,
    double amount, {
    String? description,
  }) async {
    try {
      // Validar pré-condições
      await _validationService.validateTransferPreconditions(
        senderId,
        receiverEmail,
        amount,
      );

      // Obter conta do destinatário
      final receiver = await _accountRepository.getAccountByEmail(
        receiverEmail,
      );
      if (receiver == null) {
        throw Exception('Destinatário não encontrado');
      }

      // Criar transação pendente
      final txn = TransactionModel.transfer(
        senderId: senderId,
        receiverId: receiver.id,
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
    } catch (e) {
      print('Erro ao iniciar transação: $e');
      _checkAuthError(e);
      rethrow;
    }
  }

  // Confirmar transação pendente
  Future<void> confirmTransaction(
    String transactionId,
    String confirmationCode,
  ) async {
    try {
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
    } catch (e) {
      print('Erro ao confirmar transação: $e');
      _checkAuthError(e);
      rethrow;
    }
  }

  // Executar a transferência (atualizar saldos)
  Future<void> _executeTransaction(TransactionModel txn) async {
    try {
      await _transactionRepository.processTransaction(txn);
    } catch (e) {
      print('Erro ao executar transação: $e');
      _checkAuthError(e);
      rethrow;
    }
  }

  // Depósito com tratamento de erro aprimorado
  Future<void> deposit(
    String userId,
    double amount, {
    String? description,
  }) async {
    try {
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
    } catch (e) {
      print('Erro ao processar depósito: $e');
      _checkAuthError(e);
      rethrow;
    }
  }

  // Gerenciamento de senha de transação
  Future<bool> hasTransactionPassword(String userId) async {
    try {
      return await _securityService.hasTransactionPassword(userId);
    } catch (e) {
      print('Erro ao verificar senha de transação: $e');
      _checkAuthError(e);
      return false;
    }
  }

  Future<void> setTransactionPassword(String userId, String password) async {
    try {
      await _securityService.setTransactionPassword(userId, password);
    } catch (e) {
      print('Erro ao definir senha de transação: $e');
      _checkAuthError(e);
      rethrow;
    }
  }

  Future<bool> validateTransactionPassword(
    String userId,
    String password,
  ) async {
    try {
      return await _securityService.validateTransactionPassword(
        userId,
        password,
      );
    } catch (e) {
      print('Erro ao validar senha de transação: $e');
      _checkAuthError(e);
      return false;
    }
  }

  // Alterar senha de transação
  Future<void> changeTransactionPassword(
    String userId,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      await _securityService.changeTransactionPassword(
        userId,
        oldPassword,
        newPassword,
      );
    } catch (e) {
      print('Erro ao alterar senha de transação: $e');
      _checkAuthError(e);
      rethrow;
    }
  }

  // Obter histórico de transações por período
  Future<List<TransactionModel>> getTransactionsByPeriod(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      return await _transactionRepository.getTransactionsByPeriod(
        userId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
    } catch (e) {
      print('Erro ao obter transações por período: $e');
      _checkAuthError(e);
      return [];
    }
  }

  // Obter resumo financeiro
  Future<Map<String, double>> getFinancialSummary(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
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
    } catch (e) {
      print('Erro ao obter resumo financeiro: $e');
      _checkAuthError(e);
      return {'deposits': 0, 'sent': 0, 'received': 0, 'balance': 0};
    }
  }

  Stream<List<TransactionModel>> getPendingTransactionsStream(String userId) {
    try {
      return _transactionRepository.getPendingTransactionsStream(userId);
    } catch (e) {
      print('Erro ao obter transações pendentes: $e');
      _checkAuthError(e);
      return Stream.value([]);
    }
  }

  // Verificar se o erro é relacionado a autenticação
  void _checkAuthError(dynamic error) {
    String errorStr = error.toString().toLowerCase();
    if (errorStr.contains('not authenticated') ||
        errorStr.contains('não autenticado') ||
        errorStr.contains('usuario nao logado') ||
        errorStr.contains('usuário não logado') ||
        errorStr.contains('permission') ||
        errorStr.contains('permissão') ||
        errorStr.contains('unauthorized') ||
        errorStr.contains('não autorizado')) {
      // Notificar controller para redirecionar para login
      Get.find<AuthService>().currentUser.value = null;
    }
  }
}
