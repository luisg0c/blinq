import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

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
              isNew ? 'Cadastre sua senha de transação' : 'Digite sua senha de transação',
              style: AppTextStyles.title.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              isNew
                  ? 'Esta senha será usada para autorizar depósitos e transferências'
                  : 'Confirme sua identidade para prosseguir com a operação',
              style: AppTextStyles.body.copyWith(color: AppColors.subtitle),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Senha de transação',
                hintText: isNew ? 'Crie sua senha' : 'Digite sua senha',
                labelStyle: AppTextStyles.subtitle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.dividerColor),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(result: null),
                  child: Text('Cancelar', style: TextStyle(color: AppColors.textColor)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // Validar se a senha não está vazia
                    final password = controller.text.trim();
                    if (password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, digite uma senha')),
                      );
                      return;
                    }
                    Get.back(result: password);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(isNew ? 'Cadastrar' : 'Confirmar'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}