import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../../../domain/repositories/pin_repository.dart';

/// Implementação de [PinRepository] usando armazenamento seguro local.
/// O PIN é armazenado com hash SHA-256 para não ser recuperável em texto puro.
class PinRepositoryImpl implements PinRepository {
  static const _pinKey = 'transaction_pin_hash';
  final FlutterSecureStorage _storage;

  PinRepositoryImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Salva o hash do PIN.
  @override
  Future<void> savePin(String pin) async {
    final hashed = _hashPin(pin);
    await _storage.write(key: _pinKey, value: hashed);
  }

  /// Compara o hash do PIN salvo com o hash do PIN informado.
  @override
  Future<bool> validatePin(String pin) async {
    final hashed = _hashPin(pin);
    final stored = await _storage.read(key: _pinKey);
    return stored == hashed;
  }

  /// Verifica se o PIN já foi configurado.
  @override
  Future<bool> hasPin() async {
    final stored = await _storage.read(key: _pinKey);
    return stored != null;
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }
}
