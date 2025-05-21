import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Formatters {
  // Evitar instanciação
  Formatters._();

  // Formatador de moeda em reais
  static final _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  // Formatador de data
  static final _dateFormat = DateFormat('dd/MM/yyyy');

  // Formatador de hora
  static final _timeFormat = DateFormat('HH:mm');

  // Formatador de data e hora
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Formata um valor para moeda (R$)
  static String formatCurrency(double value) {
    return _currencyFormat.format(value);
  }

  /// Formata uma data
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Formata uma hora
  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }

  /// Formata data e hora
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// Formata uma data relativa (hoje, ontem, etc.)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCompare = DateTime(date.year, date.month, date.day);

    if (dateToCompare == today) {
      return 'Hoje, ${formatTime(date)}';
    } else if (dateToCompare == yesterday) {
      return 'Ontem, ${formatTime(date)}';
    } else {
      return formatDateTime(date);
    }
  }

  /// Formatter para entrada de valor monetário
  static final currencyInputFormatter = TextInputFormatter.withFunction(
    (oldValue, newValue) {
      if (newValue.text.isEmpty) {
        return newValue;
      }

      // Remover caracteres não numéricos
      String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

      // Converter para valor monetário
      if (newText.isEmpty) {
        newText = '0';
      }

      final value = double.parse(newText) / 100;
      final formatted = NumberFormat('#,##0.00', 'pt_BR').format(value);

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    },
  );
}
