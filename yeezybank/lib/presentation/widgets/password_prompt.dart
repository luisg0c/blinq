import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yeezybank/presentation/theme/app_colors.dart';
import 'package:yeezybank/presentation/theme/app_text_styles.dart';

/// Exibe dialog de senha para transações.
/// [isNew] define se é cadastro (true) ou validação (false).
Future<String?> promptPassword(BuildContext context, {bool isNew = false}) async {
  final controller = TextEditingController();

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isNew ? 'Cadastre sua senha' : 'Digite sua senha',
              style: AppTextStyles.title.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Senha',
                labelStyle: AppTextStyles.input,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(result: null),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => Get.back(result: controller.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    )),
                  child: const Text('Confirmar'),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
}
