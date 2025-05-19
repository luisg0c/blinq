import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/user_repository.dart';

class TransactionService {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final UserRepository _userRepository = UserRepository();

  Future<TransactionModel?> deposit({
    required String userId, 
    required double amount
  }) async {
    try {
      if (amount <= 0) {
        throw Exception('Valor de depósito inválido');
      }

      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        throw Exception('Usuário não encontrado');
      }

      final transaction = TransactionModel.deposit(
        userId: userId, 
        amount: amount
      );

      final savedTransaction = await _transactionRepository.createTransaction(transaction);
      
      if (savedTransaction != null) {
        await _userRepository.updateBalance(userId, amount);
      }

      return savedTransaction;
    } catch (e) {
      print('Erro no depósito: $e');
      return null;
    }
  }

  Future<TransactionModel?> transfer({
    required String senderId, 
    required String receiverId, 
    required double amount
  }) async {
    try {
      if (amount <= 0) {
        throw Exception('Valor de transferência inválido');
      }

      final sender = await _userRepository.getUserById(senderId);
      final receiver = await _userRepository.getUserById(receiverId);

      if (sender == null || receiver == null) {
        throw Exception('Usuário remetente ou destinatário não encontrado');
      }

      if (sender.balance < amount) {
        throw Exception('Saldo insuficiente');
      }

      final transaction = TransactionModel.transfer(
        senderId: senderId, 
        receiverId: receiverId, 
        amount: amount
      );

      final savedTransaction = await _transactionRepository.createTransaction(transaction);
      
      if (savedTransaction != null) {
        await _userRepository.updateBalance(senderId, -amount);
        await _userRepository.updateBalance(receiverId, amount);
      }

      return savedTransaction;
    } catch (e) {
      print('Erro na transferência: $e');
      return null;
    }
  }

  Future<List<TransactionModel>> getUserTransactions(String userId) async {
    return await _transactionRepository.getUserTransactions(userId);
  }

  Future<double> getUserBalance(String userId) async {
    try {
      final user = await _userRepository.getUserById(userId);
      return user?.balance ?? 0.0;
    } catch (e) {
      print('Erro ao buscar saldo do usuário: $e');
      return 0.0;
    }
  }

  Future<double> getTotalDeposits(String userId) async {
    return await _transactionRepository.getTotalTransactionsByType(
      userId, 
      TransactionType.deposit
    );
  }

  Future<double> getTotalTransfers(String userId) async {
    return await _transactionRepository.getTotalTransactionsByType(
      userId, 
      TransactionType.transfer
    );
  }
}