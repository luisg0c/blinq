import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/transaction_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ChangeTransactionPasswordPage extends StatefulWidget {
  const ChangeTransactionPasswordPage({super.key});

  @override
  State<ChangeTransactionPasswordPage> createState() => _ChangeTransactionPasswordPageState();
}

class _ChangeTransactionPasswordPageState extends State<ChangeTransactionPasswordPage> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  final transactionService = Get.find<TransactionService>();
  final authService = Get.find<AuthService>();
  
  bool isLoading = false;
  bool hasExistingPassword = false;

  @override
  void initState() {
    super.initState();
    checkExistingPassword();
  }
  
  Future<void> checkExistingPassword() async {
    try {
      final userId = authService.getCurrentUserId();
      final has = await transactionService.hasTransactionPassword(userId);
      setState(() {
        hasExistingPassword = has;
      });
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao verificar senha: $e');
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hasExistingPassword 
          ? 'Alterar Senha de Transação'
          : 'Cadastrar Senha de Transação',
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textColor),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A senha de transação é utilizada para autorizar depósitos e transferências',
              style: AppTextStyles.body.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 32),
            // Apenas mostra campo de senha atual se já tiver senha cadastrada
            if (hasExistingPassword)
              _buildTextField(
                controller: currentPasswordController,
                labelText: 'Senha Atual',
                hintText: 'Digite sua senha atual',
                obscureText: true,
              ),
            if (hasExistingPassword) const SizedBox(height: 24),
            _buildTextField(
              controller: newPasswordController,
              labelText: 'Nova Senha',
              hintText: 'Digite sua nova senha',
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: confirmPasswordController,
              labelText: 'Confirmar Nova Senha',
              hintText: 'Confirme sua nova senha',
              obscureText: true,
            ),
            const SizedBox(height: 32),
            SizedBox(
              const Text('Nova Senha', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Digite sua nova senha',
                ),
              ),
              const SizedBox(height: 20),
              
              const Text('Confirmar Nova Senha', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Confirme sua nova senha',
                ),
              ),
              const SizedBox(height: 40),
            ElevatedButton(
              onPressed: isLoading ? null : _savePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                textStyle: AppTextStyles.button,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                  : const Text('Salvar Senha'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Future<void> _savePassword() async {
    // Validar entradas
    if (newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        (hasExistingPassword && currentPasswordController.text.isEmpty)) {
      Get.snackbar('Erro', 'Preencha todos os campos');
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar('Erro', 'As senhas não conferem');
      return;
    }

    setState(() => isLoading = true);

    try {
      final userId = authService.getCurrentUserId();

      if (hasExistingPassword) {
        // Alterar senha existente
        await transactionService.changeTransactionPassword(
          userId,
          currentPasswordController.text,
          newPasswordController.text,
        );
        Get.snackbar('Sucesso', 'Senha alterada com sucesso');
      } else {
        // Cadastrar nova senha
        await transactionService.setTransactionPassword(
          userId,
          newPasswordController.text,
        );
        Get.snackbar('Sucesso', 'Senha cadastrada com sucesso');
      }

      Get.back();
    } catch (e) {
      Get.snackbar('Erro', e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }
}
        ),
      ),
    );
  }
  
  Future<void> _savePassword() async {
    // Validar entradas
    if (newPasswordController.text.isEmpty || 
        confirmPasswordController.text.isEmpty ||
        (hasExistingPassword && currentPasswordController.text.isEmpty)) {
      Get.snackbar('Erro', 'Preencha todos os campos');
      return;
    }
    
    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar('Erro', 'As senhas não conferem');
      return;
    }
    
    setState(() => isLoading = true);
    
    try {
      final userId = authService.getCurrentUserId();
      
      if (hasExistingPassword) {
        // Alterar senha existente
        await transactionService.changeTransactionPassword(
          userId, 
          currentPasswordController.text,
          newPasswordController.text,
        );
        Get.snackbar('Sucesso', 'Senha alterada com sucesso');
      } else {
        // Cadastrar nova senha
        await transactionService.setTransactionPassword(
          userId, 
          newPasswordController.text,
        );
        Get.snackbar('Sucesso', 'Senha cadastrada com sucesso');
      }
      
      Get.back();
    } catch (e) {
      Get.snackbar('Erro', e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }
}