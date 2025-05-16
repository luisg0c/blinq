import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../utils/formatters.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  const BalanceCard({
    Key? key,
    required this.balance,
    required this.isVisible,
    required this.onToggleVisibility,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo Disponível',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textLight,
                ),
              ),
              GestureDetector(
                onTap: onToggleVisibility,
                child: Icon(
                  isVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textLight,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onToggleVisibility,
            child: Text(
              isVisible ? Formatters.formatCurrency(balance) : 'R\$ •••••',
              style: GoogleFonts.lexend(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
