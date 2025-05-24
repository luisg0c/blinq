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

    // Validações
    if (pin.isEmpty) {
      setState(() => _errorMessage = 'Digite um PIN');
      return;
    }

    if (pin.length < 4 || pin.length > 6) {
      setState(() => _errorMessage = 'O PIN deve ter entre 4 e 6 dígitos');
      return;
    }

    if (!RegExp(r'^\d+

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Configurar PIN'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            
            // Ícone
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.security,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'Crie seu PIN de segurança',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'PIN de 4 a 6 dígitos para autorizar transações',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
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
            
            // Botão salvar
            SizedBox(
              width: double.infinity,
              height: 50,
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
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
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
            
            const SizedBox(height: 20),
            
            // Mensagem de erro
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 20),
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
            
            const Spacer(),
            
            // Info de segurança
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Seu PIN é armazenado de forma criptografada no dispositivo',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}).hasMatch(pin)) {
      setState(() => _errorMessage = 'O PIN deve conter apenas números');
      return;
    }

    if (pin != confirm) {
      setState(() => _errorMessage = 'Os PINs não coincidem');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🔧 Tentando encontrar PinController...');
      
      // Verificar se PinController existe
      PinController? pinController;
      try {
        pinController = Get.find<PinController>();
        print('✅ PinController encontrado');
      } catch (e) {
        print('❌ PinController não encontrado: $e');
        setState(() => _errorMessage = 'Configuração do PIN não disponível');
        return;
      }
      
      print('🔧 Executando setPin...');
      await pinController.setPin(pin);
      
      print('🔧 Verificando resultado...');
      print('Success: ${pinController.successMessage.value}');
      print('Error: ${pinController.errorMessage.value}');
      
      final error = pinController.errorMessage.value;
      if (error != null && error.isNotEmpty) {
        print('❌ Erro do controller: $error');
        setState(() => _errorMessage = error);
        return;
      }

      final success = pinController.successMessage.value;
      if (success != null && success.isNotEmpty) {
        print('✅ Sucesso: $success');
        // Sucesso
        Get.snackbar(
          'Sucesso',
          'PIN configurado com segurança! 🔒',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        Future.delayed(const Duration(seconds: 1), () {
          Get.offAllNamed(AppRoutes.home);
        });
      } else {
        print('⚠️ Sem sucesso nem erro definido');
        setState(() => _errorMessage = 'PIN salvo, mas sem confirmação');
      }
      
    } catch (e) {
      print('❌ Exceção ao salvar PIN: $e');
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Configurar PIN'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            
            // Ícone
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.security,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'Crie seu PIN de segurança',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'PIN de 4 a 6 dígitos para autorizar transações',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
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
            
            // Botão salvar
            SizedBox(
              width: double.infinity,
              height: 50,
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
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
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
            
            const SizedBox(height: 20),
            
            // Mensagem de erro
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 20),
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
            
            const Spacer(),
            
            // Info de segurança
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Seu PIN é armazenado de forma criptografada no dispositivo',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}