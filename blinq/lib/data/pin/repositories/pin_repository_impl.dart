// lib/data/pin/repositories/pin_repository_impl.dart - VERSÃO CORRIGIDA

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../../../core/exceptions/app_exception.dart';
import '../../../domain/repositories/pin_repository.dart';

/// Implementação de [PinRepository] usando armazenamento seguro local.
class PinRepositoryImpl implements PinRepository {
  static const _pinKey = 'blinq_transaction_pin_hash';
  static const _pinSetKey = 'blinq_pin_configured';
  final FlutterSecureStorage _storage;

  PinRepositoryImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> savePin(String pin) async {
    try {
      print('💾 Salvando PIN...');
      final hash = _hashPin(pin);
      
      // Salvar hash do PIN e flag de configuração
      await _storage.write(key: _pinKey, value: hash);
      await _storage.write(key: _pinSetKey, value: 'true');
      
      print('✅ PIN salvo com sucesso');
    } catch (e) {
      print('❌ Erro ao salvar PIN: $e');
      throw AppException('Erro ao salvar PIN: ${e.toString()}');
    }
  }

  @override
  Future<bool> validatePin(String pin) async {
    try {
      print('🔍 Validando PIN...');
      
      // Verificar se PIN existe primeiro
      if (!await hasPin()) {
        print('❌ PIN não configurado');
        return false;
      }
      
      final storedHash = await _storage.read(key: _pinKey);
      if (storedHash == null || storedHash.isEmpty) {
        print('❌ Hash do PIN não encontrado');
        return false;
      }
      
      final inputHash = _hashPin(pin);
      final isValid = inputHash == storedHash;
      
      print(isValid ? '✅ PIN válido' : '❌ PIN inválido');
      return isValid;
    } catch (e) {
      print('❌ Erro ao validar PIN: $e');
      return false;
    }
  }

  @override
  Future<bool> hasPin() async {
    try {
      print('🔍 Verificando se PIN está configurado...');
      
      // Verificar flag de configuração
      final configured = await _storage.read(key: _pinSetKey);
      
      // Verificar se hash do PIN existe
      final pinHash = await _storage.read(key: _pinKey);
      
      // PIN está configurado se ambos os valores existem e são válidos
      final isConfigured = configured == 'true' && 
                          pinHash != null && 
                          pinHash.isNotEmpty;
      
      print('📍 Status do PIN:');
      print('   Flag configurado: $configured');
      print('   Hash existe: ${pinHash != null && pinHash.isNotEmpty}');
      print('   ✅ PIN configurado: $isConfigured');
      
      return isConfigured;
    } catch (e) {
      print('❌ Erro ao verificar PIN: $e');
      return false;
    }
  }

  /// ✅ MÉTODO PARA RESETAR PIN (desenvolvimento/debug)
  Future<void> resetPin() async {
    try {
      print('🗑️ Resetando PIN...');
      await _storage.delete(key: _pinKey);
      await _storage.delete(key: _pinSetKey);
      print('✅ PIN resetado');
    } catch (e) {
      print('❌ Erro ao resetar PIN: $e');
    }
  }

  /// ✅ VERIFICAR INTEGRIDADE DO PIN
  Future<bool> isPinIntegrityValid() async {
    try {
      final configured = await _storage.read(key: _pinSetKey);
      final pinHash = await _storage.read(key: _pinKey);
      
      if (configured == 'true' && (pinHash == null || pinHash.isEmpty)) {
        print('⚠️ Inconsistência detectada: flag=true mas hash=null');
        // Limpar estado inconsistente
        await _storage.delete(key: _pinSetKey);
        return false;
      }
      
      return true;
    } catch (e) {
      print('❌ Erro ao verificar integridade: $e');
      return false;
    }
  }

  /// Gerar hash seguro do PIN
  String _hashPin(String pin) {
    const salt = 'blinq_salt_2024_v2'; // Salt atualizado
    final bytes = utf8.encode(pin + salt);
    return sha256.convert(bytes).toString();
  }
}