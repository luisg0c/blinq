import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../models/transaction_model.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final transactionService = TransactionService();
    final userId = authService.getCurrentUserId();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Transações'),
        backgroundColor: const Color(0xFF388E3C),
      ),
      backgroundColor: const Color(0xFFF0F2F5),
      body: StreamBuilder<List<TransactionModel>>(
        stream: transactionService.getUserTransactionsStream(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar transações: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data ?? [];

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
        },
      ),
    );
  }
}
