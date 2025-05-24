import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/entities/transaction.dart';
import '../../controllers/home_controller.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extrato de Transações'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = controller.recentTransactions;

        if (transactions.isEmpty) {
          return const Center(child: Text('Nenhuma transação encontrada.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24.0),
          itemCount: transactions.length,
          separatorBuilder: (_, __) => const Divider(height: 24),
          itemBuilder: (context, index) {
            final tx = transactions[index];
            final isIn = tx.amount >= 0;

            return ListTile(
              title: Text(tx.description),
              subtitle: Text(tx.date.toString()),
              trailing: Text(
                '${isIn ? '+' : '-'} R\$ ${tx.amount.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  color: isIn ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
