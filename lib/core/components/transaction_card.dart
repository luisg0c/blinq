// lib/core/components/transaction_card.dart - CORES CORRIGIDAS

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction.dart';

/// Card de transação com cores consistentes ao tema neomorfo
class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6EE1C6);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // ✅ CORES CONSISTENTES COM O TEMA NEOMORFO
    final backgroundColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E5E5);
    final highlightColor = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFFFFFFF);
    final shadowDarkColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFBEBEBE);
    final textPrimaryColor = isDark ? Colors.white : const Color(0xFF0D1517);
    final textSecondaryColor = isDark ? Colors.white70 : Colors.grey[600];
    
    final isReceived = transaction.amount >= 0;
    final amountColor = isReceived 
        ? const Color(0xFF10B981) 
        : const Color(0xFFEF4444);
    
    final formattedDate = DateFormat('dd/MM • HH:mm').format(transaction.date);
    final formattedAmount = NumberFormat.simpleCurrency(locale: 'pt_BR')
        .format(transaction.amount.abs());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        // ✅ SOMBRAS NEOMORFAS CONSISTENTES
        boxShadow: [
          BoxShadow(
            color: highlightColor.withOpacity(0.7),
            offset: const Offset(-3, -3),
            blurRadius: 6,
          ),
          BoxShadow(
            color: shadowDarkColor.withOpacity(0.5),
            offset: const Offset(3, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // ✅ ÍCONE COM ESTILO NEOMORFO
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: highlightColor.withOpacity(0.7),
                        offset: const Offset(-2, -2),
                        blurRadius: 4,
                      ),
                      BoxShadow(
                        color: shadowDarkColor.withOpacity(0.5),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _getTransactionIcon(transaction.type, isReceived),
                      color: _getIconColor(transaction.type, isReceived),
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Informações da transação
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTransactionTitle(transaction, isReceived),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (transaction.counterparty.isNotEmpty)
                        Text(
                          transaction.counterparty,
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondaryColor,
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Valor da transação
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isReceived ? '+' : '-'} $formattedAmount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: amountColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // ✅ STATUS COM ESTILO NEOMORFO
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: highlightColor.withOpacity(0.5),
                            offset: const Offset(-1, -1),
                            blurRadius: 2,
                          ),
                          BoxShadow(
                            color: shadowDarkColor.withOpacity(0.3),
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Text(
                        'Concluído',
                        style: TextStyle(
                          fontSize: 10,
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

  // ✅ ÍCONES ESPECÍFICOS PARA CADA TIPO
  IconData _getTransactionIcon(String type, bool isReceived) {
    switch (type.toLowerCase()) {
      case 'deposit':
      case 'bonus':
        return Icons.add_circle_outline;
      case 'transfer':
        return isReceived ? Icons.call_received : Icons.call_made;
      case 'receive':
        return Icons.call_received;
      case 'pix':
        return Icons.qr_code;
      default:
        return isReceived ? Icons.arrow_downward : Icons.arrow_upward;
    }
  }

  // ✅ CORES DOS ÍCONES
  Color _getIconColor(String type, bool isReceived) {
    switch (type.toLowerCase()) {
      case 'deposit':
      case 'bonus':
        return const Color(0xFF6EE1C6);
      case 'transfer':
        return isReceived 
            ? const Color(0xFF10B981)
            : const Color(0xFF3B82F6);
      case 'receive':
        return const Color(0xFF10B981);
      case 'pix':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6EE1C6);
    }
  }

  // ✅ TÍTULOS MAIS CLAROS
  String _getTransactionTitle(Transaction transaction, bool isReceived) {
    switch (transaction.type.toLowerCase()) {
      case 'deposit':
        return 'Depósito';
      case 'bonus':
        return 'Bônus de Boas-vindas';
      case 'transfer':
        return isReceived ? 'Dinheiro Recebido' : 'Transferência Enviada';
      case 'receive':
        return 'Dinheiro Recebido';
      case 'pix':
        return isReceived ? 'PIX Recebido' : 'PIX Enviado';
      default:
        return isReceived ? 'Entrada' : 'Saída';
    }
  }
}