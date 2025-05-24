// lib/presentation/controllers/transfer_controller.dart

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/exceptions/app_exception.dart';
import '../../../domain/usecases/transfer_usecase.dart';

/// Controller responsável pelo fluxo de transferência de valores.
class TransferController extends GetxController {
  final TransferUseCase _transferUseCase;
  TransferController({required TransferUseCase transferUseCase})
      : _transferUseCase = transferUseCase;

  /// Indica se a operação está em progresso
  final RxBool isLoading = false.obs;

  /// Mensagem de erro de negócio ou técnico (null = sem erro)
  final RxnString errorMessage = RxnString();

  /// E-mail do destinatário
  final RxString recipientEmail = ''.obs;

  /// Valor da transferência
  final RxDouble amount = 0.0.obs;

  /// Configura os dados antes de partir para a confirmação do PIN
  void setTransferData({required String email, required double value}) {
    recipientEmail.value = email;
    amount.value = value;
  }

  /// Executa a transferência após PIN validado
  Future<void> executeTransfer() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Captura o usuário atual
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw AppException('Usuário não autenticado');
      }

      // Chama o método correto do use case
      await _transferUseCase.execute(
        senderId: user.uid,
        receiverEmail: recipientEmail.value,
        amount: amount.value,
      );
    } on AppException catch (e) {
      // Erro de negócio (e-mail não cadastrado, saldo insuficiente etc)
      errorMessage.value = e.message;
      rethrow;
    } catch (e) {
      // Erro genérico
      errorMessage.value = 'Não foi possível completar a transferência.';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
