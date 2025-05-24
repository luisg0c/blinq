import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AppTheme {
  // Tipografia Blinq
  static const String _fontFamily = 'Inter';
  
  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      fontFamily: _fontFamily,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      fontFamily: _fontFamily,
      letterSpacing: -0.5,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: _fontFamily,
      letterSpacing: -0.25,
    ),
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      fontFamily: _fontFamily,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      fontFamily: _fontFamily,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      fontFamily: _fontFamily,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      fontFamily: _fontFamily,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      fontFamily: _fontFamily,
    ),
    titleSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      fontFamily: _fontFamily,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      fontFamily: _fontFamily,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      fontFamily: _fontFamily,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      fontFamily: _fontFamily,
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      fontFamily: _fontFamily,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      fontFamily: _fontFamily,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      fontFamily: _fontFamily,
    ),
  );

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      textTheme: _textTheme.copyWith(
        displayLarge: _textTheme.displayLarge?.copyWith(color: AppColors.textPrimary),
        displayMedium: _textTheme.displayMedium?.copyWith(color: AppColors.textPrimary),
        displaySmall: _textTheme.displaySmall?.copyWith(color: AppColors.textPrimary),
        headlineLarge: _textTheme.headlineLarge?.copyWith(color: AppColors.textPrimary),
        headlineMedium: _textTheme.headlineMedium?.copyWith(color: AppColors.textPrimary),
        headlineSmall: _textTheme.headlineSmall?.copyWith(color: AppColors.textPrimary),
        titleLarge: _textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
        titleMedium: _textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
        titleSmall: _textTheme.titleSmall?.copyWith(color: AppColors.textSecondary),
        bodyLarge: _textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
        bodyMedium: _textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        bodySmall: _textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        labelLarge: _textTheme.labelLarge?.copyWith(color: AppColors.textPrimary),
        labelMedium: _textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
        labelSmall: _textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: _textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: _textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: _textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        hintStyle: _textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.surface,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        error: AppColors.error,
      ),
      textTheme: _textTheme.copyWith(
        displayLarge: _textTheme.displayLarge?.copyWith(color: AppColors.darkTextPrimary),
        displayMedium: _textTheme.displayMedium?.copyWith(color: AppColors.darkTextPrimary),
        displaySmall: _textTheme.displaySmall?.copyWith(color: AppColors.darkTextPrimary),
        headlineLarge: _textTheme.headlineLarge?.copyWith(color: AppColors.darkTextPrimary),
        headlineMedium: _textTheme.headlineMedium?.copyWith(color: AppColors.darkTextPrimary),
        headlineSmall: _textTheme.headlineSmall?.copyWith(color: AppColors.darkTextPrimary),
        titleLarge: _textTheme.titleLarge?.copyWith(color: AppColors.darkTextPrimary),
        titleMedium: _textTheme.titleMedium?.copyWith(color: AppColors.darkTextPrimary),
        titleSmall: _textTheme.titleSmall?.copyWith(color: AppColors.darkTextSecondary),
        bodyLarge: _textTheme.bodyLarge?.copyWith(color: AppColors.darkTextPrimary),
        bodyMedium: _textTheme.bodyMedium?.copyWith(color: AppColors.darkTextSecondary),
        bodySmall: _textTheme.bodySmall?.copyWith(color: AppColors.darkTextSecondary),
        labelLarge: _textTheme.labelLarge?.copyWith(color: AppColors.darkTextPrimary),
        labelMedium: _textTheme.labelMedium?.copyWith(color: AppColors.darkTextSecondary),
        labelSmall: _textTheme.labelSmall?.copyWith(color: AppColors.darkTextSecondary),
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
    );
  }
}