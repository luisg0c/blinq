import '../../../domain/entities/account.dart';

/// Modelo de conta usado na camada de dados.
class AccountModel extends Account {
  const AccountModel({
    required String userId,
    required double balance,
    required bool hasTransactionPassword,
  }) : super(
          userId: userId,
          balance: balance,
          hasTransactionPassword: hasTransactionPassword,
        );

  /// Cria um [AccountModel] a partir de dados do Firestore.
  factory AccountModel.fromFirestore(String userId, Map<String, dynamic> data) {
    return AccountModel(
      userId: userId,
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
      hasTransactionPassword: data['transactionPassword'] != null,
    );
  }

  /// Converte para Map do Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'balance': balance,
      // transactionPassword é gerenciado separadamente por segurança
    };
  }
}