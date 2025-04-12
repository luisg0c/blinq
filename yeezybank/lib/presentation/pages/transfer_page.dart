import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/transaction_service.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/transaction_password_handler.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
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
  final descriptionController = TextEditingController();

  // Usar Get.find para evitar problemas de ciclo de vida
  late final AuthService authService;
  late final TransactionService transactionService;
  late final TransactionController transactionController;
  late final TransactionPasswordHandler passwordHandler;

  bool isLoading = false;
  String? errorMessage;
  String? currentUserEmail;
  bool isLoggedIn = true;

  @override
  void initState() {
    super.initState();
    // Inicializar services e controllers
    _initDependencies();
    // Obter email do usuário atual
    _loadUserEmail();
  }

  void _initDependencies() {
    try {
      authService = Get.find<AuthService>();
      transactionService = Get.find<TransactionService>();
      transactionController = Get.find<TransactionController>();
      passwordHandler = Get.find<TransactionPasswordHandler>();
    } catch (e) {
      print('Erro ao inicializar dependências: $e');
      // Marcar como não logado para redirecionar
      isLoggedIn = false;
      // Redirecionar para login após construção da UI
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/login');
      });
    }
  }

  void _loadUserEmail() {
    try {
      final user = authService.getCurrentUser();
      if (user != null) {
        setState(() {
          currentUserEmail = user.email;
        });
      } else {
        // Usuário não está logado
        setState(() {
          isLoggedIn = false;
        });

        // Redirecionar para login após construção da UI
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed('/login');
        });
      }
    } catch (e) {
      print('Erro ao carregar email do usuário: $e');
      // Marcar como não logado para possível redirecionamento
      setState(() {
        isLoggedIn = false;
      });
    }
  }

  @override
  void dispose() {
    recipientController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Se não estiver logado, mostrar tela de carregamento
    if (!isLoggedIn) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Pix', style: AppTextStyles.appBarTitle),
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
                Text('Para quem você vai enviar?', style: AppTextStyles.title),
                const SizedBox(height: 32),
                _buildRecipientField(),
                const SizedBox(height: 32),
                _buildAmountField(),
                const SizedBox(height: 24),
                _buildDescriptionField(),
                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(errorMessage!, style: AppTextStyles.error),
                ],
                const SizedBox(height: 24),
                _buildTransferButton(),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: _buildSecurityInfoSheet(),
    );
  }

  Widget _buildRecipientField() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.dividerColor),
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
              borderSide: const BorderSide(
                color: AppColors.dividerColor,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.dividerColor,
                width: 1.0,
              ),
            ),
            prefixIcon: const Icon(
              Icons.alternate_email,
              color: AppColors.textColor,
            ),
          ),
          onChanged: (value) {
            if (currentUserEmail != null &&
                value.toLowerCase().trim() ==
                    currentUserEmail!.toLowerCase().trim()) {
              setState(() {
                errorMessage =
                    'Não é possível transferir para sua própria conta';
              });
            } else {
              setState(() {
                errorMessage = null;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: MoneyInputField(
          controller: amountController,
          label: 'Valor da transferência (R\$)',
          hint: '0,00',
          onChanged: (value) {
            if (value.isNotEmpty) {
              final amount = double.tryParse(value.replaceAll(',', '.'));
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
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: 'Descrição (opcional)',
            hintText: 'Ex: Pagamento de almoço',
            hintStyle: AppTextStyles.input.copyWith(color: AppColors.hintColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.dividerColor,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.dividerColor,
                width: 1.0,
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
    );
  }

  Widget _buildTransferButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : _initiateTransfer,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.surface,
        minimumSize: const Size(double.infinity, 50),
        textStyle: AppTextStyles.button,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child:
          isLoading
              ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
              )
              : const Text('Transferir'),
    );
  }

  Widget _buildSecurityInfoSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Segurança', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          const Text(
            'Suas transferências são protegidas com senha e confirmação.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _initiateTransfer() async {
    // Verificar estado de autenticação
    if (!isLoggedIn) {
      setState(() {
        errorMessage = 'Sessão expirada. Por favor, faça login novamente.';
      });

      Future.delayed(Duration(seconds: 1), () {
        Get.offAllNamed('/login');
      });

      return;
    }

    // Validar entradas
    final email = recipientController.text.trim();
    final amountText = amountController.text.trim();
    final description = descriptionController.text.trim();

    if (email.isEmpty) {
      setState(() {
        errorMessage = 'Informe o email do destinatário';
      });
      return;
    }

    final amount = double.tryParse(amountText.replaceAll(',', '.'));
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
      String? userId;
      try {
        userId = authService.getCurrentUserId();
        if (userId.isEmpty) {
          throw Exception('Usuário não logado');
        }
      } catch (e) {
        throw Exception('Sessão expirada. Faça login novamente.');
      }

      // Solicitar senha de transação de forma mais robusta
      String? password;
      try {
        password = await passwordHandler.ensureValidPassword(context, userId);
      } catch (e) {
        throw Exception('Erro ao processar senha: $e');
      }

      if (password == null || password.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Verificar limite diário com tratamento de erro
      try {
        final withinLimit = await transactionService.checkDailyTransferLimit(
          userId,
          amount,
        );
        if (!withinLimit) {
          throw Exception('Limite diário de transferência excedido');
        }
      } catch (e) {
        if (e.toString().contains('limite')) {
          throw e;
        } else {
          throw Exception('Erro ao verificar limite diário');
        }
      }

      // Iniciar transação usando o controller melhorado
      await transactionController.transfer(
        amount,
        email,
        password,
        description: description.isNotEmpty ? description : null,
      );

      // Sucesso - voltar para a página anterior
      Get.back(result: true);
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });

      // Verificar se erro é de autenticação
      String errorStr = e.toString().toLowerCase();
      if (errorStr.contains('sessão') ||
          errorStr.contains('login') ||
          errorStr.contains('autenticação') ||
          errorStr.contains('usuário não logado')) {
        Future.delayed(Duration(seconds: 2), () {
          Get.offAllNamed('/login');
        });
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
