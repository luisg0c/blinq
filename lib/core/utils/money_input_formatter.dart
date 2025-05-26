// lib/core/utils/money_input_formatter.dart - VERSÃO CORRIGIDA

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

  /// ✅ MÉTODO ESTÁTICO CORRIGIDO PARA CONVERTER TEXTO FORMATADO EM DOUBLE
  static double parseAmount(String formattedText) {
    if (formattedText.trim().isEmpty) {
      print('💰 Texto vazio -> 0.0');
      return 0.0;
    }
    
    try {
      print('🔄 Parseando: "$formattedText"');
      
      // ✅ LIMPEZA ROBUSTA DO TEXTO
      String cleaned = formattedText
          .trim()
          .replaceAll('R\$', '')
          .replaceAll(' ', '')
          .replaceAll('\u00A0', '') // espaço não-quebrável
          .replaceAll('\u202F', '') // espaço fino não-quebrável
          .replaceAll('\u00AD', '') // hífen suave
          .trim();
      
      print('🧹 Após limpeza: "$cleaned"');
      
      if (cleaned.isEmpty) {
        print('💰 Texto limpo vazio -> 0.0');
        return 0.0;
      }
      
      // ✅ TRATAR FORMATO BRASILEIRO (1.234,56)
      if (cleaned.contains('.') && cleaned.contains(',')) {
        // Formato: 1.234,56 -> 1234.56
        final lastCommaIndex = cleaned.lastIndexOf(',');
        final lastDotIndex = cleaned.lastIndexOf('.');
        
        if (lastCommaIndex > lastDotIndex) {
          // Vírgula é o separador decimal
          cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
          print('🇧🇷 Formato brasileiro detectado: "$cleaned"');
        } else {
          // Ponto é o separador decimal
          cleaned = cleaned.replaceAll(',', '');
          print('🇺🇸 Formato americano detectado: "$cleaned"');
        }
      } else if (cleaned.contains(',') && !cleaned.contains('.')) {
        // Apenas vírgula: substituir por ponto
        cleaned = cleaned.replaceAll(',', '.');
        print('🔄 Vírgula -> ponto: "$cleaned"');
      } else if (cleaned.contains('.')) {
        // Verificar se é separador de milhares ou decimal
        final dotIndex = cleaned.lastIndexOf('.');
        final afterDot = cleaned.substring(dotIndex + 1);
        
        if (afterDot.length > 2) {
          // Provavelmente separador de milhares: 1.234.567 -> 1234567
          cleaned = cleaned.replaceAll('.', '');
          print('🔢 Separadores de milhares removidos: "$cleaned"');
        } else {
          // Provavelmente separador decimal
          print('💯 Separador decimal mantido: "$cleaned"');
        }
      }
      
      // ✅ CONVERSÃO FINAL
      final amount = double.tryParse(cleaned) ?? 0.0;
      
      // ✅ VALIDAÇÃO DE SANIDADE
      if (amount.isNaN || amount.isInfinite) {
        print('❌ Valor inválido (NaN/Infinite): $amount');
        return 0.0;
      }
      
      if (amount < 0) {
        print('❌ Valor negativo: $amount -> 0.0');
        return 0.0;
      }
      
      if (amount > 999999.99) {
        print('⚠️ Valor muito alto: $amount -> 999999.99');
        return 999999.99;
      }
      
      print('✅ Conversão bem-sucedida: "$formattedText" -> $amount');
      return amount;
      
    } catch (e) {
      print('❌ Erro ao converter "$formattedText": $e');
      return 0.0;
    }
  }

  /// ✅ MÉTODO ESTÁTICO PARA FORMATAR DOUBLE EM TEXTO
  static String formatAmount(double amount) {
    try {
      // ✅ VALIDAÇÃO DE ENTRADA
      if (amount.isNaN || amount.isInfinite) {
        print('❌ Valor inválido para formatação: $amount');
        return 'R\$ 0,00';
      }
      
      if (amount < 0) {
        print('⚠️ Valor negativo para formatação: $amount');
        amount = 0.0;
      }
      
      if (amount > 999999.99) {
        print('⚠️ Valor muito alto para formatação: $amount');
        amount = 999999.99;
      }
      
      final formatter = NumberFormat.currency(
        locale: 'pt_BR',
        symbol: 'R\$ ',
        decimalDigits: 2,
      );
      
      final formatted = formatter.format(amount);
      print('✅ Formatação: $amount -> "$formatted"');
      return formatted;
      
    } catch (e) {
      print('❌ Erro ao formatar $amount: $e');
      return 'R\$ 0,00';
    }
  }

  /// ✅ VALIDAR SE TEXTO REPRESENTA UM VALOR VÁLIDO
  static bool isValidAmount(String formattedText) {
    final amount = parseAmount(formattedText);
    final isValid = amount > 0 && amount <= 999999.99;
    print('🔍 Validação: "$formattedText" -> $amount -> válido: $isValid');
    return isValid;
  }

  /// ✅ EXTRAIR APENAS NÚMEROS DO TEXTO
  static String extractDigits(String text) {
    return text.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// ✅ VERIFICAR SE É FORMATO MONETÁRIO BRASILEIRO
  static bool isBrazilianFormat(String text) {
    // R$ 1.234,56 ou 1.234,56
    return RegExp(r'^R\$?\s*\d{1,3}(\.\d{3})*,\d{2}$').hasMatch(text.trim());
  }

  /// ✅ VERIFICAR SE É FORMATO MONETÁRIO AMERICANO
  static bool isAmericanFormat(String text) {
    // $1,234.56 ou 1,234.56
    return RegExp(r'^\$?\s*\d{1,3}(,\d{3})*\.\d{2}$').hasMatch(text.trim());
  }

  /// ✅ NORMALIZAR DIFERENTES FORMATOS PARA PADRÃO BRASILEIRO
  static String normalizeToBrazilianFormat(String text) {
    try {
      final amount = parseAmount(text);
      return formatAmount(amount);
    } catch (e) {
      print('❌ Erro ao normalizar "$text": $e');
      return 'R\$ 0,00';
    }
  }

  /// ✅ CONVERTER CENTAVOS PARA REAIS
  static double centavosToReais(int centavos) {
    return centavos / 100.0;
  }

  /// ✅ CONVERTER REAIS PARA CENTAVOS
  static int reaisToCentavos(double reais) {
    return (reais * 100).round();
  }

  /// ✅ FORMATAÇÃO COMPACTA (SEM SÍMBOLO)
  static String formatAmountCompact(double amount) {
    try {
      if (amount.isNaN || amount.isInfinite || amount < 0) {
        return '0,00';
      }
      
      return amount.toStringAsFixed(2).replaceAll('.', ',');
    } catch (e) {
      print('❌ Erro na formatação compacta: $e');
      return '0,00';
    }
  }

  /// ✅ PARSING DE VALOR COM DIFERENTES SEPARADORES
  static double parseFlexible(String text) {
    if (text.trim().isEmpty) return 0.0;
    
    try {
      // Tentar diferentes formatos
      final formats = [
        text,                                    // Original
        text.replaceAll(',', '.'),              // Vírgula -> ponto
        text.replaceAll('.', ''),               // Remover pontos
        text.replaceAll(',', '').replaceAll('.', ''), // Limpar tudo
      ];
      
      for (final format in formats) {
        final cleaned = format.replaceAll(RegExp(r'[^\d\.]'), '');
        if (cleaned.isNotEmpty) {
          final value = double.tryParse(cleaned);
          if (value != null && value >= 0 && !value.isNaN && !value.isInfinite) {
            return value;
          }
        }
      }
      
      return 0.0;
    } catch (e) {
      print('❌ Erro no parsing flexível: $e');
      return 0.0;
    }
  }

  /// ✅ MÉTODO DE TESTE PARA VALIDAR CONVERSÕES
  static Map<String, double> testConversions() {
    final testCases = {
      'R\$ 1,00': 1.0,
      'R\$ 10,50': 10.5,
      'R\$ 100,99': 100.99,
      'R\$ 1.000,00': 1000.0,
      'R\$ 1.234,56': 1234.56,
      '1,50': 1.5,
      '123,45': 123.45,
      '1.000,00': 1000.0,
      '0,01': 0.01,
      '': 0.0,
      'abc': 0.0,
    };
    
    final results = <String, double>{};
    
    print('🧪 Testando conversões do MoneyInputFormatter:');
    for (final entry in testCases.entries) {
      final input = entry.key;
      final expected = entry.value;
      final result = parseAmount(input);
      final isCorrect = (result - expected).abs() < 0.001;
      
      results[input] = result;
      
      print('   "$input" -> $result (esperado: $expected) ${isCorrect ? "✅" : "❌"}');
    }
    
    return results;
  }
}