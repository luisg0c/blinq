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
      final hash = _hashPin(pin);
      await _storage.write(key: _pinKey, value: hash);
      await _storage.write(key: _pinSetKey, value: 'true');
    } catch (e) {
      throw AppException('Erro ao salvar PIN: ${e.toString()}');
    }
  }

  @override
  Future<bool> validatePin(String pin) async {
    try {
      final storedHash = await _storage.read(key: _pinKey);
      if (storedHash == null) return false;
      final inputHash = _hashPin(pin);
      return inputHash == storedHash;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> hasPin() async {
    try {
      final configured = await _storage.read(key: _pinSetKey);
      return configured == 'true';
    } catch (_) {
      return false;
    }
  }

  String _hashPin(String pin) {
    const salt = 'blinq_salt_2024';
    final bytes = utf8.encode(pin + salt);
    return sha256.convert(bytes).toString();
  }
}
