import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/account_service.dart';
import '../services/transaction_service.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({Key? key}) : super(key: key);

  static const String routeName = '/transfer';

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _transactionPasswordController = TextEditingController();

  final _authService = AuthService();
  final _accountService = AccountService();
  final _transactionService = TransactionService();

  bool _isLoading = false;
  bool _showTransactionPasswordDialog = false;
  double? _accountBalance;
  String? _userId;
  String? _errorMessage;
  double? _transferAmount;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _transactionPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.getCurrentUserModel();
      if (user != null) {
        _userId = user.id;
        final account = await _accountService.getAccount(user.id);
        setState(() {
          _accountBalance = account?.balance ?? 0;
        });
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initiateTransfer() async {
    if (!_formKey.currentState!.validate()) return;

    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;

    // Check if amount is within limits
    if (amount < AppConstants.minTransferAmount) {
      setState(() {
        _errorMessage =
            'Valor mínimo de transferência: ${Formatters.formatCurrency(AppConstants.minTransferAmount)}';
      });
      return;
    }

    if (amount > AppConstants.maxTransferAmount) {
      setState(() {
        _errorMessage =
            'Valor máximo de transferência: ${Formatters.formatCurrency(AppConstants.maxTransferAmount)}';
      });
      return;
    }

    // Check if user has enough balance
    if (amount > (_accountBalance ?? 0)) {
      setState(() {
        _errorMessage = 'Saldo insuficiente para realizar esta transferência';
      });
      return;
    }

    setState(() {
      _transferAmount = amount;
      _errorMessage = null;
      _showTransactionPasswordDialog = true;
    });
  }

  Future<void> _confirmTransfer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_userId == null || _transferAmount == null) {
        throw Exception('Dados de transferência inválidos');
      }

      // First validate transaction password
      final hasPassword =
          await _accountService.hasTransactionPassword(_userId!);

      if (hasPassword) {
        final isValid = await _accountService.validateTransactionPassword(
          _userId!,
          _transactionPasswordController.text,
        );

        if (!isValid) {
          setState(() {
            _errorMessage = 'Senha de transação incorreta';
            _isLoading = false;
          });
          return;
        }
      } else {
        // Set transaction password if it doesn't exist
        if (_transactionPasswordController.text.length <
            AppConstants.minTransactionPasswordLength) {
          setState(() {
            _errorMessage =
                'A senha deve ter pelo menos ${AppConstants.minTransactionPasswordLength} dígitos';
            _isLoading = false;
          });
          return;
        }

        await _accountService.setTransactionPassword(
          _userId!,
          _transactionPasswordController.text,
        );
      }

      // Process transfer
      await _transactionService.transfer(
        senderId: _userId!,
        receiverEmail: _emailController.text,
        amount: _transferAmount!,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
      );

      // Show success UI and navigate back
      _showSuccessDialog();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao realizar transferência: ${e.toString()}';
        _isLoading = false;
        _showTransactionPasswordDialog = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Transferência realizada!',
              style: GoogleFonts.lexend(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Sua transferência foi processada com sucesso.',
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Voltar para a tela inicial',
              onPressed: () {
                Navigator.of(context).popUntil(ModalRoute.withName('/home'));
              },
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.text,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Transferência',
          style: GoogleFonts.lexend(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ),
      body: _isLoading && !_showTransactionPasswordDialog
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Available Balance Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Saldo disponível',
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                color: AppColors.textLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Formatters.formatCurrency(_accountBalance ?? 0),
                              style: GoogleFonts.lexend(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Para quem você deseja transferir?',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.text,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Recipient Email
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email do destinatário',
                        hint: 'Digite o email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (value) => Validators.validateEmail(value),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Qual valor você deseja transferir?',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.text,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Amount
                      CustomTextField(
                        controller: _amountController,
                        label: 'Valor',
                        hint: 'R\$ 0,00',
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: Icons.attach_money_rounded,
                        validator: (value) => Validators.validateAmount(value),
                        inputFormatters: [Formatters.currencyInputFormatter],
                      ),

                      const SizedBox(height: 24),

                      // Description (Optional)
                      CustomTextField(
                        controller: _descriptionController,
                        label: 'Descrição (opcional)',
                        hint: 'Adicione uma descrição',
                        prefixIcon: Icons.description_outlined,
                        maxLines: 2,
                      ),

                      // Error Message
                      if (_errorMessage != null &&
                          !_showTransactionPasswordDialog) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Continue Button
                      CustomButton(
                        text: 'Continuar',
                        onPressed: _initiateTransfer,
                        isFullWidth: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

      // Transaction Password Dialog
      bottomSheet: _showTransactionPasswordDialog
          ? Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Confirmar transferência',
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: AppColors.textLight,
                        ),
                        onPressed: () {
                          setState(() {
                            _showTransactionPasswordDialog = false;
                            _transactionPasswordController.clear();
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Summary
                  Text(
                    'Você está transferindo:',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    Formatters.formatCurrency(_transferAmount ?? 0),
                    style: GoogleFonts.lexend(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Para: ${_emailController.text}',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Transaction Password
                  CustomTextField(
                    controller: _transactionPasswordController,
                    label: 'Senha de transação',
                    hint: 'Digite sua senha de transação',
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.lock_outline,
                  ),

                  // Error Message
                  if (_errorMessage != null &&
                      _showTransactionPasswordDialog) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Confirm Button
                  CustomButton(
                    text: 'Confirmar',
                    onPressed: _isLoading ? null : _confirmTransfer,
                    isLoading: _isLoading,
                    isFullWidth: true,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
