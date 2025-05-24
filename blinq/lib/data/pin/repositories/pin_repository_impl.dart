import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../../../domain/repositories/pin_repository.dart';

/// Implementação simples de [PinRepository] usando armazenamento seguro local.
class PinRepositoryImpl implements PinRepository {
  static const _pinKey = 'blinq_transaction_pin_hash';
  static const _pinSetKey = 'blinq_pin_configured';
  final FlutterSecureStorage _storage;

  PinRepositoryImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> savePin(String pin) async {
    try {
      print('🔧 PinRepository: Iniciando savePin...');
      print('🔧 PIN recebido: ${pin.length} dígitos');
      
      if (pin.isEmpty || pin.length < 4 || pin.length > 6) {
        print('❌ PIN com tamanho inválido: ${pin.length}');
        throw Exception('PIN deve ter entre 4 e 6 dígitos');
      }

      if (!RegExp(r'^\d+

  @override
  Future<bool> validatePin(String pin) async {
    try {
      if (pin.isEmpty) return false;

      final storedHash = await _storage.read(key: _pinKey);
      if (storedHash == null) return false;

      final inputHash = _hashPin(pin);
      return storedHash == inputHash;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> hasPin() async {
    try {
      final pinConfigured = await _storage.read(key: _pinSetKey);
      final storedHash = await _storage.read(key: _pinKey);
      
      return pinConfigured == 'true' && storedHash != null;
    } catch (e) {
      return false;
    }
  }

  String _hashPin(String pin) {
    const salt = 'blinq_salt_2024';
    final saltedPin = pin + salt;
    final bytes = utf8.encode(saltedPin);
    return sha256.convert(bytes).toString();
  }
}).hasMatch(pin)) {
        print('❌ PIN contém caracteres não numéricos');
        throw Exception('PIN deve conter apenas números');
      }

      print('🔧 Gerando hash...');
      final hashed = _hashPin(pin);
      print('🔧 Hash gerado: ${hashed.substring(0, 10)}...');
      
      print('🔧 Salvando no storage...');
      await _storage.write(key: _pinKey, value: hashed);
      await _storage.write(key: _pinSetKey, value: 'true');
      
      print('✅ PIN salvo com sucesso no storage');
      
      // Verificar se realmente foi salvo
      final saved = await _storage.read(key: _pinKey);
      print('🔍 Verificação: PIN existe no storage? ${saved != null}');
      
    } catch (e) {
      print('❌ Erro no PinRepository.savePin: $e');
      rethrow;
    }
  }

  @override
  Future<bool> validatePin(String pin) async {
    try {
      if (pin.isEmpty) return false;

      final storedHash = await _storage.read(key: _pinKey);
      if (storedHash == null) return false;

      final inputHash = _hashPin(pin);
      return storedHash == inputHash;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> hasPin() async {
    try {
      final pinConfigured = await _storage.read(key: _pinSetKey);
      final storedHash = await _storage.read(key: _pinKey);
      
      return pinConfigured == 'true' && storedHash != null;
    } catch (e) {
      return false;
    }
  }

  String _hashPin(String pin) {
    const salt = 'blinq_salt_2024';
    final saltedPin = pin + salt;
    final bytes = utf8.encode(saltedPin);
    return sha256.convert(bytes).toString();
  }
}