import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/services/auth_service.dart';
import '../theme/app_text_styles.dart';
import '../controllers/transaction_controller.dart';
import '../../domain/models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../pages/transaction_details_page.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionController>();

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
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            );
          }

          final transactions = controller.transactions;
          final userId = controller.currentUserId;

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppColors.subtitle,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma transação encontrada.',
                    style: AppTextStyles.body.copyWith(color: AppColors.subtitle),
                  ),
                ],
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
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final transactionType = _getTransactionType(txn, userId);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => Get.to(() => TransactionDetailsPage(transaction: txn)),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: transactionType.color.withOpacity(0.2),
                radius: 24,
                child: Icon(transactionType.icon, color: transactionType.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transactionType.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(txn.timestamp),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if ((txn.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        txn.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(txn.amount),
                style: TextStyle(
                  color: transactionType.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _TransactionType _getTransactionType(TransactionModel txn, String userId) {
    if (txn.type == 'deposit') {
      return _TransactionType(
        title: 'Depósito',
        icon: Icons.add_circle_outline,
        color: AppColors.primaryColor,
      );
    } else if (txn.type == 'transfer') {
      final isSender = txn.senderId == userId;
      return _TransactionType(
        title: isSender ? 'Transferência enviada' : 'Transferência recebida',
        icon: isSender ? Icons.arrow_upward : Icons.arrow_downward,
        color: isSender ? AppColors.error : AppColors.success,
      );
    } else {
      return _TransactionType(
        title: 'Outra transação',
        icon: Icons.swap_horiz,
        color: AppColors.subtitle,
      );
    }
  }
}

class _TransactionType {
  final String title;
  final IconData icon;
  final Color color;

  _TransactionType({
    required this.title,
    required this.icon,
    required this.color,
  });
}
