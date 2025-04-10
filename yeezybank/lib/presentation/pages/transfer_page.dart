import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeezybank/presentation/theme/app_colors.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/transaction_service.dart';
import '../../domain/models/transaction_model.dart';
import '../theme/app_text_styles.dart';
import '../widgets/password_prompt.dart';
import '../widgets/money_input_field.dart';
import '../widgets/transaction_confirmation_dialog.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final recipientController = TextEditingController();
  final amountController = TextEditingController();
  final authService = Get.find<AuthService>();
  final transactionService = Get.find<TransactionService>();
  
  bool isLoading = false;
  String? errorMessage;
  
  // Email do usuário atual
  String? currentUserEmail;
  
  @override
  void initState() {
    super.initState();
    // Obter email do usuário atual
    currentUserEmail = authService.getCurrentUser()?.email;
  }
  
  @override
  void dispose() {
    recipientController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Pix', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textColor),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Para quem você vai enviar?',
              style: AppTextStyles.title,
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: recipientController,
                  decoration: InputDecoration(
                    hintText: 'Email do destinatário',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.alternate_email, color: AppColors.primaryColor),
                    errorText: _getRecipientError(),
                  ),
                  onChanged: _validateRecipient,
                ),
              ),
            ),
            const SizedBox(height: 16),
            MoneyInputField(
              controller: recipientController,
              icon: Icons.alternate_email,
              label: 'Email do destinatário',
                labelText: 'Email do destinatário',
                border: const OutlineInputBorder(),
                errorText: _getRecipientError(),
              ),
              onChanged: (value) {
                // Validar se não é o mesmo email
                if (currentUserEmail != null && 
                    value.toLowerCase().trim() == currentUserEmail!.toLowerCase().trim()) {
                  setState(() {
                    errorMessage = 'Não é possível transferir para sua própria conta';
                  });
                } else {
                  setState(() {
                    errorMessage = null;
                  });
                }
              },
            ),
            const SizedBox(height: 32),
            MoneyInputField(
              controller: amountController,
              icon: Icons.attach_money,
              label: 'Valor da transferência (R\$)',
              validator: (value) {
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                    hintText: 'Valor da transferência (R\$)',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.attach_money, color: AppColors.primaryColor),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, informe um valor';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Valor inválido';
                }
                return null;
              },
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(errorMessage!, style: AppTextStyles.error),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _initiateTransfer,
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
                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                  : const Text('Transferir'),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Segurança', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),
            Text(
              'Suas transferências são protegidas com senha e confirmação.',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Future<void> _initiateTransfer() async {
    // Validar entradas
    final email = recipientController.text.trim();
    final amountText = amountController.text.trim();
    
    if (email.isEmpty) {
      setState(() {
        errorMessage = 'Informe o email do destinatário';
      });
      return;
    }
    
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() {
        errorMessage = 'Informe um valor válido';
      });
      return;
    }
    
    // Validar novamente se não é transferência para si mesmo
    if (currentUserEmail != null && 
        email.toLowerCase() == currentUserEmail!.toLowerCase()) {
      setState(() {
        errorMessage = 'Não é possível transferir para você mesmo';
      });
      return;
    }
    
    // Validar senha de transação
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      final userId = authService.getCurrentUserId();
      
      // Solicitar senha de transação
      final password = await promptPassword(context);
      if (password == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      
      // Validar senha
      final isValid = await transactionService.validateTransactionPassword(userId, password);
      if (!isValid) {
        setState(() {
          isLoading = false;
          errorMessage = 'Senha de transação incorreta';
        });
        return;
      }
      
      // Criar estrutura de transação
      final txn = TransactionModel(
        id: '',
        senderId: userId,
        receiverId: '', // será preenchido pelo serviço
        amount: amount,
        timestamp: DateTime.now(),
        participants: [],
        type: 'transfer',
      );
      
      // Iniciar transação
      final pendingTxn = await transactionService.initiateTransaction(
        userId, 
        email, 
        amount
      );
      
      setState(() {
        isLoading = false;
      });
      
      // Mostrar dialog de confirmação
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => TransactionConfirmationDialog(
          transaction: pendingTxn,
          receiverEmail: email,
        ),
      );
      
      if (confirmed == true) {
        // Transação confirmada com sucesso - volta para home
        Get.back(result: true);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }
}