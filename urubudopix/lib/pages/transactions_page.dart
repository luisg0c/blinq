import 'package:flutter/material.dart';
import '../services/transaction_service.dart';
import '../services/auth_service.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_card.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionService = TransactionService();
    final authService = AuthService();
    final String userId = authService.getCurrentUserId();

    return Scaffold(
      appBar: AppBar(title: const Text('Extrato de Transações')),
      body: StreamBuilder<List<TransactionModel>>(
        stream: transactionService.getUserTransactions(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final transactions = snapshot.data ?? [];
          if (transactions.isEmpty) {
            return const Center(child: Text('Nenhuma transação encontrada.'));
          }
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              return TransactionCard(transaction: transactions[index]);
            },
          );
        },
      ),
    );
  }
}
