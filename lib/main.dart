import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';

import 'presentation/bindings/home_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();
    debugPrint('✅ .env carregado');
  } catch (e) {
    debugPrint('⚠️ .env não encontrado: $e');
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase inicializado');
  } catch (e) {
    debugPrint('❌ Erro na inicialização do Firebase: $e');
  }

  _initializeGlobalDependencies();

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
    return GetMaterialApp( // ✅ CORRIGIDO: GetMaterialApp
      title: 'Blinq',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      // ✅ CONFIGURAÇÃO ROBUSTA DO GetX
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
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling, 
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      unknownRoute: GetPage(
        name: '/404',
        page: () => const Scaffold(
          body: Center(
            child: Text('Página não encontrada'),
          ),
        ),
      ),
    );
  }
}