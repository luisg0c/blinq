import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/services/auth_service.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Erro', 'Preencha todos os campos');
      return;
    }

    try {
      await _authService.signIn(email, password);
      Get.snackbar('Sucesso', 'Login realizado!');
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Erro de login', e.toString());
    }
  }

  void signup() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Erro', 'Preencha todos os campos');
      return;
    }

    try {
      await _authService.signUp(email, password);
      Get.snackbar('Sucesso', 'Conta criada com sucesso!');
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Erro ao cadastrar', e.toString());
    }
  }
}
