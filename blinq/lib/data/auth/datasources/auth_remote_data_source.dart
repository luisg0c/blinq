import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user_model.dart';

/// Contrato que define as operações de autenticação remota.
abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
  Future<void> resetPassword(String email);
}

/// Implementação concreta usando FirebaseAuth.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final fb.FirebaseAuth _firebaseAuth;

  AuthRemoteDataSourceImpl({fb.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fb.User fbUser = credential.user!;
      final token = await fbUser.getIdToken();
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
  Future<UserModel> register(
      String name, String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fb.User fbUser = credential.user!;
      await fbUser.updateDisplayName(name);
      await fbUser.reload();
      final updated = _firebaseAuth.currentUser!;
      final token = await updated.getIdToken();
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
}