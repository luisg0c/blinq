import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controllers/home_controller.dart';
import 'package:intl/intl.dart';
import '../theme/app_text_styles.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: AppColors.textColor),
        title: const Text('YeezyBank', style: AppTextStyles.appBarTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.resetState();
          await Future.delayed(const Duration(milliseconds: 300));
          return;
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(controller),
              const SizedBox(height: 20),
              _buildBalanceCard(controller),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 20),
              _buildTransactionHistory(controller),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader(HomeController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Olá,', style: AppTextStyles.subtitle),
            // Se userName não existir, usar email ou um placeholder
            Obx(
              () => Text(
                controller.currentUserEmail ?? 'Usuário',
                style: AppTextStyles.title,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () => Get.toNamed('/profile'),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(HomeController controller) {
    return Card(
      color: AppColors.primaryColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saldo disponível', style: AppTextStyles.card),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                    .format(controller.balance.value),
                style: AppTextStyles.cardTitle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildQuickActionItem(Icons.pix, 'Pix', () {}),
          _buildQuickActionItem(Icons.money, 'Transferir', () => Get.toNamed('/transfer')),
          _buildQuickActionItem(Icons.add_circle_outline, 'Depositar', () => Get.toNamed('/deposit')),
          _buildQuickActionItem(Icons.payment, 'Pagar', () {}),
          _buildQuickActionItem(Icons.history, 'Histórico', () => Get.toNamed('/transactions')),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 32),
            const SizedBox(height: 8),
            Text(
              label, 
              style: AppTextStyles.quickAction, 
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Últimas transações', style: AppTextStyles.sectionTitle),
            TextButton(
              onPressed: () => Get.toNamed('/transactions'),
              child: Text(
                'Ver todas',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() => 
          controller.isHistoryVisible.value
            ? controller.transactions.isNotEmpty
                ? SizedBox(
                    height: 300,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.transactions.length > 5 
                          ? 5 
                          : controller.transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = controller.transactions[index];
                        return ListTile(
                          leading: Icon(
                            _getTransactionIcon(transaction, controller.userId),
                            color: _getTransactionColor(transaction, controller.userId),
                          ),
                          title: Text(_getTransactionTitle(transaction, controller.userId)),
                          subtitle: Text(DateFormat('dd/MM/yyyy').format(transaction.timestamp)),
                          trailing: Text(
                            NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(transaction.amount),
                            style: AppTextStyles.transactionValue.copyWith(
                              color: _getTransactionColor(transaction, controller.userId),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('Nenhuma transação recente.')),
                  )
            : GestureDetector(
                onTap: () => controller.promptForPassword(context),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, size: 32, color: AppColors.primaryColor),
                        SizedBox(height: 8),
                        Text('Toque para visualizar o histórico'),
                      ],
                    ),
                  ),
                ),
              )
        ),
      ],
    );
  }

  IconData _getTransactionIcon(TransactionModel transaction, String userId) {
    if (transaction.type == 'deposit') {
      return Icons.add_circle_outline;
    } else if (transaction.type == 'transfer') {
      if (transaction.senderId == userId) {
        return Icons.arrow_upward;
      } else {
        return Icons.arrow_downward;
      }
    }
    return Icons.swap_horiz;
  }

  Color _getTransactionColor(TransactionModel transaction, String userId) {
    if (transaction.type == 'deposit') {
      return AppColors.primaryColor;
    } else if (transaction.type == 'transfer') {
      if (transaction.senderId == userId) {
        return AppColors.error;
      } else {
        return AppColors.success;
      }
    }
    return AppColors.subtitle;
  }

  String _getTransactionTitle(TransactionModel transaction, String userId) {
    if (transaction.type == 'deposit') {
      return 'Depósito';
    } else if (transaction.type == 'transfer') {
      if (transaction.senderId == userId) {
        return 'Transferência enviada';
      } else {
        return 'Transferência recebida';
      }
    }
    return 'Transação';
  }

  Widget _buildBottomNavigationBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20), 
        topRight: Radius.circular(20)
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: AppColors.backgroundColor,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.hintColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'Cartões'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: 'Contas'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}

// Modelo de transação para o exemplo
class TransactionModel {
  final String id;
  final String senderId;
  final String receiverId;
  final double amount;
  final DateTime timestamp;
  final List<String> participants;
  final String type;
  final String? description;

  TransactionModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.timestamp,
    required this.participants,
    required this.type,
    this.description,
  });
}