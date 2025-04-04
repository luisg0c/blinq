import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../widgets/balance_card_widget.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/transaction_history_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inicializa o controlador
    final controller = Get.put(HomeController());
    
    return Scaffold(
      appBar: _buildAppBar(controller),
      backgroundColor: const Color(0xFFF0F2F5),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.resetState();
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Área de Saldo e Botões
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Saldo Atual
                  BalanceCard(
                    userId: controller.userId,
                    animation: controller.scaleAnimation,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Botões de Ação
                  const QuickActionsWidget(),
                  
                  const SizedBox(height: 24),
                  
                  // Título da seção de histórico
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Histórico de Transações',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (controller.isHistoryVisible.value)
                        TextButton(
                          onPressed: () {
                            Get.toNamed('/transactions');
                          },
                          child: const Text('Ver todas'),
                        ),
                    ],
                  )),
                  
                  const SizedBox(height: 8),
                ]),
              ),
            ),
            
            // Histórico de Transações com Obx para reatividade
            Obx(() => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: TransactionHistoryWidget(
                transactionsStream: controller.transactionsStream,
                userId: controller.userId,
                isHistoryVisible: controller.isHistoryVisible.value,
                onRequestUnlock: () => controller.promptForPassword(context),
              ),
            )),
          ],
        ),
      ),
    );
  }
  
  AppBar _buildAppBar(HomeController controller) {
    return AppBar(
      title: const Text('YeezyBank'),
      backgroundColor: const Color(0xFF388E3C),
      actions: [
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () => Get.toNamed('/profile'),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => controller.logout(),
        ),
      ],
    );
  }
}