import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
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

  // Estado da validação de email
  bool _isValidatingEmail = false;
  EmailValidationResult? _emailValidationResult;
  bool _isProcessing = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    recipientCtrl.addListener(_onEmailChanged);
    _checkQrCodeData();
  }

  @override
  void dispose() {
    recipientCtrl.removeListener(_onEmailChanged);
    recipientCtrl.dispose();
    amountCtrl.dispose();
    descriptionCtrl.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// ✅ LISTENER PARA VALIDAÇÃO EM TEMPO REAL
  void _onEmailChanged() {
    final email = recipientCtrl.text.trim();
    _debounceTimer?.cancel();
    
    if (_emailValidationResult != null && 
        !email.toLowerCase().contains(_emailValidationResult!.userName?.toLowerCase().substring(0, 3) ?? '')) {
      setState(() => _emailValidationResult = null);
    }
    
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (email.isNotEmpty && email.length >= 3) {
        _validateEmail(email);
      } else {
        setState(() => _emailValidationResult = null);
      }
    });
  }

  /// ✅ VERIFICAR DADOS DO QR CODE
  void _checkQrCodeData() {
    final args = Get.arguments as Map<String, dynamic>?;
    
    if (args != null && args['fromQrCode'] == true) {
      print('📱 Preenchendo dados do QR Code');
      
      if (args['recipient'] != null) {
        recipientCtrl.text = args['recipient'].toString();
        _validateEmail(args['recipient'].toString());
      }
      
      if (args['amount'] != null) {
        final amount = args['amount'] as double;
        final formattedAmount = 'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}';
        amountCtrl.text = formattedAmount;
      }
      
      if (args['description'] != null && args['description'].toString().isNotEmpty) {
        descriptionCtrl.text = args['description'].toString();
      }
      
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
      appBar: _buildAppBar(context, neomorphTheme),
      body: _buildBody(context, neomorphTheme),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, NeomorphTheme theme) {
    return AppBar(
      backgroundColor: theme.backgroundColor,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: const EdgeInsets.all(8),
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
          child: Icon(Icons.arrow_back, color: theme.textPrimaryColor, size: 20),
        ),
      ),
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
        Padding(
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
              child: const Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, NeomorphTheme theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Destinatário', theme),
            const SizedBox(height: 12),
            _buildEmailField(theme),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Valor', theme),
            const SizedBox(height: 12),
            _buildMoneyField(theme),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Descrição (opcional)', theme),
            const SizedBox(height: 12),
            _buildDescriptionField(theme),
            const SizedBox(height: 40),
            
            _buildContinueButton(theme),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

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
          Container(
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
            child: const Icon(Icons.send_rounded, color: AppColors.primary, size: 28),
          ),
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

  Widget _buildEmailField(NeomorphTheme theme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _getBorderColor(isDark), width: 1),
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
            controller: recipientCtrl,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: theme.textPrimaryColor, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Digite o email do destinatário',
              hintStyle: TextStyle(color: theme.textSecondaryColor, fontSize: 16),
              prefixIcon: Container(
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
                child: const Icon(Icons.person_search, color: AppColors.primary, size: 20),
              ),
              suffixIcon: _buildEmailSuffixIcon(),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe o destinatário';
              }
              if (_emailValidationResult?.isValid == false) {
                return _emailValidationResult?.errorMessage;
              }
              if (_emailValidationResult?.userExists == false) {
                return 'Este usuário não está cadastrado no Blinq';
              }
              return null;
            },
          ),
        ),

        // Feedback visual da validação
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
                    'Destinatário: ${_emailValidationResult!.userName ?? 'Usuário Blinq'}',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Feedback de erro
        if (_emailValidationResult != null && !_emailValidationResult!.userExists && _emailValidationResult!.errorMessage != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _emailValidationResult!.errorMessage!,
                    style: const TextStyle(
                      color: AppColors.warning,
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
      return isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08);
    }
  }

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
      child: CustomMoneyField(controller: amountCtrl),
    );
  }

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
        controller: descriptionCtrl,
        maxLines: 3,
        style: TextStyle(color: theme.textPrimaryColor, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Motivo da transferência',
          hintStyle: TextStyle(color: theme.textSecondaryColor, fontSize: 16),
          prefixIcon: Container(
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
            child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildContinueButton(NeomorphTheme theme) {
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
            colors: [AppColors.primary, Color(0xFF5BC4A8)],
          ),
          color: _isProcessing ? Colors.grey : null,
          boxShadow: _isProcessing ? [] : [
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
          ],
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

  /// ✅ PROCESSAR TRANSFERÊNCIA
  Future<void> _onContinuePressed() async {
    if (!_formKey.currentState!.validate()) return;

    if (_emailValidationResult?.userExists != true) {
      Get.snackbar(
        'Destinatário Inválido',
        'Aguarde a validação do destinatário ou informe um usuário válido',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (amountCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Valor Obrigatório',
        'Informe o valor da transferência',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final amount = _extractAmountFromText(amountCtrl.text);
      
      if (amount <= 0) {
        throw Exception('Valor inválido para transferência');
      }
      if (amount > 50000) {
        throw Exception('Valor máximo por transferência: R\$ 50.000,00');
      }
      if (amount < 0.01) {
        throw Exception('Valor mínimo para transferência: R\$ 0,01');
      }

      final transferData = {
        'flow': 'transfer',
        'recipient': recipientCtrl.text.trim(),
        'amount': amount,
        'description': descriptionCtrl.text.trim().isNotEmpty 
            ? descriptionCtrl.text.trim()
            : 'Transferência PIX',
        'recipientName': _emailValidationResult?.userName,
        'recipientId': _emailValidationResult?.userId,
      };

      Get.toNamed(AppRoutes.verifyPin, arguments: transferData);

    } catch (e) {
      Get.snackbar(
        'Erro na Transferência',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// ✅ EXTRAIR VALOR NUMÉRICO DO TEXTO FORMATADO
  double _extractAmountFromText(String formattedText) {
    if (formattedText.trim().isEmpty) return 0.0;
    
    final cleanText = formattedText
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    
    return double.tryParse(cleanText) ?? 0.0;
  }
}