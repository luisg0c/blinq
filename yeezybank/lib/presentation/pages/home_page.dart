import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/balance_card_widget.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/transaction_history_widget.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Obx(
          () => Text(
            'Olá, ${controller.currentUserEmail.value.split('@').first}',
            style: AppTextStyles.appBarTitle,
          ),
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.textColor),
            onPressed: () => Get.toNamed('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.resetState();
          // Simular delay para melhor UX
          await Future.delayed(Duration(milliseconds: 500));
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedBuilder(
                      animation: controller.animationController,
                      builder: (context, child) {
                        return BalanceCard(
                          userId: controller.userId,
                          animation: controller.scaleAnimation,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const QuickActionsWidget(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Histórico',
                          style: AppTextStyles.sectionTitle,
                        ),
                        Obx(
                          () => TextButton.icon(
                            onPressed: () {
                              if (controller.isHistoryVisible.value) {
                                Get.toNamed('/transactions');
                              } else {
                                controller.promptForPassword(context);
                              }
                            },
                            icon: Icon(
                              controller.isHistoryVisible.value
                                  ? Icons.visibility
                                  : Icons.lock,
                              color: AppColors.primaryColor,
                              size: 18,
                            ),
                            label: Text(
                              controller.isHistoryVisible.value
                                  ? 'Ver todos'
                                  : 'Desbloquear',
                              style: TextStyle(color: AppColors.primaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Obx(
              () => TransactionHistoryWidget(
                transactionsStream: controller.transactionsStream,
                userId: controller.userId,
                isHistoryVisible: controller.isHistoryVisible.value,
                onRequestUnlock: () => controller.promptForPassword(context),
              ),
            ),
            // Espaço no final da lista
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}
