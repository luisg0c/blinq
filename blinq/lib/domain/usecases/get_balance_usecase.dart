import '../repositories/account_repository.dart';

/// Caso de uso para obter o saldo atual do usuário.
class GetBalanceUseCase {
  final AccountRepository _accountRepository;

  GetBalanceUseCase(this._accountRepository);

  Future<double> execute(String userId) {
    return _accountRepository.getBalance(userId);
  }
}