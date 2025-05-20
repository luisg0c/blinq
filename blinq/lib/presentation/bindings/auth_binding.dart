import 'package:get/get.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../data/auth/datasources/auth_remote_data_source.dart';
import '../../data/auth/repositories/auth_repository_impl.dart';
import '../controllers/auth_controller.dart';

/// Binding que conecta dependências para o módulo de autenticação.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(),
    );
    Get.lazyPut<AuthRepositoryImpl>(
      () => AuthRepositoryImpl(
        remoteDataSource: Get.find<AuthRemoteDataSource>(),
      ),
    );
    Get.lazyPut<LoginUseCase>(
      () => LoginUseCase(Get.find<AuthRepositoryImpl>()),
    );
    Get.lazyPut<RegisterUseCase>(
      () => RegisterUseCase(Get.find<AuthRepositoryImpl>()),
    );
    Get.lazyPut<ResetPasswordUseCase>(
      () => ResetPasswordUseCase(Get.find<AuthRepositoryImpl>()),
    );
    Get.lazyPut<AuthController>(
      () => AuthController(
        loginUseCase: Get.find<LoginUseCase>(),
        registerUseCase: Get.find<RegisterUseCase>(),
        resetPasswordUseCase: Get.find<ResetPasswordUseCase>(),
      ),
    );
  }
}