import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeezybank/presentation/theme/app_colors.dart';
import 'package:yeezybank/presentation/theme/app_text_styles.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.dividerColor.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _actionButton(
            icon: Icons.add,
            label: 'Depositar',
            route: '/deposit',
            context: context,
          ),
          _actionButton(
            icon: Icons.send,
            label: 'Transferir',
            route: '/transfer',
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required String route,
    required BuildContext context,
  }) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: () => Get.toNamed(route),
          icon: Icon(icon, size: 24, color: AppColors.primaryColor),
          style: IconButton.styleFrom(backgroundColor: AppColors.primaryColor.withOpacity(0.1),),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.button.copyWith(fontSize: 14, color: AppColors.textColor),),
      ),
    );
  }
}