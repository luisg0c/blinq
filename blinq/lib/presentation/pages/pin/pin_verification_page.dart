// lib/presentation/pages/pin/pin_verification_page.dart - VERSÃO SIMPLIFICADA

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  late final Map<String, dynamic> args;
  late final String flow;

  @override
  void initState() {
    super.initState();
    args = Get.arguments as Map<String, dynamic>? ?? {};
    flow = args['flow'] ?? 'default';
    print('🔐 PIN Verification iniciada para: $flow');
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Ícone
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.lock, color: Colors.white, size: 40),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Digite seu PIN',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              _getDescription(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Campo PIN
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
                prefixIcon: const Icon(Icons.lock_outline),
                counterText: '',
              ),
              onSubmitted: (_) => _verifyPin(),
            ),
            
            // Erro
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Botão
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Confirmar',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyPin() async {
    final pin = _pinController.text.trim();
    
    if (pin.length < 4) {
      _showError('Digite um PIN válido');
      return;
    }

    if (_attemptCount >= 3) {
      _showError('Muitas tentativas. Tente mais tarde.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pinController = Get.find<PinController>();
      final isValid = await pinController.validatePin(pin);

      if (!isValid) {
        _attemptCount++;
        _showError('PIN incorreto. Tentativas: $_attemptCount/3');
        _pinController.clear();
        return;
      }

      // PIN válido - executar ação
      await _executeAction();

    } catch (e) {
      print('❌ Erro na verificação: $e');
      _showError('Erro ao verificar PIN');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _executeAction() async {
    try {
      print('✅ PIN válido! Executando: $flow');

      switch (flow) {
        case 'deposit':
          await _executeDeposit();
          break;
        case 'transfer':
          await _executeTransfer();
          break;
        default:
          Get.back(result: true);
          Get.snackbar('Sucesso', 'PIN validado!');
      }
    } catch (e) {
      print('❌ Erro na execução: $e');
      Get.back();
      Get.snackbar(
        'Erro',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _executeDeposit() async {
    if (!Get.isRegistered<DepositController>()) {
      throw Exception('DepositController não disponível');
    }

    final controller = Get.find<DepositController>();
    final amountText = args['amountText'] as String? ?? '0';
    final description = args['description'] as String? ?? '';

    final amount = controller.parseAmountFromText(amountText);
    if (amount <= 0) throw Exception('Valor inválido');

    controller.setDepositData(value: amount, desc: description);
    Get.back(); // Fechar PIN
    await controller.executeDeposit();
  }

  Future<void> _executeTransfer() async {
    if (!Get.isRegistered<TransferController>()) {
      throw Exception('TransferController não disponível');
    }

    final controller = Get.find<TransferController>();
    final recipient = args['recipient'] as String? ?? '';
    final amount = args['amount'] as double? ?? 0.0;

    if (amount <= 0 || recipient.isEmpty) {
      throw Exception('Dados de transferência inválidos');
    }

    controller.setTransferData(email: recipient, value: amount);
    Get.back(); // Fechar PIN
    await controller.executeTransfer();
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
  }

  String _getTitle() {
    switch (flow) {
      case 'deposit': return 'Confirmar Depósito';
      case 'transfer': return 'Confirmar Transferência';
      default: return 'Verificar PIN';
    }
  }

  String _getDescription() {
    switch (flow) {
      case 'deposit': return 'Confirme seu PIN para realizar o depósito';
      case 'transfer': return 'Confirme seu PIN para realizar a transferência';
      default: return 'Digite seu PIN para continuar';
    }
  }
}