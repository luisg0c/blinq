import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../entities/user.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/account_repository.dart';
import '../repositories/user_repository.dart';
import '../../core/exceptions/app_exception.dart';

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
    print('💸 TransferUseCase - Iniciando transferência');
    print('   Remetente: $senderId');
    print('   Destinatário: $receiverEmail');
    print('   Valor: R\$ $amount');

    // ✅ VALIDAÇÕES BÁSICAS MELHORADAS
    try {
      if (amount <= 0) {
        throw const AppException('Valor da transferência deve ser maior que zero');
      }

      if (amount > 50000) {
        throw const AppException('Valor máximo por transferência: R\$ 50.000,00');
      }

      if (senderId.trim().isEmpty || receiverEmail.trim().isEmpty) {
        throw const AppException('Dados de transferência inválidos');
      }

      // ✅ BUSCAR DESTINATÁRIO COM TRATAMENTO DE ERRO
      print('🔍 Buscando destinatário...');
      User receiver;
      try {
        receiver = await _userRepository.getUserByEmail(receiverEmail);
        print('✅ Destinatário encontrado: ${receiver.name}');
      } catch (e) {
        print('❌ Erro ao buscar destinatário: $e');
        throw const AppException('Destinatário não encontrado no Blinq');
      }
      
      if (senderId == receiver.id) {
        throw const AppException('Você não pode transferir para si mesmo');
      }

      // ✅ VERIFICAR SALDO ANTES DA TRANSAÇÃO
      print('💰 Verificando saldo do remetente...');
      double senderBalance;
      try {
        senderBalance = await _accountRepository.getBalance(senderId);
        print('💰 Saldo atual: R\$ $senderBalance');
      } catch (e) {
        print('❌ Erro ao obter saldo: $e');
        throw const AppException('Erro ao verificar saldo');
      }

      if (senderBalance < amount) {
        throw AppException('Saldo insuficiente. Disponível: R\$ ${senderBalance.toStringAsFixed(2)}');
      }

      // ✅ EXECUTAR TRANSAÇÃO ATÔMICA COM MELHOR TRATAMENTO DE ERRO
      print('🔄 Executando transação atômica...');
      await _executeAtomicTransfer(senderId, receiver, amount, description ?? 'Transferência PIX');
      
      print('✅ Transferência concluída com sucesso!');

    } catch (e) {
      print('❌ Erro no TransferUseCase: $e');
      
      // ✅ RELANÇAR EXCEÇÕES DE NEGÓCIO
      if (e is AppException) {
        rethrow;
      }
      
      // ✅ CONVERTER ERROS TÉCNICOS EM ERROS DE NEGÓCIO
      String errorMessage = 'Erro interno na transferência';
      
      if (e.toString().contains('PERMISSION_DENIED')) {
        errorMessage = 'Permissão negada. Verifique sua autenticação.';
      } else if (e.toString().contains('UNAVAILABLE')) {
        errorMessage = 'Serviço temporariamente indisponível. Tente novamente.';
      } else if (e.toString().contains('DEADLINE_EXCEEDED')) {
        errorMessage = 'Tempo limite excedido. Verifique sua conexão.';
      } else if (e.toString().contains('NOT_FOUND')) {
        errorMessage = 'Conta não encontrada.';
      }
      
      throw AppException(errorMessage);
    }
  }

  /// ✅ MÉTODO SEPARADO PARA TRANSAÇÃO ATÔMICA
  Future<void> _executeAtomicTransfer(
    String senderId,
    User receiver,
    double amount,
    String description,
  ) async {
    final firestore = FirebaseFirestore.instance;
    
    try {
      await firestore.runTransaction((transaction) async {
        print('🔄 Iniciando transação atômica...');
        
        // ✅ REFERÊNCIAS
        final senderAccountRef = firestore.collection('accounts').doc(senderId);
        final receiverAccountRef = firestore.collection('accounts').doc(receiver.id);
        
        // ✅ OBTER DOCUMENTOS ATUAIS
        DocumentSnapshot senderAccountSnap;
        DocumentSnapshot receiverAccountSnap;
        
        try {
          senderAccountSnap = await transaction.get(senderAccountRef);
          receiverAccountSnap = await transaction.get(receiverAccountRef);
        } catch (e) {
          print('❌ Erro ao obter documentos: $e');
          throw const AppException('Erro ao acessar contas');
        }
        
        // ✅ VERIFICAR EXISTÊNCIA DAS CONTAS
        if (!senderAccountSnap.exists) {
          throw const AppException('Conta do remetente não encontrada');
        }
        
        if (!receiverAccountSnap.exists) {
          throw const AppException('Conta do destinatário não encontrada');
        }
        
        // ✅ OBTER SALDOS ATUAIS COM VERIFICAÇÃO
        final senderData = senderAccountSnap.data() as Map<String, dynamic>?;
        final receiverData = receiverAccountSnap.data() as Map<String, dynamic>?;
        
        if (senderData == null || receiverData == null) {
          throw const AppException('Dados das contas inválidos');
        }
        
        final senderBalance = (senderData['balance'] as num?)?.toDouble() ?? 0.0;
        final receiverBalance = (receiverData['balance'] as num?)?.toDouble() ?? 0.0;
        
        // ✅ VERIFICAÇÃO FINAL DE SALDO
        if (senderBalance < amount) {
          throw AppException('Saldo insuficiente. Disponível: R\$ ${senderBalance.toStringAsFixed(2)}');
        }
        
        // ✅ CALCULAR NOVOS SALDOS
        final newSenderBalance = senderBalance - amount;
        final newReceiverBalance = receiverBalance + amount;
        
        print('💸 Atualizando saldos:');
        print('   Remetente: R\$ $senderBalance → R\$ $newSenderBalance');
        print('   Destinatário: R\$ $receiverBalance → R\$ $newReceiverBalance');
        
        // ✅ ATUALIZAR SALDOS
        try {
          transaction.update(senderAccountRef, {
            'balance': newSenderBalance,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          
          transaction.update(receiverAccountRef, {
            'balance': newReceiverBalance,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          print('❌ Erro ao atualizar saldos: $e');
          throw const AppException('Erro ao atualizar saldos');
        }
        
        // ✅ CRIAR TRANSAÇÕES COM IDs ÚNICOS
        final timestamp = FieldValue.serverTimestamp();
        
        // Transação de saída (remetente)
        final outgoingTransactionId = 'tx_out_${const Uuid().v4()}';
        final outgoingTransactionRef = firestore.collection('transactions').doc(outgoingTransactionId);
        
        try {
          transaction.set(outgoingTransactionRef, {
            'userId': senderId,
            'type': 'transfer',
            'amount': -amount, // Negativo para o remetente
            'description': description,
            'counterparty': receiver.name,
            'status': 'completed',
            'date': timestamp,
            'createdAt': timestamp,
            'relatedUserId': receiver.id,
            'transferDirection': 'outgoing',
          });
        } catch (e) {
          print('❌ Erro ao criar transação de saída: $e');
          throw const AppException('Erro ao registrar transação de saída');
        }
        
        // Transação de entrada (destinatário)
        final incomingTransactionId = 'tx_in_${const Uuid().v4()}';
        final incomingTransactionRef = firestore.collection('transactions').doc(incomingTransactionId);
        
        try {
          transaction.set(incomingTransactionRef, {
            'userId': receiver.id,
            'type': 'receive',
            'amount': amount, // Positivo para o destinatário
            'description': 'Transferência PIX recebida',
            'counterparty': 'Recebido de remetente',
            'status': 'completed',
            'date': timestamp,
            'createdAt': timestamp,
            'relatedUserId': senderId,
            'transferDirection': 'incoming',
          });
        } catch (e) {
          print('❌ Erro ao criar transação de entrada: $e');
          throw const AppException('Erro ao registrar transação de entrada');
        }
        
        print('📝 Transações criadas:');
        print('   Saída: $outgoingTransactionId');
        print('   Entrada: $incomingTransactionId');
      });
      
      print('✅ Transação atômica concluída com sucesso');
      
    } catch (e) {
      print('❌ Erro na transação atômica: $e');
      
      // ✅ RELANÇAR EXCEÇÕES DE NEGÓCIO
      if (e is AppException) {
        rethrow;
      }
      
      // ✅ CONVERTER ERROS DO FIRESTORE
      if (e.toString().contains('aborted')) {
        throw const AppException('Transação foi abortada. Tente novamente.');
      } else if (e.toString().contains('deadline-exceeded')) {
        throw const AppException('Tempo limite excedido. Verifique sua conexão.');
      } else if (e.toString().contains('permission-denied')) {
        throw const AppException('Permissão negada. Faça login novamente.');
      }
      
      throw const AppException('Erro interno na transferência');
    }
  }

  /// ✅ MÉTODO PARA VERIFICAR LIMITES (FUTURO)
  Future<void> _validateTransferLimits(String userId, double amount) async {
    try {
      // TODO: Implementar verificação de limites diários/mensais
      const dailyLimit = 5000.0;
      const perTransactionLimit = 2000.0;
      
      if (amount > perTransactionLimit) {
        throw AppException('Valor excede o limite por transação: R\$ ${perTransactionLimit.toStringAsFixed(2)}');
      }
      
      // Aqui seria verificado o total gasto no dia
      // final todaySpent = await _getTodaySpentAmount(userId);
      // if (todaySpent + amount > dailyLimit) { ... }
      
    } catch (e) {
      print('❌ Erro na validação de limites: $e');
      rethrow;
    }
  }
}