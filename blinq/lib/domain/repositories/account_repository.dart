import '../entities/account.dart';

/// Contrato da camada de domínio para operações de conta.
abstract class AccountRepository {
  /// Obtém informações completas da conta do usuário.
  Future<Account> getAccount(String userId);
  
  /// Obtém apenas o saldo atual do usuário.
  Future<double> getBalance(String userId);
  
  /// Atualiza o saldo da conta.
  Future<void> updateBalance(String userId, double newBalance);
  
  /// Define a senha de transação.
  Future<void> setTransactionPassword(String userId, String password);
  
  /// Valida a senha de transação.
  Future<bool> validateTransactionPassword(String userId, String password);
  
  /// Verifica se o usuário já tem senha de transação configurada.
  Future<bool> hasTransactionPassword(String userId);
  
  /// Stream para observar mudanças no saldo em tempo real.
  Stream<double> watchBalance(String userId);
}