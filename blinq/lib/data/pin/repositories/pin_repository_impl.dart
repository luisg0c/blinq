// lib/data/pin/repositories/pin_repository_impl.dart - VERSÃO REFATORADA

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../../../core/exceptions/app_exception.dart';
import '../../../domain/repositories/pin_repository.dart';

/// Estratégias de armazenamento disponíveis
enum PinStorageStrategy {
  firebase,
  local,
  hybrid,
}

/// Resultado de operação de PIN
class PinOperationResult {
  final bool success;
  final String? error;
  final Map<String, dynamic>? metadata;

  const PinOperationResult({
    required this.success,
    this.error,
    this.metadata,
  });

  factory PinOperationResult.success([Map<String, dynamic>? metadata]) {
    return PinOperationResult(success: true, metadata: metadata);
  }

  factory PinOperationResult.failure(String error) {
    return PinOperationResult(success: false, error: error);
  }
}

/// Dados de PIN estruturados
class PinData {
  final String hash;
  final String userId;
  final DateTime createdAt;
  final String version;
  final String? syncedFrom;

  const PinData({
    required this.hash,
    required this.userId,
    required this.createdAt,
    required this.version,
    this.syncedFrom,
  });

  factory PinData.fromMap(Map<String, dynamic> map) {
    return PinData(
      hash: map['hash'] ?? map['pinHash'] ?? '',
      userId: map['userId'] ?? map['user_id'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      version: map['version'] ?? '5.0',
      syncedFrom: map['syncedFrom'] ?? map['synced_from'],
    );
  }

  Map<String, dynamic> toLocalMap() {
    return {
      'hash': hash,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'version': version,
      'synced_from': syncedFrom,
    };
  }

  Map<String, dynamic> toFirebaseMap() {
    return {
      'pinHash': hash,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'version': version,
      'syncedFrom': syncedFrom,
    };
  }

  bool get isValid => hash.isNotEmpty && userId.isNotEmpty;
}

/// Implementação híbrida robusta do repositório de PIN
class PinRepositoryImpl implements PinRepository {
  // ===== CONFIGURAÇÕES =====
  static const String _currentVersion = '5.0';
  static const String _pinKey = 'blinq_pin_v5';
  static const String _firebaseCollection = 'user_pins';
  static const String _saltPrefix = 'blinq_pin_salt_v5_hybrid';
  
  // ===== DEPENDÊNCIAS =====
  final FlutterSecureStorage _storage;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  // ===== CONFIGURAÇÃO =====
  final PinStorageStrategy _strategy;
  final Duration _operationTimeout;
  
  PinRepositoryImpl({
    FlutterSecureStorage? storage,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    PinStorageStrategy strategy = PinStorageStrategy.hybrid,
    Duration operationTimeout = const Duration(seconds: 10),
  }) : _storage = storage ?? _createSecureStorage(),
       _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _strategy = strategy,
       _operationTimeout = operationTimeout;

  // ===== MÉTODOS PÚBLICOS =====

  @override
  Future<void> savePin(String pin) async {
    final result = await _executeWithTimeout(
      () => _savePinInternal(pin),
      'savePin',
    );
    
    if (!result.success) {
      throw AppException(result.error ?? 'Falha ao salvar PIN');
    }
  }

  @override
  Future<bool> validatePin(String pin) async {
    final result = await _executeWithTimeout(
      () => _validatePinInternal(pin),
      'validatePin',
    );
    
    return result.success && (result.metadata?['isValid'] == true);
  }

  @override
  Future<bool> hasPin() async {
    final result = await _executeWithTimeout(
      () => _hasPinInternal(),
      'hasPin',
    );
    
    return result.success && (result.metadata?['exists'] == true);
  }

  // ===== MÉTODOS INTERNOS PRINCIPAIS =====

  Future<PinOperationResult> _savePinInternal(String pin) async {
    try {
      _log('💾 Iniciando salvamento de PIN');
      
      // Validações
      final user = _getCurrentUser();
      if (user == null) {
        return PinOperationResult.failure('Usuário não autenticado');
      }
      
      if (!_isValidPin(pin)) {
        return PinOperationResult.failure('PIN deve ter entre 4 e 6 dígitos numéricos');
      }

      // Criar dados do PIN
      final pinData = PinData(
        hash: _hashPin(pin),
        userId: user.uid,
        createdAt: DateTime.now(),
        version: _currentVersion,
      );

      // Salvar conforme estratégia
      final results = await _saveWithStrategy(pinData);
      
      // Verificar se pelo menos uma operação foi bem-sucedida
      final hasSuccess = results.values.any((r) => r.success);
      
      if (!hasSuccess) {
        final errors = results.values
            .where((r) => !r.success)
            .map((r) => r.error)
            .join(', ');
        return PinOperationResult.failure('Falha em todos os storages: $errors');
      }

      _log('✅ PIN salvo com sucesso');
      return PinOperationResult.success(results);

    } catch (e) {
      _logError('Erro no salvamento', e);
      return PinOperationResult.failure('Erro interno: $e');
    }
  }

  Future<PinOperationResult> _validatePinInternal(String pin) async {
    try {
      _log('🔍 Iniciando validação de PIN');
      
      // Validações básicas
      final user = _getCurrentUser();
      if (user == null) {
        return PinOperationResult.failure('Usuário não autenticado');
      }
      
      if (!_isValidPin(pin)) {
        return PinOperationResult.success({'isValid': false, 'reason': 'formato_invalido'});
      }

      final inputHash = _hashPin(pin);
      
      // Validar conforme estratégia
      final results = await _validateWithStrategy(inputHash, user.uid);
      
      // Se qualquer storage validou com sucesso, PIN é válido
      final isValid = results.values.any((r) => 
          r.success && r.metadata?['isValid'] == true);
      
      if (isValid) {
        _log('✅ PIN válido');
        // Sincronizar se necessário
        _syncInBackground(inputHash, user.uid);
      } else {
        _log('❌ PIN inválido');
      }

      return PinOperationResult.success({
        'isValid': isValid,
        'storageResults': results,
      });

    } catch (e) {
      _logError('Erro na validação', e);
      return PinOperationResult.success({'isValid': false, 'error': e.toString()});
    }
  }

  Future<PinOperationResult> _hasPinInternal() async {
    try {
      _log('📍 Verificando existência de PIN');
      
      final user = _getCurrentUser();
      if (user == null) {
        return PinOperationResult.failure('Usuário não autenticado');
      }

      // Verificar conforme estratégia
      final results = await _checkExistenceWithStrategy(user.uid);
      
      // Se qualquer storage tem PIN, consideramos que existe
      final exists = results.values.any((r) => 
          r.success && r.metadata?['exists'] == true);

      _log('📍 PIN existe: $exists');
      
      return PinOperationResult.success({
        'exists': exists,
        'storageResults': results,
      });

    } catch (e) {
      _logError('Erro na verificação', e);
      return PinOperationResult.failure('Erro interno: $e');
    }
  }

  // ===== MÉTODOS DE ESTRATÉGIA =====

  Future<Map<String, PinOperationResult>> _saveWithStrategy(PinData pinData) async {
    final results = <String, PinOperationResult>{};
    
    switch (_strategy) {
      case PinStorageStrategy.firebase:
        results['firebase'] = await _saveToFirebase(pinData);
        break;
        
      case PinStorageStrategy.local:
        results['local'] = await _saveToLocal(pinData);
        break;
        
      case PinStorageStrategy.hybrid:
        // Executar ambos em paralelo
        final futures = await Future.wait([
          _saveToFirebase(pinData),
          _saveToLocal(pinData),
        ]);
        results['firebase'] = futures[0];
        results['local'] = futures[1];
        break;
    }
    
    return results;
  }

  Future<Map<String, PinOperationResult>> _validateWithStrategy(
      String inputHash, String userId) async {
    final results = <String, PinOperationResult>{};
    
    switch (_strategy) {
      case PinStorageStrategy.firebase:
        results['firebase'] = await _validateInFirebase(inputHash, userId);
        break;
        
      case PinStorageStrategy.local:
        results['local'] = await _validateInLocal(inputHash);
        break;
        
      case PinStorageStrategy.hybrid:
        // Tentar Firebase primeiro, depois local
        results['firebase'] = await _validateInFirebase(inputHash, userId);
        
        // Se Firebase falhou, tentar local
        if (!results['firebase']!.success || 
            results['firebase']!.metadata?['isValid'] != true) {
          results['local'] = await _validateInLocal(inputHash);
        }
        break;
    }
    
    return results;
  }

  Future<Map<String, PinOperationResult>> _checkExistenceWithStrategy(String userId) async {
    final results = <String, PinOperationResult>{};
    
    switch (_strategy) {
      case PinStorageStrategy.firebase:
        results['firebase'] = await _checkFirebaseExistence(userId);
        break;
        
      case PinStorageStrategy.local:
        results['local'] = await _checkLocalExistence();
        break;
        
      case PinStorageStrategy.hybrid:
        // Verificar ambos em paralelo
        final futures = await Future.wait([
          _checkFirebaseExistence(userId),
          _checkLocalExistence(),
        ]);
        results['firebase'] = futures[0];
        results['local'] = futures[1];
        break;
    }
    
    return results;
  }

  // ===== OPERAÇÕES FIREBASE =====

  Future<PinOperationResult> _saveToFirebase(PinData pinData) async {
    try {
      await _firestore
          .collection(_firebaseCollection)
          .doc(pinData.userId)
          .set(pinData.toFirebaseMap());
      
      _log('✅ PIN salvo no Firebase');
      return PinOperationResult.success();
    } catch (e) {
      _logError('Erro ao salvar no Firebase', e);
      return PinOperationResult.failure('Firebase: $e');
    }
  }

  Future<PinOperationResult> _validateInFirebase(String inputHash, String userId) async {
    try {
      final doc = await _firestore
          .collection(_firebaseCollection)
          .doc(userId)
          .get();
      
      if (!doc.exists) {
        return PinOperationResult.success({'isValid': false, 'reason': 'not_found'});
      }

      final pinData = PinData.fromMap(doc.data()!);
      final isValid = pinData.isValid && pinData.hash == inputHash;
      
      return PinOperationResult.success({
        'isValid': isValid,
        'source': 'firebase',
        'pinData': pinData,
      });
    } catch (e) {
      _logError('Erro ao validar no Firebase', e);
      return PinOperationResult.failure('Firebase: $e');
    }
  }

  Future<PinOperationResult> _checkFirebaseExistence(String userId) async {
    try {
      final doc = await _firestore
          .collection(_firebaseCollection)
          .doc(userId)
          .get();
      
      final exists = doc.exists && doc.data()?['pinHash'] != null;
      
      return PinOperationResult.success({
        'exists': exists,
        'source': 'firebase',
      });
    } catch (e) {
      _logError('Erro ao verificar Firebase', e);
      return PinOperationResult.failure('Firebase: $e');
    }
  }

  // ===== OPERAÇÕES LOCAIS =====

  Future<PinOperationResult> _saveToLocal(PinData pinData) async {
    try {
      final data = json.encode(pinData.toLocalMap());
      await _storage.write(key: _pinKey, value: data);
      
      _log('✅ PIN salvo localmente');
      return PinOperationResult.success();
    } catch (e) {
      _logError('Erro ao salvar localmente', e);
      return PinOperationResult.failure('Local: $e');
    }
  }

  Future<PinOperationResult> _validateInLocal(String inputHash) async {
    try {
      final data = await _storage.read(key: _pinKey);
      
      if (data == null || data.isEmpty) {
        return PinOperationResult.success({'isValid': false, 'reason': 'not_found'});
      }

      final pinData = PinData.fromMap(json.decode(data));
      final isValid = pinData.isValid && pinData.hash == inputHash;
      
      return PinOperationResult.success({
        'isValid': isValid,
        'source': 'local',
        'pinData': pinData,
      });
    } catch (e) {
      _logError('Erro ao validar localmente', e);
      return PinOperationResult.failure('Local: $e');
    }
  }

  Future<PinOperationResult> _checkLocalExistence() async {
    try {
      final data = await _storage.read(key: _pinKey);
      
      bool exists = false;
      if (data != null && data.isNotEmpty) {
        try {
          final pinData = PinData.fromMap(json.decode(data));
          exists = pinData.isValid;
        } catch (e) {
          _logError('Dados locais corrompidos', e);
          // Limpar dados corrompidos
          await _storage.delete(key: _pinKey);
        }
      }
      
      return PinOperationResult.success({
        'exists': exists,
        'source': 'local',
      });
    } catch (e) {
      _logError('Erro ao verificar local', e);
      return PinOperationResult.failure('Local: $e');
    }
  }

  // ===== SINCRONIZAÇÃO =====

  void _syncInBackground(String hash, String userId) {
    // Executar sincronização em background sem bloquear
    Future.microtask(() async {
      try {
        await _synchronizePins(hash, userId);
      } catch (e) {
        _logError('Erro na sincronização em background', e);
      }
    });
  }

  Future<void> _synchronizePins(String hash, String userId) async {
    try {
      final firebaseExists = await _checkFirebaseExistence(userId);
      final localExists = await _checkLocalExistence();
      
      final hasFirebase = firebaseExists.success && 
          firebaseExists.metadata?['exists'] == true;
      final hasLocal = localExists.success && 
          localExists.metadata?['exists'] == true;
      
      final pinData = PinData(
        hash: hash,
        userId: userId,
        createdAt: DateTime.now(),
        version: _currentVersion,
      );
      
      if (!hasFirebase && hasLocal) {
        _log('🔄 Sincronizando Local → Firebase');
        await _saveToFirebase(pinData.copyWith(syncedFrom: 'local'));
      } else if (hasFirebase && !hasLocal) {
        _log('🔄 Sincronizando Firebase → Local');
        await _saveToLocal(pinData.copyWith(syncedFrom: 'firebase'));
      }
    } catch (e) {
      _logError('Erro na sincronização', e);
    }
  }

  // ===== UTILITÁRIOS =====

  Future<T> _executeWithTimeout<T>(
    Future<T> Function() operation,
    String operationName,
  ) async {
    try {
      return await operation().timeout(_operationTimeout);
    } catch (e) {
      _logError('Timeout em $operationName', e);
      rethrow;
    }
  }

  User? _getCurrentUser() => _auth.currentUser;

  String _hashPin(String pin) {
    final combined = '$_saltPrefix$pin$_saltPrefix';
    final bytes = utf8.encode(combined);
    return sha256.convert(bytes).toString();
  }

  bool _isValidPin(String pin) {
    final cleanPin = pin.trim();
    return cleanPin.length >= 4 && 
           cleanPin.length <= 6 && 
           RegExp(r'^\d+$').hasMatch(cleanPin);
  }

  void _log(String message) {
    print('[PinRepository] $message');
  }

  void _logError(String message, dynamic error) {
    print('[PinRepository] ❌ $message: $error');
  }

  static FlutterSecureStorage _createSecureStorage() {
    return const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        resetOnError: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
        synchronizable: false,
      ),
    );
  }

  // ===== MÉTODOS PÚBLICOS ADICIONAIS =====

  /// Limpa completamente o PIN de todos os storages
  Future<void> clearPin() async {
    try {
      _log('🧹 Limpando PIN completamente');
      
      final user = _getCurrentUser();
      final futures = <Future>[];
      
      // Limpar Firebase
      if (user != null) {
        futures.add(_firestore
            .collection(_firebaseCollection)
            .doc(user.uid)
            .delete()
            .catchError((e) => _logError('Erro ao limpar Firebase', e)));
      }
      
      // Limpar local
      futures.add(_storage
          .delete(key: _pinKey)
          .catchError((e) => _logError('Erro ao limpar local', e)));
      
      await Future.wait(futures);
      _log('✅ PIN limpo');
    } catch (e) {
      _logError('Erro ao limpar PIN', e);
    }
  }

  /// Obtém informações de diagnóstico detalhadas
  Future<Map<String, dynamic>> getDebugInfo() async {
    try {
      final user = _getCurrentUser();
      final timestamp = DateTime.now().toIso8601String();
      
      final result = <String, dynamic>{
        'timestamp': timestamp,
        'version': _currentVersion,
        'strategy': _strategy.toString(),
        'user': {
          'authenticated': user != null,
          'uid': user?.uid,
          'email': user?.email,
        },
      };
      
      // Diagnóstico Firebase
      if (user != null) {
        try {
          final firebaseResult = await _checkFirebaseExistence(user.uid);
          result['firebase'] = {
            'available': firebaseResult.success,
            'exists': firebaseResult.metadata?['exists'] ?? false,
            'error': firebaseResult.error,
          };
          
          if (firebaseResult.success && firebaseResult.metadata?['exists'] == true) {
            final doc = await _firestore
                .collection(_firebaseCollection)
                .doc(user.uid)
                .get();
            if (doc.exists) {
              final data = doc.data()!;
              result['firebase']['details'] = {
                'createdAt': data['createdAt']?.toString(),
                'version': data['version'],
                'syncedFrom': data['syncedFrom'],
              };
            }
          }
        } catch (e) {
          result['firebase'] = {'error': e.toString()};
        }
      }
      
      // Diagnóstico Local
      try {
        final localResult = await _checkLocalExistence();
        result['local'] = {
          'available': localResult.success,
          'exists': localResult.metadata?['exists'] ?? false,
          'error': localResult.error,
        };
        
        if (localResult.success && localResult.metadata?['exists'] == true) {
          final data = await _storage.read(key: _pinKey);
          if (data != null) {
            final pinData = json.decode(data);
            result['local']['details'] = {
              'createdAt': pinData['created_at'],
              'version': pinData['version'],
              'syncedFrom': pinData['synced_from'],
              'userId': pinData['user_id'],
            };
          }
        }
      } catch (e) {
        result['local'] = {'error': e.toString()};
      }
      
      // Informações do storage
      try {
        final allKeys = await _storage.readAll();
        final blinqKeys = allKeys.keys.where((k) => k.contains('blinq')).toList();
        result['storage'] = {
          'totalKeys': allKeys.length,
          'blinqKeys': blinqKeys,
        };
      } catch (e) {
        result['storage'] = {'error': e.toString()};
      }
      
      return result;
    } catch (e) {
      return {'critical_error': e.toString()};
    }
  }

  /// Força sincronização entre storages
  Future<void> forceSynchronization() async {
    try {
      final user = _getCurrentUser();
      if (user == null) throw Exception('Usuário não autenticado');
      
      _log('🔄 Forçando sincronização');
      
      final results = await _checkExistenceWithStrategy(user.uid);
      final hasFirebase = results['firebase']?.metadata?['exists'] == true;
      final hasLocal = results['local']?.metadata?['exists'] == true;
      
      if (hasFirebase && !hasLocal) {
        // Copiar do Firebase para local
        final validateResult = await _validateInFirebase('dummy', user.uid);
        if (validateResult.success) {
          final pinData = validateResult.metadata?['pinData'] as PinData?;
          if (pinData != null) {
            await _saveToLocal(pinData.copyWith(syncedFrom: 'firebase'));
          }
        }
      } else if (!hasFirebase && hasLocal) {
        // Copiar do local para Firebase
        final data = await _storage.read(key: _pinKey);
        if (data != null) {
          final pinData = PinData.fromMap(json.decode(data));
          await _saveToFirebase(pinData.copyWith(syncedFrom: 'local'));
        }
      }
      
      _log('✅ Sincronização concluída');
    } catch (e) {
      _logError('Erro na sincronização forçada', e);
      rethrow;
    }
  }

  /// Migra PINs de versões antigas
  Future<void> migrateFromOldVersions() async {
    try {
      _log('🔄 Verificando migração');
      
      final user = _getCurrentUser();
      if (user == null) return;
      
      // Se já tem PIN na versão atual, não migrar
      if (await hasPin()) {
        _log('✅ PIN já existe na versão atual');
        return;
      }
      
      // Procurar versões antigas
      final allKeys = await _storage.readAll();
      final oldKeys = allKeys.keys
          .where((k) => k.contains('pin') && !k.contains('v5'))
          .toList();
      
      _log('🔍 Encontradas ${oldKeys.length} chaves antigas');
      
      for (final oldKey in oldKeys) {
        try {
          final oldData = allKeys[oldKey];
          if (oldData != null && oldData.isNotEmpty) {
            final oldPinData = json.decode(oldData);
            if (oldPinData['hash'] != null) {
              final pinData = PinData(
                hash: oldPinData['hash'],
                userId: user.uid,
                createdAt: DateTime.tryParse(oldPinData['created_at'] ?? '') ?? DateTime.now(),
                version: _currentVersion,
                syncedFrom: 'migration',
              );
              
              await _saveWithStrategy(pinData);
              await _storage.delete(key: oldKey);
              
              _log('✅ Migrado de $oldKey');
              break;
            }
          }
        } catch (e) {
          _logError('Erro ao migrar $oldKey', e);
        }
      }
    } catch (e) {
      _logError('Erro na migração', e);
    }
  }

  /// Testa o sistema completo de PIN
  Future<bool> runSystemTest() async {
    try {
      _log('🧪 Iniciando teste do sistema');
      
      const testPin = '1234';
      final originalStrategy = _strategy;
      
      // Teste básico de fluxo
      await savePin(testPin);
      
      if (!await hasPin()) {
        _log('❌ Teste falhou: PIN não foi salvo');
        return false;
      }
      
      if (!await validatePin(testPin)) {
        _log('❌ Teste falhou: PIN correto não validou');
        return false;
      }
      
      if (await validatePin('9999')) {
        _log('❌ Teste falhou: PIN incorreto foi aceito');
        return false;
      }
      
      await clearPin();
      
      if (await hasPin()) {
        _log('❌ Teste falhou: PIN não foi limpo');
        return false;
      }
      
      _log('✅ Todos os testes passaram');
      return true;
    } catch (e) {
      _logError('Erro no teste do sistema', e);
      return false;
    }
  }
}

// ===== EXTENSÕES ÚTEIS =====

extension PinDataExtensions on PinData {
  PinData copyWith({
    String? hash,
    String? userId,
    DateTime? createdAt,
    String? version,
    String? syncedFrom,
  }) {
    return PinData(
      hash: hash ?? this.hash,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      version: version ?? this.version,
      syncedFrom: syncedFrom ?? this.syncedFrom,
    );
  }
}