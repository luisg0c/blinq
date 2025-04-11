// lib/domain/services/transaction_validation_service.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../../data/repositories/account_repository.dart';
import 'transaction_security_service.dart';

class TransactionValidationService extends GetxService {
  final AccountRepository _accountRepository = Get.find<AccountRepository>();
  final TransactionSecurityService _securityService =
      Get.find<TransactionSecurityService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String errorSaldoInsuficiente = 'Saldo insuficiente';
  static const String errorDestinatarioNaoEncontrado =
      'Destinatário não encontrado';
  static const String errorValorInvalido = 'Valor inválido';
  static const String errorUsuarioNaoLogado = 'Usuário não logado';
  static const String errorMesmoUsuario =
      'Não é possível transferir para você mesmo';
  static const String errorTransacaoDuplicada =
      'Possível transação duplicada detectada';
  static const String errorTransacaoNaoEncontrada = 'Transação não encontrada';
  static const String errorCodigoInvalido = 'Código de confirmação inválido';
  static const String errorLimiteDiario =
      'Limite diário de transferência excedido';
  static const double LIMITE_ALERTA = 5000.0;
  static const double LIMITE_DIARIO = 10000.0;

  // Validação de transferência
  Future<void> validateTransferPreconditions(
    String senderId,
    String receiverEmail,
    double amount,
  ) async {
    // 1. Validar valor
    if (amount <= 0) {
      throw Exception(errorValorInvalido);
    }

    // 2. Validação para valores altos
    if (amount > LIMITE_ALERTA) {
      print('ALERTA: Transferência acima do limite de alerta: $amount');
    }

    // 3. Verificar possível duplicação
    final duplicateKey = '$senderId-${receiverEmail.toLowerCase()}-$amount';
    if (_securityService.isRecentDuplicate(duplicateKey)) {
      throw Exception(errorTransacaoDuplicada);
    }

    // 4. Verificação de transferência para si mesmo
    final currentUserEmail = await _accountRepository.getCurrentUserEmail();
    if (currentUserEmail != null) {
      final normalizedCurrentEmail = currentUserEmail.toLowerCase().trim();
      final normalizedReceiverEmail = receiverEmail.toLowerCase().trim();

      if (normalizedCurrentEmail == normalizedReceiverEmail) {
        throw Exception(errorMesmoUsuario);
      }
    }

    // 5. Obter conta do destinatário
    final receiver = await _accountRepository.getAccountByEmail(receiverEmail);
    if (receiver == null) {
      throw Exception(errorDestinatarioNaoEncontrado);
    }

    // 6. Verificação adicional por ID
    if (receiver.id == senderId) {
      throw Exception(errorMesmoUsuario);
    }

    // 7. Obter conta do remetente
    final sender = await _accountRepository.getAccount(senderId);
    if (sender == null) {
      throw Exception(errorUsuarioNaoLogado);
    }

    // 8. Verificar saldo suficiente
    if (sender.balance < amount) {
      throw Exception(errorSaldoInsuficiente);
    }

    // 9. Verificar limite diário de transferências
    final withinLimit = await checkDailyTransferLimit(senderId, amount);
    if (!withinLimit) {
      throw Exception(errorLimiteDiario);
    }
  }

  // Validação do código de confirmação
  Future<void> validateConfirmation(
    TransactionModel txn,
    String confirmationCode,
  ) async {
    // Verificar status
    if (txn.status != TransactionStatus.pending) {
      throw Exception('Esta transação não está pendente de confirmação');
    }

    // Verificar código de confirmação
    if (!txn.validateConfirmationCode(confirmationCode)) {
      throw Exception(errorCodigoInvalido);
    }
  }

  // Validação de depósito
  Future<void> validateDeposit(String userId, double amount) async {
    // Validar valor
    if (amount <= 0) {
      throw Exception(errorValorInvalido);
    }

    // Validação adicional para valores altos
    if (amount > LIMITE_ALERTA) {
      print('ALERTA: Depósito acima do limite de alerta: $amount');
    }

    // Verificar duplicidade
    final duplicateKey = '$userId-deposit-$amount';
    if (_securityService.isRecentDuplicate(duplicateKey)) {
      throw Exception(errorTransacaoDuplicada);
    }
  }

  // Verificar limite diário
  Future<bool> checkDailyTransferLimit(String userId, double amount) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final txns =
        await _firestore
            .collection('transactions')
            .where('senderId', isEqualTo: userId)
            .where(
              'timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .where('type', isEqualTo: 'transfer')
            .get();

    double totalTransferred = 0;
    for (final doc in txns.docs) {
      totalTransferred += (doc.data()['amount'] as num).toDouble();
    }

    return (totalTransferred + amount) <= LIMITE_DIARIO;
  }
}
