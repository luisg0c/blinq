// lib/presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      appBar: _buildAppBar(context, isDark),
      body: Obx(() => _buildBody(context, controller, isDark)),
      bottomNavigationBar: _buildBottomBar(context, isDark),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    final surfaceColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E5E5);
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white60 : Colors.black45;
    final user = FirebaseAuth.instance.currentUser;
    
    return AppBar(
      backgroundColor: surfaceColor,
      elevation: 0,
      toolbarHeight: 70,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            // Avatar do usuário
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
                    colors: [AppColors.primary, Color(0xFF5BC4A8)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Saudação
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
                    user?.displayName?.split(' ').first ?? 'Usuário',
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
            onTap: () => _showNotifications(context),
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
                  // Badge (opcional)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
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
      return _buildErrorState(context, controller, isDark);
    }

    return RefreshIndicator(
      onRefresh: () => controller.refreshData(),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de saldo
            _buildBalanceCard(context, controller.balance.value, isDark),
            
            const SizedBox(height: 24),
            
            // Ações rápidas
            _buildQuickActions(context, isDark),
            
            const SizedBox(height: 24),
            
            // Transações recentes
            _buildRecentTransactions(context, controller, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, HomeController controller, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              'Ops! Algo deu errado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.error.value,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.refreshData(),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Tentar novamente',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance, bool isDark) {
    final surfaceColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E5E5);
    final highlightColor = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFFFFFFF);
    final shadowColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFBEBEBE);
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: highlightColor.withOpacity(0.7),
            offset: const Offset(-6, -6),
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
                  fontSize: 15,
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: highlightColor.withOpacity(0.7),
                      offset: const Offset(-2, -2),
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
                  size: 16,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          Text(
            'R\$ ${balance.toStringAsFixed(2).replaceAll('.', ',')}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Indicador de crescimento
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 12,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 3),
                    Text(
                      '+2.5%',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'vs. mês anterior',
                style: TextStyle(
                  fontSize: 11,
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
        'onTap': () => Get.toNamed(AppRoutes.deposit),
      },
      {
        'icon': Icons.receipt_long_outlined,
        'label': 'Extrato',
        'onTap': () => Get.toNamed(AppRoutes.transactions),
      },
      {
        'icon': Icons.currency_exchange,
        'label': 'Cotações',
        'onTap': () => Get.toNamed(AppRoutes.exchangeRates),
      },
      {
        'icon': Icons.qr_code_scanner,
        'label': 'QR Code',
        'onTap': () => _showComingSoon(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((action) {
            return _buildActionButton(
              context,
              isDark,
              icon: action['icon'] as IconData,
              label: action['label'] as String,
              onTap: action['onTap'] as VoidCallback,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButton(
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14),
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
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, HomeController controller, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transações Recentes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            if (controller.recentTransactions.isNotEmpty)
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.transactions),
                child: const Text(
                  'Ver todas',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        if (controller.recentTransactions.isEmpty)
          _buildEmptyTransactions(context, isDark)
        else
          ...controller.recentTransactions.take(3).map((transaction) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TransactionCard(
                transaction: transaction,
                onTap: () => _showTransactionDetails(context, transaction, isDark),
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildEmptyTransactions(BuildContext context, bool isDark) {
    final surfaceColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E5E5);
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
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

  Widget _buildBottomBar(BuildContext context, bool isDark) {
    final backgroundColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E5E5);
    final surfaceColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E5E5);
    final highlightColor = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFFFFFFF);
    final shadowColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFBEBEBE);

    return SafeArea(
      child: Container(
        height: 90,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom > 0 ? 16 : 24,
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
                ],
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, Color(0xFF5BC4A8)],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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

  void _showNotifications(BuildContext context) {
    Get.snackbar(
      '🔔 Notificações',
      'Você não tem notificações pendentes',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      duration: const Duration(seconds: 2),
    );
  }

  void _showComingSoon() {
    Get.snackbar(
      '🚧 Em breve',
      'Funcionalidade em desenvolvimento',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.warning.withOpacity(0.1),
      duration: const Duration(seconds: 2),
    );
  }

  // Substitua este método na sua HomePage

void _showTransactionDetails(BuildContext context, dynamic transaction, bool isDark) {
  Get.dialog(
    AlertDialog(
      backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        _getTransactionTitle(transaction),
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('ID:', _getShortId(transaction.id), isDark),
          _buildDetailRow('Tipo:', _getTransactionTypeText(transaction.type), isDark),
          _buildDetailRow('Valor:', _formatCurrency(transaction.amount.abs()), isDark),
          _buildDetailRow('Data:', _formatFullDate(transaction.date), isDark),
          _buildDetailRow('Descrição:', transaction.description, isDark),
          if (transaction.counterparty.isNotEmpty)
            _buildDetailRow('Contraparte:', transaction.counterparty, isDark),
          _buildDetailRow('Status:', _getStatusText(transaction.status), isDark),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Fechar', style: TextStyle(color: AppColors.primary)),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            _showComingSoon();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Gerar Comprovante',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

// ✅ MÉTODOS HELPER CORRIGIDOS

String _getTransactionTitle(dynamic transaction) {
  switch (transaction.type.toLowerCase()) {
    case 'deposit':
      return 'Detalhes do Depósito';
    case 'transfer':
      return transaction.amount > 0 ? 'Transferência Recebida' : 'Transferência Enviada';
    case 'receive':
      return 'Transferência Recebida';
    default:
      return 'Detalhes da Transação';
  }
}

String _getShortId(String id) {
  return id.length > 8 ? '${id.substring(0, 8)}...' : id;
}

String _getTransactionTypeText(String type) {
  switch (type.toLowerCase()) {
    case 'deposit':
      return 'Depósito';
    case 'transfer':
      return 'Transferência';
    case 'receive':
      return 'Recebimento';
    default:
      return type;
  }
}

String _formatCurrency(double amount) {
  return 'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}';
}

String _formatFullDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year;
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  
  return '$day/$month/$year - $hour:$minute';
}

String _getStatusText(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return 'Concluído';
    case 'pending':
      return 'Pendente';
    case 'failed':
      return 'Falhou';
    case 'cancelled':
      return 'Cancelado';
    default:
      return status;
  }
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
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 14,
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
}