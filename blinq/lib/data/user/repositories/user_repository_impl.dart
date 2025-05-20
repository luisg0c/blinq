import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../domain/entities/user.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../transaction/models/transaction_model.dart';

class UserRepositoryImpl implements UserRepository {
  final fs.FirebaseFirestore _firestore;
  final fb.FirebaseAuth _firebaseAuth;

  UserRepositoryImpl({
    fs.FirebaseFirestore? firestore,
    fb.FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? fs.FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;

  @override
  Future<User> getCurrentUser() async {
    final fb.User? fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) throw Exception('Usuário não autenticado');

    return User(
      id: fbUser.uid,
      name: fbUser.displayName ?? '',
      email: fbUser.email!,
    );
  }

  @override
  Future<User> getUserByEmail(String email) async {
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Usuário não encontrado');
    }

    final doc = query.docs.first;
    final data = doc.data();

    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'],
    );
  }

  @override
  Future<void> createTransactionForUser(
      String userId, Transaction transaction) async {
    if (transaction is! TransactionModel) {
      transaction = TransactionModel(
        id: transaction.id,
        amount: transaction.amount,
        date: transaction.date,
        description: transaction.description,
        type: transaction.type,
        counterparty: transaction.counterparty,
        status: transaction.status,
      );
    }

    final doc = (transaction as TransactionModel).toDocument();
    doc['userId'] = userId;

    await _firestore.collection('transactions').add(doc);
  }
}
