import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_theme.dart';
import 'package:blinq/presentation/pages/pin/pin_verification_page.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Mock para valor do saldo
    final RxBool isBalanceVisible = true.obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blinq'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // futura lógica de logout
              Get.offAllNamed(AppRoutes.welcome);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Obx(() => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Saldo atual', style: textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBalanceVisible.value ? 'R\$ 5.780,00' : '••••••',
                            style: textTheme.headlineMedium,
                          ),
                          IconButton(
                            onPressed: () => isBalanceVisible.toggle(),
                            icon: Icon(
                              isBalanceVisible.value ? Icons.visibility : Icons.visibility_off,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 32),

            // Ações rápidas
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
          ],
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
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
