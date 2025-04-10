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
          subtitle: Text(
            DateFormat('dd/MM/yyyy - HH:mm').format(transaction.timestamp),
            style: TextStyle(color: AppColors.subtitle, fontSize: 12),
          ),
          trailing: Text(
            'R$ ${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: display.color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          tileColor: AppColors.surface,
        ),
      ),
    );
  }

  TransactionDisplay _getTransactionDisplay() {
    if (transaction.type == 'deposit') {
      return TransactionDisplay(
        title: 'Depósito',
        icon: Icons.add_circle_outline,
        color: AppColors.primaryColor,
      );
    } else if (transaction.type == 'transfer') {
      if (transaction.senderId == currentUserId) {
        return TransactionDisplay(
          title: 'Pix Enviado',
          icon: Icons.arrow_upward,
          color: AppColors.error,
        );
      } else {
        return TransactionDisplay(
          title: 'Pix Recebido',
          icon: Icons.arrow_downward,
          color: AppColors.primaryColor,
        );
      }
    } else {
      return TransactionDisplay(
        title: 'Transação',
        icon: Icons.swap_horiz,
        color: AppColors.subtitle,
      );
    }
  }
}

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