import '../../../domain/entities/user.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> getUserById(String userId) async {
    return await remoteDataSource.getUserById(userId);
  }

  @override
  Future<User> getUserByEmail(String email) async {
    return await remoteDataSource.getUserByEmail(email);
  }

  @override
  Future<User> getCurrentUser() async {
    return await remoteDataSource.getCurrentUser();
  }

  @override
  Future<void> createTransactionForUser(String userId, Transaction tx) async {
    await remoteDataSource.createTransactionForUser(userId, tx);
  }

  @override
  Future<void> saveUser(User user) async {
    if (user is! UserModel) {
      throw Exception('Usuário inválido (esperado UserModel)');
    }
    await remoteDataSource.saveUser(user);
  }
}
