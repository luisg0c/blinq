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
        },
        child: Padding(
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
            Obx(
              () => Text(
                controller.userName.value,
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
                    .format(controller.accountBalance.value),
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
          _buildQuickActionItem(Icons.payment, 'Pagar', () {}),
          _buildQuickActionItem(Icons.money_off, 'Empréstimos', () {}),
          _buildQuickActionItem(Icons.credit_card, 'Cartão Virtual', () {}),
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
        const Text('Últimas transações', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 10),
        Obx(() => controller.isHistoryVisible.value
            ? controller.transactions.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = controller.transactions[index];
                      return ListTile(
                        leading: const Icon(Icons.arrow_forward, color: AppColors.primaryColor),
                        title: Text(transaction.description ?? ''),
                        subtitle: Text(DateFormat('dd/MM/yyyy').format(transaction.timestamp)),
                        trailing: Text(
                          NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(transaction.amount),
                          style: AppTextStyles.transactionValue.copyWith(
                            color: transaction.amount > 0 ? AppColors.success : AppColors.error,
                          ),
                        ),
                      );
                    },
                  )
                : const Text('Nenhuma transação recente.')
            : const Text('Histórico de transações bloqueado.')),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20), 
        topRight: Radius.circular(20)
      ),
      child: BottomNavigationBar(
        backgroundColor: AppColors.backgroundColor,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.hintColor,
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