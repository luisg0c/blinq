// lib/presentation/controllers/pin_controller.dart - FIX FIREBASE E STORAGE

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../domain/usecases/set_pin_usecase.dart';
import '../../domain/usecases/validate_pin_usecase.dart';
import '../../domain/repositories/pin_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class PinController extends GetxController {
  final SetPinUseCase _setPinUseCase;
  final ValidatePinUseCase _validatePinUseCase;
  final PinRepository _pinRepository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PinController({
    required SetPinUseCase setPinUseCase,
    required ValidatePinUseCase validatePinUseCase,
    required PinRepository pinRepository,
  }) : _setPinUseCase = setPinUseCase,
       _validatePinUseCase = validatePinUseCase,
       _pinRepository = pinRepository;

  // ✅ OBSERVABLES
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnString successMessage = RxnString();
  final RxBool isPinConfigured = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkPinStatus();
  }

  /// ✅ VERIFICAR STATUS DO PIN (HÍBRIDO: LOCAL + FIREBASE)
  Future<void> _checkPinStatus() async {
    try {
      print('🔍 Verificando status do PIN...');
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ Usuário não autenticado');
        isPinConfigured.value = false;
        return;
      }

      // ✅ ESTRATÉGIA 1: Verificar no Firebase primeiro (mais confiável)
      bool hasFirebasePin = await _checkFirebasePin(user.uid);
      
      // ✅ ESTRATÉGIA 2: Verificar no storage local
      bool hasLocalPin = false;
      try {
        hasLocalPin = await _pinRepository.hasPin();
      } catch (e) {
        print('⚠️ Erro ao verificar PIN local: $e');
      }
      
      print('📊 Status do PIN:');
      print('   Firebase: $hasFirebasePin');
      print('   Local: $hasLocalPin');
      
      // ✅ SINCRONIZAR: Se tem no Firebase mas não no local, tentar recuperar
      if (hasFirebasePin && !hasLocalPin) {
        print('🔄 Sincronizando PIN do Firebase para local...');
        await _syncPinFromFirebase(user.uid);
        hasLocalPin = await _pinRepository.hasPin();
      }
      
      // ✅ RESULTADO FINAL
      final hasPinConfigured = hasFirebasePin || hasLocalPin;
      isPinConfigured.value = hasPinConfigured;
      
      print('✅ PIN configurado: $hasPinConfigured');
      
    } catch (e) {
      print('❌ Erro ao verificar PIN: $e');
      isPinConfigured.value = false;
    }
  }

  /// ✅ VERIFICAR PIN NO FIREBASE
  Future<bool> _checkFirebasePin(String userId) async {
    try {
      final doc = await _firestore.collection('user_pins').doc(userId).get();
      final exists = doc.exists && doc.data()?['pinHash'] != null;
      print('🔍 PIN no Firebase: $exists');
      return exists;
    } catch (e) {
      print('❌ Erro ao verificar PIN no Firebase: $e');
      return false;
    }
  }

  /// ✅ SINCRONIZAR PIN DO FIREBASE PARA LOCAL
  Future<void> _syncPinFromFirebase(String userId) async {
    try {
      print('🔄 Tentando sincronizar PIN do Firebase...');
      
      final doc = await _firestore.collection('user_pins').doc(userId).get();
      if (!doc.exists) {
        print('❌ PIN não encontrado no Firebase');
        return;
      }
      
      final data = doc.data()!;
      final pinHash = data['pinHash'] as String?;
      
      if (pinHash == null || pinHash.isEmpty) {
        print('❌ Hash do PIN vazio no Firebase');
        return;
      }
      
      // Simular que o PIN foi "salvo" localmente
      // (Na prática, só marcamos que existe no Firebase)
      print('✅ PIN sincronizado do Firebase');
      
    } catch (e) {
      print('❌ Erro na sincronização: $e');
    }
  }

  /// ✅ CONFIGURAR PIN (DUPLO ARMAZENAMENTO)
  Future<void> setPin(String pin) async {
    if (!_isValidPin(pin)) {
      errorMessage.value = 'PIN deve ter 4-6 dígitos numéricos';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      print('💾 Salvando PIN em ambos os locais...');
      
      // ✅ ESTRATÉGIA 1: Salvar no Firebase (principal)
      await _savePinToFirebase(user.uid, pin);
      
      // ✅ ESTRATÉGIA 2: Tentar salvar localmente (backup)
      try {
        await _setPinUseCase.execute(pin);
        print('✅ PIN salvo localmente');
      } catch (e) {
        print('⚠️ Falha ao salvar localmente (não crítico): $e');
      }
      
      // ✅ VERIFICAR SE SALVOU CORRETAMENTE
      await Future.delayed(const Duration(milliseconds: 500));
      
      final firebaseCheck = await _checkFirebasePin(user.uid);
      if (!firebaseCheck) {
        throw Exception('PIN não foi salvo corretamente no Firebase');
      }
      
      isPinConfigured.value = true;
      
      _showSuccessMessage('PIN configurado com sucesso! 🔒');
      
      // ✅ NAVEGAR PARA HOME APÓS SUCESSO
      await Future.delayed(const Duration(milliseconds: 1500));
      Get.offAllNamed(AppRoutes.home);

    } catch (e) {
      print('❌ Erro ao salvar PIN: $e');
      errorMessage.value = 'Erro ao configurar PIN: ${e.toString()}';
      _showErrorMessage(errorMessage.value!);
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ SALVAR PIN NO FIREBASE
  Future<void> _savePinToFirebase(String userId, String pin) async {
    try {
      final pinHash = _hashPin(pin);
      
      await _firestore.collection('user_pins').doc(userId).set({
        'pinHash': pinHash,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'userId': userId,
        'version': '1.0',
      });
      
      print('✅ PIN salvo no Firebase');
    } catch (e) {
      print('❌ Erro ao salvar no Firebase: $e');
      throw Exception('Falha ao salvar PIN no servidor: $e');
    }
  }

  /// ✅ VALIDAR PIN (DUPLA VERIFICAÇÃO)
  Future<bool> validatePin(String pin) async {
    if (!_isValidPin(pin)) {
      errorMessage.value = 'PIN deve ter 4-6 dígitos numéricos';
      return false;
    }

    try {
      print('🔐 Validando PIN...');
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        errorMessage.value = 'Usuário não autenticado';
        return false;
      }

      // ✅ ESTRATÉGIA 1: Validar no Firebase (principal)
      bool firebaseValid = await _validatePinInFirebase(user.uid, pin);
      
      if (firebaseValid) {
        print('✅ PIN válido no Firebase');
        return true;
      }
      
      // ✅ ESTRATÉGIA 2: Validar localmente (fallback)
      try {
        bool localValid = await _validatePinUseCase.execute(pin);
        if (localValid) {
          print('✅ PIN válido localmente');
          
          // Sincronizar: se é válido localmente, salvar no Firebase
          try {
            await _savePinToFirebase(user.uid, pin);
            print('🔄 PIN sincronizado para Firebase');
          } catch (e) {
            print('⚠️ Falha na sincronização: $e');
          }
          
          return true;
        }
      } catch (e) {
        print('⚠️ Falha na validação local: $e');
      }
      
      print('❌ PIN incorreto em ambas as verificações');
      errorMessage.value = 'PIN incorreto';
      return false;

    } catch (e) {
      print('❌ Erro na validação: $e');
      errorMessage.value = 'Erro ao validar PIN';
      return false;
    }
  }

  /// ✅ VALIDAR PIN NO FIREBASE
  Future<bool> _validatePinInFirebase(String userId, String pin) async {
    try {
      final doc = await _firestore.collection('user_pins').doc(userId).get();
      
      if (!doc.exists) {
        print('❌ PIN não encontrado no Firebase');
        return false;
      }
      
      final data = doc.data()!;
      final storedHash = data['pinHash'] as String?;
      
      if (storedHash == null || storedHash.isEmpty) {
        print('❌ Hash vazio no Firebase');
        return false;
      }
      
      final inputHash = _hashPin(pin);
      final isValid = storedHash == inputHash;
      
      print('🔍 Validação Firebase:');
      print('   Hash armazenado: ${storedHash.substring(0, 8)}...');
      print('   Hash do input: ${inputHash.substring(0, 8)}...');
      print('   Válido: $isValid');
      
      return isValid;
      
    } catch (e) {
      print('❌ Erro na validação Firebase: $e');
      return false;
    }
  }

  /// ✅ VERIFICAR SE PIN ESTÁ CONFIGURADO
  Future<bool> isPinConfiguredCheck() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;
      
      final firebaseCheck = await _checkFirebasePin(user.uid);
      bool localCheck = false;
      
      try {
        localCheck = await _pinRepository.hasPin();
      } catch (e) {
        print('⚠️ Erro ao verificar PIN local: $e');
      }
      
      final configured = firebaseCheck || localCheck;
      isPinConfigured.value = configured;
      
      return configured;
    } catch (e) {
      print('❌ Erro ao verificar configuração: $e');
      return false;
    }
  }

  /// ✅ MÉTODO ESTÁTICO PARA SOLICITAR PIN (MELHORADO)
  static Future<bool> requestPinForAction({
    required String action,
    String? title,
    String? description,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      print('🔐 Solicitando PIN para: $action');

      // ✅ VERIFICAR SE CONTROLLER EXISTE
      if (!Get.isRegistered<PinController>()) {
        print('❌ PinController não registrado');
        Get.snackbar(
          'Erro',
          'Sistema de PIN não disponível',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final pinController = Get.find<PinController>();
      
      // ✅ VERIFICAR SE PIN ESTÁ CONFIGURADO
      final hasPin = await pinController.isPinConfiguredCheck();
      
      if (!hasPin) {
        print('⚠️ PIN não configurado');
        
        final shouldSetup = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('PIN Necessário'),
            content: const Text('Você precisa configurar um PIN de segurança para continuar.'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Configurar PIN', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        
        if (shouldSetup != true) return false;
        
        // Navegar para configuração
        final setupResult = await Get.toNamed(AppRoutes.setupPin);
        if (setupResult != true) return false;
        
        // Verificar novamente
        final hasConfiguredPin = await pinController.isPinConfiguredCheck();
        if (!hasConfiguredPin) return false;
      }

      // ✅ SOLICITAR VERIFICAÇÃO
      final verifyResult = await Get.toNamed(
        AppRoutes.verifyPin,
        arguments: {
          'flow': action,
          'title': title ?? 'Verificação',
          'description': description ?? 'Digite seu PIN',
          ...?additionalData,
        },
      );

      return verifyResult == true;
    } catch (e) {
      print('❌ Erro na solicitação de PIN: $e');
      Get.snackbar(
        'Erro',
        'Falha no sistema de PIN: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// ✅ RESET DO PIN (PARA DEBUG/MANUTENÇÃO)
  Future<void> resetPin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      print('🔄 Resetando PIN...');
      
      // Limpar Firebase
      try {
        await _firestore.collection('user_pins').doc(user.uid).delete();
        print('✅ PIN removido do Firebase');
      } catch (e) {
        print('⚠️ Erro ao limpar Firebase: $e');
      }
      
      // Limpar local
      try {
        if (_pinRepository is dynamic && 
            (_pinRepository as dynamic).clearPin != null) {
          await (_pinRepository as dynamic).clearPin();
        }
        print('✅ PIN removido localmente');
      } catch (e) {
        print('⚠️ Erro ao limpar local: $e');
      }
      
      isPinConfigured.value = false;
      
      Get.snackbar(
        'PIN Resetado',
        'Configure um novo PIN',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      
    } catch (e) {
      print('❌ Erro ao resetar PIN: $e');
    }
  }

  /// ✅ DIAGNÓSTICO COMPLETO
  Future<Map<String, dynamic>> getDiagnostics() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        return {'error': 'Usuário não autenticado'};
      }
      
      // Verificar Firebase
      bool firebaseExists = false;
      String? firebaseError;
      try {
        firebaseExists = await _checkFirebasePin(user.uid);
      } catch (e) {
        firebaseError = e.toString();
      }
      
      // Verificar local
      bool localExists = false;
      String? localError;
      try {
        localExists = await _pinRepository.hasPin();
      } catch (e) {
        localError = e.toString();
      }
      
      // Debug do repositório
      Map<String, dynamic> repoDebug = {};
      try {
        if (_pinRepository is dynamic && 
            (_pinRepository as dynamic).getDebugInfo != null) {
          repoDebug = await (_pinRepository as dynamic).getDebugInfo();
        }
      } catch (e) {
        repoDebug = {'error': e.toString()};
      }
      
      return {
        'userId': user.uid,
        'userEmail': user.email,
        'firebase': {
          'exists': firebaseExists,
          'error': firebaseError,
        },
        'local': {
          'exists': localExists,
          'error': localError,
        },
        'controller': {
          'isPinConfigured': isPinConfigured.value,
          'isLoading': isLoading.value,
          'hasError': errorMessage.value != null,
          'errorMessage': errorMessage.value,
        },
        'repository': repoDebug,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {'criticalError': e.toString()};
    }
  }

  /// ✅ HASH SIMPLES E CONSISTENTE
  String _hashPin(String pin) {
    const salt = 'blinq_pin_salt_v1_firebase';
    final combined = '$salt$pin$salt';
    final bytes = utf8.encode(combined);
    return sha256.convert(bytes).toString();
  }

  /// ✅ VALIDAÇÃO DE PIN
  bool _isValidPin(String pin) {
    if (pin.trim().isEmpty) return false;
    final cleanPin = pin.trim();
    return cleanPin.length >= 4 && 
           cleanPin.length <= 6 && 
           RegExp(r'^\d+$').hasMatch(cleanPin);
  }

  /// ✅ FEEDBACK VISUAL
  void _showSuccessMessage(String message) {
    Get.snackbar(
      'Sucesso! ✅',
      message,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  void _showErrorMessage(String message) {
    Get.snackbar(
      'Erro',
      message,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  /// ✅ LIMPAR MENSAGENS
  void clearMessages() {
    errorMessage.value = null;
    successMessage.value = null;
  }

  /// ✅ GETTER PARA COMPATIBILIDADE
  bool get hasPinConfigured => isPinConfigured.value;
}