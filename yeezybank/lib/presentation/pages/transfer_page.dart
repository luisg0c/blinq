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
                side: BorderSide(color: AppColors.dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextFormField(
                  controller: recipientController,
                  decoration: InputDecoration(
                    hintText: 'Email do destinatário',
                    hintStyle: AppTextStyles.input.copyWith(color: AppColors.hintColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.dividerColor, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.dividerColor, width: 1.0)),
                    prefixIcon: Icon(Icons.alternate_email, color: AppColors.textColor),
                    errorText: errorMessage, // Exibe a mensagem de erro
                    errorStyle: AppTextStyles.error,
                  ),
                  onChanged: (value) {                    
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
              ),
            ),            
            const SizedBox(height: 32),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                    hintText: 'Valor da transferência (R\$)',                  
                    hintStyle: AppTextStyles.input.copyWith(color: AppColors.hintColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.dividerColor, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.dividerColor, width: 1.0)),
                    prefixIcon: Icon(Icons.attach_money, color: AppColors.textColor),
                  ),
                  keyboardType: TextInputType.number,                  
                  onChanged: (value) {                    
                    if (value.isNotEmpty) {                      
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        setState(() {
                          errorMessage = 'Valor inválido';
                        });
                      } else {
                        setState(() {
                          errorMessage = null;
                        });
                      }
                    } else {
                      setState(() {
                        errorMessage = null;
                      });
                    }
                  },
                ),
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
                foregroundColor: AppColors.surface,
                minimumSize: const Size(double.infinity, 50),
                textStyle: AppTextStyles.button,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface))
                  : const Text('Transferir'),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
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