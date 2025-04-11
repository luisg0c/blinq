// lib/data/repositories/account_repository.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/firebase_service.dart';
import '../../domain/models/account_model.dart';

class AccountRepository extends GetxService {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obter saldo do usuário
  Future<double> getBalance(String userId) async {
    final account = await _firebaseService.getAccount(userId);
    if (account != null) {
      return account.balance;
    } else {
      // Criar conta se não existir
      await _firebaseService.createAccount(
        userId,
        _firebaseService.currentUser!.email!,
      );
      return 0.0;
    }
  }

  // Obter conta do usuário
  Future<AccountModel?> getAccount(String userId) async {
    return await _firebaseService.getAccount(userId);
  }

  // Stream da conta do usuário
  Stream<AccountModel> getAccountStream(String userId) {
    return _firebaseService.getAccountStream(userId);
  }

  // Obter conta por email
  Future<AccountModel?> getAccountByEmail(String email) async {
    return await _firebaseService.getAccountByEmail(email);
  }

  // Atualizar conta
  Future<void> updateAccount(String userId, Map<String, dynamic> data) async {
    await _firebaseService.updateAccount(userId, data);
  }

  // Atualizar saldo
  Future<void> updateBalance(String userId, double newBalance) async {
    await _firebaseService.updateAccount(userId, {'balance': newBalance});
  }

  // Obter email do usuário atual
  Future<String?> getCurrentUserEmail() async {
    return _firebaseService.currentUser?.email;
  }

  // Senha de transação
  Future<bool> hasTransactionPassword(String userId) {
    return _firebaseService.hasTransactionPassword(userId);
  }

  Future<void> setTransactionPassword(String userId, String password) {
    return _firebaseService.setTransactionPassword(userId, password);
  }

  Future<bool> validateTransactionPassword(String userId, String password) {
    return _firebaseService.validateTransactionPassword(userId, password);
  }
}
