import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import 'user_session_manager.dart';

class AppInitializer {
  
  /// ✅ INICIALIZAR APP E DETERMINAR ROTA INICIAL
  static Future<void> initializeAndNavigate() async {
    try {
      print('🚀 Inicializando aplicação...');
      
      // 1. Aguardar um pouco para garantir que tudo está carregado
      await Future.delayed(const Duration(milliseconds: 2000));
      
      // 2. Verificar se usuário está logado
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        print('👤 Usuário logado: ${user.email}');
        
        // 3. Inicializar sessão do usuário
        await UserSessionManager.initializeUserSession(user.uid);
        
        // 4. Navegar para home
        Get.offAllNamed(AppRoutes.home);
      } else {
        print('👤 Usuário não logado');
        
        // 5. Limpar qualquer sessão anterior
        await UserSessionManager.clearAllUserData();
        
        // 6. Navegar para welcome
        Get.offAllNamed(AppRoutes.welcome);
      }
      
    } catch (e) {
      print('❌ Erro na inicialização: $e');
      
      // Em caso de erro, ir para welcome
      try {
        await UserSessionManager.clearAllUserData();
      } catch (clearError) {
        print('❌ Erro ao limpar dados: $clearError');
      }
      
      Get.offAllNamed(AppRoutes.welcome);
    }
  }
  
  /// ✅ VERIFICAR SE O APP FOI ABERTO VIA NOTIFICAÇÃO
  static Future<bool> wasOpenedFromNotification() async {
    try {
      // Esta verificação seria feita pelo NotificationService
      // Por enquanto, sempre false
      return false;
    } catch (e) {
      print('❌ Erro ao verificar abertura via notificação: $e');
      return false;
    }
  }
  
  /// ✅ CONFIGURAR LISTENERS GLOBAIS
  static void setupGlobalListeners() {
    try {
      // Listener para mudanças de autenticação
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        _handleAuthStateChange(user);
      });
      
      print('👂 Listeners globais configurados');
    } catch (e) {
      print('❌ Erro ao configurar listeners: $e');
    }
  }
  
  /// ✅ LIDAR COM MUDANÇAS DE AUTENTICAÇÃO
  static void _handleAuthStateChange(User? user) async {
    try {
      if (user == null) {
        print('👤 Usuário deslogado');
        
        // Limpar sessão
        await UserSessionManager.clearAllUserData();
        
        // Só navegar se não estivermos em uma rota pública
        if (!_isOnPublicRoute()) {
          Get.offAllNamed(AppRoutes.welcome);
        }
      } else {
        print('👤 Usuário logado: ${user.email}');
        
        // Inicializar sessão
        await UserSessionManager.initializeUserSession(user.uid);
        
        // Só navegar se não estivermos na home
        if (Get.currentRoute != AppRoutes.home && !_isOnPublicRoute()) {
          Get.offAllNamed(AppRoutes.home);
        }
      }
    } catch (e) {
      print('❌ Erro ao lidar com mudança de autenticação: $e');
    }
  }
  
  /// ✅ VERIFICAR SE ESTAMOS EM UMA ROTA PÚBLICA
  static bool _isOnPublicRoute() {
    final publicRoutes = [
      AppRoutes.splash,
      AppRoutes.onboarding,
      AppRoutes.welcome,
      AppRoutes.login,
      AppRoutes.signup,
      AppRoutes.resetPassword,
    ];
    
    return publicRoutes.contains(Get.currentRoute);
  }
  
  /// ✅ INICIALIZAÇÃO ESPECÍFICA PARA USUÁRIO LOGADO
  static Future<void> initializeForLoggedUser(String userId) async {
    try {
      print('👤 Inicializando para usuário logado: $userId');
      
      // Inicializar sessão
      await UserSessionManager.initializeUserSession(userId);
      
      // Aqui poderíamos inicializar outros serviços específicos do usuário
      // Como notificações, sincronização, etc.
      
      print('✅ Inicialização para usuário concluída');
    } catch (e) {
      print('❌ Erro na inicialização para usuário: $e');
      rethrow;
    }
  }
  
  /// ✅ LIMPAR DADOS DO USUÁRIO AO FAZER LOGOUT
  static Future<void> cleanupOnLogout() async {
    try {
      print('🧹 Limpando dados no logout...');
      
      // Limpar sessão
      await UserSessionManager.clearAllUserData();
      
      // Aqui poderíamos limpar outros dados/serviços
      // Como cache, notificações locais, etc.
      
      print('✅ Limpeza no logout concluída');
    } catch (e) {
      print('❌ Erro na limpeza do logout: $e');
    }
  }
  
  /// ✅ VERIFICAR SAÚDE DA APLICAÇÃO
  static bool checkAppHealth() {
    try {
      // Verificar se o Firebase está funcionando
      final user = FirebaseAuth.instance.currentUser;
      
      // Verificar se o GetX está funcionando
      final routeIsValid = Get.currentRoute.isNotEmpty;
      
      // Verificar se a sessão está consistente (se há usuário)
      bool sessionIsHealthy = true;
      if (user != null) {
        sessionIsHealthy = UserSessionManager.isSessionConsistent();
      }
      
      final isHealthy = routeIsValid && sessionIsHealthy;
      
      print('🏥 Saúde da app: $isHealthy');
      print('   Rota válida: $routeIsValid');
      print('   Sessão saudável: $sessionIsHealthy');
      
      return isHealthy;
    } catch (e) {
      print('❌ Erro ao verificar saúde da app: $e');
      return false;
    }
  }
  
  /// ✅ REPARAR PROBLEMAS DA APLICAÇÃO
  static Future<void> repairAppIfNeeded() async {
    try {
      print('🔧 Verificando se app precisa de reparo...');
      
      if (!checkAppHealth()) {
        print('⚠️ App não está saudável, tentando reparar...');
        
        // Reparar sessão se necessário
        await UserSessionManager.repairSessionIfNeeded();
        
        // Reparar navegação se necessário
        if (Get.currentRoute.isEmpty) {
          await initializeAndNavigate();
        }
        
        print('✅ Tentativa de reparo concluída');
      } else {
        print('✅ App está saudável');
      }
    } catch (e) {
      print('❌ Erro no reparo da app: $e');
    }
  }
  
  /// ✅ INFORMAÇÕES DE DEBUG
  static Map<String, dynamic> getDebugInfo() {
    final user = FirebaseAuth.instance.currentUser;
    
    return {
      'currentRoute': Get.currentRoute,
      'isOnPublicRoute': _isOnPublicRoute(),
      'hasFirebaseUser': user != null,
      'firebaseUserId': user?.uid,
      'firebaseUserEmail': user?.email,
      'sessionInfo': UserSessionManager.getSessionDebugInfo(),
      'appIsHealthy': checkAppHealth(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  /// ✅ INICIALIZAÇÃO COMPLETA COM VERIFICAÇÕES
  static Future<void> completeInitialization() async {
    try {
      print('🔄 Inicialização completa...');
      
      // 1. Configurar listeners globais
      setupGlobalListeners();
      
      // 2. Verificar e reparar se necessário
      await repairAppIfNeeded();
      
      // 3. Inicializar e navegar
      await initializeAndNavigate();
      
      print('✅ Inicialização completa concluída');
    } catch (e) {
      print('❌ Erro na inicialização completa: $e');
      
      // Fallback para rota segura
      Get.offAllNamed(AppRoutes.welcome);
    }
  }
}