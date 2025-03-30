import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/services/auth_service.dart';
import '../controllers/transaction_controller.dart';
import '../../domain/models/transaction_model.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionController = Get.find<TransactionController>();
    final userId = transactionController.currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Transações'),
        backgroundColor: const Color(0xFF388E3C),
      ),
      backgroundColor: const Color(0xFFF0F2F5),
      body: Obx(() {
        final transactions = transactionController.transactions;

        if (transactions.isEmpty) {
          return const Center(child: Text('Nenhuma transação encontrada.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: transactions.length,
          separatorBuilder: (_, __) => const Divider(height: 16),
          itemBuilder: (context, index) {
            final txn = transactions[index];

            String title;
            IconData icon;
            Color color;

            if (txn.type == 'deposit') {
              title = 'Depósito';
              icon = Icons.add_circle_outline;
              color = Colors.blue;
            } else if (txn.type == 'transfer') {
              if (txn.senderId == userId) {
                title = 'Pix Enviado';
                icon = Icons.arrow_upward;
                color = Colors.red;
              } else {
                title = 'Pix Recebido';
                icon = Icons.arrow_downward;
                color = Colors.green;
              }
            } else {
              title = 'Transação';
              icon = Icons.swap_horiz;
              color = Colors.grey;
            }

            return ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              title: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
              subtitle: Text(
                DateFormat('dd/MM/yyyy HH:mm').format(txn.timestamp),
              ),
              trailing: Text(
                'R\$ ${txn.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
