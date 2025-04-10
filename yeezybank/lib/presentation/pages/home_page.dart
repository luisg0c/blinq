import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeezybank/presentation/theme/app_colors.dart';
import '../controllers/home_controller.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
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
            Text(
              'Olá,',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            Text(
              controller.userName.value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
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
            const Text(
              'Saldo disponível',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
                  NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                      .format(controller.accountBalance.value),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                )),
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
              style: TextStyle(color: Colors.grey[700]),
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
        const Text(
          'Últimas transações',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
                        title: Text(transaction.description),
                        subtitle: Text(DateFormat('dd/MM/yyyy').format(transaction.date)),
                        trailing: Text(
                          NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(transaction.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: transaction.amount > 0 ? Colors.green : Colors.red,
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
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'Cartões'),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: 'Contas'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
      ],
    );
  }
}