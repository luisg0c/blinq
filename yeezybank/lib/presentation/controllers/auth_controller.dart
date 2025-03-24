import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;

  // Login
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Preencha todos os campos');
      return;
    }

    isLoading.value = true;
    try {
      await _authService.signIn(email, password);
      clearFields();
      Get.offAllNamed('/home');
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Cadastro
  Future<void> signup() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Preencha todos os campos');
      return;
    }

    isLoading.value = true;
    try {
      await _authService.signUp(email, password);
      clearFields();
      Get.offAllNamed('/home');
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.signOut();
    Get.offAllNamed('/welcome');
  }

  void clearFields() {
    emailController.clear();
    passwordController.clear();
  }

  void _showError(String message) {
    Get.snackbar('Erro', message, snackPosition: SnackPosition.BOTTOM);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
