import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../../../domain/repositories/pin_repository.dart';

/// Implementação de [PinRepository] usando armazenamento seguro local.
/// O PIN é armazenado com hash SHA-256 para não ser recuperável em texto puro.
class PinRepositoryImpl implements PinRepository {
  static const _pinKey = 'blinq_transaction_pin_hash';
  static const _pinSetKey = 'blinq_pin_configured';
  final FlutterSecureStorage _storage;

  PinRepositoryImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: IOSOptions(
            accessibility: IOSAccessibility.first_unlock_this_device,
          ),
        );

  /// Salva o hash do PIN.
  @override
  Future<void> savePin(String pin) async {
    try {
      if (pin.isEmpty || pin.length < 4 || pin.length > 6) {
        throw Exception('PIN deve ter entre 4 e 6 dígitos');
      }

      if (!RegExp(r'^\d+$').hasMatch(pin)) {
        throw Exception('PIN deve conter apenas números');
      }

      final hashed = _hashPin(pin);
      
      // Salvar hash do PIN
      await _storage.write(key: _pinKey, value: hashed);
      
      // Marcar como configurado
      await _storage.write(key: _pinSetKey, value: 'true');
      
      print('✅ PIN salvo com sucesso no secure storage');
    } catch (e) {
      print('❌ Erro ao salvar PIN: $e');
      rethrow;
    }
  }

  /// Compara o hash do PIN salvo com o hash do PIN informado.
  @override
  Future<bool> validatePin(String pin) async {
    try {
      if (pin.isEmpty) {
        return false;
      }

      final storedHash = await _storage.read(key: _pinKey);
      if (storedHash == null) {
        print('⚠️ PIN não encontrado no storage');
        return false;
      }

      final inputHash = _hashPin(pin);
      final isValid = storedHash == inputHash;
      
      print('🔐 Validação PIN: ${isValid ? "✅ Válido" : "❌ Inválido"}');
      return isValid;
    } catch (e) {
      print('❌ Erro ao validar PIN: $e');
      return false;
    }
  }

  /// Verifica se o PIN já foi configurado.
  @override
  Future<bool> hasPin() async {
    try {
      final pinConfigured = await _storage.read(key: _pinSetKey);
      final storedHash = await _storage.read(key: _pinKey);
      
      final hasPin = pinConfigured == 'true' && storedHash != null;
      print('📱 PIN configurado: ${hasPin ? "✅ Sim" : "❌ Não"}');
      
      return hasPin;
    } catch (e) {
      print('❌ Erro ao verificar PIN: $e');
      return false;
    }
  }

  /// Remove o PIN (útil para reset).
  Future<void> removePin() async {
    try {
      await _storage.delete(key: _pinKey);
      await _storage.delete(key: _pinSetKey);
      print('🗑️ PIN removido do storage');
    } catch (e) {
      print('❌ Erro ao remover PIN: $e');
    }
  }

  /// Gera hash SHA-256 do PIN.
  String _hashPin(String pin) {
    final salt = 'blinq_salt_2024'; // Salt fixo para consistência
    final saltedPin = pin + salt;
    final bytes = utf8.encode(saltedPin);
    return sha256.convert(bytes).toString();
  }

  /// Debug: Lista todas as chaves no storage (apenas para desenvolvimento).
  Future<void> debugStorage() async {
    try {
      final allKeys = await _storage.readAll();
      print('🔍 Storage Debug:');
      allKeys.forEach((key, value) {
        if (key.contains('pin')) {
          print('  $key: ${value.substring(0, 10)}...');
        }
      });
    } catch (e) {
      print('❌ Erro no debug: $e');
    }
  }
}