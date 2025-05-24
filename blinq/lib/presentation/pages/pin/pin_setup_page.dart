import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/pin_controller.dart';
import '../../../routes/app_routes.dart';

class PinSetupPage extends StatefulWidget {
  const PinSetupPage({super.key});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  late PinController pinController;

  @override
  void initState() {
    super.initState();
    // ✅ Usar o controller real com secure storage
    pinController = Get.find<PinController>();
  }

  Future<void> _savePin() async {
    final pin = _pinController.text.trim();
    final confirm = _confirmController.text.trim();

    // Validações básicas
    if (pin.length < 4 || pin.length > 6) {
      Get.snackbar(
        'Erro',
        'O PIN deve ter entre 4 e 6 dígitos',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (pin != confirm) {
      Get.snackbar(
        'Erro',
        'Os PINs não coincidem',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // ✅ SALVAR PIN REAL no secure storage
    await pinController.setPin(pin);
    
    // Verificar se foi salvo com sucesso
    if (pinController.successMessage.value != null) {
      Get.snackbar(
        'Sucesso',
        'PIN configurado com segurança! 🔒',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      // Navegar para Home
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed(AppRoutes.home);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar PIN de Segurança'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 32),
            
            // Ícone de segurança
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.security,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Proteja suas transações',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Crie um PIN de 4 a 6 dígitos para autorizar transferências e depósitos.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Campo PIN
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'PIN',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pin),
                helperText: 'Digite entre 4 e 6 números',
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Campo confirmar PIN
            TextField(
              controller: _confirmController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Confirmar PIN',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pin_outlined),
                helperText: 'Digite o mesmo PIN novamente',
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Botão salvar
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: pinController.isLoading.value ? null : _savePin,
                icon: pinController.isLoading.value 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  pinController.isLoading.value 
                      ? 'Salvando PIN...' 
                      : 'Salvar PIN',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            )),
            
            const SizedBox(height: 16),
            
            // Mostrar erro se houver
            Obx(() => pinController.errorMessage.value != null
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pinController.errorMessage.value!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}