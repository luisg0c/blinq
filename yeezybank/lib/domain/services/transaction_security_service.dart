// lib/domain/services/transaction_security_service.dart
import 'package:get/get.dart';
import 'dart:math';
import '../../data/repositories/account_repository.dart';

class TransactionSecurityService extends GetxService {
  final AccountRepository _accountRepository = Get.find<AccountRepository>();

  // Cache para controle de duplicidade (manter em memória para detecção rápida)
  final Map<String, DateTime> _recentTransactions = {};

  // Verificar transação duplicada
  bool isRecentDuplicate(String key) {
    if (_recentTransactions.containsKey(key)) {
      final lastProcess = _recentTransactions[key]!;
      return DateTime.now().difference(lastProcess).inSeconds < 30;
    }
    return false;
  }

  // Marcar transação como processada
  void markTransactionAsProcessed(String key) {
    _recentTransactions[key] = DateTime.now();
    _cleanupOldEntries();
  }

  // Limpar entradas antigas do cache
  void _cleanupOldEntries() {
    final now = DateTime.now();
    _recentTransactions.removeWhere((key, timestamp) {
      return now.difference(timestamp).inMinutes > 10;
    });
  }

  // Gerar ID de dispositivo
  String generateDeviceId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final buffer = StringBuffer();

    for (var i = 0; i < 12; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }

    return 'yeezybank_${buffer.toString()}_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Senha de transação
  Future<bool> hasTransactionPassword(String userId) {
    return _accountRepository.hasTransactionPassword(userId);
  }

  Future<void> setTransactionPassword(String userId, String password) {
    return _accountRepository.setTransactionPassword(userId, password);
  }

  Future<bool> validateTransactionPassword(String userId, String password) {
    return _accountRepository.validateTransactionPassword(userId, password);
  }

  // Alterar senha de transação
  Future<void> changeTransactionPassword(
    String userId,
    String oldPassword,
    String newPassword,
  ) async {
    final isValid = await validateTransactionPassword(userId, oldPassword);
    if (!isValid) {
      throw Exception('Senha atual incorreta');
    }
    await setTransactionPassword(userId, newPassword);
  }
}
