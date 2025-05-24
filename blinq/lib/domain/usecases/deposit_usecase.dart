// blinq/lib/domain/usecases/deposit_usecase.dart
import 'package:uuid/uuid.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/account_repository.dart';

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
    print('💰 DepositUseCase - Iniciando depósito para $userId: R\$ $amount');
    print('   Descrição: ${description ?? "Sem descrição"}');

    // Validações
    if (amount <= 0) {
      print('❌ Valor inválido: $amount');
      throw Exception('Valor do depósito deve ser maior que zero');
    }

    if (amount > 50000) {
      print('❌ Valor muito alto: $amount');
      throw Exception('Valor máximo por depósito: R\$ 50.000,00');
    }

    try {
      // 1. Obter saldo atual
      print('💰 Obtendo saldo atual...');
      final currentBalance = await _accountRepository.getBalance(userId);
      print('💰 Saldo atual: R\$ $currentBalance');
      
      // 2. Calcular novo saldo
      final newBalance = currentBalance + amount;
      print('💰 Novo saldo: R\$ $newBalance');
      
      // 3. Criar transação ANTES de atualizar o saldo
      print('📝 Criando transação de depósito...');
      final transaction = Transaction.deposit(
        id: const Uuid().v4(),
        amount: amount,
        description: description ?? 'Depósito PIX',
      );
      
      print('📝 Transação criada: ${transaction.id}');
      print('   Tipo: ${transaction.type}');
      print('   Valor: R\$ ${transaction.amount}');
      print('   Data: ${transaction.date}');
      
      await _transactionRepository.createTransaction(userId, transaction);
      print('✅ Transação de depósito salva no Firebase');
      
      // 4. Atualizar saldo na conta
      print('💰 Atualizando saldo no Firebase...');
      await _accountRepository.updateBalance(userId, newBalance);
      print('✅ Saldo atualizado no Firebase: R\$ $newBalance');

      print('🎉 Depósito concluído com sucesso!');
      
    } catch (e) {
      print('❌ Erro no DepositUseCase: $e');
      print('   Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }
}