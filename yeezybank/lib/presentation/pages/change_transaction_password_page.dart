import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/transaction_service.dart';

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
          : 'Cadastrar Senha de Transação'),
        backgroundColor: const Color(0xFF388E3C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'A senha de transação é utilizada para autorizar depósitos e transferências',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              
              // Apenas mostra campo de senha atual se já tiver senha cadastrada
              if (hasExistingPassword) ...[
                const Text('Senha Atual', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Digite sua senha atual',
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
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
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _savePassword,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green[600],
                  ),
                  child: isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Salvar Senha', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
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