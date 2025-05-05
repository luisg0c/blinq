import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/account_repository.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/account_model.dart';
import '../../core/utils/logger.dart';
import '../../core/constants/app_constants.dart';

/// Controlador para gerenciar operações financeiras no aplicativo
class TransactionController extends GetxController {
  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;
  final AppLogger _logger = AppLogger('TransactionController');
  
  // Observables
  final RxDouble balance = 0.0.obs;
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxList<TransactionModel> pendingTransactions = <TransactionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final Rx<AccountModel?> account = Rx<AccountModel?>(null);
  
  // Controladores para formulários
  final TextEditingController amountController = TextEditingController();
  final TextEditingController receiverEmailController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController transactionPasswordController = TextEditingController();
  
  // Variáveis para paginação
  DocumentSnapshot? _lastDocument;
  final RxBool hasMoreTransactions = true.obs;
  final int transactionsPerPage = AppConstants.transactionsPerPage;
  
  // Construtor com injeção de dependências
  TransactionController(
    this._transactionRepository,
    this._accountRepository,
  );
  
  @override
  void onInit() {
    super.onInit();
  }
  
  @override
  void onClose() {
    amountController.dispose();
    receiverEmailController.dispose();
    descriptionController.dispose();
    transactionPasswordController.dispose();
    super.onClose();
  }
  
  /// Inicializa os dados do usuário
  Future<void> initUserData(String userId) async {
    try {
      isLoading.value = true;
      
      // Carregar saldo do usuário
      await _loadBalance(userId);
      
      // Carregar informações da conta
      await _loadAccount(userId);
      
      // Escutar transações
      _listenToTransactions(userId);
      
      // Escutar transações pendentes
      _listenToPendingTransactions(userId);
      
      _logger.info('Dados do usuário inicializados: $userId');
    } catch (e) {
      _logger.error('Erro ao inicializar dados do usuário', e);
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Carrega o saldo do usuário
  Future<void> _loadBalance(String userId) async {
    try {
      final userBalance = await _accountRepository.getBalance(userId);
      balance.value = userBalance;
      
      // Também escutamos as mudanças em tempo real
      _listenToBalanceChanges(userId);
      
      _logger.info('Saldo carregado: $userBalance');
    } catch (e) {
      _logger.error('Erro ao carregar saldo', e);
      error.value = 'Não foi possível carregar o saldo';
    }
  }
  
  /// Carrega informações da conta do usuário
  Future<void> _loadAccount(String userId) async {
    try {
      final userAccount = await _accountRepository.getAccount(userId);
      account.value = userAccount;
      
      _logger.info('Conta carregada: ${userAccount?.id}');
    } catch (e) {
      _logger.error('Erro ao carregar conta', e);
      error.value = 'Não foi possível carregar informações da conta';
    }
  }
  
  /// Escuta mudanças no saldo em tempo real
  void _listenToBalanceChanges(String userId) {
    _accountRepository.getAccountStream(userId).listen(
      (accountData) {
        if (accountData != null) {
          balance.value = accountData.balance;
          account.value = accountData;
        }
      },
      onError: (e) {
        _logger.error('Erro no stream de saldo', e);
      },
    );
  }
  
  /// Escuta transações do usuário em tempo real
  void _listenToTransactions(String userId) {
    _transactionRepository.getUserTransactionsStream(
      userId,
      limit: transactionsPerPage,
    ).listen(
      (List<TransactionModel> txns) {
        transactions.value = txns;
        if (txns.isNotEmpty) {
          _lastDocument = null; // Reset para paginação
        }
        hasMoreTransactions.value = txns.length >= transactionsPerPage;
      },
      onError: (e) {
        _logger.error('Erro no stream de transações', e);
      },
    );
  }
  
  /// Escuta transações pendentes do usuário em tempo real
  void _listenToPendingTransactions(String userId) {
    _transactionRepository.getPendingTransactionsStream(userId).listen(
      (List<TransactionModel> txns) {
        pendingTransactions.value = txns;
      },
      onError: (e) {
        _logger.error('Erro no stream de transações pendentes', e);
      },
    );
  }
  
  /// Limpa os campos dos formulários
  void clearFields() {
    amountController.clear();
    receiverEmailController.clear();
    descriptionController.clear();
    transactionPasswordController.clear();
    error.value = '';
  }
  
  /// Realiza um depósito na conta do usuário
  Future<bool> deposit(String userId) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final amountText = amountController.text.trim().replaceAll(',', '.');
      final description = descriptionController.text.trim();
      final password = transactionPasswordController.text.trim();
      
      // Validar campos
      if (amountText.isEmpty) {
        error.value = 'Informe o valor do depósito';
        return false;
      }
      
      // Converter valor para double
      final amount = double.tryParse(amountText);
      if (amount == null || amount <= 0) {
        error.value = 'Informe um valor válido';
        return false;
      }
      
      // Validar limites
      if (amount < AppConstants.minDepositAmount) {
        error.value = 'Valor mínimo para depósito: ${AppConstants.minDepositAmount}';
        return false;
      }
      
      if (amount > AppConstants.maxDepositAmount) {
        error.value = 'Valor máximo para depósito: ${AppConstants.maxDepositAmount}';
        return false;
      }
      
      // Verificar senha de transação
      final hasPassword = await _accountRepository.hasTransactionPassword(userId);
      
      if (hasPassword) {
        // Validar senha existente
        final isValid = await _accountRepository.validateTransactionPassword(
          userId,
          password,
        );
        
        if (!isValid) {
          error.value = 'Senha de transação incorreta';
          return false;
        }
      } else {
        // Definir nova senha
        if (password.length < AppConstants.minTransactionPasswordLength) {
          error.value = 'A senha deve ter pelo menos ${AppConstants.minTransactionPasswordLength} dígitos';
          return false;
        }
        
        await _accountRepository.setTransactionPassword(userId, password);
      }
      
      // Criar modelo de transação
      final transaction = TransactionModel.deposit(
        userId: userId,
        amount: amount,
        description: description.isNotEmpty ? description : null,
      );
      
      // Processar depósito
      await _transactionRepository.processDeposit(transaction);
      
      _logger.info('Depósito realizado: $amount');
      clearFields();
      return true;
    } catch (e) {
      _logger.error('Erro ao realizar depósito', e);
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Realiza uma transferência para outro usuário
  Future<bool> transfer(String userId, String currentUserEmail) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final amountText = amountController.text.trim().replaceAll(',', '.');
      final receiverEmail = receiverEmailController.text.trim();
      final description = descriptionController.text.trim();
      final password = transactionPasswordController.text.trim();
      
      // Validar campos
      if (amountText.isEmpty) {
        error.value = 'Informe o valor da transferência';
        return false;
      }
      
      if (receiverEmail.isEmpty) {
        error.value = 'Informe o email do destinatário';
        return false;
      }
      
      // Não permitir transferência para si mesmo
      if (receiverEmail.toLowerCase() == currentUserEmail.toLowerCase()) {
        error.value = 'Você não pode transferir para si mesmo';
        return false;
      }
      
      // Converter valor para double
      final amount = double.tryParse(amountText);
      if (amount == null || amount <= 0) {
        error.value = 'Informe um valor válido';
        return false;
      }
      
      // Validar limites
      if (amount < AppConstants.minTransferAmount) {
        error.value = 'Valor mínimo para transferência: ${AppConstants.minTransferAmount}';
        return false;
      }
      
      if (amount > AppConstants.maxTransferAmount) {
        error.value = 'Valor máximo para transferência: ${AppConstants.maxTransferAmount}';
        return false;
      }
      
      // Verificar saldo suficiente
      if (amount > balance.value) {
        error.value = 'Saldo insuficiente';
        return false;
      }
      
      // Verificar limite diário
      final isWithinLimit = await _transactionRepository.checkDailyTransferLimit(
        userId,
        amount,
      );
      
      if (!isWithinLimit) {
        error.value = 'Limite diário de transferência excedido';
        return false;
      }
      
      // Verificar senha de transação
      final hasPassword = await _accountRepository.hasTransactionPassword(userId);
      
      if (!hasPassword) {
        error.value = 'Você precisa definir uma senha de transação primeiro';
        return false;
      }
      
      // Validar senha
      final isValid = await _accountRepository.validateTransactionPassword(
        userId,
        password,
      );
      
      if (!isValid) {
        error.value = 'Senha de transação incorreta';
        return false;
      }
      
      // Criar modelo de transação sem receiverId (será preenchido pelo repositório)
      final transaction = TransactionModel.transfer(
        senderId: userId,
        receiverId: '',  // Será preenchido pelo repositório
        amount: amount,
        description: description.isNotEmpty ? description : null,
      );
      
      // Processar transferência
      await _transactionRepository.processTransaction(
        transaction,
        receiverEmail,
      );
      
      _logger.info('Transferência realizada: $amount para $receiverEmail');
      clearFields();
      return true;
    } catch (e) {
      _logger.error('Erro ao realizar transferência', e);
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Cancela uma transação pendente
  Future<bool> cancelTransaction(String transactionId) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _transactionRepository.cancelTransaction(transactionId);
      
      _logger.info('Transação cancelada: $transactionId');
      return true;
    } catch (e) {
      _logger.error('Erro ao cancelar transação', e);
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Confirma uma transação pendente
  Future<bool> confirmTransaction(
    String transactionId,
    String confirmationCode,
  ) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _transactionRepository.confirmTransaction(
        transactionId,
        confirmationCode,
      );
      
      _logger.info('Transação confirmada: $transactionId');
      return true;
    } catch (e) {
      _logger.error('Erro ao confirmar transação', e);
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Carrega mais transações para a paginação
  Future<void> loadMoreTransactions(String userId) async {
    if (isLoading.value || !hasMoreTransactions.value) return;
    
    try {
      isLoading.value = true;
      
      final currentTransactions = transactions.value;
      if (currentTransactions.isEmpty) return;
      
      // Usar o último documento para paginação
      final moreTxns = await _transactionRepository.getUserTransactionsStream(
        userId,
        limit: transactionsPerPage,
        startAfterDoc: _lastDocument,
      ).first;
      
      if (moreTxns.isNotEmpty) {
        transactions.addAll(moreTxns);
        _lastDocument = 'LastDoc'; // Atualizar para próxima paginação
        hasMoreTransactions.value = moreTxns.length >= transactionsPerPage;
      } else {
        hasMoreTransactions.value = false;
      }
      
      _logger.info('Mais transações carregadas: ${moreTxns.length}');
    } catch (e) {
      _logger.error('Erro ao carregar mais transações', e);
      error.value = 'Não foi possível carregar mais transações';
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Obtém resumo financeiro do período especificado
  Future<Map<String, double>> getFinancialSummary(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      isLoading.value = true;
      
      final summary = await _transactionRepository.getTransactionTotalsByType(
        userId,
        startDate: startDate,
        endDate: endDate,
      );
      
      _logger.info('Resumo financeiro obtido');
      return summary;
    } catch (e) {
      _logger.error('Erro ao obter resumo financeiro', e);
      return {
        'deposits': 0.0,
        'sent': 0.0,
        'received': 0.0,
      };
    } finally {
      isLoading.value = false;
    }
  }
}