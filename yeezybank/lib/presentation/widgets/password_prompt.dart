import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Exibe dialog de senha para transações.
/// [isNew] define se é cadastro (true) ou validação (false).
Future<String?> promptPassword(
  BuildContext context, {
  bool isNew = false,
  String? title,
}) async {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder:
        (BuildContext context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ??
                        (isNew
                            ? 'Cadastre sua senha de transação'
                            : 'Digite sua senha de transação'),
                    style: AppTextStyles.title.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isNew
                        ? 'Esta senha será usada para autorizar depósitos e transferências'
                        : 'Confirme sua identidade para prosseguir com a operação',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.subtitle,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, digite uma senha';
                      }
                      if (isNew && value.length < 4) {
                        return 'A senha deve ter pelo menos 4 dígitos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(result: null),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: AppColors.textColor),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Validar se a senha não está vazia
                          if (formKey.currentState!.validate()) {
                            final password = controller.text.trim();
                            Get.back(result: password);
                          }
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
        ),
  );
}
