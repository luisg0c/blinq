import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< Updated upstream
import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../models/user.dart' as app_models;
=======
import '../models/user.dart';
import '../core/constants.dart';
>>>>>>> Stashed changes

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

<<<<<<< Updated upstream
  // Obtém o usuário atual do Firebase
  firebase_auth.User? get currentUser => _auth.currentUser;

  // Verifica se o usuário está autenticado
  bool get isAuthenticated => _auth.currentUser != null;

  // Stream de mudanças no estado de autenticação
  Stream<bool> get authStateChanges =>
      _auth.authStateChanges().map((user) => user != null);

  // Obtém o modelo de usuário atual
  Future<app_models.User?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return app_models.User.fromMap(doc.data() ?? {}, doc.id);
      } else {
        // Criar documento de usuário se não existir
        final newUser = app_models.User(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
          isEmailVerified: user.emailVerified,
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(newUser.toMap());

        return newUser;
      }
    } catch (e) {
      debugPrint('Erro ao obter usuário: $e');
      return null;
    }
  }

  // Busca usuário pelo ID
  Future<app_models.User?> getUserById(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return app_models.User.fromMap(doc.data() ?? {}, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar usuário por ID: $e');
      return null;
    }
  }

  // Cadastrar novo usuário
  Future<app_models.User?> signUp(
      String email, String password, String name) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Atualizar o nome do usuário no Firebase Auth
        await result.user!.updateDisplayName(name);

        // Criar o documento do usuário no Firestore
        final user = app_models.User(
=======
  // Stream de estado de autenticação
  Stream<bool> get authStateChanges => 
      _auth.authStateChanges().map((user) => user != null);

  // Obter usuário atual
  Future<User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();
      
      if (doc.exists) {
        return User.fromMap(doc.data() ?? {}, doc.id);
      }
    } catch (e) {
      print('Erro ao obter usuário: $e');
    }
    return null;
  }

  // Cadastrar novo usuário
  Future<User?> signUp(String email, String password, String name) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      if (result.user != null) {
        final user = User(
>>>>>>> Stashed changes
          id: result.user!.uid,
          email: email,
          name: name,
          isEmailVerified: result.user!.emailVerified,
        );
<<<<<<< Updated upstream

=======
        
>>>>>>> Stashed changes
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.id)
            .set(user.toMap());
<<<<<<< Updated upstream

        return user;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Este email já está sendo usado por outra conta.';
          break;
        case 'weak-password':
          errorMessage = 'A senha é muito fraca.';
          break;
        case 'invalid-email':
          errorMessage = 'O email fornecido é inválido.';
          break;
        default:
          errorMessage = 'Ocorreu um erro durante o cadastro: ${e.message}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('Erro no cadastro: $e');
      throw Exception('Erro ao criar conta.');
=======
        
        return user;
      }
    } catch (e) {
      print('Erro no cadastro: $e');
      rethrow;
>>>>>>> Stashed changes
    }
    return null;
  }

<<<<<<< Updated upstream
  // Login com email e senha
  Future<app_models.User?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        return getCurrentUserModel();
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Não existe usuário com este email.';
          break;
        case 'wrong-password':
          errorMessage = 'Senha incorreta.';
          break;
        case 'invalid-email':
          errorMessage = 'O email fornecido é inválido.';
          break;
        case 'user-disabled':
          errorMessage = 'Este usuário foi desativado.';
          break;
        default:
          errorMessage = 'Erro ao fazer login: ${e.message}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('Erro no login: $e');
      throw Exception('Erro ao fazer login.');
=======
  // Login
  Future<User?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      if (result.user != null) {
        return getCurrentUser();
      }
    } catch (e) {
      print('Erro no login: $e');
      rethrow;
>>>>>>> Stashed changes
    }
    return null;
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
<<<<<<< Updated upstream

  // Enviar email de recuperação de senha
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'O email fornecido é inválido.';
          break;
        case 'user-not-found':
          errorMessage = 'Não existe usuário com este email.';
          break;
        default:
          errorMessage = 'Erro ao enviar email: ${e.message}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('Erro ao enviar email de recuperação: $e');
      throw Exception('Erro ao enviar email de recuperação de senha.');
    }
  }

  // Atualizar informações do usuário
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? photoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (name != null) {
        updates['name'] = name;
        // Atualizar o nome no Firebase Auth também
        if (currentUser != null) {
          await currentUser!.updateDisplayName(name);
        }
      }

      if (photoUrl != null) {
        updates['photoUrl'] = photoUrl;
        // Atualizar a foto no Firebase Auth também
        if (currentUser != null) {
          await currentUser!.updatePhotoURL(photoUrl);
        }
      }

      if (updates.isNotEmpty) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .update(updates);
      }
    } catch (e) {
      debugPrint('Erro ao atualizar perfil: $e');
      throw Exception('Erro ao atualizar informações do perfil.');
    }
  }
}
=======
}
>>>>>>> Stashed changes
