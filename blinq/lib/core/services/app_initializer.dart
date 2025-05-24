// lib/core/services/app_initializer.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import 'notification_service.dart';

class AppInitializer {
  
  /// Inicializar app e determinar rota inicial
  static Future<void> initializeAndNavigate() async {
    try {
      print('🚀 Inicializando aplicação...');
      
      // 1. Aguardar um pouco para garantir que tudo está carregado
      await Future.delayed(const Duration(milliseconds: 2000));
      
      // 2. Verificar mensagem inicial de notificação
      await NotificationService.checkForInitialMessage();
      
      // 3. Verificar se usuário está logado
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        print('👤 Usuário logado: ${user.email}');
        // Verificar se precisa configurar PIN
        // TODO: Implementar verificação de PIN configurado
        Get.offAllNamed(AppRoutes.home);
      } else {
        print('👤 Usuário não logado');
        Get.offAllNamed(AppRoutes.welcome);
      }
      
    } catch (e) {
      print('❌ Erro na inicialização: $e');
      // Em caso de erro, ir para welcome
      Get.offAllNamed(AppRoutes.welcome);
    }
  }
  
  /// Verificar se o app foi aberto via notificação
  static Future<bool> wasOpenedFromNotification() async {
    try {
      // Esta verificação seria feita pelo NotificationService
      return false; // Por enquanto, sempre false
    } catch (e) {
      print('❌ Erro ao verificar abertura via notificação: $e');
      return false;
    }
  }
  
  /// Configurar listeners globais
  static void setupGlobalListeners() {
    // Listener para mudanças de autenticação
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('👤 Usuário deslogado');
        Get.offAllNamed(AppRoutes.welcome);
      } else {
        print('👤 Usuário logado: ${user.email}');
        // Não navegar automaticamente para evitar loops
      }
    });
  }
}