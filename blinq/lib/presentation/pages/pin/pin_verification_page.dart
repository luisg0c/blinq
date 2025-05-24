// lib/presentation/pages/pin/pin_verification_page.dart

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

  // Receber argumentos da navegação
  late final Map<String, dynamic> args;
  late final String flow;

  @override
  void initState() {
    super.initState();
    args = Get.arguments as Map<String, dynamic>? ?? {};
    flow = args['flow'] ?? 'default';
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verifyPin() async {
    final pin = _pinController.text.trim();
    setState(() => _errorMessage = null);

    // Validações básicas
    if (pin.isEmpty) {
      setState(() => _errorMessage = 'Digite o PIN');
      return;
    }
    if (pin.length < 4 || pin.length > 6) {
      setState(() => _errorMessage = 'O PIN deve ter entre 4 e 6 dígitos');
      return;
    }
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      setState(() => _errorMessage = 'O PIN deve conter apenas números');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final pinController = Get.find<PinController>();
      pinController.clearMessages();

      final isValid = await pinController.validatePin(pin);
      if (!isValid) {
        setState(() => _errorMessage = 'PIN incorreto');
        return;
      }

      // PIN válido - executar ação baseada no fluxo
      await _executeFlowAction();

    } catch (e) {
      setState(() => _errorMessage = 'Erro: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _executeFlowAction() async {
    try {
      switch (flow) {
        case 'deposit':
          await _executeDeposit();
          break;
        case 'transfer':
          await _executeTransfer();
          break;
        default:
          // Apenas validação de PIN
          Get.back(result: true);
          Get.snackbar(
            'Sucesso',
            'PIN validado com sucesso!',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Erro',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _executeDeposit() async {
    final depositController = Get.find<DepositController>();
    
    // Configurar dados do depósito
    final amountText = args['amountText'] as String? ?? '0';
    final description = args['description'] as String? ?? '';
    
    // Converter texto para valor
    final amount = _parseAmount(amountText);
    
    depositController.setDepositData(
      value: amount,
      desc: description.isNotEmpty ? description : null,
    );

    await depositController.executeDeposit();
  }

  Future<void> _executeTransfer() async {
    final transferController = Get.find<TransferController>();
    
    // Configurar dados da transferência
    final recipient = args['recipient'] as String? ?? '';
    final amountText = args['amountText'] as String? ?? '0';
    final description = args['description'] as String? ?? '';
    
    final amount = _parseAmount(amountText);
    
    transferController.setTransferData(
      email: recipient,
      value: amount,
    );

    await transferController.executeTransfer();
    
    // Voltar para home após sucesso
    Get.offAllNamed(AppRoutes.home);
  }

  double _parseAmount(String amountText) {
    // Remove formatação brasileira: "R$ 1.234,56" -> 1234.56
    final cleanText = amountText
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    
    return double.tryParse(cleanText) ?? 0.0;
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
        leading: BackButton(color: isDark ? Colors.white : Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),
            
            // Ícone baseado no fluxo
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                _getFlowIcon(),
                size: 40,
                color: AppColors.primary,
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
            
            // Campo PIN
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'PIN (4-6 dígitos)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
                counterText: '',
              ),
            ),
            
            // Mostrar resumo da operação
            if (args.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildOperationSummary(),
            ],
            
            // Erro
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
            
            // Botão confirmar
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
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
                    : const Text(
                        'Confirmar',
                        style: TextStyle(
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

  String _getTitle() {
    switch (flow) {
      case 'deposit':
        return 'Confirmar Depósito';
      case 'transfer':
        return 'Confirmar Transferência';
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
      default:
        return Icons.lock;
    }
  }

  String _getSubtitle() {
    switch (flow) {
      case 'deposit':
        return 'Digite seu PIN';
      case 'transfer':
        return 'Digite seu PIN';
      default:
        return 'Digite seu PIN';
    }
  }

  String _getDescription() {
    switch (flow) {
      case 'deposit':
        return 'Confirme seu PIN para realizar o depósito';
      case 'transfer':
        return 'Confirme seu PIN para realizar a transferência';
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
          Text(
            'Resumo da operação:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (args['amountText'] != null)
            Text('Valor: ${args['amountText']}'),
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