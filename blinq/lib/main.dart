import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';

import 'presentation/bindings/home_binding.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ CARREGAR VARIÁVEIS DE AMBIENTE
    await dotenv.load();
    debugPrint('✅ .env carregado');
  } catch (e) {
    debugPrint('⚠️ .env não encontrado: $e');
  }

  try {
    // ✅ INICIALIZAR FIREBASE
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase inicializado');

    // ✅ CONFIGURAR HANDLER DE BACKGROUND PARA NOTIFICAÇÕES
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    debugPrint('✅ Background message handler configurado');

  } catch (e) {
    debugPrint('❌ Erro na inicialização do Firebase: $e');
  }

  // ✅ INICIALIZAR DEPENDÊNCIAS GLOBAIS
  _initializeGlobalDependencies();

  // ✅ INICIALIZAR NOTIFICAÇÕES (SEM USUÁRIO ESPECÍFICO)
  try {
    await NotificationService.initialize();
    debugPrint('✅ NotificationService inicializado');
  } catch (e) {
    debugPrint('❌ Erro ao inicializar NotificationService: $e');
  }

  runApp(const BlinqApp());
}

void _initializeGlobalDependencies() {
  try {
    debugPrint('🔧 Inicializando dependências globais...');
    HomeBinding().dependencies();
    debugPrint('✅ Dependências globais inicializadas');
  } catch (e) {
    debugPrint('❌ Erro nas dependências globais: $e');
  }
}

class BlinqApp extends StatelessWidget {
  const BlinqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Blinq',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      
      // ✅ CONFIGURAÇÕES ROBUSTAS DO GetX
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      enableLog: true,
      logWriterCallback: (text, {isError = false}) {
        if (isError) {
          debugPrint('❌ GetX Error: $text');
        } else {
          debugPrint('ℹ️ GetX: $text');
        }
      },
      routingCallback: (routing) {
        debugPrint('🧭 Navegação: ${routing?.current}');
      },
      navigatorKey: Get.key,
      
      // ✅ BUILDER PARA CONFIGURAÇÕES GLOBAIS
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      
      // ✅ ROTA 404
      unknownRoute: GetPage(
        name: '/404',
        page: () => const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Página não encontrada',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'A página que você está procurando não existe.',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}