import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import 'dart:math';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();

  String _generateAccountNumber() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<UserModel?> signUp({
    required String name,
    required String email, 
    required String password,
    DateTime? birthDate,
  }) async {
    try {
      final existingUser = await _userRepository.getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('Email já cadastrado');
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      if (userCredential.user == null) {
        throw Exception('Falha ao criar usuário');
      }

      String accountNumber;
      do {
        accountNumber = _generateAccountNumber();
      } while (await _userRepository.getUserByEmail(accountNumber) != null);

      final user = UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        accountNumber: accountNumber,
        birthDate: birthDate,
        isEmailVerified: false
      );

      final savedUser = await _userRepository.createUser(user);
      
      if (savedUser == null) {
        await userCredential.user!.delete();
        throw Exception('Falha ao salvar usuário');
      }

      return savedUser;
    } catch (e) {
      print('Erro no cadastro: $e');
      return null;
    }
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );

      if (userCredential.user == null) {
        throw Exception('Usuário não encontrado');
      }

      return await _userRepository.getUserById(userCredential.user!.uid);
    } catch (e) {
      print('Erro no login: $e');
      return null;
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      return await _userRepository.getUserByEmail(email);
    } catch (e) {
      print('Erro ao buscar usuário por email: $e');
      return null;
    }
  }

  UserModel? getCurrentUser() {
    final user = _auth.currentUser;
    return user != null 
      ? UserModel(
          id: user.uid,
          email: user.email!,
          name: user.displayName ?? '',
          accountNumber: '', 
          isEmailVerified: user.emailVerified
        )
      : null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}