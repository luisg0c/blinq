import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

import 'data/services/firebase_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/firestore_service.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/theme/app_theme.dart';
import 'core/utils/logger.dart';

final AppLogger _logger = AppLogger('Main');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar tratamento global de erros
  FlutterError.onError = (FlutterErrorDetails details) {
    _logger.error('Flutter error', details.exception, details.stack);
    FlutterError.presentError(details);
  };
  
  try {
    _logger.info('Inicializando aplicativo...');
    
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _logger.info('Firebase inicializado com sucesso');
    
    // Inicializar serviços
    await _initServices();
    _logger.info('Serviços inicializados com sucesso');
    
    runApp(const BlinqApp());
  } catch (e, stackTrace) {
    _logger.error('Erro ao inicializar aplicativo', e, stackTrace);
    // Mostrar tela de erro genérica
    runApp(ErrorApp(error: e.toString()));
  }
}

Future<void> _initServices() async {
  // Inicializar serviços principais
  await Get.putAsync(() => FirebaseService().init());
  Get.put(FirestoreService());
  Get.put(AuthService());
  
  // Adicionar outros serviços conforme necessário
}

/// Aplicativo principal
class BlinqApp extends StatelessWidget {
  const BlinqApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Blinq',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashPage(),
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

/// Tela de erro para fallback
class ErrorApp extends StatelessWidget {
  final String error;
  
  const ErrorApp({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Oops! Ocorreu um erro',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Tentar reiniciar o app
                    main();
                  },
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}