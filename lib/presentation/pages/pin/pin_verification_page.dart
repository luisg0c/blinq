// lib/presentation/pages/pin/pin_verification_page.dart - CORREÇÃO PARA TRANSFERÊNCIAS

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../controllers/pin_controller.dart';
import '../../controllers/deposit_controller.dart';
import '../../controllers/transfer_controller.dart';
import '../../../core/theme/app_colors.dart';

class PinVerificationPage extends StatefulWidget {
  const PinVerificationPage({super.key});

  @override
  State<PinVerificationPage> createState() => _PinVerificationPageState();
}

class _PinVerificationPageState extends State<PinVerificationPage> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  int _attemptCount = 0;
  
  // ✅ CONTROLE DE LIFECYCLE
  bool _disposed = false;
  Timer? _debounceTimer;
  late final Map<String, dynamic> args;
  late final String flow;

  @override
  void initState() {
    super.initState();
    
    try {
      args = Get.arguments as Map<String, dynamic>? ?? {};
      flow = args['flow'] ?? 'default';
      print('🔐 PIN Verification iniciada para: $flow');
      print('📋 Argumentos recebidos: $args');
    } catch (e) {
      print('❌ Erro ao inicializar PIN Verification: $e');
      flow = 'default';
      args = {};
    }
  }

  @override
  void dispose() {
    print('🗑️ Disposing PinVerificationPage');
    _disposed = true;
    
    _debounceTimer?.cancel();
    _pinController.dispose();
    
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (!_disposed && mounted) {
      setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _handleBack(),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          _handleBack();
          return false;
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Ícone
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF5BC4A8)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_outline, 
                  color: Colors.white, 
                  size: 36,
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                _getTitle(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                _getDescription(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              // ✅ MOSTRAR DETALHES DA TRANSFERÊNCIA SE DISPONÍVEL
              if (flow == 'transfer') ...[
                const SizedBox(height: 24),
                _buildTransferSummary(),
              ],
              
              const SizedBox(height: 32),
              
              // Campo PIN
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                autofocus: true,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Digite seu PIN (4-6 dígitos)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.primary,
                  ),
                  counterText: '',
                  fillColor: _isLoading ? Colors.grey[100] : null,
                  filled: _isLoading,
                ),
                onSubmitted: (_) => _verifyPin(),
                onChanged: (value) {
                  if (_errorMessage != null) {
                    _safeSetState(() => _errorMessage = null);
                  }
                },
              ),
              
              // ✅ ERRO COM ANIMAÇÃO
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _errorMessage != null ? 70 : 0,
                child: _errorMessage != null ? Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.error, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ) : const SizedBox.shrink(),
              ),
              
              const SizedBox(height: 32),
              
              // ✅ BOTÃO COM ESTADO VISUAL CLARO
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyPin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLoading ? Colors.grey : AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: _isLoading ? 0 : 2,
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Verificando...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Confirmar PIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              if (_attemptCount > 0) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Tentativas: $_attemptCount/3',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              TextButton(
                onPressed: _isLoading ? null : () => _showComingSoon(),
                child: Text(
                  'Esqueci meu PIN',
                  style: TextStyle(
                    color: _isLoading ? Colors.grey : AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ RESUMO DA TRANSFERÊNCIA
  Widget _buildTransferSummary() {
    final amount = args['amount'];
    final recipient = args['recipient']?.toString() ?? '';
    final recipientName = args['recipientName']?.toString();
    
    // ✅ CONVERSÃO SEGURA DO VALOR
    String formattedAmount = 'R\$ 0,00';
    if (amount != null) {
      try {
        double amountValue;
        if (amount is double) {
          amountValue = amount;
        } else if (amount is int) {
          amountValue = amount.toDouble();
        } else if (amount is String) {
          amountValue = double.tryParse(amount.replaceAll(',', '.')) ?? 0.0;
        } else {
          amountValue = 0.0;
        }
        formattedAmount = 'R\$ ${amountValue.toStringAsFixed(2).replaceAll('.', ',')}';
      } catch (e) {
        print('❌ Erro ao formatar valor: $e');
        formattedAmount = 'R\$ 0,00';
      }
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.send, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Resumo da Transferência',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Para:', recipientName ?? recipient),
          _buildSummaryRow('Valor:', formattedAmount),
          if (args['description'] != null && args['description'].toString().isNotEmpty)
            _buildSummaryRow('Descrição:', args['description'].toString()),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ MÉTODO PRINCIPAL DE VERIFICAÇÃO
  Future<void> _verifyPin() async {
    if (_disposed || !mounted) {
      print('⚠️ Tentativa de verificar PIN em widget disposed');
      return;
    }

    final pin = _pinController.text.trim();
    
    if (pin.length < 4) {
      _showError('Digite um PIN válido (4-6 dígitos)');
      return;
    }

    if (_attemptCount >= 3) {
      _showError('Muitas tentativas incorretas. Tente mais tarde.');
      return;
    }

    _safeSetState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔐 Verificando PIN...');
      
      if (!Get.isRegistered<PinController>()) {
        throw Exception('Sistema de PIN não disponível');
      }

      final pinController = Get.find<PinController>();
      
      final isValid = await Future.any([
        pinController.validatePin(pin),
        Future.delayed(
          const Duration(seconds: 10), 
          () => throw TimeoutException('Timeout na verificação'),
        ),
      ]);

      if (_disposed || !mounted) {
        print('⚠️ Widget disposed durante verificação');
        return;
      }

      if (!isValid) {
        _attemptCount++;
        _showError('PIN incorreto. Tentativas: $_attemptCount/3');
        _pinController.clear();
        return;
      }

      print('✅ PIN válido! Executando ação: $flow');
      await _executeAction();

    } catch (e) {
      print('❌ Erro na verificação: $e');
      
      if (_disposed || !mounted) return;
      
      String errorMsg = 'Erro ao verificar PIN';
      if (e.toString().contains('TimeoutException')) {
        errorMsg = 'Tempo limite excedido. Tente novamente.';
      } else if (e.toString().contains('não disponível')) {
        errorMsg = 'Sistema temporariamente indisponível';
      }
      
      _showError(errorMsg);
      
    } finally {
      _safeSetState(() => _isLoading = false);
    }
  }

  /// ✅ EXECUÇÃO DE AÇÃO PROTEGIDA CONTRA DISPOSE
  Future<void> _executeAction() async {
    if (_disposed || !mounted) {
      print('⚠️ Tentativa de executar ação em widget disposed');
      return;
    }

    try {
      switch (flow) {
        case 'deposit':
          await _executeDeposit();
          break;
        case 'transfer':
          await _executeTransfer();
          break;
        case 'show_balance':
        case 'change_limits':
        default:
          _handleSuccess();
          break;
      }
    } catch (e) {
      print('❌ Erro na execução: $e');
      
      if (_disposed || !mounted) return;
      
      Get.back();
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      Get.snackbar(
        'Erro na Operação',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// ✅ EXECUÇÃO DE DEPÓSITO SEGURA
  Future<void> _executeDeposit() async {
    if (!Get.isRegistered<DepositController>()) {
      throw Exception('DepositController não disponível');
    }

    final controller = Get.find<DepositController>();
    final amountText = args['amountText'] as String? ?? '0';
    final description = args['description'] as String? ?? '';

    final amount = controller.parseAmountFromText(amountText);
    if (amount <= 0) {
      throw Exception('Valor inválido para depósito');
    }

    controller.setDepositData(value: amount, desc: description);
    
    if (_disposed || !mounted) return;
    
    Get.back();
    
    await Future.delayed(const Duration(milliseconds: 100));
    await controller.executeDeposit();
  }

  /// ✅ EXECUÇÃO DE TRANSFERÊNCIA CORRIGIDA
  Future<void> _executeTransfer() async {
    print('💸 Executando transferência via PIN...');
    print('📋 Argumentos: $args');

    if (!Get.isRegistered<TransferController>()) {
      throw Exception('TransferController não disponível');
    }

    final controller = Get.find<TransferController>();
    
    // ✅ VERIFICAR SE OS DADOS ESSENCIAIS ESTÃO PRESENTES
    final recipient = args['recipient']?.toString();
    final amount = args['amount'];
    
    if (recipient == null || recipient.isEmpty) {
      throw Exception('Destinatário não informado');
    }
    
    if (amount == null) {
      throw Exception('Valor não informado');
    }

    print('🔍 Dados da transferência:');
    print('   Destinatário: $recipient');
    print('   Valor bruto: $amount (${amount.runtimeType})');

    try {
      // ✅ USAR O MÉTODO ESPECÍFICO PARA ARGUMENTOS
      controller.setTransferDataFromArguments(args);
      
      if (_disposed || !mounted) return;
      
      Get.back(); // Fechar PIN
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      // ✅ VERIFICAR SE OS DADOS FORAM CONFIGURADOS CORRETAMENTE
      final debugInfo = controller.getDebugInfo();
      print('🔍 Estado do controller após configuração: $debugInfo');
      
      if (controller.amount.value <= 0) {
        throw Exception('Falha ao configurar valor da transferência: ${controller.amount.value}');
      }
      
      await controller.executeTransfer();
      
    } catch (e) {
      print('❌ Erro ao configurar/executar transferência: $e');
      rethrow;
    }
  }

  /// ✅ SUCESSO GENÉRICO
  void _handleSuccess() {
    if (_disposed || !mounted) return;
    
    Get.back(result: true);
    
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.snackbar(
        'PIN Verificado! ✅',
        'Operação autorizada com sucesso',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }

  /// ✅ MÉTODO SEGURO PARA MOSTRAR ERRO
  void _showError(String message) {
    if (_disposed || !mounted) return;
    
    _safeSetState(() => _errorMessage = message);
  }

  /// ✅ CONTROLE DE BACK BUTTON
  void _handleBack() {
    if (_isLoading) {
      Get.dialog(
        AlertDialog(
          title: const Text('Cancelar Verificação?'),
          content: const Text('A verificação do PIN está em andamento. Deseja cancelar?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Não'),
            ),
            TextButton(
              onPressed: () {
                Get.back(); // Fechar dialog
                Get.back(result: false); // Fechar PIN screen
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
      Get.back(result: false);
    }
  }

  /// ✅ MÉTODOS HELPER
  String _getTitle() {
    switch (flow) {
      case 'deposit': 
        return 'Confirmar Depósito';
      case 'transfer': 
        return 'Confirmar Transferência';
      case 'show_balance':
        return 'Revelar Saldo';
      case 'change_limits':
        return 'Alterar Limites';
      default: 
        return 'Verificar PIN';
    }
  }

  String _getDescription() {
    switch (flow) {
      case 'deposit': 
        return 'Digite seu PIN para confirmar o depósito';
      case 'transfer': 
        return 'Digite seu PIN para confirmar a transferência';
      case 'show_balance':
        return 'Digite seu PIN para visualizar o saldo';
      case 'change_limits':
        return 'Digite seu PIN para alterar os limites';
      default: 
        return 'Digite seu PIN para continuar';
    }
  }

  void _showComingSoon() {
    Get.snackbar(
      'Em Breve 🚧',
      'Funcionalidade em desenvolvimento',
      backgroundColor: AppColors.warning.withOpacity(0.1),
      colorText: AppColors.warning,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

/// ✅ CLASSE DE EXCEÇÃO PERSONALIZADA
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}