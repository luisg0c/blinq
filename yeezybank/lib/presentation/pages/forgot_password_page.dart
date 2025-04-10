import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recuperar senha', style: AppTextStyles.appBarTitle),
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textColor),
        ),
        backgroundColor: AppColors.backgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Informe seu e-mail para receber o link de redefinição de senha.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    hintText: 'seuemail@exemplo.com',
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.dividerColor),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, informe seu e-mail';
                    }
                    if (!value.contains('@')) {
                      return 'Informe um e-mail válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isLoading = true);
                      String email = _emailController.text.trim();
                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                        Get.snackbar(
                          'Sucesso',
                          'Link de redefinição de senha enviado para $email',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        Get.back();
                      } on FirebaseAuthException catch (e) {
                        Get.snackbar('Erro ao enviar e-mail', e.message ?? 'Tente novamente mais tarde', snackPosition: SnackPosition.BOTTOM);
                      } finally{
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.surface,
                    minimumSize: const Size(double.infinity, 50),
                    textStyle: AppTextStyles.button,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                      : const Text('Enviar link'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void setState(Null Function() param0) {}
}

                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: email,
                  );
                  Get.snackbar(
                    'Sucesso',
                    'Link de redefinição de senha enviado para $email',
                  );
                  Get.back();
                } catch (e) {
                  Get.snackbar('Erro ao enviar e-mail', e.toString());
                }
              },
              child: const Text('Enviar link'),
            ),
          ],
        ),
      ),
    );
  }
}
