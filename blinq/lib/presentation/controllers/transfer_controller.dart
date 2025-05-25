import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/exceptions/app_exception.dart';
import '../../domain/usecases/transfer_usecase.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../core/services/notification_service.dart';

/// Controller robusto para o fluxo completo de transferências
class TransferController extends GetxController {
  final TransferUseCase _transferUseCase;

  TransferController({required TransferUseCase transferUseCase})
      : _transferUseCase = transferUseCase;

  // ✅ OBSERVABLES DE ESTADO
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();
  
  // ✅ DADOS DA TRANSFERÊNCIA
  final RxString recipientEmail = ''.obs;
  final RxDouble amount = 0.0.obs;
  final RxString description = ''.obs;
  final RxnString recipientName = RxnString();
  final RxnString recipientId = RxnString();

  // ✅ CONTROLE DE TENTATIVAS E FEEDBACK
  final RxInt attemptCount = 0.obs;
  final RxBool isRetrying = false.obs;
  final RxDouble transferProgress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    print('🔧 TransferController inicializado');
  }

  @override
  void onClose() {
    _clearSensitiveData();
    super.onClose();
  }

  /// ✅ CONFIGURAR DADOS DA TRANSFERÊNCIA COM VALIDAÇÃO
  void setTransferData({
    required String email,
    required double value,
    String? desc,
    String? recipientUserName,
    String? recipientUserId,
  }) {
    try {
      print('📝 Configurando dados da transferência...');
      
      // Validações básicas
      if (email.trim().isEmpty) {
        throw const AppException('Email do destinatário é obrigatório');
      }
      
      if (value <= 0) {
        throw const AppException('Valor deve ser maior que zero');
      }
      
      if (value > 50000) {
        throw const AppException('Valor máximo por transferência: R\$ 50.000,00');
      }

      // Verificar se não é auto-transferência
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser?.email?.toLowerCase() == email.toLowerCase()) {
        throw const AppException('Você não pode transferir para si mesmo');
      }

      // Configurar dados
      recipientEmail.value = email.trim().toLowerCase();
      amount.value = value;
      description.value = desc?.trim() ?? 'Transferência PIX';
      recipientName.value = recipientUserName;
      recipientId.value = recipientUserId;

      // Limpar estados anteriores
      errorMessage.value = null;
      successMessage.value = null;
      attemptCount.value = 0;
      transferProgress.value = 0.0;

      print('✅ Dados configurados:');
      print('   Destinatário: ${recipientEmail.value}');
      print('   Valor: R\$ ${amount.value.toStringAsFixed(2)}');
      print('   Descrição: ${description.value}');

    } catch (e) {
      print('❌ Erro ao configurar dados: $e');
      errorMessage.value = e.toString().replaceAll('AppException: ', '');
      _showErrorFeedback(errorMessage.value!);
    }
  }

  /// ✅ EXECUTAR TRANSFERÊNCIA COM PROGRESSO E RETRY
  Future<void> executeTransfer() async {
    if (isLoading.value) {
      print('⚠️ Transferência já em andamento');
      return;
    }

    print('💸 Iniciando execução da transferência...');
    
    // Validar dados antes de executar
    if (!_validateTransferData()) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    transferProgress.value = 0.1; // Progresso inicial

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw const AppException('Usuário não autenticado');
      }

      attemptCount.value++;
      print('🔄 Tentativa ${attemptCount.value}/3');

      // Simular progresso da operação
      await _updateProgress();

      // ✅ EXECUTAR TRANSFERÊNCIA VIA USE CASE
      await _transferUseCase.execute(
        senderId: currentUser.uid,
        receiverEmail: recipientEmail.value,
        amount: amount.value,
        description: description.value,
      );

      transferProgress.value = 1.0; // Progresso completo

      // ✅ SUCESSO - CONFIGURAR FEEDBACK E NAVEGAR
      await _handleTransferSuccess();

    } on AppException catch (e) {
      print('❌ Erro de negócio: ${e.message}');
      transferProgress.value = 0.0;
      errorMessage.value = e.message;
      
      await _handleTransferError(e);

    } catch (e) {
      print('❌ Erro técnico: $e');
      transferProgress.value = 0.0;
      
      final errorMsg = _formatTechnicalError(e);
      errorMessage.value = errorMsg;
      
      await _handleTransferError(AppException(errorMsg));

    } finally {
      isLoading.value = false;
      isRetrying.value = false;
    }
  }

  /// ✅ SIMULAR PROGRESSO DA OPERAÇÃO
  Future<void> _updateProgress() async {
    // Validação inicial
    transferProgress.value = 0.2;
    await Future.delayed(const Duration(milliseconds: 300));

    // Verificação de saldo
    transferProgress.value = 0.4;
    await Future.delayed(const Duration(milliseconds: 300));

    // Busca do destinatário
    transferProgress.value = 0.6;
    await Future.delayed(const Duration(milliseconds: 300));

    // Execução da transação
    transferProgress.value = 0.8;
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// ✅ LIDAR COM SUCESSO DA TRANSFERÊNCIA
  Future<void> _handleTransferSuccess() async {
    successMessage.value = 'Transferência realizada com sucesso! 🎉';
    
    print('✅ Transferência executada com sucesso');
    print('   Para: ${recipientName.value ?? recipientEmail.value}');
    print('   Valor: R\$ ${amount.value.toStringAsFixed(2)}');

    // ✅ CAPTURAR VALORES ANTES DE LIMPAR
    final transferAmount = amount.value;
    final recipientDisplayName = recipientName.value ?? recipientEmail.value;
    final transferDescription = description.value;

    // ✅ LIMPAR DADOS SENSÍVEIS
    _clearSensitiveData();

    // ✅ NAVEGAR PARA HOME
    Get.offAllNamed(AppRoutes.home);

    // ✅ MOSTRAR FEEDBACK APÓS NAVEGAÇÃO
    await Future.delayed(const Duration(milliseconds: 800));
    
    _showSuccessFeedback(
      'Transferência Realizada! 💸',
      'R\$ ${transferAmount.toStringAsFixed(2).replaceAll('.', ',')} enviados para $recipientDisplayName',
    );

    // ✅ TENTAR ENVIAR NOTIFICAÇÃO (SEM FALHAR SE DER ERRO)
    try {
      await NotificationService.sendTransferReceivedNotification(
        receiverUserId: recipientId.value ?? '',
        amount: transferAmount,
        senderName: FirebaseAuth.instance.currentUser?.displayName ?? 'Usuário Blinq',
      );
    } catch (e) {
      print('⚠️ Falha ao enviar notificação: $e');
      // Não falhar a transferência por causa da notificação
    }
  }

  /// ✅ LIDAR COM ERRO DA TRANSFERÊNCIA
  Future<void> _handleTransferError(AppException exception) async {
    print('❌ Lidando com erro: ${exception.message}');

    // ✅ VERIFICAR SE PODE TENTAR NOVAMENTE
    final canRetry = _canRetryTransfer(exception);
    
    if (canRetry && attemptCount.value < 3) {
      _showRetryOption(exception);
    } else {
      _showFinalError(exception);
    }
  }

  /// ✅ VERIFICAR SE ERRO PERMITE RETRY
  bool _canRetryTransfer(AppException exception) {
    final message = exception.message.toLowerCase();
    
    // Erros que permitem retry
    if (message.contains('conexão') ||
        message.contains('timeout') ||
        message.contains('temporariamente') ||
        message.contains('tempo limite') ||
        message.contains('indisponível')) {
      return true;
    }
    
    // Erros que NÃO permitem retry
    if (message.contains('saldo insuficiente') ||
        message.contains('não encontrado') ||
        message.contains('não pode transferir para si mesmo') ||
        message.contains('valor máximo') ||
        message.contains('permissão negada')) {
      return false;
    }
    
    return false; // Por padrão, não permitir retry
  }

  /// ✅ MOSTRAR OPÇÃO DE RETRY
  void _showRetryOption(AppException exception) {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Erro na Transferência'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exception.message),
            const SizedBox(height: 16),
            Text(
              'Tentativa ${attemptCount.value}/3',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _clearSensitiveData();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              retryTransfer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text(
              'Tentar Novamente',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// ✅ MOSTRAR ERRO FINAL
  void _showFinalError(AppException exception) {
    _showErrorFeedback(
      'Transferência Falhou',
      exception.message,
    );
  }

  /// ✅ RETRY DA TRANSFERÊNCIA
  Future<void> retryTransfer() async {
    if (attemptCount.value >= 3) {
      _showErrorFeedback('Limite de tentativas atingido');
      return;
    }

    isRetrying.value = true;
    
    print('🔄 Tentando transferência novamente...');
    
    // Aguardar um pouco antes de tentar novamente
    await Future.delayed(const Duration(seconds: 2));
    
    await executeTransfer();
  }

  /// ✅ VALIDAR DADOS DA TRANSFERÊNCIA
  bool _validateTransferData() {
    if (recipientEmail.value.trim().isEmpty) {
      errorMessage.value = 'Email do destinatário é obrigatório';
      _showErrorFeedback(errorMessage.value!);
      return false;
    }

    if (amount.value <= 0) {
      errorMessage.value = 'Valor deve ser maior que zero';
      _showErrorFeedback(errorMessage.value!);
      return false;
    }

    if (amount.value > 50000) {
      errorMessage.value = 'Valor máximo por transferência: R\$ 50.000,00';
      _showErrorFeedback(errorMessage.value!);
      return false;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      errorMessage.value = 'Usuário não autenticado';
      _showErrorFeedback(errorMessage.value!);
      return false;
    }

    return true;
  }

  /// ✅ FORMATAR ERROS TÉCNICOS
  String _formatTechnicalError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('network') || errorStr.contains('connection')) {
      return 'Erro de conexão. Verifique sua internet.';
    }
    
    if (errorStr.contains('timeout') || errorStr.contains('deadline')) {
      return 'Tempo limite excedido. Tente novamente.';
    }
    
    if (errorStr.contains('permission')) {
      return 'Permissão negada. Faça login novamente.';
    }
    
    if (errorStr.contains('unavailable')) {
      return 'Serviço temporariamente indisponível.';
    }
    
    return 'Erro interno. Tente novamente mais tarde.';
  }

  /// ✅ FEEDBACK VISUAL DE SUCESSO
  void _showSuccessFeedback(String title, [String? message]) {
    Get.snackbar(
      title,
      message ?? 'Operação realizada com sucesso',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(
        Icons.check_circle,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  /// ✅ FEEDBACK VISUAL DE ERRO
  void _showErrorFeedback(String title, [String? message]) {
    Get.snackbar(
      title,
      message ?? 'Ocorreu um erro na operação',
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(
        Icons.error_outline,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  /// ✅ LIMPAR DADOS SENSÍVEIS
  void _clearSensitiveData() {
    recipientEmail.value = '';
    amount.value = 0.0;
    description.value = '';
    recipientName.value = null;
    recipientId.value = null;
    errorMessage.value = null;
    successMessage.value = null;
    attemptCount.value = 0;
    transferProgress.value = 0.0;
    
    print('🧹 Dados sensíveis limpos');
  }

  /// ✅ LIMPAR APENAS MENSAGENS DE ERRO
  void clearError() {
    errorMessage.value = null;
  }

  /// ✅ CANCELAR TRANSFERÊNCIA
  void cancelTransfer() {
    if (isLoading.value) {
      print('⚠️ Tentativa de cancelar transferência em andamento');
      
      Get.dialog(
        AlertDialog(
          title: const Text('Cancelar Transferência?'),
          content: const Text(
            'A transferência está sendo processada. Tem certeza que deseja cancelar?'
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Não'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                _forceCancelTransfer();
              },
              child: const Text(
                'Sim, Cancelar',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      );
    } else {
      _clearSensitiveData();
      Get.back();
    }
  }

  /// ✅ FORÇAR CANCELAMENTO
  void _forceCancelTransfer() {
    isLoading.value = false;
    isRetrying.value = false;
    _clearSensitiveData();
    
    Get.back();
    
    Get.snackbar(
      'Transferência Cancelada',
      'A operação foi cancelada pelo usuário',
      backgroundColor: AppColors.warning.withOpacity(0.1),
      colorText: AppColors.warning,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// ✅ OBTER RESUMO DA TRANSFERÊNCIA
  Map<String, dynamic> getTransferSummary() {
    return {
      'recipient': recipientEmail.value,
      'recipientName': recipientName.value,
      'amount': amount.value,
      'formattedAmount': 'R\$ ${amount.value.toStringAsFixed(2).replaceAll('.', ',')}',
      'description': description.value,
      'isValid': _validateTransferData(),
      'isLoading': isLoading.value,
      'progress': transferProgress.value,
    };
  }

  /// ✅ VERIFICAR SE HÁ DADOS VÁLIDOS
  bool get hasValidData => 
      recipientEmail.value.isNotEmpty && 
      amount.value > 0 && 
      amount.value <= 50000;

  /// ✅ VERIFICAR SE PODE EXECUTAR TRANSFERÊNCIA
  bool get canExecuteTransfer => 
      hasValidData && 
      !isLoading.value && 
      errorMessage.value == null;
}