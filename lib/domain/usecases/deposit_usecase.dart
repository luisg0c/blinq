import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/account_repository.dart';

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

    // Validações básicas
    if (amount <= 0) {
      throw Exception('Valor do depósito deve ser maior que zero');
    }
    if (amount > 50000) {
      throw Exception('Valor máximo por depósito: R\$ 50.000,00');
    }

    try {
      // ✅ USANDO TRANSAÇÃO ATÔMICA DO FIRESTORE
      final firestore = FirebaseFirestore.instance;
      
      await firestore.runTransaction((transaction) async {
        
        // 1. Obter saldo atual
        final accountRef = firestore.collection('accounts').doc(userId);
        final accountSnap = await transaction.get(accountRef);
        
        if (!accountSnap.exists) {
          throw Exception('Conta não encontrada');
        }
        
        final currentBalance = (accountSnap.data()!['balance'] as num?)?.toDouble() ?? 0.0;
        final newBalance = currentBalance + amount;
        
        print('💰 Saldo atual: R\$ $currentBalance');
        print('💰 Novo saldo: R\$ $newBalance');
        
        // 2. Atualizar saldo
        transaction.update(accountRef, {
          'balance': newBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // 3. Criar transação global
        final transactionId = const Uuid().v4();
        final transactionRef = firestore.collection('transactions').doc(transactionId);
        
        transaction.set(transactionRef, {
          'userId': userId,
          'type': 'deposit',
          'amount': amount,
          'description': description ?? 'Depósito PIX',
          'counterparty': 'Depósito',
          'status': 'completed',
          'date': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        print('📝 Transação criada: $transactionId');
      });

      print('✅ Depósito concluído com sucesso!');
      
    } catch (e) {
      print('❌ Erro no DepositUseCase: $e');
      rethrow;
    }
  }
}