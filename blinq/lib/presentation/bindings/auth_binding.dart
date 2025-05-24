import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../data/auth/datasources/auth_remote_data_source.dart';
import '../../data/auth/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';

/// Binding para autenticação.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(),
    );

    // Repository
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: Get.find<AuthRemoteDataSource>(),
      ),
    );

    // Use Cases
    Get.lazyPut<LoginUseCase>(
      () => LoginUseCase(Get.find<AuthRepository>()),
    );

    Get.lazyPut<RegisterUseCase>(
      () => RegisterUseCase(Get.find<AuthRepository>()),
    );

    Get.lazyPut<ResetPasswordUseCase>(
      () => ResetPasswordUseCase(Get.find<AuthRepository>()),
    );

    // Controller
    Get.lazyPut(() => AuthController(
      loginUseCase: Get.find<LoginUseCase>(),
      registerUseCase: Get.find<RegisterUseCase>(),
      resetPasswordUseCase: Get.find<ResetPasswordUseCase>(),
    ));
  }
}