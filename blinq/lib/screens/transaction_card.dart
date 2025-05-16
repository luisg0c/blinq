import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final String currentUserId;
  final VoidCallback onTap;

  const TransactionCard({
    Key? key,
    required this.transaction,
    required this.currentUserId,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isIncoming = transaction.isDeposit ||
        (transaction.isTransfer && transaction.receiverId == currentUserId);
    final color = isIncoming ? AppColors.success : AppColors.error;
    final sign = isIncoming ? '+' : '-';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            // Transaction Type Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                transaction.isDeposit
                    ? Icons.add_rounded
                    : isIncoming
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_forward_rounded,
                color: color,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.isDeposit
                        ? 'Depósito'
                        : isIncoming
                            ? 'Transferência Recebida'
                            : 'Transferência Enviada',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    Formatters.formatRelativeDate(transaction.timestamp),
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),

            // Transaction Amount
            Text(
              '$sign${Formatters.formatCurrency(transaction.amount)}',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
