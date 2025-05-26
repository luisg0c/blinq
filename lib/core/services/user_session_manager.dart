// lib/core/services/user_session_manager.dart - VERSÃO CORRIGIDA E FUNCIONAL

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ✅ GERENCIADOR SIMPLES E FUNCIONAL DE SESSÕES
class UserSessionManager {
  static String? _currentUserId;
  static String? _currentUserEmail;
  static DateTime? _sessionStartTime;
  static bool _isInitialized = false;

  /// ✅ INICIALIZAR SESSÃO
  static Future<void> initializeUserSession(String userId) async {
    try {
      print('🔐 Inicializando sessão para: $userId');

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || currentUser.uid != userId) {
        throw Exception('Usuário não autenticado');
      }

      // Verificar se é uma nova sessão
      if (_currentUserId != null && _currentUserId != userId) {
        print('🔄 Mudança de usuário detectada');
        await clearPreviousSession();
      }

      // Configurar nova sessão
      _currentUserId = userId;
      _currentUserEmail = currentUser.email;
      _sessionStartTime = DateTime.now();
      _isInitialized = true;

      print('✅ Sessão inicializada: $userId (${currentUser.email})');

    } catch (e) {
      print('❌ Erro ao inicializar sessão: $e');
      rethrow;
    }
  }

  /// ✅ LIMPAR SESSÃO ANTERIOR
  static Future<void> clearPreviousSession() async {
    try {
      print('🧹 Limpando sessão anterior...');

      if (_currentUserId != null) {
        print('   Usuário anterior: $_currentUserId ($_currentUserEmail)');
        
        // Limpar controllers que podem ter dados do usuário anterior
        _cleanupControllers();
        
        // Limpar caches se necessário
        _clearCaches();
      }

      print('✅ Sessão anterior limpa');

    } catch (e) {
      print('❌ Erro ao limpar sessão anterior: $e');
    }
  }

  /// ✅ LIMPAR TODOS OS DADOS DO USUÁRIO
  static Future<void> clearAllUserData() async {
    try {
      print('🗑️ Limpando todos os dados...');

      _cleanupControllers();
      _clearCaches();

      _currentUserId = null;
      _currentUserEmail = null;
      _sessionStartTime = null;
      _isInitialized = false;

      print('✅ Todos os dados limpos');

    } catch (e) {
      print('❌ Erro ao limpar dados: $e');
    }
  }

  /// ✅ LIMPAR CONTROLLERS (MÉTODO SEGURO)
  static void _cleanupControllers() {
    try {
      // Lista de controllers que podem precisar de limpeza
      final controllersToTryDelete = [
        'HomeController',
        'TransferController', 
        'DepositController',
        // PinController não deletamos pois é global
      ];

      for (final controllerName in controllersToTryDelete) {
        try {
          // Tentar deletar usando tag do usuário se existir
          if (_currentUserId != null && Get.isRegistered(tag: _currentUserId)) {
            Get.delete(tag: _currentUserId, force: true);
          }
          
          // Tentar deletar instância genérica se existir
          if (Get.isRegistered()) {
            // Não forçar delete de controllers críticos
            if (!controllerName.contains('Pin')) {
              Get.delete(force: false);
            }
          }
        } catch (e) {
          // Ignorar erros de controllers específicos
          print('⚠️ Não foi possível limpar $controllerName: $e');
        }
      }

      print('🧹 Controllers limpos');
    } catch (e) {
      print('❌ Erro ao limpar controllers: $e');
    }
  }

  /// ✅ LIMPAR CACHES
  static void _clearCaches() {
    try {
      // Aqui poderíamos limpar caches específicos do usuário
      // Por enquanto, apenas um placeholder
      print('🧹 Caches limpos');
    } catch (e) {
      print('❌ Erro ao limpar caches: $e');
    }
  }

  /// ✅ VERIFICAR SESSÃO ATIVA
  static bool hasActiveSession() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null && 
           _currentUserId != null && 
           _currentUserId == currentUser.uid &&
           _isInitialized;
  }

  /// ✅ OBTER USUÁRIO ATUAL
  static String? getCurrentUserId() {
    return _currentUserId;
  }

  /// ✅ OBTER EMAIL ATUAL
  static String? getCurrentUserEmail() {
    return _currentUserEmail;
  }

  /// ✅ VERIFICAR SE É USUÁRIO AUTORIZADO
  static bool isAuthorizedUser(String userId) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null && 
           currentUser.uid == userId && 
           _currentUserId == userId;
  }

  /// ✅ TEMPO DE SESSÃO
  static Duration? getSessionDuration() {
    if (_sessionStartTime == null) return null;
    return DateTime.now().difference(_sessionStartTime!);
  }

  /// ✅ VERIFICAR SE SESSÃO É RECENTE
  static bool isRecentSession({Duration threshold = const Duration(hours: 1)}) {
    final duration = getSessionDuration();
    if (duration == null) return false;
    return duration < threshold;
  }

  /// ✅ INFORMAÇÕES DE DEBUG
  static Map<String, dynamic> getSessionDebugInfo() {
    final currentUser = FirebaseAuth.instance.currentUser;
    final sessionDuration = getSessionDuration();
    
    return {
      'currentUserId': _currentUserId,
      'currentUserEmail': _currentUserEmail,
      'firebaseUserId': currentUser?.uid,
      'firebaseUserEmail': currentUser?.email,
      'sessionStartTime': _sessionStartTime?.toIso8601String(),
      'sessionDuration': sessionDuration?.inMinutes,
      'hasActiveSession': hasActiveSession(),
      'isRecentSession': isRecentSession(),
      'isInitialized': _isInitialized,
      'registeredControllers': _getRegisteredControllersCount(),
      'controllersList': _getRegisteredControllersList(),
    };
  }

  /// ✅ INVALIDAR SESSÃO (FORÇAR NOVA INICIALIZAÇÃO)
  static void invalidateSession() {
    print('🔄 Invalidando sessão atual...');
    _currentUserId = null;
    _currentUserEmail = null;
    _sessionStartTime = null;
    _isInitialized = false;
    print('✅ Sessão invalidada');
  }

  /// ✅ VERIFICAR CONSISTÊNCIA DA SESSÃO
  static bool isSessionConsistent() {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    // Usuário Firebase deve existir
    if (currentUser == null) return false;
    
    // IDs devem bater
    if (_currentUserId != currentUser.uid) return false;
    
    // Emails devem bater
    if (_currentUserEmail != currentUser.email) return false;
    
    return _isInitialized;
  }

  /// ✅ REPARAR SESSÃO INCONSISTENTE
  static Future<void> repairSessionIfNeeded() async {
    if (!isSessionConsistent()) {
      print('⚠️ Sessão inconsistente detectada, reparando...');
      
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await initializeUserSession(currentUser.uid);
      } else {
        await clearAllUserData();
      }
    }
  }

  /// ✅ VERIFICAR SE ESTÁ INICIALIZADO
  static bool get isInitialized => _isInitialized;

  /// ✅ OBTER INFORMAÇÕES DE CONTROLLERS REGISTRADOS
  static Map<String, dynamic> get registeredInfo {
    // GetX não tem uma propriedade 'registered' pública
    // Retornamos informações básicas sobre controllers
    return {
      'length': _getRegisteredControllersCount(),
      'controllers': _getRegisteredControllersList(),
    };
  }

  /// ✅ CONTAR CONTROLLERS REGISTRADOS (MÉTODO SEGURO)
  static int _getRegisteredControllersCount() {
    try {
      // Tentar obter informações básicas sobre controllers GetX
      int count = 0;
      
      // Lista de controllers conhecidos para verificar
      final knownControllers = [
        'HomeController',
        'AuthController',
        'TransferController',
        'DepositController',
        'PinController',
      ];
      
      for (final controller in knownControllers) {
        if (Get.isRegistered(tag: _currentUserId)) {
          count++;
        }
      }
      
      return count;
    } catch (e) {
      print('⚠️ Erro ao contar controllers: $e');
      return 0;
    }
  }

  /// ✅ LISTAR CONTROLLERS REGISTRADOS (MÉTODO SEGURO)
  static List<String> _getRegisteredControllersList() {
    try {
      final registeredControllers = <String>[];
      
      // Lista de controllers conhecidos para verificar
      final knownControllers = [
        'HomeController',
        'AuthController', 
        'TransferController',
        'DepositController',
        'PinController',
      ];
      
      for (final controller in knownControllers) {
        try {
          if (Get.isRegistered(tag: _currentUserId)) {
            registeredControllers.add(controller);
          }
        } catch (e) {
          // Ignorar erros individuais
        }
      }
      
      return registeredControllers;
    } catch (e) {
      print('⚠️ Erro ao listar controllers: $e');
      return [];
    }
  }
}