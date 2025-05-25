import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(); // ✅ CARREGAR VARIÁVEIS .ENV AQUI

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase inicializado');
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
      routingCallback: (routing) {
        debugPrint('🧭 Navegação: ${routing?.current}');
      },
    );
  }
}
