import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/models/user_model.dart'; // ✅ Import correto

/// Contrato da fonte de dados remota para usuários.
abstract class UserRemoteDataSource {
  Future<UserModel> getUserById(String userId);
  Future<UserModel> getUserByEmail(String email);
  Future<void> saveUser(UserModel user);
  Future<List<UserModel>> searchUsersByEmail(String emailQuery);
}

/// Implementação usando Firebase Firestore (accounts collection).
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore _firestore;

  UserRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel> getUserById(String userId) async {
    final doc = await _firestore.collection('accounts').doc(userId).get();
    if (!doc.exists) throw Exception('Usuário não encontrado');
    
    final data = doc.data()!;
    return UserModel.fromFirestore(data);
  }

  @override
  Future<UserModel> getUserByEmail(String email) async {
    final snapshot = await _firestore
        .collection('accounts')
        .where('user.email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('Usuário com email $email não encontrado');
    }

    final data = snapshot.docs.first.data();
    return UserModel.fromFirestore(data);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _firestore.collection('accounts').doc(user.id).update({
      'user': user.toFirestoreUser(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<UserModel>> searchUsersByEmail(String emailQuery) async {
    if (emailQuery.isEmpty) return [];

    final snapshot = await _firestore
        .collection('accounts')
        .where('user.email', isGreaterThanOrEqualTo: emailQuery)
        .where('user.email', isLessThan: '$emailQuery\uf8ff')
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc.data()))
        .toList();
  }
}