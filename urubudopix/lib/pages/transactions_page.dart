import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../models/transaction_model.dart';
import 'package:intl/intl.dart';

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
      body: FutureBuilder<List<TransactionModel>>(
        future: transactionService.getUserTransactions(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return const Center(child: Text('Nenhuma transação encontrada.'));
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final txn = transactions[index];
              final isSent = txn.senderId == userId;
              final isDeposit = txn.senderId == txn.receiverId;

              String title;
              IconData icon;
              Color color;

              if (isDeposit) {
                title = 'Depósito';
                icon = Icons.add;
                color = Colors.blue;
              } else if (isSent) {
                title = 'Enviado';
                icon = Icons.arrow_upward;
                color = Colors.red;
              } else {
                title = 'Recebido';
                icon = Icons.arrow_downward;
                color = Colors.green;
              }

              return ListTile(
                leading: Icon(icon, color: color),
                title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(txn.timestamp),
                ),
                trailing: Text(
                  'R\$ ${txn.amount.toStringAsFixed(2)}',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
