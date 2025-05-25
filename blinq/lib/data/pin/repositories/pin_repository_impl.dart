// lib/data/pin/repositories/pin_repository_impl.dart - SOLUÇÃO DEFINITIVA

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../../../core/exceptions/app_exception.dart';
import '../../../domain/repositories/pin_repository.dart';

class PinRepositoryImpl implements PinRepository {
  static const _pinKey = 'blinq_pin_hash';
  final FlutterSecureStorage _storage;

  PinRepositoryImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> savePin(String pin) async {
    try {
      print('💾 Salvando PIN...');
      final hash = _hashPin(pin);
      await _storage.write(key: _pinKey, value: hash);
      print('✅ PIN salvo: ${hash.substring(0, 8)}...');
    } catch (e) {
      print('❌ Erro ao salvar PIN: $e');
      throw AppException('Erro ao salvar PIN');
    }
  }

  @override
  Future<bool> validatePin(String pin) async {
    try {
      print('🔍 Validando PIN...');
      final storedHash = await _storage.read(key: _pinKey);
      
      if (storedHash == null) {
        print('❌ PIN não encontrado no storage');
        return false;
      }
      
      final inputHash = _hashPin(pin);
      final isValid = inputHash == storedHash;
      
      print('Stored: ${storedHash.substring(0, 8)}...');
      print('Input:  ${inputHash.substring(0, 8)}...');
      print('Valid:  $isValid');
      
      return isValid;
    } catch (e) {
      print('❌ Erro na validação: $e');
      return false;
    }
  }

  @override
  Future<bool> hasPin() async {
    try {
      final hash = await _storage.read(key: _pinKey);
      final exists = hash != null && hash.isNotEmpty;
      print('📍 PIN existe: $exists');
      return exists;
    } catch (e) {
      print('❌ Erro ao verificar PIN: $e');
      return false;
    }
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode('blinq_$pin');
    return sha256.convert(bytes).toString();
  }
}