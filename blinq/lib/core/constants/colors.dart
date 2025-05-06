import 'package:flutter/material.dart';

/// Classe com as cores do aplicativo
class AppColors {
  // Evitar instanciação
  AppColors._();

  // Cores principais
  static const Color primary = Color(0xFF8AE0A1); // Verde claro (cabeçalho)
  static const Color primaryDark = Color(0xFF5AAD78); // Verde médio
  static const Color secondary = Color(0xFF26A27B); // Verde escuro
  static const Color accent = Color(0xFF8AE0A1); // Verde claro (destaque)

  // Cores de background
  static const Color background = Color(0xFF121212); // Preto principal
  static const Color cardBackground = Color(0xFF2C2C2C); // Cinza escuro (cards)
  static const Color surface = Color(0xFF1E1E1E); // Preto secundário

  // Cores de texto
  static const Color textLight =
      Color(0xFFFFFFFF); // Branco para texto principal
  static const Color textMedium =
      Color(0xFFCCCCCC); // Cinza claro para texto secundário
  static const Color textDark =
      Color(0xFF333333); // Texto escuro (em áreas claras)

  // Cores de status
  static const Color success = Color(0xFF8AE0A1); // Verde claro
  static const Color error = Color(0xFFFF5252); // Vermelho
  static const Color warning = Color(0xFFFFD740); // Amarelo
  static const Color info = Color(0xFF40C4FF); // Azul informativo

  // Cores de borda
  static const Color border = Color(0xFF2C2C2C); // Cinza escuro
  static const Color divider = Color(0xFF3A3A3A); // Cinza um pouco mais claro

  // Cores específicas de operações
  static const Color depositColor = Color(0xFF8AE0A1); // Verde para depósitos
  static const Color transferOutColor =
      Color(0xFFFF5252); // Vermelho para saídas
  static const Color transferInColor = Color(0xFF8AE0A1); // Verde para entradas
  static const Color investColor = Color(0xFF40C4FF); // Azul para investimentos

  // Cores para ícones
  static const Color iconBackground =
      Color(0xFF3A3A3A); // Fundo dos ícones circulares

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8AE0A1), // Verde claro
      Color(0xFF26A27B), // Verde escuro
    ],
  );

  // Cor do overlay (para telas de onboarding)
  static const Color overlay = Color(0x998AE0A1); // Verde semi-transparente
}
