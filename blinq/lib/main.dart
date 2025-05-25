// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart'; // ❌ Comentado
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';
// import 'core/services/notification_service.dart'; // ❌ Comentado

// ❌ Comentado o handler de background
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   debugPrint('🔔 Mensagem em background: ${message.notification?.title}');
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // ✅ Inicializar apenas Firebase Core
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase inicializado');
    
    // ❌ Comentado configuração de messaging
    // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
    // ❌ Comentado inicialização de notificações  
    // await NotificationService.initialize();
    
  } catch (e) {
    debugPrint('❌ Erro na inicialização: $e');
  }
  
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
      onInit: () {
        debugPrint('🚀 Blinq App inicializado');
        // ❌ Comentado verificação de notificações
        // Future.delayed(const Duration(milliseconds: 1500), () {
        //   NotificationService.checkForInitialMessage();
        // });
      },
      routingCallback: (routing) {
        debugPrint('🧭 Navegação: ${routing?.current}');
      },
    );
  }
}