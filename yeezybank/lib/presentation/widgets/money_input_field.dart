import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        prefixIcon: icon != null ? Icon(icon) : null,
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        // Feedback visual para valores inválidos
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }
}