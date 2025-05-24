// lib/presentation/pages/pin/pin_verification_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/pin_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class PinVerificationPage extends StatefulWidget {
  /// Callback opcional que será executado em caso de PIN válido.
  /// Se fornecido, a navegação padrão (Get.offAllNamed) não será utilizada.
  final Future<void> Function()? onSuccess;

  const PinVerificationPage({
    Key? key,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<PinVerificationPage> createState() => _PinVerificationPageState();
}

class _PinVerificationPageState extends State<PinVerificationPage> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

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
        setState(() => _errorMessage = pinController.errorMessage.value ?? 'PIN incorreto');
        return;
      }

      // Sucesso
      Get.snackbar(
        'Sucesso',
        'PIN validado com sucesso!',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Se fornecido callback onSuccess, executa e retorna
      if (widget.onSuccess != null) {
        await widget.onSuccess!();
        return;
      }

      // Senão, navega para a home
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      setState(() => _errorMessage = 'Erro técnico: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      appBar: AppBar(
        title: const Text('Verificar PIN'),
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
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(Icons.lock, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 32),
            const Text(
              'Digite seu PIN',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Insira seu PIN para continuar',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.error),
                      onPressed: () => setState(() => _errorMessage = null),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
}
