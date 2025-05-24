// lib/domain/usecases/deposit_usecase.dart

import 'package:uuid/uuid.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/account_repository.dart';
import '../../core/services/notification_service.dart';

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
    print('💰 Iniciando depósito para $userId: R\$ $amount');

    if (amount <= 0) {
      throw Exception('Valor do depósito deve ser maior que zero');
    }

    if (amount > 50000) {
      throw Exception('Valor máximo por depósito: R\$ 50.000,00');
    }

    try {
      // 1. Obter saldo atual
      final currentBalance = await _accountRepository.getBalance(userId);
      print('💰 Saldo atual: R\$ $currentBalance');
      
      // 2. Calcular novo saldo
      final newBalance = currentBalance + amount;
      print('💰 Novo saldo: R\$ $newBalance');
      
      // 3. Atualizar saldo na conta
      await _accountRepository.updateBalance(userId, newBalance);
      print('✅ Saldo atualizado no banco');
      
      // 4. Criar registro da transação
      final transaction = Transaction.deposit(
        id: const Uuid().v4(),
        amount: amount,
        description: description ?? 'Depósito',
      );
      
      await _transactionRepository.createTransaction(userId, transaction);
      print('✅ Transação de depósito criada');

      // 5. ✅ Enviar notificação de confirmação
      try {
        await NotificationService.sendDepositConfirmedNotification(
          amount: amount,
        );
        print('📱 Notificação de depósito enviada');
      } catch (e) {
        print('⚠️ Erro ao enviar notificação (não crítico): $e');
        // Não falhar o depósito por causa da notificação
      }

      print('🎉 Depósito concluído com sucesso!');
      
    } catch (e) {
      print('❌ Erro no depósito: $e');
      rethrow;
    }
  }
}