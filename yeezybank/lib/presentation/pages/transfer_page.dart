import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/transaction_service.dart';
import '../../domain/models/transaction_model.dart';
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
      appBar: AppBar(title: const Text('Enviar Pix')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Realizar Transferência',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: recipientController,
              decoration: InputDecoration(
                prefixIcon: const Icon(LineIcons.user),
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
            const SizedBox(height: 20),
            MoneyInputField(
              controller: amountController,
              icon: LineIcons.dollarSign,
              label: 'Valor da transferência (R\$)',
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
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red[700], fontSize: 14),
              ),
            ],
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: isLoading 
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ) 
                    : const Icon(LineIcons.paperPlane),
                label: const Text('Iniciar Transferência'),
                onPressed: isLoading ? null : _initiateTransfer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            
            // Texto explicativo
            const SizedBox(height: 24),
            const Text(
              'Segurança Estilo Nubank',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Suas transferências agora são mais seguras:\n'
              '1. Você inicia a transferência\n'
              '2. Insere um código de confirmação\n'
              '3. A transação só é concluída após sua confirmação',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String? _getRecipientError() {
    if (currentUserEmail != null && 
        recipientController.text.isNotEmpty &&
        recipientController.text.toLowerCase().trim() == currentUserEmail!.toLowerCase().trim()) {
      return 'Não é possível transferir para você mesmo';
    }
    return null;
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