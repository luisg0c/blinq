import '../entities/account.dart';

abstract class AccountRepository {
  Future<AccountModel?> getAccount(String userId);
  Future<double> getBalance(String userId);
  Future<void> createAccount(String userId, String email);
  Future<void> updateBalance(String userId, double amount);
  Future<bool> hasTransactionPassword(String userId);
  Future<void> setTransactionPassword(String userId, String password);
  Future<bool> validateTransactionPassword(String userId, String password);
}