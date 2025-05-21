import 'package:intl/intl.dart';

/// Formatadores globais de valores, datas e CPFs.
class Formatters {
  /// Formata valores monetários em R$ com vírgula.
  static String currency(double value) {
    final format = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return format.format(value);
  }

  /// Formata uma [DateTime] para "dd/MM/yyyy HH:mm"
  static String dateTime(DateTime date) {
    final format = DateFormat('dd/MM/yyyy HH:mm');
    return format.format(date);
  }

  /// Formata uma [DateTime] para "MMM yyyy"
  static String monthYear(DateTime date) {
    final format = DateFormat('MMMM yyyy', 'pt_BR');
    return format.format(date);
  }

  /// Formata CPF (sem máscara): 12345678900 → 123.456.789-00
  static String cpf(String rawCpf) {
    final digits = rawCpf.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) return rawCpf;
    return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6, 9)}-${digits.substring(9)}';
  }
}
