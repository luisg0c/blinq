import 'package:flutter/material.dart';

class AppColors {
  // Cor principal do app
  static const Color primary =
      Color(0xFF6EE1C6); // Verde-água que você mencionou

  // Cores de fundo
  static const Color background = Color(0xFFF5F5F5); // Cinza bem claro
  static const Color surface = Colors.white;

  // Cores de texto
  static const Color text = Color(0xFF0D1517);
  static const Color textLight = Color(0xFF787878);

  // Cores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFD740);
  static const Color info = Color(0xFF40C4FF);

  // Cores para uso especial
  static const Color depositColor = success;
  static const Color transferOutColor = error;
  static const Color transferInColor = success;
}

class AppTheme {
  // Tema da aplicação
  static ThemeData get theme => ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.primary,
          surface: AppColors.surface,
          background: AppColors.background,
          error: AppColors.error,
          onPrimary: AppColors.text,
          onSecondary: AppColors.text,
          onSurface: AppColors.text,
          onBackground: AppColors.text,
          onError: AppColors.surface,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.text,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: AppColors.surface,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.text,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            elevation: 2,
          ),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(color: AppColors.text),
          displayMedium: TextStyle(color: AppColors.text),
          displaySmall: TextStyle(color: AppColors.text),
          headlineLarge: TextStyle(color: AppColors.text),
          headlineMedium: TextStyle(color: AppColors.text),
          headlineSmall: TextStyle(color: AppColors.text),
          titleLarge: TextStyle(color: AppColors.text),
          titleMedium: TextStyle(color: AppColors.text),
          titleSmall: TextStyle(color: AppColors.text),
          bodyLarge: TextStyle(color: AppColors.text),
          bodyMedium: TextStyle(color: AppColors.text),
          bodySmall: TextStyle(color: AppColors.textLight),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.error, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      );
}
