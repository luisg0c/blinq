import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../entities/user.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/account_repository.dart';
import '../repositories/user_repository.dart';

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

    // Validações básicas
    if (amount <= 0) {
      throw Exception('Valor da transferência deve ser maior que zero');
    }

    try {
      // 1. Buscar destinatário pelo email
      final receiver = await _userRepository.getUserByEmail(receiverEmail);
      
      if (senderId == receiver.id) {
        throw Exception('Você não pode transferir para si mesmo');
      }

      // ✅ USANDO TRANSAÇÃO ATÔMICA DO FIRESTORE
      final firestore = FirebaseFirestore.instance;
      
      await firestore.runTransaction((transaction) async {
        
        // 2. Verificar saldo do remetente
        final senderAccountRef = firestore.collection('accounts').doc(senderId);
        final senderAccountSnap = await transaction.get(senderAccountRef);
        
        if (!senderAccountSnap.exists) {
          throw Exception('Conta do remetente não encontrada');
        }
        
        final senderBalance = (senderAccountSnap.data()!['balance'] as num?)?.toDouble() ?? 0.0;
        
        if (senderBalance < amount) {
          throw Exception('Saldo insuficiente. Disponível: R\$ ${senderBalance.toStringAsFixed(2)}');
        }
        
        // 3. Verificar conta do destinatário
        final receiverAccountRef = firestore.collection('accounts').doc(receiver.id);
        final receiverAccountSnap = await transaction.get(receiverAccountRef);
        
        if (!receiverAccountSnap.exists) {
          throw Exception('Conta do destinatário não encontrada');
        }
        
        final receiverBalance = (receiverAccountSnap.data()!['balance'] as num?)?.toDouble() ?? 0.0;
        
        // 4. Atualizar saldos
        final newSenderBalance = senderBalance - amount;
        final newReceiverBalance = receiverBalance + amount;
        
        print('💸 Atualizando saldos:');
        print('   Remetente: R\$ $senderBalance → R\$ $newSenderBalance');
        print('   Destinatário: R\$ $receiverBalance → R\$ $newReceiverBalance');
        
        transaction.update(senderAccountRef, {
          'balance': newSenderBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        transaction.update(receiverAccountRef, {
          'balance': newReceiverBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // 5. Criar transação de saída (remetente)
        final outgoingTransactionId = const Uuid().v4();
        final outgoingTransactionRef = firestore.collection('transactions').doc(outgoingTransactionId);
        
        transaction.set(outgoingTransactionRef, {
          'userId': senderId,
          'type': 'transfer',
          'amount': -amount, // Negativo para o remetente
          'description': description ?? 'Transferência PIX',
          'counterparty': receiver.name,
          'status': 'completed',
          'date': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'relatedUserId': receiver.id,
        });
        
        // 6. Criar transação de entrada (destinatário)
        final incomingTransactionId = const Uuid().v4();
        final incomingTransactionRef = firestore.collection('transactions').doc(incomingTransactionId);
        
        transaction.set(incomingTransactionRef, {
          'userId': receiver.id,
          'type': 'receive',
          'amount': amount, // Positivo para o destinatário
          'description': description ?? 'Transferência PIX recebida',
          'counterparty': 'Recebido via PIX',
          'status': 'completed',
          'date': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'relatedUserId': senderId,
        });
        
        print('📝 Transações criadas:');
        print('   Saída: $outgoingTransactionId');
        print('   Entrada: $incomingTransactionId');
      });

      print('✅ Transferência concluída com sucesso!');
      
    } catch (e) {
      print('❌ Erro no TransferUseCase: $e');
      rethrow;
    }
  }
}