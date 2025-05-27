import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';

import 'presentation/bindings/home_binding.dart';
import 'core/services/notification_service.dart';
import 'core/services/app_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ CARREGAR VARIÁVEIS DE AMBIENTE (OPCIONAL)
    try {
      await dotenv.load();
      debugPrint('✅ .env carregado');
    } catch (e) {
      debugPrint('⚠️ .env não encontrado (opcional): $e');
    }

    // ✅ INICIALIZAR FIREBASE
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase inicializado');

    // ✅ CONFIGURAR HANDLER DE BACKGROUND PARA NOTIFICAÇÕES
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    debugPrint('✅ Background message handler configurado');

  } catch (e) {
    debugPrint('❌ Erro crítico na inicialização: $e');
    // Continuar mesmo com erro para não quebrar o app
  }

  // ✅ INICIALIZAR DEPENDÊNCIAS GLOBAIS CRÍTICAS
  _initializeGlobalDependencies();

  // ✅ INICIALIZAR NOTIFICAÇÕES (SEM USUÁRIO ESPECÍFICO)
  try {
    await NotificationService.initialize();
    debugPrint('✅ NotificationService inicializado');
  } catch (e) {
    debugPrint('❌ Erro ao inicializar NotificationService (não crítico): $e');
  }

  runApp(const BlinqApp());
}

/// ✅ INICIALIZAÇÃO ROBUSTA DAS DEPENDÊNCIAS GLOBAIS
void _initializeGlobalDependencies() {
  try {
    debugPrint('🔧 Inicializando dependências globais...');
    
    // Usar o HomeBinding que já contém todas as dependências necessárias
    HomeBinding().dependencies();
    
    debugPrint('✅ Dependências globais inicializadas');
  } catch (e) {
    debugPrint('❌ Erro nas dependências globais: $e');
    
    // Tentar recuperação básica
    try {
      debugPrint('🔄 Tentando recuperação básica...');
      HomeBinding().dependencies();
      debugPrint('✅ Recuperação básica bem-sucedida');
    } catch (recoveryError) {
      debugPrint('💥 Falha na recuperação: $recoveryError');
    }
  }
}

class BlinqApp extends StatefulWidget {
  const BlinqApp({super.key});

  @override
  State<BlinqApp> createState() => _BlinqAppState();
}

class _BlinqAppState extends State<BlinqApp> {
  bool _isAppInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// ✅ INICIALIZAÇÃO APÓS GETX ESTAR PRONTO
  void _initializeApp() {
    // Aguardar um frame para garantir que o GetMaterialApp foi criado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupAppAfterGetX();
    });
  }

  /// ✅ CONFIGURAR APP APÓS GETX ESTAR PRONTO
  void _setupAppAfterGetX() async {
    try {
      // Aguardar um pouco para garantir que GetX está completamente pronto
      await Future.delayed(const Duration(milliseconds: 500));
      
      debugPrint('🚀 Configurando listeners após GetX estar pronto...');
      
      // Configurar listeners globais
      AppInitializer.setupGlobalListeners();
      
      setState(() {
        _isAppInitialized = true;
      });
      
      debugPrint('✅ App configurado e pronto');
      
    } catch (e) {
      debugPrint('❌ Erro na configuração pós-GetX: $e');
      setState(() {
        _isAppInitialized = true; // Continuar mesmo com erro
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Blinq - Seu banco digital',
      debugShowCheckedModeBanner: false,
      
      // ✅ TEMAS
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      
      // ✅ NAVEGAÇÃO
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      
      // ✅ CONFIGURAÇÕES ROBUSTAS DO GetX
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      enableLog: true,
      
      // ✅ LOGGER CUSTOMIZADO PARA DEBUG
      logWriterCallback: (text, {isError = false}) {
        if (isError) {
          debugPrint('❌ GetX Error: $text');
        } else {
          // Filtrar logs muito verbosos em produção
          if (text.contains('GOING TO ROUTE') || 
              text.contains('CLOSE TO ROUTE') ||
              text.contains('FIND EX')) {
            // debugPrint('ℹ️ GetX: $text');
          }
        }
      },
      
      // ✅ CALLBACK DE ROTEAMENTO PARA DEBUG
      routingCallback: (routing) {
        if (routing != null && _isAppInitialized) {
          debugPrint('🧭 Navegação: ${routing.current}');
          
          // Verificar saúde da app a cada navegação (apenas se inicializado)
          Future.delayed(const Duration(milliseconds: 500), () {
            AppInitializer.repairAppIfNeeded();
          });
        }
      },
      
      navigatorKey: Get.key,
      
      // ✅ BUILDER PARA CONFIGURAÇÕES GLOBAIS E TRATAMENTO DE ERROS
      builder: (context, child) {
        // Configurar escala de texto fixa para consistência
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling, // Evitar mudanças de escala de sistema
          ),
          child: Builder(
            builder: (context) {
              // Adicionar tratamento de erros globais
              ErrorWidget.builder = (FlutterErrorDetails details) {
                debugPrint('🚨 Erro global capturado: ${details.exception}');
                
                return Material(
                  child: Container(
                    color: const Color(0xFFE5E5E5),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Color(0xFF6EE1C6),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Oops! Algo deu errado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0D1517),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Reinicie o app para continuar',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              };
              
              return child ?? const SizedBox.shrink();
            },
          ),
        );
      },
      
      // ✅ ROTA 404 PERSONALIZADA
      unknownRoute: GetPage(
        name: '/404',
        page: () => const NotFoundPage(),
      ),
      
      // ✅ CONFIGURAÇÕES DE ACESSIBILIDADE
      locale: const Locale('pt', 'BR'),
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}

/// ✅ PÁGINA 404 PERSONALIZADA
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Blinq
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF6EE1C6),
                        Color(0xFF5BC4A8),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'B',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                const Icon(
                  Icons.map_outlined,
                  size: 48,
                  color: Color(0xFF6B7280),
                ),
                
                const SizedBox(height: 16),
                
                const Text(
                  'Página não encontrada',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D1517),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'A página que você está procurando não existe ou foi movida.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Botão para voltar ao início
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Aguardar um pouco para garantir que GetX está pronto
                      Future.delayed(const Duration(milliseconds: 200), () {
                        try {
                          if (Get.isRegistered<GetMaterialController>()) {
                            Get.offAllNamed('/home');
                          } else {
                            // Fallback manual se GetX não estiver pronto
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/welcome', 
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          debugPrint('❌ Erro na navegação 404: $e');
                          // Fallback para welcome se home não funcionar
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/welcome', 
                            (route) => false,
                          );
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6EE1C6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Voltar ao Início',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Botão de debug (apenas para desenvolvimento)
                if (kDebugMode)
                  TextButton(
                    onPressed: () {
                      // Mostrar informações de debug
                      final debugInfo = AppInitializer.getDebugInfo();
                      Get.dialog(
                        AlertDialog(
                          title: const Text('Debug Info'),
                          content: SingleChildScrollView(
                            child: Text(debugInfo.toString()),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Fechar'),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back();
                                AppInitializer.forceReset();
                              },
                              child: const Text('Force Reset'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      'Info Debug',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
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

/// ✅ HANDLER PARA NOTIFICAÇÕES EM BACKGROUND (GLOBAL)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Não inicializar Firebase aqui pois já foi inicializado
  debugPrint('🔔 Mensagem em background: ${message.notification?.title}');
  
  try {
    // Processar notificação mesmo com app fechado
    if (message.data['type'] == 'transfer_received') {
      debugPrint('💰 Transferência recebida em background');
    }
    
    // Aqui poderia salvar dados localmente ou fazer outras operações necessárias
    
  } catch (e) {
    debugPrint('❌ Erro no handler de background: $e');
  }
}
