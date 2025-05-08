import 'package:flutter/material.dart';

/// Classe com as cores do aplicativo
class AppColors {
  // Evitar instanciação
  AppColors._();

  // --- PALETA PRINCIPAL ---
  static const Color blinqGreen = Color(0xFF6EE1C6); // Seu verde principal
  static const Color blinqBlack = Color(0xFF0D1517); // Seu preto principal

  // --- TEMA CLARO (Light Theme) ---
  static const Color primaryLight =
      blinqGreen; // Verde como primário no tema claro
  static const Color secondaryLight =
      Color(0xFF50C878); // Um verde complementar mais escuro
  static const Color accentLight = blinqGreen;

  static const Color backgroundLight = Color(0xFFF5F5F5); // Quase branco
  static const Color surfaceLight = Colors.white; // Cards e superfícies brancas
  static const Color onPrimaryLight =
      Colors.black; // Texto sobre o verde primário
  static const Color onSecondaryLight =
      Colors.white; // Texto sobre o verde secundário
  static const Color onBackgroundLight =
      blinqBlack; // Texto principal sobre fundo claro
  static const Color onSurfaceLight =
      blinqBlack; // Texto sobre superfícies claras

  static const Color textDarkOnLight = blinqBlack; // Texto principal
  static const Color textMediumOnLight =
      Color(0xFF4A4A4A); // Cinza escuro para subtextos
  static const Color textLightOnLight =
      Color(0xFF787878); // Cinza médio para hints

  static const Color borderLight = Color(0xFFD0D0D0); // Cinza claro para bordas
  static const Color dividerLight =
      Color(0xFFE0E0E0); // Cinza muito claro para divisores

  // --- TEMA ESCURO (Dark Theme) ---
  static const Color primaryDark =
      blinqGreen; // Verde como primário no tema escuro também
  static const Color secondaryDark = Color(0xFF50C878); // Verde complementar
  static const Color accentDark = blinqGreen;

  static const Color backgroundDark = blinqBlack; // Preto principal
  static const Color surfaceDark =
      Color(0xFF1A2427); // Cinza muito escuro para cards/superfícies
  static const Color surfaceDarkVariant =
      Color(0xFF1F292C); // Variação para inputs, etc.
  static const Color onPrimaryDark =
      Colors.black; // Texto sobre o verde primário
  static const Color onSecondaryDark =
      Colors.black; // Texto sobre o verde secundário
  static const Color onBackgroundDark =
      Colors.white; // Texto principal sobre fundo escuro
  static const Color onSurfaceDark =
      Colors.white; // Texto sobre superfícies escuras

  static const Color textWhiteOnDark = Colors.white; // Texto principal
  static const Color textMediumOnDark =
      Color(0xFFCCCCCC); // Cinza claro para subtextos
  static const Color textHintOnDark = Color(0xFFA0A0A0); // Cinza para hints

  static const Color borderDark = Color(0xFF2C3A3F); // Cinza escuro para bordas
  static const Color dividerDark =
      Color(0xFF2C3A3F); // Mesma cor da borda ou um pouco diferente

  // --- CORES DE STATUS (Unificadas ou específicas por tema) ---
  static const Color success =
      Color(0xFF6EE1C6); // Verde (pode ser o blinqGreen)
  static const Color error = Color(0xFFFF5252); // Vermelho (mantido)
  static const Color errorDark =
      Color(0xFFCF6679); // Vermelho mais suave para tema escuro
  static const Color warning = Color(0xFFFFD740); // Amarelo (mantido)
  static const Color info = Color(0xFF40C4FF); // Azul (mantido)

  // --- CORES ESPECÍFICAS DE OPERAÇÕES (Podem usar cores da paleta) ---
  static const Color depositColor = success;
  static const Color transferOutColor = error;
  static const Color transferInColor = success;
  static const Color investColor = info;

  // --- CORES PARA ÍCONES ---
  static const Color iconBackgroundLight = Color(0xFFE0E0E0);
  static const Color iconBackgroundDark =
      Color(0xFF2C3A3F); // Mesma cor da borda escura

  // --- GRADIENTES ---
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      blinqGreen, // Verde principal
      Color(0xFF50C878), // Verde complementar
    ],
  );

  // --- OUTRAS ---
  static const Color overlay = Color(0x996EE1C6); // Verde semi-transparente
}
