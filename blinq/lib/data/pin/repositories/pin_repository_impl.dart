import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/exceptions/app_exception.dart';
import '../../../domain/repositories/pin_repository.dart';

class PinRepositoryImpl implements PinRepository {
  final FlutterSecureStorage _storage;
  
  // ✅ CHAVE ÚNICA POR USUÁRIO PARA EVITAR CONFLITOS
  static String _getPinKey() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }
    return 'blinq_pin_${user.uid}';
  }

  PinRepositoryImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        );

  @override
  Future<void> savePin(String pin) async {
    try {
      print('💾 Salvando PIN para usuário...');
      
      // ✅ VALIDAR PIN ANTES DE SALVAR
      if (!_isValidPin(pin)) {
        throw const AppException('PIN deve ter entre 4 e 6 dígitos numéricos');
      }

      // ✅ GERAR HASH SEGURO COM SALT ÚNICO POR USUÁRIO
      final hash = _hashPinSecurely(pin);
      final pinKey = _getPinKey();
      
      // ✅ SALVAR COM METADADOS PARA VALIDAÇÃO
      final pinData = {
        'hash': hash,
        'created_at': DateTime.now().toIso8601String(),
        'version': '2.0', // Para futuras migrações
      };
      
      await _storage.write(
        key: pinKey,
        value: json.encode(pinData),
      );
      
      print('✅ PIN salvo com segurança');
      
      // ✅ VERIFICAR SE REALMENTE SALVOU
      await Future.delayed(const Duration(milliseconds: 100));
      final saved = await hasPin();
      if (!saved) {
        throw const AppException('Falha ao verificar salvamento do PIN');
      }
      
      print('✅ Salvamento do PIN verificado');

    } catch (e) {
      print('❌ Erro ao salvar PIN: $e');
      if (e is AppException) {
        rethrow;
      }
      throw const AppException('Erro interno ao salvar PIN');
    }
  }

  @override
  Future<bool> validatePin(String pin) async {
    try {
      print('🔍 Validando PIN...');
      
      // ✅ VALIDAR FORMATO BÁSICO
      if (!_isValidPin(pin)) {
        print('❌ PIN com formato inválido');
        return false;
      }

      // ✅ OBTER DADOS SALVOS
      final pinKey = _getPinKey();
      final storedData = await _storage.read(key: pinKey);
      
      if (storedData == null || storedData.isEmpty) {
        print('❌ PIN não encontrado no storage');
        return false;
      }

      // ✅ PARSING SEGURO DOS DADOS
      Map<String, dynamic> pinData;
      try {
        pinData = json.decode(storedData);
      } catch (e) {
        print('❌ Dados do PIN corrompidos: $e');
        return false;
      }

      final storedHash = pinData['hash'] as String?;
      if (storedHash == null || storedHash.isEmpty) {
        print('❌ Hash do PIN não encontrado');
        return false;
      }
      
      // ✅ GERAR HASH DO PIN INFORMADO
      final inputHash = _hashPinSecurely(pin);
      final isValid = inputHash == storedHash;
      
      // ✅ LOG DETALHADO PARA DEBUG (SEM EXPOR DADOS SENSÍVEIS)
      print('🔍 Validação do PIN:');
      print('   Hash stored length: ${storedHash.length}');
      print('   Hash input length: ${inputHash.length}');
      print('   Match: $isValid');
      
      if (isValid) {
        print('✅ PIN válido!');
      } else {
        print('❌ PIN inválido');
      }
      
      return isValid;

    } catch (e) {
      print('❌ Erro na validação do PIN: $e');
      return false;
    }
  }

  @override
  Future<bool> hasPin() async {
    try {
      final pinKey = _getPinKey();
      final storedData = await _storage.read(key: pinKey);
      
      if (storedData == null || storedData.isEmpty) {
        print('📍 PIN não existe');
        return false;
      }

      // ✅ VERIFICAR SE OS DADOS ESTÃO ÍNTEGROS
      try {
        final pinData = json.decode(storedData);
        final hash = pinData['hash'] as String?;
        final exists = hash != null && hash.isNotEmpty;
        
        print('📍 PIN existe: $exists');
        return exists;
      } catch (e) {
        print('❌ Dados do PIN corrompidos: $e');
        // Remover dados corrompidos
        await _storage.delete(key: pinKey);
        return false;
      }

    } catch (e) {
      print('❌ Erro ao verificar PIN: $e');
      return false;
    }
  }

  /// ✅ HASH SEGURO COM SALT BASEADO NO USUÁRIO
  String _hashPinSecurely(String pin) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado para hash do PIN');
    }

    // ✅ USAR UID + EMAIL + CONSTANTE COMO SALT
    final salt = 'blinq_secure_${user.uid}_${user.email ?? 'no_email'}_v2';
    final saltedPin = '$salt$pin$salt'; // PIN no meio do salt
    
    final bytes = utf8.encode(saltedPin);
    final hash = sha256.convert(bytes).toString();
    
    // ✅ HASH DUPLO PARA MAIOR SEGURANÇA
    final finalBytes = utf8.encode('$hash$salt');
    return sha256.convert(finalBytes).toString();
  }

  /// ✅ VALIDAÇÃO RIGOROSA DO PIN
  bool _isValidPin(String pin) {
    if (pin.trim().isEmpty) return false;
    
    final cleanPin = pin.trim();
    
    // Deve ter entre 4 e 6 dígitos
    if (cleanPin.length < 4 || cleanPin.length > 6) return false;
    
    // Deve conter apenas números
    if (!RegExp(r'^\d+$').hasMatch(cleanPin)) return false;
    
    // Não pode ser sequencial (1234, 5678, etc.)
    if (_isSequentialPin(cleanPin)) return false;
    
    // Não pode ser repetitivo (1111, 2222, etc.)
    if (_isRepetitivePin(cleanPin)) return false;
    
    return true;
  }

  /// ✅ VERIFICAR SE PIN É SEQUENCIAL
  bool _isSequentialPin(String pin) {
    if (pin.length < 4) return false;
    
    // Verificar sequência crescente
    bool isAscending = true;
    bool isDescending = true;
    
    for (int i = 1; i < pin.length; i++) {
      final current = int.parse(pin[i]);
      final previous = int.parse(pin[i - 1]);
      
      if (current != previous + 1) isAscending = false;
      if (current != previous - 1) isDescending = false;
    }
    
    return isAscending || isDescending;
  }

  /// ✅ VERIFICAR SE PIN É REPETITIVO
  bool _isRepetitivePin(String pin) {
    if (pin.length < 4) return false;
    
    final firstDigit = pin[0];
    return pin.split('').every((digit) => digit == firstDigit);
  }

  /// ✅ MÉTODO PARA MIGRAÇÃO/LIMPEZA
  Future<void> clearPin() async {
    try {
      final pinKey = _getPinKey();
      await _storage.delete(key: pinKey);
      print('🧹 PIN removido');
    } catch (e) {
      print('❌ Erro ao remover PIN: $e');
    }
  }

  /// ✅ MÉTODO PARA DEBUG (SEM EXPOR DADOS SENSÍVEIS)
  Future<Map<String, dynamic>> getDebugInfo() async {
    try {
      final pinKey = _getPinKey();
      final storedData = await _storage.read(key: pinKey);
      
      if (storedData == null) {
        return {'hasPin': false, 'pinKey': pinKey};
      }

      final pinData = json.decode(storedData);
      return {
        'hasPin': true,
        'pinKey': pinKey,
        'createdAt': pinData['created_at'],
        'version': pinData['version'],
        'hashLength': (pinData['hash'] as String?)?.length ?? 0,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// ✅ VERIFICAR INTEGRIDADE DOS DADOS
  Future<bool> verifyIntegrity() async {
    try {
      final pinKey = _getPinKey();
      final storedData = await _storage.read(key: pinKey);
      
      if (storedData == null) return true; // Sem PIN é válido
      
      final pinData = json.decode(storedData);
      final hash = pinData['hash'] as String?;
      final createdAt = pinData['created_at'] as String?;
      
      // Verificar se tem dados essenciais
      if (hash == null || hash.isEmpty) return false;
      if (createdAt == null || createdAt.isEmpty) return false;
      
      // Verificar se hash tem tamanho esperado (SHA256 = 64 chars)
      if (hash.length != 64) return false;
      
      return true;
    } catch (e) {
      print('❌ Erro na verificação de integridade: $e');
      return false;
    }
  }
}