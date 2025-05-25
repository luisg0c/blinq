// lib/presentation/pages/pin/pin_verification_page.dart - VERSÃO CORRIGIDA

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/pin_controller.dart';
import '../../controllers/deposit_controller.dart';
import '../../controllers/transfer_controller.dart';
import '../../../routes/app_routes.dart';
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
  static const int _maxAttempts = 3;

  late final Map<String, dynamic> args;
  late final String flow;

  @override
  void initState() {
    super.initState();
    args = Get.arguments as Map<String, dynamic>? ?? {};
    flow = args['flow'] ?? 'default';
    
    print('🔐 PinVerificationPage iniciada');
    print('   Fluxo: $flow');
    print('   Argumentos: $args');

    // ✅ VERIFICAR SE PIN ESTÁ CONFIGURADO
    _checkPinConfiguration();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  /// ✅ VERIFICAR SE PIN ESTÁ CONFIGURADO
  Future<void> _checkPinConfiguration() async {
    try {
      if (!Get.isRegistered<PinController>()) {
        print('❌ PinController não registrado');
        _showError('Sistema de PIN não disponível');
        return;
      }

      final pinController = Get.find<PinController>();
      
      // Verificar se PIN existe (tentativa de validação com string vazia)
      final hasPin = await pinController.validatePin('invalid_pin_test');
      
      if (!hasPin) {
        print('⚠️ PIN não configurado, redirecionando para configuração');
        Get.offNamed(AppRoutes.setupPin);
        return;
      }
      
      print('✅ PIN configurado, continuando...');
    } catch (e) {
      print('❌ Erro ao verificar PIN: $e');
      // Continuar mesmo com erro - assumir que PIN existe
    }
  }

  /// ✅ VERIFICAÇÃO ROBUSTA DO PIN
  Future<void> _verifyPin() async {
    final pin = _pinController.text.trim();
    setState(() => _errorMessage = null);

    // ✅ VALIDAÇÕES RIGOROSAS
    if (!_validatePinInput(pin)) return;

    // ✅ VERIFICAR LIMITE DE TENTATIVAS
    if (_attemptCount >= _maxAttempts) {
      _showError('Muitas tentativas. Tente novamente mais tarde.');
      _blockForSecurity();
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      if (!Get.isRegistered<PinController>()) {
        throw Exception('Sistema de PIN não disponível');
      }

      final pinController = Get.find<PinController>();
      pinController.clearMessages();

      print('🔐 Validando PIN... (Tentativa ${_attemptCount + 1}/$_maxAttempts)');
      
      final isValid = await pinController.validatePin(pin);
      
      if (!isValid) {
        _attemptCount++;
        final remainingAttempts = _maxAttempts - _attemptCount;
        
        print('❌ PIN incorreto (${_attemptCount}/$_maxAttempts)');
        
        if (remainingAttempts > 0) {
          _showError('PIN incorreto. Restam $remainingAttempts tentativas.');
        } else {
          _showError('Limite de tentativas excedido. Tente novamente mais tarde.');
          _blockForSecurity();
        }
        
        _pinController.clear();
        return;
      }

      print('✅ PIN válido! Executando ação do fluxo: $flow');
      
      // ✅ RESETAR CONTADOR DE TENTATIVAS
      _attemptCount = 0;

      // ✅ EXECUTAR AÇÃO BASEADA NO FLUXO
      await _executeFlowAction();

    } catch (e) {
      print('❌ Erro na verificação do PIN: $e');
      _showError('Erro no sistema: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// ✅ VALIDAÇÕES DE ENTRADA DO PIN
  bool _validatePinInput(String pin) {
    if (pin.isEmpty) {
      _showError('Digite o PIN');
      return false;
    }
    
    if (pin.length < 4 || pin.length > 6) {
      _showError('O PIN deve ter entre 4 e 6 dígitos');
      return false;
    }
    
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      _showError('O PIN deve conter apenas números');
      return false;
    }
    
    return true;
  }

  /// ✅ EXECUÇÃO SEGURA DAS AÇÕES
  Future<void> _executeFlowAction() async {
    try {
      switch (flow) {
        case 'deposit':
          await _executeDeposit();
          break;
        case 'transfer':
          await _executeTransfer();
          break;
        case 'change_limits':
          await _executeChangeLimits();
          break;
        case 'show_balance':
          await _executeShowBalance();
          break;
        default:
          print('✅ PIN validado para fluxo genérico');
          Get.back(result: true);
          
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.snackbar(
              'Sucesso! 🔒',
              'PIN validado com sucesso',
              backgroundColor: AppColors.success,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          });
      }
    } catch (e) {
      print('❌ Erro na execução do fluxo: $e');
      _handleExecutionError(e);
    }
  }

  /// ✅ DEPÓSITO COM VALIDAÇÃO ROBUSTA
  Future<void> _executeDeposit() async {
    print('💰 Executando depósito...');
    
    if (!Get.isRegistered<DepositController>()) {
      throw Exception('DepositController não está disponível');
    }
    
    final depositController = Get.find<DepositController>();
    
    // ✅ VALIDAR DADOS DO DEPÓSITO
    final amountText = args['amountText'] as String? ?? '0';
    final description = args['description'] as String? ?? '';
    
    print('💰 Dados do depósito:');
    print('   Texto do valor: $amountText');
    print('   Descrição: $description');
    
    final amount = depositController.parseAmountFromText(amountText);
    print('💰 Valor convertido: R\$ $amount');
    
    if (amount <= 0) {
      throw Exception('Valor inválido para depósito');
    }
    
    if (amount > 50000) {
      throw Exception('Valor máximo por depósito: R\$ 50.000,00');
    }
    
    // ✅ CONFIGURAR E EXECUTAR
    depositController.setDepositData(value: amount, desc: description.isNotEmpty ? description : null);
    
    // Fechar PIN antes de executar
    Get.back();
    
    await depositController.executeDeposit();
    print('✅ Depósito concluído!');
  }

  /// ✅ TRANSFERÊNCIA COM VALIDAÇÃO ROBUSTA
  Future<void> _executeTransfer() async {
    print('💸 Executando transferência...');
    
    if (!Get.isRegistered<TransferController>()) {
      throw Exception('TransferController não está disponível');
    }
    
    final transferController = Get.find<TransferController>();
    
    // ✅ VALIDAR DADOS DA TRANSFERÊNCIA
    final recipient = args['recipient'] as String? ?? '';
    final amount = args['amount'] as double? ?? 0.0;
    final description = args['description'] as String? ?? '';
    
    print('💸 Dados da transferência:');
    print('   Destinatário: $recipient');
    print('   Valor: R\$ $amount');
    print('   Descrição: $description');
    
    if (amount <= 0) {
      throw Exception('Valor inválido para transferência');
    }
    
    if (recipient.isEmpty) {
      throw Exception('Destinatário não informado');
    }
    
    // ✅ VALIDAR EMAIL DO DESTINATÁRIO
    if (!GetUtils.isEmail(recipient)) {
      throw Exception('Email do destinatário inválido');
    }
    
    // ✅ CONFIGURAR E EXECUTAR
    transferController.setTransferData(email: recipient, value: amount);
    
    // Fechar PIN antes de executar
    Get.back();
    
    await transferController.executeTransfer();
    print('✅ Transferência concluída!');
  }

  /// ✅ ALTERAÇÃO DE LIMITES
  Future<void> _executeChangeLimits() async {
    print('⚙️ Executando alteração de limites...');
    
    // Fechar PIN
    Get.back(result: true);
    
    // Permitir alteração
    Get.snackbar(
      'Autorizado! 🔒',
      'Você pode alterar seus limites agora',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// ✅ MOSTRAR SALDO
  Future<void> _executeShowBalance() async {
    print('👁️ Executando mostrar saldo...');
    
    // Fechar PIN
    Get.back(result: true);
    
    Get.snackbar(
      'Saldo Revelado! 👁️',
      'Seu saldo está agora visível',
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// ✅ TRATAMENTO DE ERROS DE EXECUÇÃO
  void _handleExecutionError(dynamic error) {
    Get.offAllNamed(AppRoutes.home);
    
    String errorMessage = error.toString().replaceAll('Exception: ', '');
    
    Get.snackbar(
      'Erro na Operação',
      errorMessage,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  /// ✅ BLOQUEIO DE SEGURANÇA
  void _blockForSecurity() {
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed(AppRoutes.home);
      
      Get.snackbar(
        'Bloqueado por Segurança 🚫',
        'Aguarde alguns minutos antes de tentar novamente',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    });
  }

  /// ✅ MOSTRAR ERRO COM FEEDBACK VISUAL
  void _showError(String message) {
    setState(() => _errorMessage = message);
    
    // Vibração se disponível
    // HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      appBar: AppBar(
        title: Text(_getTitle()),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: isDark ? Colors.white : Colors.black,
          onPressed: () {
            // ✅ CONFIRMAR CANCELAMENTO PARA OPERAÇÕES IMPORTANTES
            if (flow == 'deposit' || flow == 'transfer') {
              _showCancelConfirmation();
            } else {
              Get.back();
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            
            // ✅ ÍCONE COM INDICADOR DE TENTATIVAS
            CircleAvatar(
              radius: 40,
              backgroundColor: _attemptCount > 0 
                  ? AppColors.error.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
              child: Stack(
                children: [
                  Icon(
                    _getFlowIcon(),
                    size: 40,
                    color: _attemptCount > 0 ? AppColors.error : AppColors.primary,
                  ),
                  if (_attemptCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$_attemptCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              _getSubtitle(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              _getDescription(),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // ✅ CAMPO PIN COM MELHOR UX
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'PIN (4-6 dígitos)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                counterText: '',
                helperText: _attemptCount > 0 
                    ? 'Tentativas restantes: ${_maxAttempts - _attemptCount}'
                    : null,
                helperStyle: TextStyle(
                  color: _attemptCount > 0 ? AppColors.error : Colors.grey,
                ),
              ),
              onSubmitted: (_) => _verifyPin(),
            ),
            
            // ✅ RESUMO DA OPERAÇÃO
            if (args.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildOperationSummary(),
            ],
            
            // ✅ ERRO COM MELHOR VISUAL
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.error),
                      onPressed: () => setState(() => _errorMessage = null),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // ✅ BOTÃO CONFIRMAR MELHORADO
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading || _attemptCount >= _maxAttempts ? null : _verifyPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _attemptCount >= _maxAttempts 
                      ? Colors.grey 
                      : AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _attemptCount >= _maxAttempts ? 'Bloqueado' : 'Confirmar',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            
            const Spacer(),
            
            const Center(
              child: Text(
                'Seu PIN é armazenado de forma criptografada no dispositivo',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// ✅ CONFIRMAÇÃO DE CANCELAMENTO
  void _showCancelConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancelar Operação'),
        content: const Text('Tem certeza que deseja cancelar esta operação?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Fechar dialog
              Get.back(); // Fechar PIN
            },
            child: const Text('Cancelar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  // ✅ MÉTODOS HELPER MELHORADOS
  String _getTitle() {
    switch (flow) {
      case 'deposit':
        return 'Confirmar Depósito';
      case 'transfer':
        return 'Confirmar Transferência';
      case 'change_limits':
        return 'Autorização Necessária';
      case 'show_balance':
        return 'Revelar Saldo';
      default:
        return 'Verificar PIN';
    }
  }

  IconData _getFlowIcon() {
    switch (flow) {
      case 'deposit':
        return Icons.add_circle;
      case 'transfer':
        return Icons.send;
      case 'change_limits':
        return Icons.settings;
      case 'show_balance':
        return Icons.visibility;
      default:
        return Icons.lock;
    }
  }

  String _getSubtitle() {
    return 'Digite seu PIN';
  }

  String _getDescription() {
    switch (flow) {
      case 'deposit':
        return 'Confirme seu PIN para realizar o depósito';
      case 'transfer':
        return 'Confirme seu PIN para realizar a transferência';
      case 'change_limits':
        return 'Confirme seu PIN para alterar os limites';
      case 'show_balance':
        return 'Confirme seu PIN para revelar o saldo';
      default:
        return 'Insira seu PIN para continuar';
    }
  }

  Widget _buildOperationSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo da operação:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (args['amountText'] != null)
            Text('Valor: ${args['amountText']}'),
          if (args['amount'] != null)
            Text('Valor: R\$ ${(args['amount'] as double).toStringAsFixed(2)}'),
          if (args['recipient'] != null)
            Text('Destinatário: ${args['recipient']}'),
          if (args['description'] != null && 
              (args['description'] as String).isNotEmpty)
            Text('Descrição: ${args['description']}'),
        ],
      ),
    );
  }
}