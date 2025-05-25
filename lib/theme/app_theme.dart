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

  // Cores específicas para modo claro
  static const Color _lightBackground = Color(0xFFE5E5E5);
  static const Color _lightSurface = Color(0xFFE5E5E5);
  static const Color _lightHighlight = Color(0xFFFFFFFF);
  static const Color _lightShadowDark = Color(0xFFBEBEBE);
  
  // Cores específicas para modo escuro
  static const Color _darkBackground = Color(0xFF2C2C2C);
  static const Color _darkSurface = Color(0xFF2C2C2C);
  static const Color _darkHighlight = Color(0xFF3A3A3A);
  static const Color _darkShadowDark = Color(0xFF1A1A1A);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: _lightSurface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: _lightBackground,
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
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // Extensões customizadas para neomorfo
      extensions: <ThemeExtension<dynamic>>[
        NeomorphTheme.light(),
      ],
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: _darkSurface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: _darkBackground,
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
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkTextPrimary,
        titleTextStyle: _textTheme.titleLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // Extensões customizadas para neomorfo
      extensions: <ThemeExtension<dynamic>>[
        NeomorphTheme.dark(),
      ],
    );
  }
}

// Extensão de tema customizada para estilos neomorfo
class NeomorphTheme extends ThemeExtension<NeomorphTheme> {
  final Color backgroundColor;
  final Color surfaceColor;
  final Color highlightColor;
  final Color shadowDarkColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;

  const NeomorphTheme({
    required this.backgroundColor,
    required this.surfaceColor,
    required this.highlightColor,
    required this.shadowDarkColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
  });

  factory NeomorphTheme.light() {
    return const NeomorphTheme(
      backgroundColor: Color(0xFFE5E5E5),
      surfaceColor: Color(0xFFE5E5E5),
      highlightColor: Color(0xFFFFFFFF),
      shadowDarkColor: Color(0xFFBEBEBE),
      textPrimaryColor: AppColors.textPrimary,
      textSecondaryColor: AppColors.textSecondary,
    );
  }

  factory NeomorphTheme.dark() {
    return const NeomorphTheme(
      backgroundColor: Color(0xFF2C2C2C),
      surfaceColor: Color(0xFF2C2C2C),
      highlightColor: Color(0xFF3A3A3A),
      shadowDarkColor: Color(0xFF1A1A1A),
      textPrimaryColor: AppColors.darkTextPrimary,
      textSecondaryColor: AppColors.darkTextSecondary,
    );
  }

  @override
  NeomorphTheme copyWith({
    Color? backgroundColor,
    Color? surfaceColor,
    Color? highlightColor,
    Color? shadowDarkColor,
    Color? textPrimaryColor,
    Color? textSecondaryColor,
  }) {
    return NeomorphTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      highlightColor: highlightColor ?? this.highlightColor,
      shadowDarkColor: shadowDarkColor ?? this.shadowDarkColor,
      textPrimaryColor: textPrimaryColor ?? this.textPrimaryColor,
      textSecondaryColor: textSecondaryColor ?? this.textSecondaryColor,
    );
  }

  @override
  NeomorphTheme lerp(ThemeExtension<NeomorphTheme>? other, double t) {
    if (other is! NeomorphTheme) {
      return this;
    }
    return NeomorphTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t)!,
      highlightColor: Color.lerp(highlightColor, other.highlightColor, t)!,
      shadowDarkColor: Color.lerp(shadowDarkColor, other.shadowDarkColor, t)!,
      textPrimaryColor: Color.lerp(textPrimaryColor, other.textPrimaryColor, t)!,
      textSecondaryColor: Color.lerp(textSecondaryColor, other.textSecondaryColor, t)!,
    );
  }
}