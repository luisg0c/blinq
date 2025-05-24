import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/components/transaction_card.dart';
import '../../../theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return Scaffold(
      backgroundColor: neomorphTheme.backgroundColor,
      appBar: _buildNeomorphAppBar(context),
      body: Obx(() => _buildBody(context, controller)),
      bottomNavigationBar: _buildNeomorphBottomBar(context),
    );
  }

  PreferredSizeWidget _buildNeomorphAppBar(BuildContext context) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return AppBar(
      backgroundColor: neomorphTheme.backgroundColor,
      elevation: 0,
      title: Row(
        children: [
          // Logo neomorfo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: neomorphTheme.surfaceColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: neomorphTheme.highlightColor.withValues(alpha: 0.7),
                  offset: const Offset(-4, -4),
                  blurRadius: 8,
                ),
                BoxShadow(
                  color: neomorphTheme.shadowDarkColor.withOpacity(0.5),
                  offset: const Offset(4, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'B',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Blinq',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: neomorphTheme.textPrimaryColor,
            ),
          ),
        ],
      ),
      actions: [
        // Botão de tema (toggle dark/light)
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {
              // Toggle tema
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
        // Botão de perfil neomorfo
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.profile),
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
                Icons.person_outline,
                color: neomorphTheme.textSecondaryColor,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, HomeController controller) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    if (controller.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 3,
        ),
      );
    }

    if (controller.error.value.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              controller.error.value,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildNeomorphButton(
              context,
              onTap: () => controller.refreshData(),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Tentar novamente',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.refreshData(),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de saldo neomorfo
            _buildNeomorphBalanceCard(context, controller.balance.value),
            
            const SizedBox(height: 32),
            
            // Ações rápidas
            _buildQuickActions(context),
            
            const SizedBox(height: 32),
            
            // Título das transações
            Text(
              'Transações Recentes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: neomorphTheme.textPrimaryColor,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Lista de transações
            _buildTransactionsList(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildNeomorphBalanceCard(BuildContext context, double balance) {
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
            offset: const Offset(-8, -8),
            blurRadius: 16,
          ),
          BoxShadow(
            color: neomorphTheme.shadowDarkColor.withOpacity(0.5),
            offset: const Offset(8, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo Disponível',
                style: TextStyle(
                  fontSize: 16,
                  color: neomorphTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: neomorphTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
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
                child: Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: neomorphTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'R\$ ${balance.toStringAsFixed(2).replaceAll('.', ',')}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: neomorphTheme.textPrimaryColor,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Indicador de crescimento
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 14,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '+2.5%',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'vs. mês anterior',
                style: TextStyle(
                  fontSize: 12,
                  color: neomorphTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    final actions = [
      {
        'icon': Icons.add_circle_outline,
        'label': 'Depositar',
        'route': AppRoutes.deposit,
      },
      {
        'icon': Icons.receipt_long_outlined,
        'label': 'Extrato',
        'route': AppRoutes.transactions,
      },
      {
        'icon': Icons.currency_exchange,
        'label': 'Cotações',
        'route': AppRoutes.exchangeRates,
      },
      {
        'icon': Icons.qr_code_scanner,
        'label': 'QR Code',
        'route': null, // Funcionalidade futura
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: neomorphTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((action) {
            return _buildNeomorphActionButton(
              context,
              icon: action['icon'] as IconData,
              label: action['label'] as String,
              onTap: () {
                final route = action['route'] as String?;
                if (route != null) {
                  Get.toNamed(route);
                } else {
                  Get.snackbar(
                    'Em breve',
                    'Funcionalidade em desenvolvimento',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    colorText: neomorphTheme.textPrimaryColor,
                  );
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNeomorphActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: neomorphTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: neomorphTheme.highlightColor.withOpacity(0.7),
                  offset: const Offset(-4, -4),
                  blurRadius: 8,
                ),
                BoxShadow(
                  color: neomorphTheme.shadowDarkColor.withOpacity(0.5),
                  offset: const Offset(4, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: neomorphTheme.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context, HomeController controller) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    if (controller.recentTransactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: neomorphTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: neomorphTheme.highlightColor.withOpacity(0.5),
              offset: const Offset(-4, -4),
              blurRadius: 8,
            ),
            BoxShadow(
              color: neomorphTheme.shadowDarkColor.withOpacity(0.3),
              offset: const Offset(4, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_outlined,
              size: 48,
              color: neomorphTheme.textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhuma transação ainda',
              style: TextStyle(
                fontSize: 16,
                color: neomorphTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Suas transações aparecerão aqui',
              style: TextStyle(
                fontSize: 14,
                color: neomorphTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: controller.recentTransactions.take(3).map((transaction) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: neomorphTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: neomorphTheme.highlightColor.withOpacity(0.5),
                  offset: const Offset(-3, -3),
                  blurRadius: 6,
                ),
                BoxShadow(
                  color: neomorphTheme.shadowDarkColor.withOpacity(0.3),
                  offset: const Offset(3, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: TransactionCard(transaction: transaction),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNeomorphBottomBar(BuildContext context) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: neomorphTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: neomorphTheme.shadowDarkColor.withOpacity(0.3),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
          BoxShadow(
            color: neomorphTheme.highlightColor.withOpacity(0.7),
            offset: const Offset(0, -1),
            blurRadius: 6,
          ),
        ],
      ),
      child: Center(
        child: GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.transfer),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: neomorphTheme.surfaceColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: neomorphTheme.highlightColor.withOpacity(0.9),
                  offset: const Offset(-6, -6),
                  blurRadius: 12,
                ),
                BoxShadow(
                  color: neomorphTheme.shadowDarkColor.withOpacity(0.5),
                  offset: const Offset(6, 6),
                  blurRadius: 12,
                ),
                // Inner glow para o botão principal
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  offset: const Offset(0, 0),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    Color(0xFF5BC4A8),
                  ],
                ),
              ),
              child: const Center(
                child: Text(
                  'B',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeomorphButton(
    BuildContext context, {
    required Widget child,
    required VoidCallback onTap,
  }) {
    final neomorphTheme = Theme.of(context).extension<NeomorphTheme>()!;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: neomorphTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
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
        child: child,
      ),
    );
  }
}