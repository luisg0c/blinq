// lib/data/pin/repositories/pin_repository_impl.dart - CORREÇÃO PARA STORAGE

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/exceptions/app_exception.dart';
import '../../../domain/repositories/pin_repository.dart';

class PinRepositoryImpl implements PinRepository {
  final FlutterSecureStorage _storage;
  
  // ✅ CHAVE FIXA PARA EVITAR PROBLEMAS DE USUÁRIO
  static const String _pinKey = 'blinq_user_pin_v3';
  
  // ✅ FALLBACK PARA CHAVE POR USUÁRIO SE NECESSÁRIO
  static String _getUserSpecificPinKey() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return 'blinq_pin_${user.uid}_v3';
      }
    } catch (e) {
      print('⚠️ Erro ao obter usuário para chave do PIN: $e');
    }
    return _pinKey; // Fallback para chave fixa
  }

  PinRepositoryImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
            resetOnError: true, // ✅ Reset em caso de erro
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
            synchronizable: false, // ✅ Não sincronizar no iCloud
          ),
        );

  @override
  Future<void> savePin(String pin) async {
    try {
      print('💾 Salvando PIN...');
      
      // ✅ VALIDAR PIN ANTES DE SALVAR
      if (!_isValidPin(pin)) {
        throw const AppException('PIN deve ter entre 4 e 6 dígitos numéricos');
      }

      // ✅ GERAR HASH SIMPLES E CONFIÁVEL
      final hash = _hashPin(pin);
      print('🔐 Hash gerado: ${hash.substring(0, 8)}...');
      
      // ✅ CRIAR DADOS SIMPLES PARA ARMAZENAR
      final pinData = {
        'hash': hash,
        'created_at': DateTime.now().toIso8601String(),
        'version': '3.0',
        'user_id': FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
      };
      
      final dataToStore = json.encode(pinData);
      print('📦 Dados para armazenar: ${dataToStore.length} caracteres');
      
      // ✅ TENTAR SALVAR COM MÚLTIPLAS ESTRATÉGIAS
      bool saved = false;
      
      // Estratégia 1: Chave fixa (mais confiável)
      try {
        await _storage.write(key: _pinKey, value: dataToStore);
        print('✅ PIN salvo com chave fixa: $_pinKey');
        saved = true;
      } catch (e) {
        print('⚠️ Falha ao salvar com chave fixa: $e');
      }
      
      // Estratégia 2: Chave específica do usuário (backup)
      try {
        final userKey = _getUserSpecificPinKey();
        await _storage.write(key: userKey, value: dataToStore);
        print('✅ PIN salvo com chave de usuário: $userKey');
        saved = true;
      } catch (e) {
        print('⚠️ Falha ao salvar com chave de usuário: $e');
      }
      
      if (!saved) {
        throw const AppException('Falha ao salvar PIN no storage seguro');
      }
      
      // ✅ VERIFICAR SE REALMENTE SALVOU
      await Future.delayed(const Duration(milliseconds: 200));
      final exists = await hasPin();
      if (!exists) {
        throw const AppException('PIN não foi salvo corretamente');
      }
      
      print('✅ PIN salvo e verificado com sucesso');

    } catch (e) {
      print('❌ Erro ao salvar PIN: $e');
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Erro interno ao salvar PIN: $e');
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

      // ✅ OBTER DADOS SALVOS COM MÚLTIPLAS ESTRATÉGIAS
      String? storedData;
      String? usedKey;
      
      // Estratégia 1: Tentar chave fixa primeiro
      try {
        storedData = await _storage.read(key: _pinKey);
        if (storedData != null && storedData.isNotEmpty) {
          usedKey = _pinKey;
          print('📖 PIN encontrado com chave fixa');
        }
      } catch (e) {
        print('⚠️ Erro ao ler com chave fixa: $e');
      }
      
      // Estratégia 2: Tentar chave específica do usuário
      if (storedData == null) {
        try {
          final userKey = _getUserSpecificPinKey();
          storedData = await _storage.read(key: userKey);
          if (storedData != null && storedData.isNotEmpty) {
            usedKey = userKey;
            print('📖 PIN encontrado com chave de usuário');
          }
        } catch (e) {
          print('⚠️ Erro ao ler com chave de usuário: $e');
        }
      }
      
      if (storedData == null || storedData.isEmpty) {
        print('❌ PIN não encontrado no storage');
        return false;
      }
      
      print('📖 Dados lidos do storage ($usedKey): ${storedData.length} caracteres');

      // ✅ PARSING SEGURO DOS DADOS
      Map<String, dynamic> pinData;
      try {
        pinData = json.decode(storedData);
        print('✅ Dados decodificados com sucesso');
      } catch (e) {
        print('❌ Dados do PIN corrompidos: $e');
        // Tentar limpar dados corrompidos
        await _clearCorruptedData();
        return false;
      }

      final storedHash = pinData['hash'] as String?;
      if (storedHash == null || storedHash.isEmpty) {
        print('❌ Hash do PIN não encontrado nos dados');
        return false;
      }
      
      // ✅ GERAR HASH DO PIN INFORMADO
      final inputHash = _hashPin(pin);
      final isValid = inputHash == storedHash;
      
      print('🔍 Validação do PIN:');
      print('   Hash armazenado: ${storedHash.substring(0, 8)}...');
      print('   Hash do input: ${inputHash.substring(0, 8)}...');
      print('   Resultado: $isValid');
      
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
      print('📍 Verificando se PIN existe...');
      
      // ✅ VERIFICAR COM MÚLTIPLAS ESTRATÉGIAS
      String? storedData;
      
      // Estratégia 1: Chave fixa
      try {
        storedData = await _storage.read(key: _pinKey);
        if (storedData != null && storedData.isNotEmpty) {
          print('📍 PIN encontrado com chave fixa');
        }
      } catch (e) {
        print('⚠️ Erro ao verificar chave fixa: $e');
      }
      
      // Estratégia 2: Chave específica do usuário
      if (storedData == null) {
        try {
          final userKey = _getUserSpecificPinKey();
          storedData = await _storage.read(key: userKey);
          if (storedData != null && storedData.isNotEmpty) {
            print('📍 PIN encontrado com chave de usuário');
          }
        } catch (e) {
          print('⚠️ Erro ao verificar chave de usuário: $e');
        }
      }
      
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
        if (exists) {
          print('   Criado em: ${pinData['created_at']}');
          print('   Versão: ${pinData['version']}');
        }
        return exists;
      } catch (e) {
        print('❌ Dados do PIN corrompidos durante verificação: $e');
        await _clearCorruptedData();
        return false;
      }

    } catch (e) {
      print('❌ Erro ao verificar PIN: $e');
      return false;
    }
  }

  /// ✅ HASH SIMPLES E CONFIÁVEL
  String _hashPin(String pin) {
    try {
      // ✅ USAR SALT FIXO E PREVISÍVEL PARA EVITAR PROBLEMAS
      final salt = 'blinq_pin_salt_v3';
      final saltedPin = '$salt$pin$salt';
      
      final bytes = utf8.encode(saltedPin);
      final hash = sha256.convert(bytes).toString();
      
      print('🔐 Hash gerado para PIN de ${pin.length} dígitos');
      return hash;
    } catch (e) {
      print('❌ Erro ao gerar hash: $e');
      throw Exception('Erro ao processar PIN');
    }
  }

  /// ✅ VALIDAÇÃO BÁSICA DO PIN
  bool _isValidPin(String pin) {
    if (pin.trim().isEmpty) return false;
    
    final cleanPin = pin.trim();
    
    // Deve ter entre 4 e 6 dígitos
    if (cleanPin.length < 4 || cleanPin.length > 6) return false;
    
    // Deve conter apenas números
    if (!RegExp(r'^\d+$').hasMatch(cleanPin)) return false;
    
    return true;
  }

  /// ✅ LIMPAR DADOS CORROMPIDOS
  Future<void> _clearCorruptedData() async {
    try {
      print('🧹 Limpando dados corrompidos...');
      
      await _storage.delete(key: _pinKey);
      
      try {
        final userKey = _getUserSpecificPinKey();
        await _storage.delete(key: userKey);
      } catch (e) {
        print('⚠️ Erro ao limpar chave de usuário: $e');
      }
      
      print('✅ Dados corrompidos removidos');
    } catch (e) {
      print('❌ Erro ao limpar dados corrompidos: $e');
    }
  }

  /// ✅ MÉTODO PARA MIGRAÇÃO/LIMPEZA MANUAL
  Future<void> clearPin() async {
    try {
      print('🧹 Removendo PIN manualmente...');
      
      await _storage.delete(key: _pinKey);
      
      try {
        final userKey = _getUserSpecificPinKey();
        await _storage.delete(key: userKey);
      } catch (e) {
        print('⚠️ Erro ao remover chave de usuário: $e');
      }
      
      print('✅ PIN removido');
    } catch (e) {
      print('❌ Erro ao remover PIN: $e');
    }
  }

  /// ✅ MÉTODO PARA DEBUG COMPLETO
  Future<Map<String, dynamic>> getDebugInfo() async {
    try {
      final fixedKeyData = await _storage.read(key: _pinKey);
      final userKey = _getUserSpecificPinKey();
      final userKeyData = await _storage.read(key: userKey);
      
      // Listar todas as chaves no storage
      final allKeys = await _storage.readAll();
      final blinqKeys = allKeys.keys.where((k) => k.contains('blinq')).toList();
      
      return {
        'fixedKey': _pinKey,
        'fixedKeyExists': fixedKeyData != null,
        'fixedKeyLength': fixedKeyData?.length ?? 0,
        'userKey': userKey,
        'userKeyExists': userKeyData != null,
        'userKeyLength': userKeyData?.length ?? 0,
        'allBlinqKeys': blinqKeys,
        'totalKeys': allKeys.length,
        'currentUser': FirebaseAuth.instance.currentUser?.uid,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// ✅ VERIFICAR INTEGRIDADE E TENTAR REPARAR
  Future<bool> verifyAndRepair() async {
    try {
      print('🔧 Verificando integridade do PIN...');
      
      final debugInfo = await getDebugInfo();
      print('📊 Debug info: $debugInfo');
      
      // Se temos dados mas hasPin() retorna false, há problema
      final hasData = debugInfo['fixedKeyExists'] == true || debugInfo['userKeyExists'] == true;
      final hasPinResult = await hasPin();
      
      if (hasData && !hasPinResult) {
        print('🔧 Detectado problema de integridade, tentando reparar...');
        await _clearCorruptedData();
        return false;
      }
      
      print('✅ Integridade verificada');
      return hasPinResult;
      
    } catch (e) {
      print('❌ Erro na verificação de integridade: $e');
      return false;
    }
  }

  /// ✅ MÉTODO DE TESTE PARA VALIDAR STORAGE
  Future<bool> testStorage() async {
    try {
      print('🧪 Testando storage...');
      
      const testKey = 'blinq_test_key';
      const testValue = 'test_value_123';
      
      // Testar escrita
      await _storage.write(key: testKey, value: testValue);
      print('✅ Escrita de teste realizada');
      
      // Testar leitura
      final readValue = await _storage.read(key: testKey);
      final writeReadOk = readValue == testValue;
      print('📖 Leitura de teste: $readValue (OK: $writeReadOk)');
      
      // Limpar teste
      await _storage.delete(key: testKey);
      print('🧹 Teste limpo');
      
      return writeReadOk;
      
    } catch (e) {
      print('❌ Erro no teste de storage: $e');
      return false;
    }
  }

  /// ✅ RESET COMPLETO DO PIN STORAGE
  Future<void> resetPinStorage() async {
    try {
      print('🔄 Resetando storage do PIN...');
      
      // Limpar todas as chaves relacionadas ao PIN
      final allKeys = await _storage.readAll();
      final pinKeys = allKeys.keys.where((k) => 
        k.contains('pin') || k.contains('blinq')).toList();
      
      for (final key in pinKeys) {
        try {
          await _storage.delete(key: key);
          print('🗑️ Removida chave: $key');
        } catch (e) {
          print('⚠️ Erro ao remover $key: $e');
        }
      }
      
      print('✅ Storage do PIN resetado');
      
    } catch (e) {
      print('❌ Erro ao resetar storage: $e');
    }
  }
}