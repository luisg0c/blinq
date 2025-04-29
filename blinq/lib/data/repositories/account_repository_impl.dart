import '../models/account_model.dart';

/// Interface para o repositório de contas
abstract class AccountRepository {
  /// Obtém a conta do usuário
  Future<AccountModel?> getAccount(String userId);
  
  /// Obtém um stream da conta do usuário para atualizações em tempo real
  Stream<AccountModel?> getAccountStream(String userId);
  
  /// Cria uma nova conta para o usuário
  Future<AccountModel> createAccount(String userId);
  
  /// Obtém o saldo da conta do usuário
  Future<double> getBalance(String userId);
  
  /// Verifica se o usuário possui uma senha de transação
  Future<bool> hasTransactionPassword(String userId);
  
  /// Define a senha de transação do usuário
  Future<void> setTransactionPassword(String userId, String password);
  
  /// Valida a senha de transação do usuário
  Future<bool> validateTransactionPassword(String userId, String password);
  
  /// Atualiza a senha de transação do usuário
  Future<void> updateTransactionPassword(
    String userId, 
    String currentPassword, 
    String newPassword,
  );
  
  /// Atualiza campos específicos da conta do usuário
  Future<void> updateAccount(String userId, Map<String, dynamic> data);
  
  /// Desativa a conta do usuário
  Future<void> deactivateAccount(String userId);
  
  /// Reativa a conta do usuário
  Future<void> reactivateAccount(String userId);
}