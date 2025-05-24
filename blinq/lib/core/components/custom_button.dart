import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;
  final bool isPrimary;

  const CustomButton({
    super.key, // ✅ Corrigido: usar super parameter
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6EE1C6);
    // ✅ Removido: variável secondaryColor não usada

    final button = Container(
      height: 50,
      decoration: BoxDecoration(
        color: isPrimary ? primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isPrimary ? null : Border.all(
          color: primaryColor,
          width: 1.5,
        ),
        boxShadow: isPrimary && !isLoading ? [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.2), // ✅ Corrigido: withValues
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildContent(),
          ),
        ),
      ),
    );

    return fullWidth 
        ? SizedBox(width: double.infinity, child: button) 
        : button;
  }

  Widget _buildContent() {
    const primaryColor = Color(0xFF6EE1C6);
    final textColor = isPrimary ? Colors.white : primaryColor;

    if (isLoading) {
      return Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(textColor),
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: textColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Center(
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}