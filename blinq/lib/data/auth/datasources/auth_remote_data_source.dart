import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Contrato que define as operações de autenticação remota.
abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
  Future<void> resetPassword(String email);
}

/// Implementação concreta usando FirebaseAuth + Firestore.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    fb.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final fb.User fbUser = credential.user!;
      final token = await fbUser.getIdToken();
      if (token == null) throw Exception('Token de autenticação inválido');

      return UserModel(
        id: fbUser.uid,
        name: fbUser.displayName ?? '',
        email: fbUser.email!,
        token: token,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw Exception('Falha no login: ${e.message}');
    }
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    try {
      // 1. Criar usuário no Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final fb.User fbUser = credential.user!;
      await fbUser.updateDisplayName(name);
      await fbUser.reload();

      // 2. Criar conta no Firestore seguindo estrutura YeezyBank
      await _createUserAccount(fbUser.uid, name, email);

      final updated = _firebaseAuth.currentUser!;
      final token = await updated.getIdToken();
      if (token == null) throw Exception('Token de autenticação inválido');

      return UserModel(
        id: updated.uid,
        name: updated.displayName ?? name,
        email: updated.email!,
        token: token,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw Exception('Falha no registro: ${e.message}');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw Exception('Erro ao enviar e-mail de recuperação: ${e.message}');
    }
  }

  /// Cria a conta do usuário no Firestore seguindo estrutura YeezyBank.
  Future<void> _createUserAccount(String userId, String name, String email) async {
    await _firestore.collection('accounts').doc(userId).set({
      'balance': 0.0,
      'transactionPassword': null, // Será configurado na primeira transação
      'createdAt': FieldValue.serverTimestamp(),
      'user': {
        'id': userId,
        'name': name,
        'email': email,
      },
    });
  }
}