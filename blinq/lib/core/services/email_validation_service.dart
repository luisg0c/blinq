// lib/core/services/email_validation_service.dart - VERSÃO CORRIGIDA

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailValidationResult {
  final bool isValid;
  final bool userExists;
  final String? userName;
  final String? userId;
  final String? errorMessage;

  EmailValidationResult({
    required this.isValid,
    required this.userExists,
    this.userName,
    this.userId,
    this.errorMessage,
  });

  factory EmailValidationResult.invalid(String error) {
    return EmailValidationResult(
      isValid: false,
      userExists: false,
      errorMessage: error,
    );
  }

  factory EmailValidationResult.notFound() {
    return EmailValidationResult(
      isValid: true,
      userExists: false,
      errorMessage: 'Usuário não encontrado no Blinq',
    );
  }

  factory EmailValidationResult.found({
    required String userName,
    required String userId,
  }) {
    return EmailValidationResult(
      isValid: true,
      userExists: true,
      userName: userName,
      userId: userId,
    );
  }
}

class EmailValidationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ VALIDAÇÃO COMPLETA DE EMAIL PARA TRANSFERÊNCIA
  static Future<EmailValidationResult> validateRecipientEmail(String email) async {
    try {
      print('📧 Validando email do destinatário: $email');

      // 1. Validação de formato
      if (!_isValidEmailFormat(email)) {
        return EmailValidationResult.invalid('Formato de email inválido');
      }

      // 2. Verificar se não é o próprio usuário
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser?.email?.toLowerCase() == email.toLowerCase()) {
        return EmailValidationResult.invalid('Você não pode transferir para si mesmo');
      }

      // 3. Buscar usuário no Firestore
      final userResult = await _findUserInFirestore(email);
      return userResult;

    } catch (e) {
      print('❌ Erro na validação de email: $e');
      return EmailValidationResult.invalid('Erro ao verificar destinatário');
    }
  }

  /// ✅ VALIDAÇÃO DE FORMATO DE EMAIL
  static bool _isValidEmailFormat(String email) {
    if (email.trim().isEmpty) return false;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    return emailRegex.hasMatch(email.trim().toLowerCase());
  }

  /// ✅ BUSCAR USUÁRIO NO FIRESTORE
  static Future<EmailValidationResult> _findUserInFirestore(String email) async {
    try {
      print('🔍 Buscando no Firestore: $email');

      final snapshot = await _firestore
          .collection('accounts')
          .where('user.email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();
        final userData = data['user'] as Map<String, dynamic>? ?? {};

        final userName = userData['name']?.toString() ?? 'Usuário Blinq';
        final userId = doc.id;

        print('✅ Usuário encontrado no Firestore: $userName');

        return EmailValidationResult.found(
          userName: userName,
          userId: userId,
        );
      }

      return EmailValidationResult.notFound();
    } catch (e) {
      print('❌ Erro ao buscar no Firestore: $e');
      return EmailValidationResult.invalid('Erro ao verificar usuário');
    }
  }

  /// ✅ VALIDAÇÃO RÁPIDA APENAS DE FORMATO
  static bool isValidFormat(String email) {
    return _isValidEmailFormat(email);
  }
}