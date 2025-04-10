import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class MoneyInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final String? hint;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const MoneyInputField({
    Key? key,
    required this.controller,
    this.label = 'Valor (R\$)',
    this.icon = Icons.attach_money,
    this.hint = '0.00',
    this.focusNode,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      onChanged: onChanged,
      validator: validator,
      // Formata apenas dígitos e até um ponto decimal com 2 casas
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, color: AppColors.textColor) : null,
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textColor, fontSize: 16),
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.subtitle, fontSize: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dividerColor),
        ),
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
        fillColor: AppColors.surface,
        errorStyle: const TextStyle(color: AppColors.error, fontSize: 14),
      ),
    );
  }
}