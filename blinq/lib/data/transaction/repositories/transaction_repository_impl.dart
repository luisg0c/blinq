// blinq/lib/data/transaction/repositories/transaction_repository_impl.dart
import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_data_source.dart';
import '../models/transaction_model.dart';

/// Implementação do repositório de transações.
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> createTransaction(String userId, Transaction transaction) async {
    try {
      print('🔄 Criando transação: ${transaction.type} - R\$ ${transaction.amount}');
      final model = TransactionModel.fromEntity(transaction);
      await remoteDataSource.addTransaction(userId, model);
      print('✅ Transação criada com sucesso');
    } catch (e) {
      print('❌ Erro ao criar transação: $e');
      rethrow;
    }
  }

  @override
  Future<List<Transaction>> getTransactionsByUser(String userId) async {
    try {
      print('📋 Buscando todas as transações para $userId');
      final transactions = await remoteDataSource.getTransactionsByUser(userId);
      print('📋 ${transactions.length} transações encontradas');
      return transactions;
    } catch (e) {
      print('❌ Erro ao buscar transações: $e');
      rethrow;
    }
  }

  @override
  Future<List<Transaction>> getTransactionsBetween({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      print('📅 Buscando transações entre $start e $end para $userId');
      final transactions = await remoteDataSource.getTransactionsBetween(
        userId: userId,
        start: start,
        end: end,
      );
      print('📅 ${transactions.length} transações encontradas no período');
      return transactions;
    } catch (e) {
      print('❌ Erro ao buscar transações por período: $e');
      rethrow;
    }
  }

  @override
  Stream<List<Transaction>> watchTransactionsByUser(String userId) {
    try {
      print('👀 Iniciando stream de transações para $userId');
      return remoteDataSource.watchTransactionsByUser(userId);
    } catch (e) {
      print('❌ Erro ao iniciar stream de transações: $e');
      rethrow;
    }
  }

  @override
  Future<List<Transaction>> getRecentTransactions(String userId, {int limit = 10}) async {
    try {
      print('📋 Buscando $limit transações mais recentes para $userId');
      final allTransactions = await getTransactionsByUser(userId);
      final recentTransactions = allTransactions.take(limit).toList();
      print('📋 ${recentTransactions.length} transações recentes obtidas');
      return recentTransactions;
    } catch (e) {
      print('❌ Erro ao buscar transações recentes: $e');
      rethrow;
    }
  }
}