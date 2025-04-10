import 'package:flutter/material.dart';
import 'package:yeezybank/presentation/theme/app_colors.dart';

class AppTextStyles {
  static const appBarTitle = TextStyle(
    color: AppColors.textColor,
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  static const body = TextStyle(
    color: AppColors.textColor,
    fontSize: 16,
  );

  static const subtitle = TextStyle(
    color: AppColors.subtitle,
    fontSize: 14,
  );

  static const card = TextStyle(
    color: Colors.white,
    fontSize: 16,
  );

  static const cardTitle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const quickAction = TextStyle(
    color: AppColors.subtitle,
    fontSize: 14,
  );

  static const sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );

  static const transactionValue = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.textColor,
  );

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
}