import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../../core/components/balance_card.dart';
import '../../../core/components/transaction_card.dart';
import '../../../core/components/custom_button.dart';

/// Tela principal após o login, mostra saldo e ações rápidas.
class HomePage extends StatelessWidget {
  final HomeController _homeCtrl = Get.find<HomeController>();

  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blinq'),
        backgroundColor: const Color(0xFF6EE1C6),
      ),
      body: Obx(() {
        if (_homeCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Saldo
              BalanceCard(balance: _homeCtrl.balance.value),

              const SizedBox(height: 24),

              // Ações rápidas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    label: 'Depositar',
                    onPressed: () => _homeCtrl.goToDeposit(),
                    fullWidth: false,
                  ),
                  CustomButton(
                    label: 'Transferir',
                    onPressed: () => _homeCtrl.goToTransfer(),
                    fullWidth: false,
                  ),
                  CustomButton(
                    label: 'Extrato',
                    onPressed: () => _homeCtrl.goToHistory(),
                    fullWidth: false,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Transações recentes
              const Text(
                'Transações Recentes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _homeCtrl.recentTransactions.length,
                  itemBuilder: (_, i) => TransactionCard(
                    transaction: _homeCtrl.recentTransactions[i],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
