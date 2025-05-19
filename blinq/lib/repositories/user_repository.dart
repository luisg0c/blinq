import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Criar usuário com validações avançadas
  Future<UserModel?> createUser(UserModel user) async {
    try {
      // Verificar se email já existe
      final emailQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        throw Exception('Email já cadastrado');
      }

      // Verificar se número de conta já existe
      final accountQuery = await _firestore
          .collection('users')
          .where('accountNumber', isEqualTo: user.accountNumber)
          .limit(1)
          .get();

      if (accountQuery.docs.isNotEmpty) {
        throw Exception('Número de conta já existe');
      }

      // Adicionar usuário
      final userRef = _firestore.collection('users').doc(user.id);
      await userRef.set(user.toMap());

      return user;
    } catch (e) {
      print('Erro ao criar usuário: $e');
      rethrow;
    }
  }

  // Buscar usuário por ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      return doc.exists ? UserModel.fromMap(doc.data()!, doc.id) : null;
    } catch (e) {
      print('Erro ao buscar usuário: $e');
      return null;
    }
  }

  // Buscar usuário por email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return query.docs.isNotEmpty
          ? UserModel.fromMap(query.docs.first.data(), query.docs.first.id)
          : null;
    } catch (e) {
      print('Erro ao buscar usuário por email: $e');
      return null;
    }
  }

  // Atualizar usuário
  Future<bool> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());

      return true;
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
      return false;
    }
  }

  // Atualizar saldo
  Future<bool> updateBalance(String userId, double amount) async {
    try {
      // Verificar limite de saldo
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final currentBalance = userDoc.data()?['balance'] as double? ?? 0.0;

      final newBalance = currentBalance + amount;

      // Validar saldo
      if (newBalance < 0) {
        throw Exception('Saldo insuficiente');
      }

      // Limite máximo de saldo
      if (newBalance > 1000000.0) {
        throw Exception('Limite de saldo excedido');
      }

      await _firestore.collection('users').doc(userId).update(
          {'balance': newBalance, 'updatedAt': FieldValue.serverTimestamp()});

      return true;
    } catch (e) {
      print('Erro ao atualizar saldo: $e');
      return false;
    }
  }

  // Verificar disponibilidade de número de conta
  Future<bool> isAccountNumberAvailable(String accountNumber) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('accountNumber', isEqualTo: accountNumber)
          .limit(1)
          .get();

      return query.docs.isEmpty;
    } catch (e) {
      print('Erro ao verificar número de conta: $e');
      return false;
    }
  }

  // Buscar usuários com filtros
  Future<List<UserModel>> searchUsers({
    String? name,
    String? email,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore.collection('users');

      if (name != null && name.isNotEmpty) {
        query = query
            .where('name', isGreaterThanOrEqualTo: name)
            .where('name', isLessThanOrEqualTo: name + '\uf8ff');
      }

      if (email != null && email.isNotEmpty) {
        query = query.where('email', isEqualTo: email);
      }

      query = query.limit(limit);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) =>
              UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Erro ao buscar usuários: $e');
      return [];
    }
  }

  // Desativar conta
  Future<bool> deactivateAccount(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update(
          {'isActive': false, 'updatedAt': FieldValue.serverTimestamp()});

      return true;
    } catch (e) {
      print('Erro ao desativar conta: $e');
      return false;
    }
  }
}
