import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/components/custom_money_field.dart';
import '../../../core/services/email_validation_service.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../theme/app_theme.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final recipientCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // ✅ CONTROLE DE VALIDAÇÃO
  bool _isValidatingEmail = false;
  EmailValidationResult? _emailValidationResult;
  bool _isProcessing = false;

  @override
  void dispose() {
    recipientCtrl.dispose();
    amountCtrl.dispose();
    descriptionCtrl.dispose();
    super.dispose();
  }

  // lib/presentation/pages/transfer/transfer_page.dart - SEÇÃO INITSTATE ATUALIZADA

  @override
  void initState() {
    super.initState();
    // ✅ LISTENER PARA VALIDAÇÃO EM TEMPO REAL
    recipientCtrl.addListener(_onEmailChanged);
    
    // ✅ VERIFICAR SE VEIO DE QR CODE
    _checkQrCodeData();
  }

  /// ✅ VERIFICAR E PREENCHER DADOS DO QR CODE
  void _checkQrCodeData() {
    final args = Get.arguments as Map<String, dynamic>?;
    
    if (args != null && args['fromQrCode'] == true) {
      print('📱 Preenchendo dados do QR Code');
      
      // Preencher email do destinatário
      if (args['recipient'] != null) {
        recipientCtrl.text = args['recipient'].toString();
        // Validar email automaticamente
        _validateEmail(args['recipient'].toString());
      }
      
      // Preencher valor
      if (args['amount'] != null) {
        final amount = args['amount'] as double;
        // Converter para formato brasileiro
        final formattedAmount = 'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}';
        amountCtrl.text = formattedAmount;
      }
      
      // Preencher descrição
      if (args['description'] != null && args['description'].toString().isNotEmpty) {
        descriptionCtrl.text = args['description'].toString();
      }
      
      // Mostrar feedback que dados foram preenchidos
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'QR Code Carregado! 📱',
          'Dados preenchidos automaticamente. Confirme as informações.',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      });
    }
  }

  /// ✅ VALIDAR EMAIL
  Future<void> _validateEmail(String email) async {
    if (!EmailValidationService.isValidFormat(email)) {
      setState(() {
        _emailValidationResult = EmailValidationResult.invalid('Formato inválido');
      });
      return;
    }

    setState(() => _isValidatingEmail = true);

    try {
      final result = await EmailValidationService.validateRecipientEmail(email);
      
      if (mounted) {
        setState(() {
          _emailValidationResult = result;
          _isValidatingEmail = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _emailValidationResult = EmailValidationResult.invalid('Erro na verificação');
          _isValidatingEmail = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return Scaffold(
      backgroundColor: neomorphTheme.backgroundColor,
      appBar: _buildNeomorphAppBar(context),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildNeomorphAppBar(BuildContext context) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return AppBar(
      backgroundColor: neomorphTheme.backgroundColor,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: neomorphTheme.surfaceColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: neomorphTheme.highlightColor.withOpacity(0.7),
                offset: const Offset(-2, -2),
                blurRadius: 6,
              ),
              BoxShadow(
                color: neomorphTheme.shadowDarkColor.withOpacity(0.5),
                offset: const Offset(2, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back,
            color: neomorphTheme.textPrimaryColor,
            size: 20,
          ),
        ),
      ),
      title: Text(
        'Transferir',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: neomorphTheme.textPrimaryColor,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com ícone
            _buildHeader(context),
            
            const SizedBox(height: 32),
            
            // ✅ CAMPO DE EMAIL COM VALIDAÇÃO
            _buildSectionTitle(context, 'Destinatário'),
            const SizedBox(height: 12),
            _buildEmailField(context),
            
            const SizedBox(height: 24),
            
            // Campo de valor
            _buildSectionTitle(context, 'Valor'),
            const SizedBox(height: 12),
            _buildMoneyField(context),
            
            const SizedBox(height: 24),
            
            // Campo de descrição
            _buildSectionTitle(context, 'Descrição (opcional)'),
            const SizedBox(height: 12),
            _buildDescriptionField(context),
            
            const SizedBox(height: 40),
            
            // Botão de continuar
            _buildContinueButton(context),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: neomorphTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: neomorphTheme.highlightColor.withOpacity(0.7),
            offset: const Offset(-6, -6),
            blurRadius: 12,
          ),
          BoxShadow(
            color: neomorphTheme.shadowDarkColor.withOpacity(0.5),
            offset: const Offset(6, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: neomorphTheme.surfaceColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: neomorphTheme.highlightColor.withOpacity(0.7),
                  offset: const Offset(-3, -3),
                  blurRadius: 6,
                ),
                BoxShadow(
                  color: neomorphTheme.shadowDarkColor.withOpacity(0.5),
                  offset: const Offset(3, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Icon(
              Icons.send_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Enviar Dinheiro',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: neomorphTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Transfira para qualquer conta Blinq\nde forma rápida e segura',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: neomorphTheme.textSecondaryColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: neomorphTheme.textPrimaryColor,
      ),
    );
  }

  /// ✅ CAMPO DE EMAIL COM VALIDAÇÃO VISUAL
  Widget _buildEmailField(BuildContext context) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: neomorphTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getBorderColor(isDark),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: neomorphTheme.highlightColor.withOpacity(0.5),
                offset: const Offset(-2, -2),
                blurRadius: 6,
              ),
              BoxShadow(
                color: neomorphTheme.shadowDarkColor.withOpacity(0.3),
                offset: const Offset(2, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextFormField(
            controller: recipientCtrl,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: neomorphTheme.textPrimaryColor,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Email do destinatário',
              hintStyle: TextStyle(
                color: neomorphTheme.textSecondaryColor,
                fontSize: 16,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: neomorphTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: neomorphTheme.highlightColor.withOpacity(0.7),
                      offset: const Offset(-2, -2),
                      blurRadius: 4,
                    ),
                    BoxShadow(
                      color: neomorphTheme.shadowDarkColor.withOpacity(0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.email_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              suffixIcon: _buildEmailSuffixIcon(),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe o email do destinatário';
              }
              
              if (_emailValidationResult?.isValid == false) {
                return _emailValidationResult?.errorMessage;
              }
              
              if (_emailValidationResult?.userExists == false) {
                return 'Este email não está cadastrado no Blinq';
              }
              
              return null;
            },
          ),
        ),

        // ✅ FEEDBACK VISUAL DA VALIDAÇÃO
        if (_emailValidationResult != null && _emailValidationResult!.userExists)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Destinatário: ${_emailValidationResult!.userName}',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// ✅ ÍCONE DO CAMPO EMAIL BASEADO NO STATUS
  Widget? _buildEmailSuffixIcon() {
    if (_isValidatingEmail) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
      );
    }

    if (_emailValidationResult != null) {
      if (_emailValidationResult!.userExists) {
        return const Icon(Icons.check_circle, color: AppColors.success);
      } else if (_emailValidationResult!.isValid) {
        return const Icon(Icons.warning, color: AppColors.warning);
      } else {
        return const Icon(Icons.error, color: AppColors.error);
      }
    }

    return null;
  }

  Color _getBorderColor(bool isDark) {
    if (_emailValidationResult?.userExists == true) {
      return AppColors.success.withOpacity(0.5);
    } else if (_emailValidationResult?.isValid == false) {
      return AppColors.error.withOpacity(0.5);
    } else {
      return isDark 
          ? Colors.white.withOpacity(0.1) 
          : Colors.black.withOpacity(0.08);
    }
  }

  Widget _buildMoneyField(BuildContext context) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return Container(
      decoration: BoxDecoration(
        color: neomorphTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomMoneyField(
        controller: amountCtrl,
        onChanged: (val) {
          // Opcional: converter de "R$ 1.234,56" para double
        },
      ),
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return Container(
      decoration: BoxDecoration(
        color: neomorphTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: neomorphTheme.highlightColor.withOpacity(0.5),
            offset: const Offset(-2, -2),
            blurRadius: 6,
          ),
          BoxShadow(
            color: neomorphTheme.shadowDarkColor.withOpacity(0.3),
            offset: const Offset(2, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: TextFormField(
        controller: descriptionCtrl,
        maxLines: 3,
        style: TextStyle(
          color: neomorphTheme.textPrimaryColor,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: 'Motivo da transferência',
          hintStyle: TextStyle(
            color: neomorphTheme.textSecondaryColor,
            fontSize: 16,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: neomorphTheme.surfaceColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: neomorphTheme.highlightColor.withOpacity(0.7),
                  offset: const Offset(-2, -2),
                  blurRadius: 4,
                ),
                BoxShadow(
                  color: neomorphTheme.shadowDarkColor.withOpacity(0.5),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return GestureDetector(
      onTap: _isProcessing ? null : _onContinuePressed,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: _isProcessing ? null : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              Color(0xFF5BC4A8),
            ],
          ),
          color: _isProcessing ? Colors.grey : null,
          boxShadow: _isProcessing ? [] : [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
            BoxShadow(
              color: neomorphTheme.highlightColor.withOpacity(0.7),
              offset: const Offset(-2, -2),
              blurRadius: 6,
            ),
            BoxShadow(
              color: neomorphTheme.shadowDarkColor.withOpacity(0.5),
              offset: const Offset(2, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: _isProcessing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Continuar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  /// ✅ PROCESSAR TRANSFERÊNCIA
  Future<void> _onContinuePressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Verificar se email foi validado
    if (_emailValidationResult?.userExists != true) {
      Get.snackbar(
        'Erro',
        'Aguarde a validação do email ou informe um email válido',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (amountCtrl.text.isEmpty) {
      Get.snackbar('Atenção', 'Informe o valor da transferência');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Converter valor corretamente
      final amountText = amountCtrl.text.replaceAll(RegExp(r'[^\d,]'), '');
      final amount = double.tryParse(amountText.replaceAll(',', '.')) ?? 0.0;
      
      if (amount <= 0) {
        throw Exception('Valor inválido');
      }
      
      // Navegar para verificação de PIN
      Get.toNamed(
        AppRoutes.verifyPin,
        arguments: {
          'flow': 'transfer',
          'recipient': recipientCtrl.text.trim(),
          'amount': amount,
          'description': descriptionCtrl.text.trim().isNotEmpty 
              ? descriptionCtrl.text.trim()
              : 'Transferência PIX',
        },
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}