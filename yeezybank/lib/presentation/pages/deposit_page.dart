import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/transaction_service.dart';
import '../controllers/transaction_password_handler.dart';
import '../widgets/money_input_field.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/transaction_confirmation_dialog.dart';
import '../../domain/models/transaction_model.dart';

class DepositPage extends StatefulWidget {
  const DepositPage({super.key});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  final amountController = TextEditingController();
  final authService = Get.find<AuthService>();
  final transactionService = Get.find<TransactionService>();
  final passwordHandler = Get.find<TransactionPasswordHandler>();
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Depositar', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textColor),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Qual valor você quer depositar?',
                style: AppTextStyles.title,
              ),
              const SizedBox(height: 32),
              Card(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.dividerColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: MoneyInputField(
                    controller: amountController,
                    icon: Icons.attach_money,
                    label: 'Valor do depósito (R\$)',
                    onChanged: (value) {
                      setState(() {
                        errorMessage = null;
                      });
                    },
                  ),
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(errorMessage!, style: const TextStyle(color: AppColors.error)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _initiateDeposit,
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
                    : const Text('Depositar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initiateDeposit() async {
    final amountText = amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      setState(() {
        errorMessage = 'Informe um valor válido';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final userId = authService.getCurrentUserId();

      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => TransactionConfirmationDialog(
          transaction: TransactionModel(
            id: '',
            senderId: '',
            receiverId: userId,
            amount: amount,
            timestamp: DateTime.now(),
            participants: [],
            type: 'deposit',
          ),
          receiverEmail: authService.getCurrentUser()!.email!,
        ),
      );

      if (confirmed == true) {
        // Aqui deveria executar a lógica real de depósito 
        // usando o service após a confirmação
        await transactionService.deposit(userId, amount);
        Get.back(result: true);
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}