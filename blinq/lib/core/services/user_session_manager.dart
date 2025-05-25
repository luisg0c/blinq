import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../presentation/controllers/home_controller.dart';
import '../../presentation/controllers/transfer_controller.dart';
import '../../presentation/controllers/deposit_controller.dart';
import '../../presentation/controllers/pin_controller.dart';
import '../services/email_validation_service.dart';
import '../services/notification_service.dart';
import '../../routes/app_routes.dart';

/// Gerenciador centralizado de sessões de usuário
class UserSessionManager {
  static String? _currentUserId;
  static final Map<String, DateTime> _sessionTimestamps = {};

  /// ✅ INICIALIZAR SESSÃO DE USUÁRIO
  static Future<void> initializeUserSession(String userId) async {
    try {
      print('🔐 Inicializando sessão para: $userId');

      // Verificar se é uma nova sessão
      if (_currentUserId != null && _currentUserId != userId) {
        print('🔄 Nova sessão detectada - limpando anterior');
        await clearPreviousSession();
      }

      _currentUserId = userId;
      _sessionTimestamps[userId] = DateTime.now();

      // Inicializar serviços específicos do usuário
      await _initializeUserServices(userId);

      // Navegar para home
      Get.offAllNamed(AppRoutes.home);

      print('✅ Sessão inicializada para: $userId');

    } catch (e) {
      print('❌ Erro ao inicializar sessão: $e');
      rethrow;
    }
  }

  /// ✅ LIMPAR SESSÃO ANTERIOR
  static Future<void> clearPreviousSession() async {
    try {
      print('🧹 Limpando sessão anterior...');

      // Limpar todos os controllers com dados de usuário
      await _cleanupUserControllers();

      // Limpar caches de serviços
      EmailValidationService.clearCache();

      print('✅ Sessão anterior limpa');

    } catch (e) {
      print('❌ Erro ao limpar sessão anterior: $e');
    }
  }

  /// ✅ LIMPAR TODOS OS DADOS DO USUÁRIO
  static Future<void> clearAllUserData() async {
    try {
      print('🗑️ Limpando todos os dados do usuário...');

      await _cleanupUserControllers();
      await _cleanupUserServices();

      _currentUserId = null;
      _sessionTimestamps.clear();

      print('✅ Todos os dados do usuário limpos');

    } catch (e) {
      print('❌ Erro ao limpar dados: $e');
    }
  }

  /// ✅ INICIALIZAR SERVIÇOS DO USUÁRIO
  static Future<void> _initializeUserServices(String userId) async {
    try {
      // Inicializar notificações para o usuário
      await NotificationService.initializeForUser(userId);

      print('✅ Serviços inicializados para: $userId');
    } catch (e) {
      print('❌ Erro ao inicializar serviços: $e');
    }
  }

  /// ✅ LIMPAR CONTROLLERS DE USUÁRIO
  static Future<void> _cleanupUserControllers() async {
    final controllersToClean = [
      HomeController,
      TransferController,
      DepositController,
      // Não limpar PinController pois é global
    ];

    for (final controllerType in controllersToClean) {
      try {
        if (Get.isRegistered(tag: _currentUserId)) {
          final controller = Get.find(tag: _currentUserId);
          if (controller is GetxController) {
            controller.onClose();
          }
          Get.delete(tag: _currentUserId);
        }

        if (Get.isRegistered<dynamic>()) {
          Get.delete<dynamic>();
        }
      } catch (e) {
        print('⚠️ Erro ao limpar controller $controllerType: $e');
      }
    }
  }

  /// ✅ LIMPAR SERVIÇOS DO USUÁRIO
  static Future<void> _cleanupUserServices() async {
    try {
      EmailValidationService.clearCache();
      await NotificationService.clearUserData(_currentUserId);
    } catch (e) {
      print('❌ Erro ao limpar serviços: $e');
    }
  }

  /// ✅ VERIFICAR SESSÃO ATIVA
  static bool hasActiveSession() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null && _currentUserId == currentUser.uid;
  }

  /// ✅ OBTER USUÁRIO ATUAL
  static String? getCurrentUserId() {
    return _currentUserId;
  }

  /// ✅ VERIFICAR SE É USUÁRIO AUTORIZADO
  static bool isAuthorizedUser(String userId) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null && 
           currentUser.uid == userId && 
           _currentUserId == userId;
  }

  /// ✅ DEBUG - ESTADO DA SESSÃO
  static Map<String, dynamic> getSessionDebugInfo() {
    return {
      'currentUserId': _currentUserId,
      'firebaseUserId': FirebaseAuth.instance.currentUser?.uid,
      'sessionTimestamp': _sessionTimestamps[_currentUserId]?.toIso8601String(),
      'hasActiveSession': hasActiveSession(),
      'registeredControllers': Get.registered.length,
    };
  }
}