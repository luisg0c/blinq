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
import '../controllers/transaction_controller.dart';

class DepositPage extends StatefulWidget {
  const DepositPage({super.key});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final authService = Get.find<AuthService>();
  final transactionService = Get.find<TransactionService>();
  final passwordHandler = Get.find<TransactionPasswordHandler>();
  final transactionController = Get.find<TransactionController>();

  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
                const SizedBox(height: 24),
                Card(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.dividerColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Descrição (opcional)',
                        hintText: 'Ex: Depósito mensal',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.dividerColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.primaryColor,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.description_outlined,
                          color: AppColors.textColor,
                        ),
                      ),
                      maxLength: 100,
                    ),
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  ),
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
                  child:
                      isLoading
                          ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                          : const Text('Depositar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _initiateDeposit() async {
    final amountText = amountController.text.trim();
    final amount = double.tryParse(amountText.replaceAll(',', '.'));
    final description = descriptionController.text.trim();

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

      // Solicitar senha de transação
      final password = await _promptForPassword(userId);
      if (password == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Criar objeto de transação para mostrar na confirmação
      final transaction = TransactionModel(
        id: '',
        senderId: userId,
        receiverId: userId,
        amount: amount,
        timestamp: DateTime.now(),
        participants: [userId],
        type: 'deposit',
        description: description.isNotEmpty ? description : null,
      );

      // Mostrar diálogo de confirmação
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => TransactionConfirmationDialog(
              transaction: transaction,
              receiverEmail: authService.getCurrentUser()!.email!,
            ),
      );

      if (confirmed == true) {
        // Executar depósito
        await transactionService.deposit(
          userId,
          amount,
          description: description.isNotEmpty ? description : null,
        );

        // Mostrar snackbar de sucesso
        Get.snackbar(
          'Sucesso',
          'Depósito realizado com sucesso!',
          backgroundColor: AppColors.success.withOpacity(0.1),
          colorText: AppColors.success,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(8),
          icon: const Icon(Icons.check_circle, color: AppColors.success),
        );

        // Voltar para a página anterior com resultado de sucesso
        Get.back(result: true);
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<String?> _promptForPassword(String userId) async {
    try {
      // Verificar se o usuário tem senha de transação
      final hasPassword = await transactionService.hasTransactionPassword(
        userId,
      );

      if (hasPassword) {
        // Solicitar senha existente
        return await passwordHandler.ensureValidPassword(context, userId)
            ? 'valid_password'
            : null;
      } else {
        // Cadastrar nova senha
        final newPassword = await passwordHandler.ensureValidPassword(
          context,
          userId,
        );
        return newPassword ? 'new_password' : null;
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao processar senha: $e';
      });
      return null;
    }
  }
}
