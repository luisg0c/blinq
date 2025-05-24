import 'package:flutter/material.dart';

/// Campo de texto customizado com borda arredondada, label e validação.
class CustomTextField extends StatelessWidget {
  /// Controlador do campo.
  final TextEditingController controller;

  /// Texto do label.
  final String labelText;

  /// Função de validação (pode ser nula).
  final String? Function(String?)? validator;

  /// Tipo de teclado (e-mail, número etc.).
  final TextInputType keyboardType;

  /// Se o texto deve ficar oculto (para senhas).
  final bool obscureText;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF6EE1C6);
    final borderRadius = BorderRadius.circular(8);

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
}