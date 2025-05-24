import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class PinSetupPage extends StatefulWidget {
  const PinSetupPage({super.key});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  String? error;
  bool isSaving = false;

  final _storage = const FlutterSecureStorage();

  Future<void> _savePin() async {
    setState(() {
      error = null;
      isSaving = true;
    });

    final pin = _pinController.text.trim();
    final confirm = _confirmController.text.trim();
    print('[PinSetup] salvar PIN: $pin, confirmar: $confirm');

    if (pin.length < 4 || pin.length > 6) {
      setState(() {
        error = 'O PIN deve ter entre 4 e 6 dígitos.';
        isSaving = false;
      });
      return;
    }
    if (pin != confirm) {
      setState(() {
        error = 'Os PINs não coincidem.';
        isSaving = false;
      });
      return;
    }

    try {
      await _storage.write(key: 'user_pin', value: pin);
      print('[PinSetup] PIN salvo no secure storage');
      Get.snackbar('Sucesso', 'PIN salvo com sucesso',
        snackPosition: SnackPosition.BOTTOM);
      // Navegar para Home
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      print('[PinSetup] Erro ao salvar PIN: $e');
      setState(() {
        error = 'Erro interno ao salvar PIN.';
      });
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Criar PIN de Segurança')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              'Crie um PIN numérico para proteger suas transações.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'PIN',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Confirme o PIN',
                border: OutlineInputBorder(),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : _savePin,
                child: isSaving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar PIN'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
