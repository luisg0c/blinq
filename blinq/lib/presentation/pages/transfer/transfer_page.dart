// lib/presentation/pages/transfer/transfer_page.dart - REFATORAÇÃO COMPLETA

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../../core/components/custom_money_field.dart';
import '../../../core/services/email_validation_service.dart';
import '../../../core/utils/money_input_formatter.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../theme/app_theme.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  // ✅ CONTROLLERS
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // ✅ ESTADO DA VALIDAÇÃO DE EMAIL
  bool _isValidatingEmail = false;
  EmailValidationResult? _emailValidationResult;
  Timer? _emailDebounceTimer;

  // ✅ ESTADO DA TRANSFERÊNCIA
  bool _isProcessing = false;
  double _currentAmount = 0.0;

  // ✅ DADOS DO QR CODE
  Map<String, dynamic>? _qrCodeData;

  @override
  void initState() {
    super.initState();
    _setupListeners();
    _checkQrCodeData();
  }

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  /// ✅ CONFIGURAR LISTENERS
  void _setupListeners() {
    _recipientController.addListener(_onEmailChanged);
  }

  /// ✅ LIMPAR RECURSOS
  void _cleanupResources() {
    _emailDebounceTimer?.cancel();
    _recipientController.removeListener(_onEmailChanged);
    _recipientController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
  }

  /// ✅ VERIFICAR DADOS DO QR CODE
  void _checkQrCodeData() {
    try {
      final args = Get.arguments as Map<String, dynamic>?;
      
      if (args != null && args['fromQrCode'] == true) {
        _qrCodeData = args;
        _fillFromQrCode(args);
      }
    } catch (e) {
      print('❌ Erro ao processar dados do QR Code: $e');
    }
  }

  /// ✅ PREENCHER DADOS DO QR CODE
  void _fillFromQrCode(Map<String, dynamic> data) {
    print('📱 Preenchendo dados do QR Code: $data');
    
    try {
      // Preencher destinatário
      if (data['recipient'] != null) {
        _recipientController.text = data['recipient'].toString();
        _validateEmailImmediate(data['recipient'].toString());
      }
      
      // Preencher valor
      if (data['amount'] != null) {
        final amount = data['amount'] as double;
        _amountController.text = MoneyInputFormatter.formatAmount(amount);
        _currentAmount = amount;
      }
      
      // Preencher descrição
      if (data['description'] != null && data['description'].toString().isNotEmpty) {
        _descriptionController.text = data['description'].toString();
      }
      
      // Mostrar feedback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showQrCodeLoadedFeedback();
      });
      
    } catch (e) {
      print('❌ Erro ao preencher dados do QR Code: $e');
    }
  }

  /// ✅ LISTENER PARA MUDANÇAS NO EMAIL
  void _onEmailChanged() {
    final email = _recipientController.text.trim();
    
    // Cancelar timer anterior
    _emailDebounceTimer?.cancel();
    
    // Limpar resultado se email mudou significativamente
    if (_emailValidationResult != null && email.isNotEmpty) {
      final previousEmail = _emailValidationResult!.userName ?? '';
      if (!email.toLowerCase().contains(previousEmail.toLowerCase().substring(0, 
          previousEmail.length > 3 ? 3 : previousEmail.length))) {
        setState(() => _emailValidationResult = null);
      }
    }
    
    // Validar após delay
    if (email.isNotEmpty && email.length >= 3 && EmailValidationService.isValidFormat(email)) {
      _emailDebounceTimer = Timer(const Duration(milliseconds: 800), () {
        _validateEmail(email);
      });
    } else {
      setState(() => _emailValidationResult = null);
    }
  }

  /// ✅ VALIDAR EMAIL COM DEBOUNCE
  Future<void> _validateEmail(String email) async {
    if (!mounted) return;
    
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
      print('❌ Erro na validação de email: $e');
      
      if (mounted) {
        setState(() {
          _emailValidationResult = EmailValidationResult.invalid('Erro na verificação');
          _isValidatingEmail = false;
        });
      }
    }
  }

  /// ✅ VALIDAR EMAIL IMEDIATAMENTE (PARA QR CODE)
  Future<void> _validateEmailImmediate(String email) async {
    if (!EmailValidationService.isValidFormat(email)) return;
    
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
      print('❌ Erro na validação imediata: $e');
      if (mounted) {
        setState(() => _isValidatingEmail = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return Scaffold(
      backgroundColor: neomorphTheme.backgroundColor,
      appBar: _buildAppBar(neomorphTheme),
      body: _buildBody(neomorphTheme),
    );
  }

  /// ✅ APP BAR MELHORADA
  PreferredSizeWidget _buildAppBar(NeomorphTheme theme) {
    return AppBar(
      backgroundColor: theme.backgroundColor,
      elevation: 0,
      leading: _buildNeomorphBackButton(theme),
      title: Text(
        'Transferir',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: theme.textPrimaryColor,
        ),
      ),
      centerTitle: true,
      actions: [
        _buildNeomorphQrButton(theme),
      ],
    );
  }

  /// ✅ BOTÃO VOLTAR NEOMORFO
  Widget _buildNeomorphBackButton(NeomorphTheme theme) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          decoration: BoxDecoration(
            color: theme.surfaceColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.highlightColor.withOpacity(0.7),
                offset: const Offset(-2, -2),
                blurRadius: 6,
              ),
              BoxShadow(
                color: theme.shadowDarkColor.withOpacity(0.5),
                offset: const Offset(2, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back,
            color: theme.textPrimaryColor,
            size: 20,
          ),
        ),
      ),
    );
  }

  /// ✅ BOTÃO QR CODE NEOMORFO
  Widget _buildNeomorphQrButton(NeomorphTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.qrCode),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.surfaceColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.highlightColor.withOpacity(0.7),
                offset: const Offset(-2, -2),
                blurRadius: 6,
              ),
              BoxShadow(
                color: theme.shadowDarkColor.withOpacity(0.5),
                offset: const Offset(2, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: const Icon(
            Icons.qr_code_scanner,
            color: AppColors.primary,
            size: 18,
          ),
        ),
      ),
    );
  }

  /// ✅ CORPO DA PÁGINA
  Widget _buildBody(NeomorphTheme theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(theme),
            const SizedBox(height: 32),
            
            // QR Code indicator
            if (_qrCodeData != null) _buildQrCodeIndicator(theme),
            
            // Destinatário
            _buildSectionTitle('Destinatário', theme),
            const SizedBox(height: 12),
            _buildEmailField(theme),
            const SizedBox(height: 24),
            
            // Valor
            _buildSectionTitle('Valor', theme),
            const SizedBox(height: 12),
            _buildMoneyField(theme),
            const SizedBox(height: 24),
            
            // Descrição
            _buildSectionTitle('Descrição (opcional)', theme),
            const SizedBox(height: 12),
            _buildDescriptionField(theme),
            const SizedBox(height: 40),
            
            // Botão continuar
            _buildContinueButton(theme),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// ✅ HEADER NEOMORFO
  Widget _buildHeader(NeomorphTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.highlightColor.withOpacity(0.7),
            offset: const Offset(-6, -6),
            blurRadius: 12,
          ),
          BoxShadow(
            color: theme.shadowDarkColor.withOpacity(0.5),
            offset: const Offset(6, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildNeomorphIcon(theme, Icons.send_rounded),
          const SizedBox(height: 16),
          Text(
            'Enviar Dinheiro',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Transfira para qualquer conta Blinq\nde forma rápida e segura',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.textSecondaryColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ ÍCONE NEOMORFO REUTILIZÁVEL
  Widget _buildNeomorphIcon(NeomorphTheme theme, IconData icon) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.highlightColor.withOpacity(0.7),
            offset: const Offset(-3, -3),
            blurRadius: 6,
          ),
          BoxShadow(
            color: theme.shadowDarkColor.withOpacity(0.5),
            offset: const Offset(3, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.primary, size: 28),
    );
  }

  /// ✅ INDICADOR QR CODE
  Widget _buildQrCodeIndicator(NeomorphTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.qr_code,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Dados preenchidos via QR Code',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: _clearQrCodeData,
            icon: const Icon(
              Icons.close,
              color: AppColors.primary,
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  /// ✅ TÍTULO DE SEÇÃO
  Widget _buildSectionTitle(String title, NeomorphTheme theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: theme.textPrimaryColor,
      ),
    );
  }

  /// ✅ CAMPO DE EMAIL MELHORADO
  Widget _buildEmailField(NeomorphTheme theme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _getEmailBorderColor(isDark), width: 1),
            boxShadow: [
              BoxShadow(
                color: theme.highlightColor.withOpacity(0.5),
                offset: const Offset(-2, -2),
                blurRadius: 6,
              ),
              BoxShadow(
                color: theme.shadowDarkColor.withOpacity(0.3),
                offset: const Offset(2, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextFormField(
            controller: _recipientController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: theme.textPrimaryColor, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Digite o email do destinatário',
              hintStyle: TextStyle(color: theme.textSecondaryColor, fontSize: 16),
              prefixIcon: _buildNeomorphFieldIcon(theme, Icons.person_search),
              suffixIcon: _buildEmailSuffixIcon(),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            validator: _validateEmailField,
          ),
        ),

        // Feedback visual da validação
        if (_emailValidationResult != null) ...[
          const SizedBox(height: 8),
          _buildEmailFeedback(),
        ],
      ],
    );
  }

  /// ✅ ÍCONE NEOMORFO PARA CAMPOS
  Widget _buildNeomorphFieldIcon(NeomorphTheme theme, IconData icon) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: theme.highlightColor.withOpacity(0.7),
            offset: const Offset(-2, -2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: theme.shadowDarkColor.withOpacity(0.5),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }

  /// ✅ ÍCONE DE SUFIXO DO EMAIL
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

  /// ✅ FEEDBACK DO EMAIL
  Widget _buildEmailFeedback() {
    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    IconData icon;
    String message;

    if (_emailValidationResult!.userExists) {
      backgroundColor = AppColors.success.withOpacity(0.1);
      borderColor = AppColors.success.withOpacity(0.3);
      iconColor = AppColors.success;
      icon = Icons.check_circle;
      message = 'Destinatário: ${_emailValidationResult!.userName ?? 'Usuário Blinq'}';
    } else if (_emailValidationResult!.isValid) {
      backgroundColor = AppColors.warning.withOpacity(0.1);
      borderColor = AppColors.warning.withOpacity(0.3);
      iconColor = AppColors.warning;
      icon = Icons.info;
      message = _emailValidationResult!.errorMessage ?? 'Usuário não encontrado';
    } else {
      backgroundColor = AppColors.error.withOpacity(0.1);
      borderColor = AppColors.error.withOpacity(0.3);
      iconColor = AppColors.error;
      icon = Icons.error;
      message = _emailValidationResult!.errorMessage ?? 'Email inválido';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ CAMPO DE VALOR CORRIGIDO
  Widget _buildMoneyField(NeomorphTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.highlightColor.withOpacity(0.5),
            offset: const Offset(-2, -2),
            blurRadius: 6,
          ),
          BoxShadow(
            color: theme.shadowDarkColor.withOpacity(0.3),
            offset: const Offset(2, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: CustomMoneyField(
        controller: _amountController,
        label: 'Valor (R\$)',
        hintText: 'Digite o valor da transferência',
        minAmount: 0.01,
        maxAmount: 50000.00,
        onAmountChanged: (amount) {
          _currentAmount = amount;
          print('💰 Valor alterado: R\$ ${amount.toStringAsFixed(2)}');
        },
        validator: _validateAmountField,
      ),
    );
  }

  /// ✅ CAMPO DE DESCRIÇÃO
  Widget _buildDescriptionField(NeomorphTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.highlightColor.withOpacity(0.5),
            offset: const Offset(-2, -2),
            blurRadius: 6,
          ),
          BoxShadow(
            color: theme.shadowDarkColor.withOpacity(0.3),
            offset: const Offset(2, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 3,
        style: TextStyle(color: theme.textPrimaryColor, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Motivo da transferência',
          hintStyle: TextStyle(color: theme.textSecondaryColor, fontSize: 16),
          prefixIcon: _buildNeomorphFieldIcon(theme, Icons.description_outlined),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  /// ✅ BOTÃO CONTINUAR MELHORADO
  Widget _buildContinueButton(NeomorphTheme theme) {
    final isEnabled = !_isProcessing && _canContinue();
    
    return GestureDetector(
      onTap: isEnabled ? _onContinuePressed : null,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isEnabled ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFF5BC4A8)],
          ) : null,
          color: !isEnabled ? Colors.grey : null,
          boxShadow: isEnabled ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
            BoxShadow(
              color: theme.highlightColor.withOpacity(0.7),
              offset: const Offset(-2, -2),
              blurRadius: 6,
            ),
            BoxShadow(
              color: theme.shadowDarkColor.withOpacity(0.5),
              offset: const Offset(2, 2),
              blurRadius: 6,
            ),
          ] : [],
        ),
        child: Center(
          child: _isProcessing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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

  /// ✅ VALIDAÇÕES MELHORADAS
  String? _validateEmailField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o destinatário';
    }
    
    if (!EmailValidationService.isValidFormat(value)) {
      return 'Formato de email inválido';
    }
    
    if (_emailValidationResult?.isValid == false) {
      return _emailValidationResult?.errorMessage;
    }
    
    if (_emailValidationResult?.userExists == false) {
      return 'Este usuário não está cadastrado no Blinq';
    }
    
    return null;
  }

  String? _validateAmountField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o valor da transferência';
    }
    
    final amount = MoneyInputFormatter.parseAmount(value);
    
    print('🔍 Validando valor: "$value" -> $amount');
    
    if (amount <= 0) {
      return 'Valor deve ser maior que zero';
    }
    
    if (amount < 0.01) {
      return 'Valor mínimo: R\$ 0,01';
    }
    
    if (amount > 50000) {
      return 'Valor máximo por transferência: R\$ 50.000,00';
    }
    
    return null;
  }

  /// ✅ LÓGICA DE CONTINUAÇÃO MELHORADA
  bool _canContinue() {
    return _recipientController.text.isNotEmpty &&
           _amountController.text.isNotEmpty &&
           _emailValidationResult?.userExists == true &&
           _currentAmount > 0;
  }

  Future<void> _onContinuePressed() async {
    if (!_formKey.currentState!.validate()) {
      print('❌ Formulário inválido');
      return;
    }

    if (_emailValidationResult?.userExists != true) {
      _showErrorSnackbar('Destinatário Inválido', 'Aguarde a validação do destinatário');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final amount = MoneyInputFormatter.parseAmount(_amountController.text);
      
      print('💰 Processando transferência:');
      print('   Destinatário: ${_recipientController.text}');
      print('   Valor texto: "${_amountController.text}"');
      print('   Valor parseado: $amount');
      print('   Descrição: "${_descriptionController.text}"');
      
      if (amount <= 0) {
        throw Exception('Valor inválido: deve ser maior que zero');
      }
      
      if (amount > 50000) {
        throw Exception('Valor máximo por transferência: R\$ 50.000,00');
      }
      
      if (amount < 0.01) {
        throw Exception('Valor mínimo para transferência: R\$ 0,01');
      }

      final transferData = {
        'flow': 'transfer',
        'recipient': _recipientController.text.trim(),
        'amount': amount,
        'description': _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim()
            : 'Transferência PIX',
        'recipientName': _emailValidationResult?.userName,
        'recipientId': _emailValidationResult?.userId,
      };

      print('✅ Dados da transferência validados, navegando para PIN...');
      
      Get.toNamed(AppRoutes.verifyPin, arguments: transferData);

    } catch (e) {
      print('❌ Erro na validação: $e');
      _showErrorSnackbar('Erro na Transferência', e.toString());
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// ✅ MÉTODOS AUXILIARES
  Color _getEmailBorderColor(bool isDark) {
    if (_emailValidationResult?.userExists == true) {
      return AppColors.success.withOpacity(0.5);
    } else if (_emailValidationResult?.isValid == false) {
      return AppColors.error.withOpacity(0.5);
    } else {
      return isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08);
    }
  }

  void _clearQrCodeData() {
    setState(() {
      _qrCodeData = null;
    });
    
    Get.snackbar(
      'QR Code Limpo',
      'Dados do QR Code foram removidos',
      backgroundColor: AppColors.primary.withOpacity(0.1),
      colorText: AppColors.primary,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _showQrCodeLoadedFeedback() {
    Get.snackbar(
      'QR Code Carregado! 📱',
      'Dados preenchidos automaticamente. Confirme as informações.',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}