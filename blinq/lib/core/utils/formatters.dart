import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

/// Classe com formatadores para exibição de dados
class Formatters {
  // Evitar instanciação
  Formatters._();
  
  // Formatador de moeda em reais
  static final _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: AppConstants.currencyFormat,
    decimalDigits: 2,
  );
  
  // Formatador de data
  static final _dateFormat = DateFormat(AppConstants.dateFormat);
  
  // Formatador de hora
  static final _timeFormat = DateFormat(AppConstants.timeFormat);
  
  // Formatador de data e hora
  static final _dateTimeFormat = DateFormat(AppConstants.dateTimeFormat);
  
  /// Formata um valor para moeda (R$)
  static String formatCurrency(double value) {
    return _currencyFormat.format(value);
  }
  
  /// Formata um valor para moeda sem o símbolo
  static String formatCurrencyWithoutSymbol(double value) {
    return _currencyFormat.format(value).replaceAll(AppConstants.currencyFormat, '').trim();
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
  
  /// Formata um número de telefone
  static String formatPhone(String phone) {
    if (phone.isEmpty) return '';
    
    // Remover caracteres não numéricos
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    
    // Aplicar formatação conforme comprimento
    if (digitsOnly.length <= 10) {
      // (XX) XXXX-XXXX
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 6)}-${digitsOnly.substring(6)}';
    } else {
      // (XX) XXXXX-XXXX
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 7)}-${digitsOnly.substring(7)}';
    }
  }
  
  /// Formata um valor para exibição em uma transação
  static String formatTransactionValue(double value, String type, String senderId, String currentUserId) {
    if (type == 'deposit') {
      return '+${formatCurrency(value)}';
    } else if (type == 'transfer') {
      if (senderId == currentUserId) {
        return '-${formatCurrency(value)}';
      } else {
        return '+${formatCurrency(value)}';
      }
    }
    return formatCurrency(value);
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
  
  /// Formata o nome do usuário para exibir apenas o primeiro nome
  static String formatFirstName(String fullName) {
    if (fullName.isEmpty) return '';
    return fullName.split(' ')[0];
  }
  
  /// Formata o nome do usuário para exibir iniciais
  static String formatNameInitials(String fullName) {
    if (fullName.isEmpty) return '';
    
    final names = fullName.split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    } else {
      return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
    }
  }
  
  /// Formata um valor para exibição simplificada (mil, milhão, etc.)
  static String formatCompactCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(2);
    }
  }
}

/// Formatador de entrada de texto para valores monetários
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
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
  }
}

/// Formatador de entrada de texto para números de telefone
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;
    
    // Remover caracteres não numéricos
    text = text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    // Aplicar formatação conforme comprimento
    String formatted = '';
    if (text.length <= 2) {
      formatted = '(${text.padRight(2, '_').substring(0, 2)}';
    } else if (text.length <= 6) {
      formatted = '(${text.substring(0, 2)}) ${text.substring(2).padRight(4, '_').substring(0, 4)}';
    } else if (text.length <= 10) {
      formatted = '(${text.substring(0, 2)}) ${text.substring(2, 6)}-${text.substring(6).padRight(4, '_').substring(0, 4)}';
    } else {
      formatted = '(${text.substring(0, 2)}) ${text.substring(2, 7)}-${text.substring(7, 11)}';
      text = text.substring(0, 11); // Limitar a 11 dígitos
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatador de entrada de texto para CPF
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;
    
    // Remover caracteres não numéricos
    text = text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    // Aplicar formatação de CPF (XXX.XXX.XXX-XX)
    String formatted = '';
    if (text.length <= 3) {
      formatted = text;
    } else if (text.length <= 6) {
      formatted = '${text.substring(0, 3)}.${text.substring(3)}';
    } else if (text.length <= 9) {
      formatted = '${text.substring(0, 3)}.${text.substring(3, 6)}.${text.substring(6)}';
    } else {
      formatted = '${text.substring(0, 3)}.${text.substring(3, 6)}.${text.substring(6, 9)}-${text.substring(9, 11)}';
      text = text.substring(0, 11); // Limitar a 11 dígitos
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}