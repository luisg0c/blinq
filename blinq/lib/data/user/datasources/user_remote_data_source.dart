import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import '../../../domain/entities/transaction.dart';
import '../models/user_model.dart';

/// Contrato da fonte de dados remota para usuários.
abstract class UserRemoteDataSource {
  Future<UserModel> getUserById(String userId);
  Future<UserModel> getUserByEmail(String email);
  Future<UserModel> getCurrentUser(); // requer FirebaseAuth se necessário
  Future<void> saveUser(UserModel user);
  Future<void> createTransactionForUser(String userId, Transaction transaction);
}

/// Implementação usando Firebase Firestore.
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final fs.FirebaseFirestore _firestore;

  UserRemoteDataSourceImpl({fs.FirebaseFirestore? firestore})
      : _firestore = firestore ?? fs.FirebaseFirestore.instance;

  @override
  Future<UserModel> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) throw Exception('Usuário não encontrado');
    return UserModel.fromMap(doc.data()!);
  }

  @override
  Future<UserModel> getUserByEmail(String email) async {
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('Usuário com email $email não encontrado');
    }

    return UserModel.fromMap(snapshot.docs.first.data());
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  @override
  Future<void> createTransactionForUser(
      String userId, Transaction transaction) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .add({
      'id': transaction.id,
      'amount': transaction.amount,
      'date': transaction.date.toIso8601String(),
      'description': transaction.description,
      'type': transaction.type,
      'counterparty': transaction.counterparty,
      'status': transaction.status,
    });
  }

  @override
  Future<UserModel> getCurrentUser() {
    throw UnimplementedError(
        'getCurrentUser requer FirebaseAuth ou contexto externo');
  }
}
