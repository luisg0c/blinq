import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction.dart';

/// Card otimizado para transações P2P simples do Blinq
class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key, // ✅ Corrigido: usar super parameter
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6EE1C6);
    const secondaryColor = Color(0xFF0D1517);
    
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03), // ✅ Corrigido: withValues
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
                    color: _getP2PIconBackground(transaction.type, isReceived),
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
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (transaction.counterparty.isNotEmpty)
                        Text(
                          transaction.counterparty,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
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
                        color: primaryColor.withValues(alpha: 0.1), // ✅ Corrigido: withValues
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
        return Icons.add_circle;
      case 'transfer':
        return isReceived ? Icons.call_received : Icons.call_made;
      case 'pix':
        return Icons.qr_code;
      default:
        return isReceived ? Icons.arrow_downward : Icons.arrow_upward;
    }
  }

  Color _getP2PIconBackground(String type, bool isReceived) {
    switch (type.toLowerCase()) {
      case 'deposit':
        return const Color(0xFF6EE1C6).withValues(alpha: 0.15); // ✅ Corrigido: withValues
      case 'transfer':
        return isReceived 
            ? const Color(0xFF10B981).withValues(alpha: 0.15) // ✅ Corrigido: withValues
            : const Color(0xFF3B82F6).withValues(alpha: 0.15); // ✅ Corrigido: withValues
      case 'pix':
        return const Color(0xFF8B5CF6).withValues(alpha: 0.15); // ✅ Corrigido: withValues
      default:
        return const Color(0xFF6EE1C6).withValues(alpha: 0.15); // ✅ Corrigido: withValues
    }
  }

  Color _getP2PIconColor(String type, bool isReceived) {
    switch (type.toLowerCase()) {
      case 'deposit':
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
      case 'transfer':
        return isReceived ? 'Recebido' : 'Enviado';
      case 'pix':
        return isReceived ? 'PIX recebido' : 'PIX enviado';
      default:
        return isReceived ? 'Entrada' : 'Saída';
    }
  }
}