import '../../../domain/entities/user.dart';
import '../../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';
import '../../auth/models/user_model.dart'; // ✅ Import correto

/// Implementação do repositório de usuários.
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
  Future<void> saveUser(User user) async {
    UserModel userModel;
    
    if (user is UserModel) {
      userModel = user;
    } else {
      userModel = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        token: user.token,
      );
    }
    
    await remoteDataSource.saveUser(userModel);
  }

  @override
  Future<List<User>> searchUsersByEmail(String emailQuery) async {
    final users = await remoteDataSource.searchUsersByEmail(emailQuery);
    return users.cast<User>();
  }
}