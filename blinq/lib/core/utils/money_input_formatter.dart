import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MoneyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$ ',
    decimalDigits: 2,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    try {
      // ✅ PERMITIR DELETION COMPLETA
      if (newValue.text.isEmpty) {
        return const TextEditingValue(text: '');
      }

      // ✅ EXTRAIR APENAS DÍGITOS
      String digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
      
      if (digits.isEmpty) {
        return const TextEditingValue(text: '');
      }

      // ✅ PREVENIR OVERFLOW (máximo 8 dígitos = 999,999.99)
      if (digits.length > 8) {
        digits = digits.substring(0, 8);
      }

      // ✅ CONVERTER PARA CENTAVOS -> REAIS
      double value = double.parse(digits) / 100;

      // ✅ FORMATAR CORRETAMENTE
      final newText = _formatter.format(value);

      // ✅ CALCULAR NOVA POSIÇÃO DO CURSOR
      int newCursorPos = newText.length;
      
      // Se o usuário estava digitando no final, manter cursor no final
      if (newValue.selection.baseOffset >= newValue.text.length) {
        newCursorPos = newText.length;
      } else {
        // Tentar manter posição relativa
        final oldDigitCount = oldValue.text.replaceAll(RegExp(r'[^\d]'), '').length;
        final newDigitCount = digits.length;
        
        if (newDigitCount > oldDigitCount) {
          // Adicionou dígito
          newCursorPos = newText.length;
        } else {
          // Removeu dígito
          newCursorPos = newText.length;
        }
      }

      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursorPos),
      );

    } catch (e) {
      print('❌ Erro no MoneyInputFormatter: $e');
      // Em caso de erro, retornar valor anterior
      return oldValue;
    }
  }

  /// ✅ MÉTODO ESTÁTICO PARA CONVERTER TEXTO FORMATADO EM DOUBLE
  static double parseAmount(String formattedText) {
    if (formattedText.trim().isEmpty) return 0.0;
    
    try {
      // Remover tudo exceto dígitos e vírgula/ponto decimal
      String cleaned = formattedText
          .replaceAll('R\$', '')
          .replaceAll(' ', '')
          .replaceAll('\u00A0', '') // espaço não-quebrável
          .trim();
      
      // Se contém ponto E vírgula, é formato brasileiro (1.000,50)
      if (cleaned.contains('.') && cleaned.contains(',')) {
        // Remove pontos (separadores de milhares) e substitui vírgula por ponto
        cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
      } else if (cleaned.contains(',') && !cleaned.contains('.')) {
        // Apenas vírgula, substitui por ponto
        cleaned = cleaned.replaceAll(',', '.');
      }
      
      final amount = double.tryParse(cleaned) ?? 0.0;
      print('💰 Texto "$formattedText" -> Valor: $amount');
      return amount;
      
    } catch (e) {
      print('❌ Erro ao converter "$formattedText": $e');
      return 0.0;
    }
  }

  /// ✅ MÉTODO ESTÁTICO PARA FORMATAR DOUBLE EM TEXTO
  static String formatAmount(double amount) {
    try {
      final formatter = NumberFormat.currency(
        locale: 'pt_BR',
        symbol: 'R\$ ',
        decimalDigits: 2,
      );
      return formatter.format(amount);
    } catch (e) {
      print('❌ Erro ao formatar $amount: $e');
      return 'R\$ 0,00';
    }
  }

  /// ✅ VALIDAR SE TEXTO REPRESENTA UM VALOR VÁLIDO
  static bool isValidAmount(String formattedText) {
    final amount = parseAmount(formattedText);
    return amount > 0 && amount <= 999999.99; // Limite máximo razoável
  }
}