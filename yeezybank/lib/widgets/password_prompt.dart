import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Exibe dialog de senha para transações.
/// [isNew] define se é cadastro (true) ou validação (false).
Future<String?> promptPassword(BuildContext context, {bool isNew = false}) async {
  final controller = TextEditingController();

  return await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(isNew ? 'Cadastre sua senha' : 'Digite sua senha'),
      content: TextField(
        controller: controller,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Senha',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: null),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: controller.text.trim()),
          child: const Text('Confirmar'),
        ),
      ],
    ),
  );
}
