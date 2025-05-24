import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/components/custom_money_field.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../theme/app_theme.dart';

class DepositPage extends StatefulWidget {
  const DepositPage({super.key});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
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
                color: neomorphTheme.highlightColor.withValues(alpha: 0.7),
                offset: const Offset(-2, -2),
                blurRadius: 6,
              ),
              BoxShadow(
                color: neomorphTheme.shadowDarkColor.withValues(alpha: 0.5),
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
        'Depositar',
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
                    color: neomorphTheme.highlightColor.withValues(alpha: 0.7),
                    offset: const Offset(-2, -2),
                    blurRadius: 6,
                  ),
                  BoxShadow(
                    color: neomorphTheme.shadowDarkColor.withValues(alpha: 0.5),
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
            
            // Métodos de depósito
            _buildDepositMethods(context),
            
            const SizedBox(height: 32),
            
            // Campo de valor
            _buildSectionTitle(context, 'Valor do Depósito'),
            const SizedBox(height: 12),
            _buildNeomorphMoneyField(context),
            
            const SizedBox(height: 24),
            
            // Campo de descrição
            _buildSectionTitle(context, 'Descrição (opcional)'),
            const SizedBox(height: 12),
            _buildNeomorphTextField(
              context,
              controller: descriptionController,
              hintText: 'Motivo do depósito',
              icon: Icons.description_outlined,
              maxLines: 2,
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
            color: neomorphTheme.highlightColor.withValues(alpha: 0.7),
            offset: const Offset(-6, -6),
            blurRadius: 12,
          ),
          BoxShadow(
            color: neomorphTheme.shadowDarkColor.withValues(alpha: 0.5),
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
                  color: neomorphTheme.highlightColor.withValues(alpha: 0.7),
                  offset: const Offset(-3, -3),
                  blurRadius: 6,
                ),
                BoxShadow(
                  color: neomorphTheme.shadowDarkColor.withValues(alpha: 0.5),
                  offset: const Offset(3, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Icon(
              Icons.add_circle_outline,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Adicionar Dinheiro',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: neomorphTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Deposite na sua conta Blinq\nde forma rápida e segura',
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

  Widget _buildDepositMethods(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Como você quer depositar?'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMethodCard(
                context,
                icon: Icons.pix,
                title: 'PIX',
                subtitle: 'Instantâneo',
                isSelected: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMethodCard(
                context,
                icon: Icons.credit_card,
                title: 'Cartão',
                subtitle: 'Em breve',
                isSelected: false,
                isEnabled: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMethodCard(
                context,
                icon: Icons.account_balance,
                title: 'TED',
                subtitle: 'Em breve',
                isSelected: false,
                isEnabled: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    bool isEnabled = true,
  }) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return GestureDetector(
      onTap: isEnabled ? () {} : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: neomorphTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected 
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              offset: const Offset(0, 0),
              blurRadius: 8,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: neomorphTheme.highlightColor.withValues(alpha: 0.7),
              offset: const Offset(-3, -3),
              blurRadius: 6,
            ),
            BoxShadow(
              color: neomorphTheme.shadowDarkColor.withValues(alpha: 0.5),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ] : [
            BoxShadow(
              color: neomorphTheme.highlightColor.withValues(alpha: 0.5),
              offset: const Offset(-2, -2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: neomorphTheme.shadowDarkColor.withValues(alpha: 0.3),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isEnabled 
                ? (isSelected ? AppColors.primary : neomorphTheme.textSecondaryColor)
                : neomorphTheme.textSecondaryColor.withValues(alpha: 0.5),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isEnabled 
                  ? (isSelected ? AppColors.primary : neomorphTheme.textPrimaryColor)
                  : neomorphTheme.textSecondaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isEnabled 
                  ? neomorphTheme.textSecondaryColor
                  : neomorphTheme.textSecondaryColor.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
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
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return Container(
      decoration: BoxDecoration(
        color: neomorphTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
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
                  color: neomorphTheme.highlightColor.withValues(alpha: 0.7),
                  offset: const Offset(-2, -2),
                  blurRadius: 4,
                ),
                BoxShadow(
                  color: neomorphTheme.shadowDarkColor.withValues(alpha: 0.5),
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
      ),
      child: TextFormField(
        controller: amountController,
        keyboardType: TextInputType.number,
        style: TextStyle(
          color: neomorphTheme.textPrimaryColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: 'R\$ 0,00',
          hintStyle: TextStyle(
            color: neomorphTheme.textSecondaryColor,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: neomorphTheme.surfaceColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: neomorphTheme.highlightColor.withValues(alpha: 0.7),
                  offset: const Offset(-2, -2),
                  blurRadius: 4,
                ),
                BoxShadow(
                  color: neomorphTheme.shadowDarkColor.withValues(alpha: 0.5),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.attach_money,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return GestureDetector(
      onTap: () {
        if (amountController.text.isEmpty) {
          Get.snackbar(
            'Atenção',
            'Informe o valor do depósito',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error.withValues(alpha: 0.1),
            colorText: AppColors.error,
          );
          return;
        }
        
        Get.toNamed(
          AppRoutes.verifyPin,
          arguments: {
            'flow': 'deposit',
            'amountText': amountController.text,
            'description': descriptionController.text,
          },
        );
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
              color: AppColors.primary.withValues(alpha: 0.3),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
            BoxShadow(
              color: neomorphTheme.highlightColor.withValues(alpha: 0.7),
              offset: const Offset(-2, -2),
              blurRadius: 6,
            ),
            BoxShadow(
              color: neomorphTheme.shadowDarkColor.withValues(alpha: 0.5),
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