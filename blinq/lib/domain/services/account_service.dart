import '../repositories/account_repository.dart';
import '../entities/account.dart';

class AccountService {
  final AccountRepository _repository;

  AccountService(this._repository);

  Future<AccountModel?> getAccount(String userId) {
    return _repository.getAccount(userId);
  }

  Future<double> getBalance(String userId) {
    return _repository.getBalance(userId);
  }

  Future<void> createAccount(String userId, String email) {
    return _repository.createAccount(userId, email);
  }

  Future<bool> hasTransactionPassword(String userId) {
    return _repository.hasTransactionPassword(userId);
  }

  Future<bool> validateTransactionPassword(String userId, String password) {
    return _repository.validateTransactionPassword(userId, password);
  }
}