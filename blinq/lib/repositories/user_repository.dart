import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> createUser(UserModel user) async {
    try {
      final emailQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();

      if (emailQuery.docs.isNotEmpty) {
        throw Exception('Email já cadastrado');
      }

      final accountQuery = await _firestore
        .collection('users')
        .where('accountNumber', isEqualTo: user.accountNumber)
        .get();

      if (accountQuery.docs.isNotEmpty) {
        throw Exception('Número de conta já existe');
      }

      final docRef = _firestore.collection('users').doc(user.id);
      await docRef.set(user.toMap());
      
      return user;
    } catch (e) {
      print('Erro ao criar usuário: $e');
      return null;
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists 
        ? UserModel.fromMap(doc.data()!, doc.id) 
        : null;
    } catch (e) {
      print('Erro ao buscar usuário: $e');
      return null;
    }
  }

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

  Future<bool> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
      return true;
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
      return false;
    }
  }

  Future<bool> updateBalance(String userId, double amount) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'balance': FieldValue.increment(amount)
      });
      return true;
    } catch (e) {
      print('Erro ao atualizar saldo: $e');
      return false;
    }
  }
}