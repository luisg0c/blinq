import 'package:flutter/material.dart';
import 'package:blinq/core/utils/money_input_formatter.dart';

class CustomMoneyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final void Function(String)? onChanged;

  const CustomMoneyField({
    Key? key,
    required this.controller,
    this.label = 'Valor (R\$)',
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [MoneyInputFormatter()],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
