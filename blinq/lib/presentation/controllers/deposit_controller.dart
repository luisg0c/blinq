import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/usecases/deposit_usecase.dart';
import '../../core/exceptions/app_exception.dart';

class DepositController extends GetxController {
  final DepositUseCase _depositUseCase;

  DepositController({required DepositUseCase depositUseCase})
      : _depositUseCase = depositUseCase;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxDouble amount = 0.0.obs;
  final RxString description = ''.obs;

  void setDepositData({required double value, String? desc}) {
    amount.value = value;
    description.value = desc ?? 'Depósito';
  }

  Future<void> executeDeposit() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw AppException('Usuário não autenticado');
      }

      if (amount.value <= 0) {
        throw AppException('Valor deve ser maior que zero');
      }

      await _depositUseCase.execute(
        userId: user.uid,
        amount: amount.value,
        description: description.value,
      );

      Get.snackbar(
        'Sucesso! 💰',
        'Depósito de R\$ ${amount.value.toStringAsFixed(2)} realizado',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Volta para home após sucesso
      Get.offAllNamed(AppRoutes.home);

    } on AppException catch (e) {
      errorMessage.value = e.message;
      rethrow;
    } catch (e) {
      errorMessage.value = 'Não foi possível realizar o depósito';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}