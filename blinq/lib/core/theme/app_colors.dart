import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6EE1C6); // Verde Blinq
  static const Color secondary = Color(0xFF0D1517); // Preto Blinq
  
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  
  static const Color textPrimary = Color(0xFF0D1517);
  static const Color textSecondary = Color(0xFF6B7280);
  
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);
  
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);
  
  static const Color darkBackground = Color(0xFF0D1517);
  static const Color darkSurface = Color(0xFF1F2937);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkBorder = Color(0xFF374151);

  static const Color green = primary;
  static const Color black = secondary;
  static const Color white = Colors.white;
  static const Color grayLight = surface;
  static const Color red = error;
  static const Color greenPositive = success;
  
  static Color primaryWithAlpha(double alpha) => primary.withValues(alpha: alpha);
  static Color surfaceWithAlpha(double alpha) => surface.withValues(alpha: alpha);
  static Color errorWithAlpha(double alpha) => error.withValues(alpha: alpha);
  static Color successWithAlpha(double alpha) => success.withValues(alpha: alpha);
}