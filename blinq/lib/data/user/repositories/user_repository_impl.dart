// lib/data/user/repositories/user_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/user_repository.dart';

/// Implementação simplificada do repositório de usuários.
class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;

  UserRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<User> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('accounts').doc(userId).get();
      if (!doc.exists) throw Exception('Usuário não encontrado');
      
      final data = doc.data()!;
      final userData = data['user'] as Map<String, dynamic>? ?? {};
      
      return User(
        id: userId,
        name: userData['name']?.toString() ?? '',
        email: userData['email']?.toString() ?? '',
        token: '', // Token será obtido via Firebase Auth
      );
    } catch (e) {
      print('❌ Erro ao buscar usuário: $e');
      rethrow;
    }
  }

  @override
  Future<User> getUserByEmail(String email) async {
    try {
      final snapshot = await _firestore
          .collection('accounts')
          .where('user.email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Usuário com email $email não encontrado');
      }

      final doc = snapshot.docs.first;
      final data = doc.data();
      final userData = data['user'] as Map<String, dynamic>? ?? {};
      
      return User(
        id: doc.id,
        name: userData['name']?.toString() ?? '',
        email: userData['email']?.toString() ?? '',
        token: '',
      );
    } catch (e) {
      print('❌ Erro ao buscar usuário por email: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveUser(User user) async {
    try {
      await _firestore.collection('accounts').doc(user.id).update({
        'user': {
          'id': user.id,
          'name': user.name,
          'email': user.email,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Erro ao salvar usuário: $e');
      rethrow;
    }
  }

  @override
  Future<List<User>> searchUsersByEmail(String emailQuery) async {
    try {
      if (emailQuery.isEmpty) return [];

      final snapshot = await _firestore
          .collection('accounts')
          .where('user.email', isGreaterThanOrEqualTo: emailQuery)
          .where('user.email', isLessThan: '$emailQuery\uf8ff')
          .limit(10)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final userData = data['user'] as Map<String, dynamic>? ?? {};
        
        return User(
          id: doc.id,
          name: userData['name']?.toString() ?? '',
          email: userData['email']?.toString() ?? '',
          token: '',
        );
      }).toList();
    } catch (e) {
      print('❌ Erro ao buscar usuários: $e');
      return [];
    }
  }
}