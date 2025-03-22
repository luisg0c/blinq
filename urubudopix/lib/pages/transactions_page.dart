import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      appBar: AppBar(title: const Text('Histórico de Transações')),
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

              return ListTile(
                leading: Icon(
                  isSent ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isSent ? Colors.red : Colors.green,
                ),
                title: Text(
                  isSent ? 'Enviado para ${txn.receiverId}' : 'Recebido de ${txn.senderId}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Valor: R\$ ${txn.amount.toStringAsFixed(2)}\nData: ${txn.timestamp}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
