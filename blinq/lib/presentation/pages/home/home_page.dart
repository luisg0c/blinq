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
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Obx(() => _buildBody(context, controller)),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Blinq'),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => Get.offAllNamed(AppRoutes.welcome),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, HomeController controller) {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.error.value.isNotEmpty) {
      return Center(
        child: Text(
          controller.error.value,
          style: const TextStyle(color: AppColors.error),
        ),
      );
    }

    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBalanceCard(context, controller.balance.value),
        const SizedBox(height: 32),
        _buildQuickActions(),
        const SizedBox(height: 32),
        Text('Transações Recentes', style: textTheme.headlineMedium),
        const SizedBox(height: 16),
        _buildTransactionList(controller),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saldo atual', style: textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text(
            'R\$ ${balance.toStringAsFixed(2)}',
            style: textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        // Primeira linha de ações
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ActionButton(
              icon: Icons.arrow_downward,
              label: 'Depositar',
              onTap: () => Get.toNamed(AppRoutes.deposit),
            ),
            _ActionButton(
              icon: Icons.compare_arrows,
              label: 'Transferir',
              onTap: () => Get.toNamed(AppRoutes.transfer),
            ),
            _ActionButton(
              icon: Icons.list,
              label: 'Extrato',
              onTap: () => Get.toNamed(AppRoutes.transactions),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Segunda linha com cotações
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ActionButton(
              icon: Icons.currency_exchange,
              label: 'Cotações',
              onTap: () => Get.toNamed(AppRoutes.exchangeRates),
            ),
            _ActionButton(
              icon: Icons.qr_code_scanner,
              label: 'QR Code',
              onTap: () => Get.snackbar('Em breve', 'Funcionalidade em desenvolvimento'),
            ),
            _ActionButton(
              icon: Icons.receipt,
              label: 'Recibos',
              onTap: () => Get.snackbar('Em breve', 'Funcionalidade em desenvolvimento'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionList(HomeController controller) {
    return Expanded(
      child: ListView.separated(
        itemCount: controller.recentTransactions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => TransactionCard(
          transaction: controller.recentTransactions[i],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Ink(
          decoration: const ShapeDecoration(
            color: AppColors.primary,
            shape: CircleBorder(),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}