// lib/core/services/app_initializer.dart - VERSÃO CORRIGIDA

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import 'user_session_manager.dart';
import 'dart:async';

class AppInitializer {
  static bool _isNavigationReady = false;
  static Timer? _navigationDelayTimer;
  
  /// ✅ INICIALIZAR APP E DETERMINAR ROTA INICIAL
  static Future<void> initializeAndNavigate() async {
    try {
      print('🚀 Inicializando aplicação...');
      
      // 1. Aguardar um pouco para garantir que tudo está carregado
      await Future.delayed(const Duration(milliseconds: 2000));
      
      // 2. Marcar navegação como pronta
      _isNavigationReady = true;
      
      // 3. Verificar se usuário está logado
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        print('👤 Usuário logado: ${user.email}');
        
        // 4. Inicializar sessão do usuário
        await UserSessionManager.initializeUserSession(user.uid);
        
        // 5. Navegar para home com verificação
        _safeNavigate(AppRoutes.home, offAll: true);
      } else {
        print('👤 Usuário não logado');
        
        // 6. Limpar qualquer sessão anterior
        await UserSessionManager.clearAllUserData();
        
        // 7. Navegar para welcome com verificação
        _safeNavigate(AppRoutes.welcome, offAll: true);
      }
      
    } catch (e) {
      print('❌ Erro na inicialização: $e');
      
      // Em caso de erro, ir para welcome
      try {
        await UserSessionManager.clearAllUserData();
      } catch (clearError) {
        print('❌ Erro ao limpar dados: $clearError');
      }
      
      _safeNavigate(AppRoutes.welcome, offAll: true);
    }
  }
  
  /// ✅ NAVEGAÇÃO SEGURA COM VERIFICAÇÕES
  static void _safeNavigate(String route, {bool offAll = false}) {
    // Verificar se a navegação está pronta
    if (!_isNavigationReady) {
      print('⚠️ Navegação não está pronta, agendando...');
      _scheduleNavigation(route, offAll: offAll);
      return;
    }
    
    // Verificar se o GetX está pronto
    if (!Get.isRegistered<GetMaterialController>()) {
      print('⚠️ GetX não está pronto, agendando...');
      _scheduleNavigation(route, offAll: offAll);
      return;
    }
    
    // Verificar se já estamos na rota correta
    if (Get.currentRoute == route) {
      print('ℹ️ Já estamos na rota: $route');
      return;
    }
    
    try {
      print('🧭 Navegando para: $route');
      
      if (offAll) {
        Get.offAllNamed(route);
      } else {
        Get.toNamed(route);
      }
      
      print('✅ Navegação concluída: $route');
    } catch (e) {
      print('❌ Erro na navegação: $e');
      _scheduleNavigation(route, offAll: offAll);
    }
  }
  
  /// ✅ AGENDAR NAVEGAÇÃO PARA QUANDO ESTIVER PRONTO
  static void _scheduleNavigation(String route, {bool offAll = false}) {
    _navigationDelayTimer?.cancel();
    
    print('⏰ Agendando navegação para: $route');
    
    _navigationDelayTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      // Verificar se o GetX está pronto
      if (Get.isRegistered<GetMaterialController>() && _isNavigationReady) {
        timer.cancel();
        
        try {
          print('🧭 Executando navegação agendada: $route');
          
          if (offAll) {
            Get.offAllNamed(route);
          } else {
            Get.toNamed(route);
          }
          
          print('✅ Navegação agendada concluída: $route');
        } catch (e) {
          print('❌ Erro na navegação agendada: $e');
        }
      }
      
      // Timeout após 10 segundos
      if (timer.tick > 20) {
        timer.cancel();
        print('⏰ Timeout na navegação agendada para: $route');
      }
    });
  }
  
  /// ✅ CONFIGURAR LISTENERS GLOBAIS (MELHORADO)
  static void setupGlobalListeners() {
    try {
      // Aguardar que o GetX esteja pronto antes de configurar listeners
      Timer(const Duration(milliseconds: 1000), () {
        _isNavigationReady = true;
        
        // Listener para mudanças de autenticação
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          _handleAuthStateChange(user);
        });
        
        print('👂 Listeners globais configurados');
      });
    } catch (e) {
      print('❌ Erro ao configurar listeners: $e');
    }
  }
  
  /// ✅ LIDAR COM MUDANÇAS DE AUTENTICAÇÃO (CORRIGIDO)
  static void _handleAuthStateChange(User? user) async {
    try {
      // Aguardar um pouco para evitar conflitos com navegação
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (user == null) {
        print('👤 Usuário deslogado');
        
        // Limpar sessão
        await UserSessionManager.clearAllUserData();
        
        // Só navegar se não estivermos em uma rota pública
        if (!_isOnPublicRoute()) {
          _safeNavigate(AppRoutes.welcome, offAll: true);
        }
      } else {
        print('👤 Usuário logado: ${user.email}');
        
        // Inicializar sessão
        await UserSessionManager.initializeUserSession(user.uid);
        
        // Só navegar se não estivermos na home e não for rota pública
        if (Get.currentRoute != AppRoutes.home && !_isOnPublicRoute()) {
          _safeNavigate(AppRoutes.home, offAll: true);
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
      final getxIsReady = Get.isRegistered<GetMaterialController>();
      
      // Verificar se a sessão está consistente (se há usuário)
      bool sessionIsHealthy = true;
      if (user != null) {
        sessionIsHealthy = UserSessionManager.isSessionConsistent();
      }
      
      final isHealthy = routeIsValid && sessionIsHealthy && getxIsReady && _isNavigationReady;
      
      print('🏥 Saúde da app: $isHealthy');
      print('   Rota válida: $routeIsValid');
      print('   GetX pronto: $getxIsReady');
      print('   Sessão saudável: $sessionIsHealthy');
      print('   Navegação pronta: $_isNavigationReady');
      
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
        
        // Aguardar um pouco para garantir que GetX está estável
        await Future.delayed(const Duration(milliseconds: 1000));
        
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
      'isNavigationReady': _isNavigationReady,
      'getxIsReady': Get.isRegistered<GetMaterialController>(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  /// ✅ INICIALIZAÇÃO COMPLETA COM VERIFICAÇÕES
  static Future<void> completeInitialization() async {
    try {
      print('🔄 Inicialização completa...');
      
      // 1. Configurar listeners globais
      setupGlobalListeners();
      
      // 2. Aguardar que tudo esteja pronto
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // 3. Verificar e reparar se necessário
      await repairAppIfNeeded();
      
      // 4. Inicializar e navegar
      await initializeAndNavigate();
      
      print('✅ Inicialização completa concluída');
    } catch (e) {
      print('❌ Erro na inicialização completa: $e');
      
      // Fallback para rota segura
      _safeNavigate(AppRoutes.welcome, offAll: true);
    }
  }
  
  /// ✅ FORÇAR RESET COMPLETO
  static Future<void> forceReset() async {
    try {
      print('🔄 Forçando reset completo...');
      
      // Cancelar timers
      _navigationDelayTimer?.cancel();
      
      // Reset flags
      _isNavigationReady = false;
      
      // Limpar dados
      await UserSessionManager.clearAllUserData();
      
      // Aguardar
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Reinicializar
      await completeInitialization();
      
      print('✅ Reset completo concluído');
    } catch (e) {
      print('❌ Erro no reset completo: $e');
    }
  }
  
  /// ✅ VERIFICAR SE GETX ESTÁ PRONTO
  static bool isGetXReady() {
    try {
      return Get.isRegistered<GetMaterialController>() && _isNavigationReady;
    } catch (e) {
      return false;
    }
  }
  
  /// ✅ AGUARDAR GETX FICAR PRONTO
  static Future<void> waitForGetXReady({Duration timeout = const Duration(seconds: 10)}) async {
    final completer = Completer<void>();
    final timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (isGetXReady()) {
        timer.cancel();
        completer.complete();
      }
    });
    
    // Timeout
    Timer(timeout, () {
      timer.cancel();
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    
    await completer.future;
  }
}