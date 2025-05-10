import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FirebaseService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Autenticação
  Future<User?> signUp(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      return userCredential.user;
    } catch (e) {
      print('Erro no cadastro: $e');
      return null;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return userCredential.user;
    } catch (e) {
      print('Erro no login: $e');
      return null;
    }
  }

  // Operações de Conta
  Future<void> createUserAccount(String userId, String email) async {
    await _firestore.collection('accounts').doc(userId).set({
      'email': email,
      'balance': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp()
    });
  }

  // Métodos adicionais podem ser implementados conforme necessário
}