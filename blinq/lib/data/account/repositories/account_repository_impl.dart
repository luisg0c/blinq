import '../../../domain/entities/account.dart';
import '../../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_data_source.dart';
import '../models/account_model.dart';

/// Implementação do repositório de conta.
class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;

  AccountRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Account> getAccount(String userId) async {
    final balance = await remoteDataSource.getBalance(userId);
    final hasPassword = await remoteDataSource.hasTransactionPassword(userId);
    
    return AccountModel(
      userId: userId,
      balance: balance,
      hasTransactionPassword: hasPassword,
    );
  }

  @override
  Future<double> getBalance(String userId) {
    return remoteDataSource.getBalance(userId);
  }

  @override
  Future<void> updateBalance(String userId, double newBalance) {
    return remoteDataSource.updateBalance(userId, newBalance);
  }

  @override
  Future<void> setTransactionPassword(String userId, String password) {
    return remoteDataSource.setTransactionPassword(userId, password);
  }

  @override
  Future<bool> validateTransactionPassword(String userId, String password) {
    return remoteDataSource.validateTransactionPassword(userId, password);
  }

  @override
  Future<bool> hasTransactionPassword(String userId) {
    return remoteDataSource.hasTransactionPassword(userId);
  }

  @override
  Stream<double> watchBalance(String userId) {
    return remoteDataSource.watchBalance(userId);
  }
}