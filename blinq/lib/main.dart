import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'theme/app_theme.dart';
<<<<<<< Updated upstream
import 'firebase_options.dart'; 
=======
import 'firebase_options.dart';
import 'core/services/notification_service.dart';

// ✅ Handler para notificações em background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('🔔 Mensagem em background: ${message.notification?.title}');
}
>>>>>>> Stashed changes

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
<<<<<<< Updated upstream
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
=======
  try {
    // ✅ Inicializar Firebase primeiro
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('🔥 Firebase inicializado');
    
    // ✅ Configurar handler de background
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
    // ✅ Inicializar notificações
    await NotificationService.initialize();
    
  } catch (e) {
    debugPrint('❌ Erro na inicialização: $e');
  }
>>>>>>> Stashed changes
  
  runApp(const BlinqApp());
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
      // ✅ Callback quando o app estiver completamente inicializado
      onInit: () {
        debugPrint('🚀 GetMaterialApp inicializado');
        // Verificar mensagem inicial após um pequeno delay
        Future.delayed(const Duration(milliseconds: 1500), () {
          NotificationService.checkForInitialMessage();
        });
      },
      // ✅ Callback para mudanças de rota
      routingCallback: (routing) {
        debugPrint('🧭 Navegação: ${routing?.current}');
      },
    );
  }
}