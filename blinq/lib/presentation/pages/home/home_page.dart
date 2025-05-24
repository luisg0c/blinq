import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/components/transaction_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E5E5),
      appBar: _buildNeomorphAppBar(context, isDark),
      body: Obx(() => _buildBody(context, controller, isDark)),
      bottomNavigationBar: _buildNeomorphBottomBar(context, isDark),
    );
  }

  PreferredSizeWidget _buildNeomorphAppBar(BuildContext context, bool isDark) {
    final surfaceColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E5E5);
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white60 : Colors.black45;
    
    return AppBar(
      backgroundColor: surfaceColor,
      elevation: 0,
      toolbarHeight: 70, // Altura customizada
      automaticallyImplyLeading: false, // Remove botão de voltar
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            // Avatar/Foto do usuário
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.profile),
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
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
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'U', // Inicial do usuário
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Saudação e nome
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getGreeting(),
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Usuário Blinq', // Nome do usuário
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Notificações
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {
              Get.snackbar(
                'Notificações',
                'Você não tem notificações pendentes',
                snackPosition: SnackPosition.TOP,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                colorText: textColor,
                duration: const Duration(seconds: 2),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.notifications_outlined,
                      color: secondaryTextColor,
                      size: 20,
                    ),
                  ),
                  // Badge de notificação (opcional)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
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
                color: surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Icon(
                Get.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: secondaryTextColor,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bom dia! 👋';
    } else if (hour < 18) {
      return 'Boa tarde! 👋';
    } else {
      return 'Boa noite! 👋';
    }
  }

  Widget _buildBody(BuildContext context, HomeController controller, bool isDark) {
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
              isDark,
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), // Reduzido padding superior
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de saldo neomorfo
            _buildNeomorphBalanceCard(context, controller.balance.value, isDark),
            
            const SizedBox(height: 24), // Reduzido de 32 para 24
            
            // Ações rápidas
            _buildQuickActions(context, isDark),
            
            const SizedBox(height: 24), // Reduzido de 32 para 24
            
            // Título das transações
            Text(
              'Transações Recentes',
              style: TextStyle(
                fontSize: 18, // Reduzido de 20 para 18
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16), // Voltou para 16px (era 12)
            
            // Lista de transações
            _buildTransactionsList(context, controller, isDark),
            
            // Espaço extra no final para compensar bottom bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildNeomorphBalanceCard(BuildContext context, double balance, bool isDark) {
    final surfaceColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E5E5);
    final highlightColor = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFFFFFFF);
    final shadowColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFBEBEBE);
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20), // Reduzido de 24 para 20
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18), // Ligeiramente menor
        boxShadow: [
          BoxShadow(
            color: highlightColor.withOpacity(0.7),
            offset: const Offset(-6, -6), // Sombras menores para dispositivos pequenos
            blurRadius: 12,
          ),
          BoxShadow(
            color: shadowColor.withOpacity(0.5),
            offset: const Offset(6, 6),
            blurRadius: 12,
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
                  fontSize: 15, // Reduzido de 16 para 15
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6), // Reduzido de 8 para 6
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(10), // Reduzido de 12 para 10
                  boxShadow: [
                    BoxShadow(
                      color: highlightColor.withOpacity(0.7),
                      offset: const Offset(-2, -2), // Sombras menores
                      blurRadius: 4,
                    ),
                    BoxShadow(
                      color: shadowColor.withOpacity(0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.visibility_outlined,
                  size: 16, // Reduzido de 18 para 16
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10), // Reduzido de 12 para 10
          
          Text(
            'R\$ ${balance.toStringAsFixed(2).replaceAll('.', ',')}',
            style: TextStyle(
              fontSize: 28, // Reduzido de 32 para 28
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          
          const SizedBox(height: 16), // Reduzido de 20 para 16
          
          // Indicador de crescimento
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Menor
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6), // Menor
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 12, // Reduzido de 14 para 12
                      color: AppColors.success,
                    ),
                    SizedBox(width: 3), // Reduzido
                    Text(
                      '+2.5%',
                      style: TextStyle(
                        fontSize: 11, // Reduzido de 12 para 11
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6), // Reduzido de 8 para 6
              Text(
                'vs. mês anterior',
                style: TextStyle(
                  fontSize: 11, // Reduzido de 12 para 11
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    
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
            fontSize: 16, // Reduzido de 18 para 16
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12), // Reduzido de 16 para 12
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((action) {
            return _buildNeomorphActionButton(
              context,
              isDark,
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
                    colorText: textColor,
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
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final surfaceColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E5E5);
    final highlightColor = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFFFFFFF);
    final shadowColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFBEBEBE);
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52, // Reduzido de 60 para 52
            height: 52, // Reduzido de 60 para 52
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14), // Reduzido de 16 para 14
              boxShadow: [
                BoxShadow(
                  color: highlightColor.withOpacity(0.7),
                  offset: const Offset(-3, -3), // Sombras menores
                  blurRadius: 6,
                ),
                BoxShadow(
                  color: shadowColor.withOpacity(0.5),
                  offset: const Offset(3, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 22, // Reduzido de 24 para 22
            ),
          ),
          const SizedBox(height: 8), // Voltou para 8px (era 6)
          Text(
            label,
            style: TextStyle(
              fontSize: 11, // Reduzido de 12 para 11
              color: secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context, HomeController controller, bool isDark) {
  final surfaceColor =
      isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E5E5);
  final highlightColor =
      isDark ? const Color(0xFF3A3A3A) : const Color(0xFFFFFFFF);
  final shadowColor =
      isDark ? const Color(0xFF1A1A1A) : const Color(0xFFBEBEBE);
  final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

  if (controller.recentTransactions.isEmpty) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: highlightColor.withOpacity(0.5),
            offset: const Offset(-4, -4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: shadowColor.withOpacity(0.3),
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
            color: secondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhuma transação ainda',
            style: TextStyle(
              fontSize: 16,
              color: secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Suas transações aparecerão aqui',
            style: TextStyle(
              fontSize: 14,
              color: secondaryTextColor,
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
        child: TransactionCard(
          transaction: transaction,
          onTap: () {
            // Navegar para detalhes da transação
            Get.dialog(
              AlertDialog(
                backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Detalhes da Transação',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Tipo:', transaction.type, isDark),
                    _buildDetailRow('Valor:', 'R\$ ${transaction.amount.abs().toStringAsFixed(2)}', isDark),
                    _buildDetailRow('Data:', _formatDate(transaction.date), isDark),
                    _buildDetailRow('Descrição:', transaction.description, isDark),
                    if (transaction.counterparty.isNotEmpty)
                      _buildDetailRow('Contraparte:', transaction.counterparty, isDark),
                    _buildDetailRow('Status:', transaction.status, isDark),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      'Fechar',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }).toList(),
  );
}

Widget _buildDetailRow(String label, String value, bool isDark) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

Widget _buildNeomorphBottomBar(BuildContext context, bool isDark) {
  final backgroundColor =
      isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E5E5);
  final surfaceColor =
      isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E5E5);
  final highlightColor =
      isDark ? const Color(0xFF3A3A3A) : const Color(0xFFFFFFFF);
  final shadowColor =
      isDark ? const Color(0xFF1A1A1A) : const Color(0xFFBEBEBE);

  return SafeArea(
    child: Container(
      height: 90,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? 16  
            : 24, 
        top: 8,     
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.3),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
          BoxShadow(
            color: highlightColor.withOpacity(0.7),
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
              color: surfaceColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: highlightColor.withOpacity(0.9),
                  offset: const Offset(-6, -6),
                  blurRadius: 12,
                ),
                BoxShadow(
                  color: shadowColor.withOpacity(0.5),
                  offset: const Offset(6, 6),
                  blurRadius: 12,
                ),
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
    ),
  );
}

  Widget _buildNeomorphButton(
    BuildContext context,
    bool isDark, {
    required Widget child,
    required VoidCallback onTap,
  }) {
    final surfaceColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E5E5);
    final highlightColor = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFFFFFFF);
    final shadowColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFBEBEBE);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: highlightColor.withOpacity(0.7),
              offset: const Offset(-3, -3),
              blurRadius: 6,
            ),
            BoxShadow(
              color: shadowColor.withOpacity(0.5),
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