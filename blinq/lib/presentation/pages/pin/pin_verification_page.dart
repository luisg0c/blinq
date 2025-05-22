import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PinVerificationPage extends StatefulWidget {
  final VoidCallback? onSuccess;

  const PinVerificationPage({super.key, this.onSuccess});

  @override
  State<PinVerificationPage> createState() => _PinVerificationPageState();
}

class _PinVerificationPageState extends State<PinVerificationPage> {
  final TextEditingController _pinController = TextEditingController();
  String? error;

  final String storedPin = '1234'; // Simulação

  void _verifyPin() {
    if (_pinController.text == storedPin) {
      widget.onSuccess?.call();
      Get.back();
    } else {
      setState(() => error = 'PIN incorreto');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Verificação de PIN')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Digite seu PIN para continuar'),
            const SizedBox(height: 16),
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
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _verifyPin,
                child: const Text('Confirmar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
