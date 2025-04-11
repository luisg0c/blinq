import 'package:intl/intl.dart';
import '../../domain/models/transaction_model.dart';

class TransactionUtils {
  static final _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );
  static final _dateFormatter = DateFormat('dd/MM/yyyy - HH:mm');
  static final _shortDateFormatter = DateFormat('dd/MM/yyyy');
  static final _timeFormatter = DateFormat('HH:mm');

  /// Retorna o valor formatado em reais
  static String formatCurrency(double value) {
    return _currencyFormatter.format(value);
  }

  /// Retorna a data formatada completa
  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  /// Retorna apenas a data (sem hora)
  static String formatShortDate(DateTime date) {
    return _shortDateFormatter.format(date);
  }

  /// Retorna apenas a hora
  static String formatTime(DateTime date) {
    return _timeFormatter.format(date);
  }

  /// Retorna a descrição amigável do tipo de transação
  static String getTransactionTypeDescription(
    TransactionModel transaction,
    String currentUserId,
  ) {
    if (transaction.type == 'deposit') {
      return 'Depósito';
    } else if (transaction.type == 'transfer') {
      if (transaction.senderId == currentUserId) {
        return 'Pix Enviado';
      } else {
        return 'Pix Recebido';
      }
    } else {
      return 'Transação';
    }
  }

  /// Gera um ID de rastreamento único para a transação (para comprovantes)
  static String generateTrackingId(TransactionModel transaction) {
    final timestamp = transaction.timestamp.millisecondsSinceEpoch
        .toString()
        .substring(6);
    final userId = transaction.senderId.substring(0, 4);
    return 'YZY${timestamp}${userId}';
  }

  /// Retorna o valor com sinal (positivo/negativo) de acordo com o tipo de transação
  static double getSignedAmount(
    TransactionModel transaction,
    String currentUserId,
  ) {
    if (transaction.type == 'deposit') {
      return transaction.amount;
    } else if (transaction.type == 'transfer') {
      if (transaction.senderId == currentUserId) {
        return -transaction.amount;
      } else {
        return transaction.amount;
      }
    }
    return transaction.amount;
  }

  /// Valida se uma transação é recente (últimas 24 horas)
  static bool isRecentTransaction(TransactionModel transaction) {
    final now = DateTime.now();
    final difference = now.difference(transaction.timestamp);
    return difference.inHours < 24;
  }

  /// Retorna uma versão resumida da descrição (truncada se muito longa)
  static String getShortDescription(
    TransactionModel transaction, {
    int maxLength = 20,
  }) {
    if (transaction.description == null || transaction.description!.isEmpty) {
      return '-';
    }

    if (transaction.description!.length <= maxLength) {
      return transaction.description!;
    }

    return '${transaction.description!.substring(0, maxLength)}...';
  }
}
