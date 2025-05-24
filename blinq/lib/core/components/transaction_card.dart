// blinq/lib/core/components/transaction_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction.dart';

/// Card otimizado para transações P2P com suporte a modo escuro
class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionCard({
<<<<<<< Updated upstream
    super.key,
=======
    super.key, // ✅ Corrigido: usar super parameter
>>>>>>> Stashed changes
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6EE1C6);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Cores adaptáveis ao tema
    final backgroundColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final textPrimaryColor = isDark ? Colors.white : const Color(0xFF0D1517);
    final textSecondaryColor = isDark ? Colors.white70 : Colors.grey[600];
    final shadowColor = isDark ? Colors.black26 : Colors.black.withOpacity(0.03);
    
    final isReceived = transaction.amount >= 0;
    final amountColor = isReceived 
        ? const Color(0xFF10B981) 
        : const Color(0xFFEF4444);
    
    final formattedDate = DateFormat('dd/MM • HH:mm').format(transaction.date);
    final formattedAmount = NumberFormat.simpleCurrency(locale: 'pt_BR')
        .format(transaction.amount.abs());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ) : null,
        boxShadow: isDark ? [
          BoxShadow(
<<<<<<< Updated upstream
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : [
          BoxShadow(
            color: shadowColor,
=======
            color: Colors.black.withValues(alpha: 0.03), // ✅ Corrigido: withValues
>>>>>>> Stashed changes
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícone P2P
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getP2PIconBackground(transaction.type, isReceived, isDark),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getP2PIcon(transaction.type, isReceived),
                    color: _getP2PIconColor(transaction.type, isReceived),
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                // Info da transação P2P
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getP2PTitle(transaction, isReceived),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (transaction.counterparty.isNotEmpty)
                        Text(
                          transaction.counterparty,
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondaryColor,
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 11,
                          color: textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Valor P2P
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isReceived ? '+' : '-'} $formattedAmount',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: amountColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
<<<<<<< Updated upstream
                        color: primaryColor.withOpacity(isDark ? 0.2 : 0.1),
=======
                        color: primaryColor.withValues(alpha: 0.1), // ✅ Corrigido: withValues
>>>>>>> Stashed changes
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text( // ✅ Corrigido: usar const
                        'Concluído',
                        style: TextStyle( // ✅ Corrigido: usar const
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Ícones específicos para P2P
  IconData _getP2PIcon(String type, bool isReceived) {
    switch (type.toLowerCase()) {
      case 'deposit':
      case 'bonus':
        return Icons.add_circle;
      case 'transfer':
        return isReceived ? Icons.call_received : Icons.call_made;
      case 'pix':
        return Icons.qr_code;
      default:
        return isReceived ? Icons.arrow_downward : Icons.arrow_upward;
    }
  }

  Color _getP2PIconBackground(String type, bool isReceived, bool isDark) {
    final opacity = isDark ? 0.25 : 0.15;
    
    switch (type.toLowerCase()) {
      case 'deposit':
<<<<<<< Updated upstream
      case 'bonus':
        return const Color(0xFF6EE1C6).withOpacity(opacity);
      case 'transfer':
        return isReceived 
            ? const Color(0xFF10B981).withOpacity(opacity)
            : const Color(0xFF3B82F6).withOpacity(opacity);
      case 'pix':
        return const Color(0xFF8B5CF6).withOpacity(opacity);
      default:
        return const Color(0xFF6EE1C6).withOpacity(opacity);
=======
        return const Color(0xFF6EE1C6).withValues(alpha: 0.15); // ✅ Corrigido: withValues
      case 'transfer':
        return isReceived 
            ? const Color(0xFF10B981).withValues(alpha: 0.15) // ✅ Corrigido: withValues
            : const Color(0xFF3B82F6).withValues(alpha: 0.15); // ✅ Corrigido: withValues
      case 'pix':
        return const Color(0xFF8B5CF6).withValues(alpha: 0.15); // ✅ Corrigido: withValues
      default:
        return const Color(0xFF6EE1C6).withValues(alpha: 0.15); // ✅ Corrigido: withValues
>>>>>>> Stashed changes
    }
  }

  Color _getP2PIconColor(String type, bool isReceived) {
    switch (type.toLowerCase()) {
      case 'deposit':
      case 'bonus':
        return const Color(0xFF6EE1C6);
      case 'transfer':
        return isReceived 
            ? const Color(0xFF10B981)
            : const Color(0xFF3B82F6);
      case 'pix':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6EE1C6);
    }
  }

  String _getP2PTitle(Transaction transaction, bool isReceived) {
    switch (transaction.type.toLowerCase()) {
      case 'deposit':
        return 'Depósito';
      case 'bonus':
        return 'Bônus';
      case 'transfer':
        return isReceived ? 'Recebido' : 'Enviado';
      case 'pix':
        return isReceived ? 'PIX recebido' : 'PIX enviado';
      default:
        return isReceived ? 'Entrada' : 'Saída';
    }
  }
}