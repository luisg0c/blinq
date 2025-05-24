import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/pin_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class PinSetupPage extends StatefulWidget {
  const PinSetupPage({super.key});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _savePin() async {
    final pin = _pinController.text.trim();
    final confirm = _confirmController.text.trim();

    setState(() {
      _errorMessage = null;
    });

    // Validações básicas
    if (pin.isEmpty) {
      setState(() => _errorMessage = 'Digite um PIN');
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
    if (pin != confirm) {
      setState(() => _errorMessage = 'Os PINs não coincidem');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Encontra o controller e limpa mensagens antigas
      final pinController = Get.find<PinController>();
      pinController.clearMessages();

      // Executa o use case
      await pinController.setPin(pin);

      // Se houve erro no controller
      if (pinController.errorMessage.value != null) {
        setState(() => _errorMessage = pinController.errorMessage.value);
        return;
      }

      // Sucesso
      Get.snackbar(
        'Sucesso',
        'PIN configurado com segurança! 🔒',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navega para a verificação de PIN
      Get.offAllNamed(AppRoutes.verifyPin);
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
        title: const Text('Configurar PIN'),
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
            // Ícone
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(
                Icons.security,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Crie seu PIN de segurança',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'PIN de 4 a 6 dígitos para autorizar transações',
              style: TextStyle(fontSize: 16, color: Colors.grey),
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
                prefixIcon: Icon(Icons.lock),
                counterText: '',
              ),
            ),
            const SizedBox(height: 20),
            // Campo confirmar
            TextField(
              controller: _confirmController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Confirme o PIN',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
                counterText: '',
              ),
            ),
            const SizedBox(height: 32),
            // Botão Salvar
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _savePin,
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Salvar PIN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            // Mensagem de erro
            if (_errorMessage != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppColors.error.withOpacity(0.3)),
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
                      onPressed: () {
                        setState(() => _errorMessage = null);
                      },
                    ),
                  ],
                ),
              ),
            ],
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
