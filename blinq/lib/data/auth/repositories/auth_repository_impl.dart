import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

/// Implementação da interface [AuthRepository] usando [AuthRemoteDataSource].
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final UserModel userModel = await remoteDataSource.login(email, password);
    return userModel;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final UserModel userModel =
        await remoteDataSource.register(name, email, password);
    return userModel;
  }

  @override
  Future<void> resetPassword({
    required String email,
  }) async {
    await remoteDataSource.resetPassword(email);
  }
}
