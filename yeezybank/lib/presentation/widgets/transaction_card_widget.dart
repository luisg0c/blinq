import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/models/transaction_model.dart';
import '../pages/transaction_details_page.dart';
import '../theme/app_colors.dart';

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
    
    return InkWell(
      onTap: () {
        // Navegar para a página de detalhes ao clicar
        Get.to(() => TransactionDetailsPage(transaction: transaction));
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          leading: CircleAvatar(
            radius: 20,
            foregroundColor: display.color,
            backgroundColor: display.color.withOpacity(0.2),
            child: Icon(display.icon, color: display.color),
          ),
          title: Text(
            display.title,
            style: TextStyle(fontWeight: FontWeight.bold, color: display.color),
          ),
          subtitle: Text(\n            DateFormat('dd/MM/yyyy - HH:mm').format(transaction.timestamp),\n            style: TextStyle(color: Colors.grey[600], fontSize: 12),          \n          ),\n          trailing: Text(\n            NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(transaction.amount),\n            style: TextStyle(\n              color: transaction.type == 'transfer' && transaction.senderId == currentUserId\n                  ? Colors.red\n                  : AppColors.textColor,\n              fontWeight: FontWeight.w500,\n              fontSize: 16,\n            ),          \n        ),        \n          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),        \n          tileColor: AppColors.surface,        \n        ),      \n      ),    \n    );\n  }\n  \n  // Método auxiliar para determinar características visuais\n  TransactionDisplay _getTransactionDisplay() {\n    if (transaction.type == 'deposit') {\n      return TransactionDisplay(\n        title: 'Depósito',\n        icon: Icons.add_circle_outline,\n        color: Colors.blue,\n      );\n    } else if (transaction.type == 'transfer') {\n      if (transaction.senderId == currentUserId) {\n        return TransactionDisplay(\n          title: 'Pix Enviado',\n          icon: Icons.arrow_circle_up,\n          color: Colors.red,\n        );\n      } else {\n        return TransactionDisplay(\n          title: 'Pix Recebido',          \n          icon: Icons.arrow_circle_down,\n          color: Colors.green,\n        );      \n    } else {\n      return TransactionDisplay(\n        title: 'Transação',\n        icon: Icons.swap_horiz,\n        color: Colors.grey,\n      );    \n  }\n}\n\n// Classe auxiliar para informações de exibição da transação\nclass TransactionDisplay {\n  final String title;\n  final IconData icon;\n  final Color color;\n  \n  TransactionDisplay({\n    required this.title,\n    required this.icon,\n    required this.color,
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