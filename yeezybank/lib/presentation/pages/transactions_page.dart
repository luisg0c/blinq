import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/services/auth_service.dart';
import '../theme/app_text_styles.dart';
import '../controllers/transaction_controller.dart';
import '../../domain/models/transaction_model.dart';
import '../theme/app_colors.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionController>();
    final userId = controller.currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transações', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textColor),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          final transactions = controller.transactions;

          if (transactions.isEmpty) {
            return Center(
              child: Text(
                'Nenhuma transação encontrada.',
                style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
              ),
            );
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final txn = transactions[index];

              return _buildTransactionCard(txn, userId);
            },
          );
        }),
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel txn, String userId) {
    String title;
    IconData icon;
    Color color;

    if (txn.type == 'deposit') {
      title = 'Depósito';
      icon = Icons.arrow_downward;
      color = Colors.green;
    } else if (txn.type == 'transfer') {
      if (txn.senderId == userId) {
        title = 'Transferência enviada';
        icon = Icons.arrow_outward;
        color = Colors.red;
      } else {
        title = 'Transferência recebida';
        icon = Icons.arrow_inward;
        color = Colors.green;
      }
    } else {
      title = 'Outra transação';
      icon = Icons.swap_horiz;
      color = Colors.grey;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: color, size: 32),
        title: Text(
          title,
          style: AppTextStyles.subtitle.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        subtitle: Text(
          DateFormat('dd/MM/yyyy HH:mm').format(txn.timestamp),
          style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'R\$ ${txn.amount.toStringAsFixed(2)}',
              style: AppTextStyles.amount.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (txn.description != null && txn.description!.isNotEmpty)
              const SizedBox(height: 4),
            if (txn.description != null && txn.description!.isNotEmpty)
              Text(
                txn.description!,
                style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }
}
