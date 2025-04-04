import 'package:get/get.dart';
import '../models/transaction_model.dart';
import '../models/account_model.dart';
import '../../data/firebase_service.dart';

class TransactionService extends GetxService {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  static const String errorSaldoInsuficiente = 'Saldo insuficiente';
  static const String errorDestinatarioNaoEncontrado = 'Destinatário não encontrado';
  static const String errorValorInvalido = 'Valor inválido';
  static const String errorUsuarioNaoLogado = 'Usuário não logado';
  static const String errorMesmoUsuario = 'Não é possível transferir para você mesmo';
  static const double LIMITE_ALERTA = 5000.0; // Novo limite para alertas de segurança

  // Obter saldo do usuário
  Future<double> getUserBalance(String userId) async {
    final account = await _firebaseService.getAccount(userId);
    if (account != null) {
      return account.balance;
    } else {
      // Criar conta se não existir
      await _firebaseService.createAccount(userId, _firebaseService.currentUser!.email!);
      return 0.0;
    }
  }

  // Stream de transações do usuário
  Stream<List<TransactionModel>> getUserTransactionsStream(String userId) {
    return _firebaseService.getUserTransactionsStream(userId);
  }

  // Stream da conta do usuário (para saldo em tempo real)
  Stream<AccountModel> getUserAccountStream(String userId) {
    return _firebaseService.getAccountStream(userId);
  }

  // Realizar depósito
  Future<void> deposit(String userId, double amount) async {
    if (amount <= 0) {
      throw Exception(errorValorInvalido);
    }
    
    // Validação adicional para valores altos
    if (amount > LIMITE_ALERTA) {
      // Apenas registro para log, poderia adicionar validação adicional
      print('ALERTA: Depósito acima do limite de alerta: $amount');
    }

    // Atualizar saldo
    await _firebaseService.updateBalance(userId, amount);

    // Registrar transação
    final txn = TransactionModel(
      id: '',
      senderId: userId,
      receiverId: userId,
      amount: amount,
      timestamp: DateTime.now(),
      participants: [userId],
      type: 'deposit',
    );

    await _firebaseService.addTransaction(txn);
    print('Depósito de $amount realizado com sucesso');
  }

  // Realizar transferência
  Future<void> sendTransaction(TransactionModel txn, String receiverEmail) async {
    if (txn.amount <= 0) {
      throw Exception(errorValorInvalido);
    }

    // Validação adicional para valores altos
    if (txn.amount > LIMITE_ALERTA) {
      print('ALERTA: Transferência acima do limite de alerta: ${txn.amount}');
    }

    // Obter conta do destinatário
    final receiver = await _firebaseService.getAccountByEmail(receiverEmail);
    if (receiver == null) {
      throw Exception(errorDestinatarioNaoEncontrado);
    }

    // Verificar se não é o mesmo usuário
    if (receiver.id == txn.senderId) {
      throw Exception(errorMesmoUsuario);
    }

    // Obter conta do remetente
    final sender = await _firebaseService.getAccount(txn.senderId);
    if (sender == null) {
      throw Exception(errorUsuarioNaoLogado);
    }

    // Verificar saldo suficiente
    if (sender.balance < txn.amount) {
      throw Exception(errorSaldoInsuficiente);
    }

    // Atualizar saldos (débito no remetente)
    await _firebaseService.updateBalance(txn.senderId, -txn.amount);
    
    // Crédito no destinatário
    await _firebaseService.updateBalance(receiver.id, txn.amount);

    // Criar transação com dados completos
    final newTxn = txn.copyWith(
      receiverId: receiver.id,
      timestamp: DateTime.now(),
      participants: [txn.senderId, receiver.id],
      type: 'transfer',
    );

    // Registrar transação
    await _firebaseService.addTransaction(newTxn);
    print('Transferência de ${txn.amount} realizada com sucesso');
  }

  // Gerenciamento de senha de transação
  Future<bool> hasTransactionPassword(String userId) {
    return _firebaseService.hasTransactionPassword(userId);
  }

  Future<void> setTransactionPassword(String userId, String password) {
    return _firebaseService.setTransactionPassword(userId, password);
  }

  Future<bool> validateTransactionPassword(String userId, String password) {
    return _firebaseService.validateTransactionPassword(userId, password);
  }
  
  // NOVA FUNÇÃO: Alterar senha de transação
  Future<void> changeTransactionPassword(String userId, String oldPassword, String newPassword) async {
    // Validar senha atual
    final isValid = await validateTransactionPassword(userId, oldPassword);
    if (!isValid) {
      throw Exception('Senha atual incorreta');
    }
    
    // Definir nova senha
    await setTransactionPassword(userId, newPassword);
  }
}