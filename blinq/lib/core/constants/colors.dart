import 'package:flutter/material.dart';

/// Classe com as cores do aplicativo
class AppColors {
  // Evitar instanciação
  AppColors._();
  
  // Cores principais
  static const Color primary = Color(0xFF037FFA);    // Azul brilhante
  static const Color primaryDark = Color(0xFF0266C7); // Azul escuro
  static const Color secondary = Color(0xFF00C8B8);  // Verde-água
  static const Color secondaryDark = Color(0xFF00A89B); // Verde-água escuro
  
  // Cores de background
  static const Color background = Color(0xFFF9FBFC);  // Cinza claro
  static const Color backgroundDark = Color(0xFF1A1F25); // Azul escuro acinzentado
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF242A32);  // Azul escuro acinzentado mais claro
  
  // Cores de texto
  static const Color textDark = Color(0xFF1A1F25);  // Quase preto
  static const Color textMedium = Color(0xFF646F7C); // Cinza médio
  static const Color textLight = Color(0xFFA1A8AF); // Cinza claro
  static const Color textDarkMode = Color(0xFFF0F0F0); // Branco levemente acinzentado
  
  // Cores de status
  static const Color success = Color(0xFF0FD186);  // Verde
  static const Color error = Color(0xFFFF4D4F);   // Vermelho
  static const Color warning = Color(0xFFFFAB49); // Laranja
  static const Color info = Color(0xFF2D9CDB);    // Azul informativo
  
  // Cores de borda
  static const Color border = Color(0xFFEAEFF2);  // Cinza muito claro
  static const Color borderDark = Color(0xFF2D333A); // Cinza escuro
  
  // Cores de gradiente
  static const List<Color> primaryGradient = [
    Color(0xFF037FFA),  // Azul principal
    Color(0xFF02B5FA),  // Azul mais claro
  ];
  
  // Cores para gráficos
  static const List<Color> chartColors = [
    primary, 
    secondary, 
    Color(0xFFF6C651), // Amarelo
    Color(0xFFFF8F00), // Laranja
    Color(0xFFFF4D4F), // Vermelho
    Color(0xFF8676FF), // Roxo
  ];
  
  // Cores de estado de transação
  static const Color depositColor = Color(0xFF0FD186); // Verde para depósitos
  static const Color transferInColor = Color(0xFF0FD186); // Verde para transferências recebidas
  static const Color transferOutColor = Color(0xFFFF4D4F); // Vermelho para transferências enviadas
  static const Color pendingColor = Color(0xFFFFAB49); // Laranja para transações pendentes
}