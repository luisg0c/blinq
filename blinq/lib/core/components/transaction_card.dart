import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction.dart';

/// Card que exibe informações de uma única transação.
class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6EE1C6);
    const secondaryColor = Color(0xFF0D1517);
    final amountColor = transaction.amount >= 0 ? Colors.green : Colors.red;
    final formattedDate = DateFormat('dd/MM/yyyy – HH:mm').format(transaction.date);
    final formattedAmount = NumberFormat.simpleCurrency(locale: 'pt_BR').format(transaction.amount);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 1,
      child: ListTile(
        leading: Icon(
          _iconForType(transaction.type),
          color: primaryColor,
        ),
        title: Text(
          transaction.description,
          style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          formattedDate,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Text(
          formattedAmount,
          style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'deposit':
        return Icons.arrow_downward;
      case 'transfer':
        return Icons.send;
      case 'payment':
        return Icons.payment;
      case 'recharge':
        return Icons.phone_android;
      default:
        return Icons.swap_horiz;
    }
  }
}
