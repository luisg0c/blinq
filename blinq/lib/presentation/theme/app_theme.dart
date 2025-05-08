import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart'; // Certifique-se que este caminho está correto

/// Classe para gerenciar os temas do aplicativo
class AppTheme {
  // Construtor privado para evitar instanciação, se essa for a intenção.
  // Se você não precisa de um construtor, pode remover esta linha.
  AppTheme._();

  // Você pode definir TextStyles reutilizáveis aqui se desejar, por exemplo:
  static final TextStyle _poppinsHeadlineSmall = GoogleFonts.poppins(
    color: AppColors.textDark,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle _poppinsBodyMedium = GoogleFonts.poppins(
    color: AppColors.primary, // Cor para textos gerais da toolbar
    fontSize: 16, // Tamanho para textos gerais da toolbar
  );

  /// Tema claro
  static ThemeData get lightTheme {
    // Para usar TextTheme de forma mais organizada:
    final TextTheme baseTextTheme = GoogleFonts.poppinsTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        // Adicione outras cores do scheme se necessário
        background: AppColors.background,
        surface: Colors.white,
        error: AppColors.error,
        onBackground: AppColors.textDark,
        onSurface: AppColors.textDark,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        // Estilo para o título principal da AppBar
        titleTextStyle: baseTextTheme.headlineSmall?.copyWith(
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
          fontSize: 20, // Sobrescreve se necessário
        ),
        // Estilo para outros textos na AppBar (ex: actions)
        toolbarTextStyle: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      textTheme: baseTextTheme.copyWith(
        // Você pode customizar outros estilos de texto aqui
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: AppColors.textDark,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          color: AppColors.textDark,
        ),
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          color: AppColors.textDark,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.textDark,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.textDark,
        ), // Usado por ListTile, etc.
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: AppColors.textDark),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textDark,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.textMedium,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ), // Usado por botões
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: baseTextTheme.labelLarge?.copyWith(
            color: Colors.white, // Explicitamente para o texto do botão
            fontSize: 16,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          textStyle: baseTextTheme.labelLarge?.copyWith(
            color: AppColors.primary, // Explicitamente para o texto do botão
            fontSize: 16,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: baseTextTheme.labelLarge?.copyWith(
            color: AppColors.primary, // Explicitamente para o texto do botão
            fontSize: 16,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white, // Ou AppColors.surfaceLight se tiver
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textLight,
        ),
        labelStyle: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textMedium,
        ), // Estilo para o label flutuante
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white, // Ou AppColors.surfaceLight
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: baseTextTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: baseTextTheme.bodySmall,
        type: BottomNavigationBarType.fixed,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: Colors.white, // Ou AppColors.surfaceLight
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      // REMOVA QUALQUER 'toolbarTextStyle: ...' QUE ESTIVESSE DIRETAMENTE AQUI
      // A linha 121 original que causava o erro provavelmente estava aqui.
    );
  }

  /// Tema escuro
  static ThemeData get darkTheme {
    final TextTheme baseTextThemeDark = GoogleFonts.poppinsTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary, // Ou AppColors.primaryDark
        brightness: Brightness.dark,
        primary: AppColors.primaryDark,
        secondary: AppColors.background,
        background: AppColors.background,
        surface: AppColors.background, // Defina uma cor de superfície escura
        error: AppColors.iconBackground, // Defina uma cor de erro escura
        onPrimary: Colors.white, // Texto sobre a cor primária
        onSecondary: Colors.black, // Texto sobre a cor secundária
        onBackground: AppColors.background, // Texto sobre o background escuro
        onSurface: AppColors.primary, // Texto sobre a superfície escura
        onError: Colors.black, // Texto sobre a cor de erro
      ),
      scaffoldBackgroundColor: AppColors.primary,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.transferOutColor, // Ou backgroundDark
        elevation: 0,
        centerTitle: true,
        titleTextStyle: baseTextThemeDark.headlineSmall?.copyWith(
          color: AppColors.secondary,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        toolbarTextStyle: baseTextThemeDark.bodyMedium?.copyWith(
          color: AppColors.primary,
        ),
        iconTheme: const IconThemeData(color: AppColors.background),
      ),
      textTheme: baseTextThemeDark.copyWith(
        displayLarge: baseTextThemeDark.displayLarge?.copyWith(
          color: AppColors.background,
        ),
        displayMedium: baseTextThemeDark.displayMedium?.copyWith(
          color: AppColors.primary,
        ),
        // ... continue para outros estilos de texto para o tema escuro
        bodyMedium: baseTextThemeDark.bodyMedium?.copyWith(
          color: AppColors.secondary,
        ),
        labelLarge: baseTextThemeDark.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppColors.background,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white, // Ou a cor de texto apropriada
          elevation: 0,
          textStyle: baseTextThemeDark.labelLarge?.copyWith(
            color: Colors.white,
            fontSize: 16,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      // Defina outros temas de componentes para o darkTheme (OutlinedButton, TextButton, InputDecoration, etc.)
      // de forma similar ao lightTheme, mas usando as cores escuras.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors
            .surfaceDarkVariant, // Uma variação mais escura da superfície
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.background),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        hintStyle: baseTextThemeDark.bodyMedium?.copyWith(
          color: AppColors.background,
        ),
        labelStyle: baseTextThemeDark.bodyMedium?.copyWith(
          color: AppColors.secondary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.primary,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.accent,
        selectedLabelStyle: baseTextThemeDark.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: baseTextThemeDark.bodySmall,
        type: BottomNavigationBarType.fixed,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: AppColors.surfaceDark,
      ),
      dividerTheme: DividerThemeData(color: AppColors.borderDark, thickness: 1),
    );
  }
}
