import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/transaction_model.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final String currentUserId;
  
  const TransactionCard({
    Key? key,
    required this.transaction,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determinar tipo, ícone e cor com base no tipo e direção da transação
    TransactionDisplay display = _getTransactionDisplay();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: display.color.withOpacity(0.2),
          child: Icon(display.icon, color: display.color),
        ),
        title: Text(
          display.title,
          style: TextStyle(fontWeight: FontWeight.bold, color: display.color),
        ),
        subtitle: Text(
          DateFormat('dd/MM/yyyy HH:mm').format(transaction.timestamp),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Text(
          'R\$ ${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: display.color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
  
  // Método auxiliar para determinar características visuais
  TransactionDisplay _getTransactionDisplay() {
    if (transaction.type == 'deposit') {
      return TransactionDisplay(
        title: 'Depósito',
        icon: Icons.add_circle_outline,
        color: Colors.blue,
      );
    } else if (transaction.type == 'transfer') {
      if (transaction.senderId == currentUserId) {
        return TransactionDisplay(
          title: 'Pix Enviado',
          icon: Icons.arrow_upward,
          color: Colors.red,
        );
      } else {
        return TransactionDisplay(
          title: 'Pix Recebido',
          icon: Icons.arrow_downward,
          color: Colors.green,
        );
      }
    } else {
      return TransactionDisplay(
        title: 'Transação',
        icon: Icons.swap_horiz,
        color: Colors.grey,
      );
    }
  }
}

// Classe auxiliar para informações de exibição da transação
class TransactionDisplay {
  final String title;
  final IconData icon;
  final Color color;
  
  TransactionDisplay({
    required this.title,
    required this.icon,
    required this.color,
  });
}