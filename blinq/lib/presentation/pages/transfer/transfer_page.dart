import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/components/custom_money_field.dart';
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

  @override
  void dispose() {
    recipientCtrl.dispose();
    amountCtrl.dispose();
    descriptionCtrl.dispose();
    super.dispose();
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
      actions: [
        // Toggle tema
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              Get.changeThemeMode(
                Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
              );
            },
            child: Container(
              width: 40,
              height: 40,
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
                Get.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: neomorphTheme.textSecondaryColor,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
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
            
            // Campo de destinatário
            _buildSectionTitle(context, 'Destinatário'),
            const SizedBox(height: 12),
            _buildNeomorphTextField(
              context,
              controller: recipientCtrl,
              hintText: 'Email ou telefone',
              icon: Icons.person_outline,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o destinatário';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            // Campo de valor
            _buildSectionTitle(context, 'Valor'),
            const SizedBox(height: 12),
            _buildNeomorphMoneyField(context),
            
            const SizedBox(height: 24),
            
            // Campo de descrição
            _buildSectionTitle(context, 'Descrição (opcional)'),
            const SizedBox(height: 12),
            _buildNeomorphTextField(
              context,
              controller: descriptionCtrl,
              hintText: 'Motivo da transferência',
              icon: Icons.description_outlined,
              maxLines: 3,
            ),
            
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

  Widget _buildNeomorphTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: neomorphTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.1) 
              : Colors.black.withOpacity(0.08),
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
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: TextStyle(
          color: neomorphTheme.textPrimaryColor,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hintText,
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
            child: Icon(
              icon,
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

  Widget _buildNeomorphMoneyField(BuildContext context) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return Container(
      decoration: BoxDecoration(
        color: neomorphTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        // Removed inner shadow effects due to Flutter limitations
      ),
      child: CustomMoneyField(
        controller: amountCtrl,
        onChanged: (val) {
          // opcional: converter de "R$ 1.234,56" para double
        },
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
  final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
  
  return GestureDetector(
    onTap: () {
      if (_formKey.currentState!.validate()) {
        if (amountCtrl.text.isEmpty) {
          Get.snackbar('Atenção', 'Informe o valor da transferência');
          return;
        }
        
        // ✅ CORRIGIDO: Converter valor corretamente
        final amountText = amountCtrl.text.replaceAll(RegExp(r'[^\d,]'), '');
        final amount = double.tryParse(amountText.replaceAll(',', '.')) ?? 0.0;
        
        if (amount <= 0) {
          Get.snackbar('Erro', 'Valor inválido');
          return;
        }
        
        Get.toNamed(
          AppRoutes.verifyPin,
          arguments: {
            'flow': 'transfer',
            'recipient': recipientCtrl.text,
            'amount': amount, // ✅ Enviar valor numérico
            'description': descriptionCtrl.text,
          },
        );
      }
    },
    
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              Color(0xFF5BC4A8),
            ],
          ),
          boxShadow: [
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
        child: const Center(
          child: Text(
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
}