import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yeezybank/presentation/theme/app_colors.dart';
import 'package:yeezybank/presentation/theme/app_text_styles.dart';

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
        labelStyle: AppTextStyles.input,
        hintText: hint,
        hintStyle: AppTextStyles.input.copyWith(color: AppColors.subtitle),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.dividerColor),
        ),
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        fillColor: AppColors.surface,
        errorStyle: AppTextStyles.error,
      ),
    );
  }
}