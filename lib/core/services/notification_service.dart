// lib/core/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  static bool _isInitialized = false;

  /// Inicializar serviço de notificações
  static Future<void> initialize() async {
    if (_isInitialized) {
      print('🔔 NotificationService já foi inicializado');
      return;
    }

    print('🔔 Inicializando NotificationService...');

    try {
      // 1. Solicitar permissões
      await _requestPermissions();

      // 2. Configurar notificações locais
      await _initializeLocalNotifications();

      // 3. Configurar Firebase Messaging
      await _initializeFirebaseMessaging();

      // 4. Configurar handlers
      _setupMessageHandlers();

      // 5. ✅ Verificar mensagem inicial (quando app é aberto via notificação)
      await _handleInitialMessage();

      _isInitialized = true;
      print('✅ NotificationService inicializado com sucesso');
    } catch (e) {
      print('❌ Erro ao inicializar NotificationService: $e');
    }
  }

  static Future<void> _requestPermissions() async {
    try {
      // Firebase Messaging permissions
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      print('🔔 Permission status: ${settings.authorizationStatus}');
      
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('⚠️ Usuário negou permissões de notificação');
      }
    } catch (e) {
      print('❌ Erro ao solicitar permissões: $e');
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false, // Já solicitado pelo Firebase
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // ✅ CORREÇÃO: Verificar se initialized não é null antes de usar
      final bool initialized = await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      ) ?? false; // ✅ Usar ?? false para tratar null

      if (!initialized) {
        print('⚠️ Falha ao inicializar notificações locais');
        return;
      }

      // Canal Android para notificações de transferência
      const androidChannel = AndroidNotificationChannel(
        'blinq_transfers',
        'Transferências Blinq',
        description: 'Notificações de transferências e depósitos',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(androidChannel);
        print('📱 Canal Android criado: ${androidChannel.id}');
      }
    } catch (e) {
      print('❌ Erro ao inicializar notificações locais: $e');
    }
  }

  static Future<void> _initializeFirebaseMessaging() async {
    try {
      // Obter token FCM
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('🔑 FCM Token: ${token.substring(0, 20)}...');
        // TODO: Salvar token no Firestore para notificações direcionadas
      } else {
        print('⚠️ Não foi possível obter FCM token');
      }

      // Listener para refresh do token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('🔄 Token atualizado: ${newToken.substring(0, 20)}...');
        // TODO: Atualizar token no backend
      });

      // Configurar opções de apresentação no foreground
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

    } catch (e) {
      print('❌ Erro ao configurar Firebase Messaging: $e');
    }
  }

  static void _setupMessageHandlers() {
    try {
      // App em foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // App em background (clique na notificação abre o app)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      print('🔧 Message handlers configurados');
    } catch (e) {
      print('❌ Erro ao configurar handlers: $e');
    }
  }

  // ✅ Método separado para lidar com mensagem inicial
  static Future<void> _handleInitialMessage() async {
    try {
      // Verificar se o app foi aberto através de uma notificação
      final RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      
      if (initialMessage != null) {
        print('🚀 App iniciado via notificação: ${initialMessage.notification?.title}');
        
        // Aguardar um pouco para garantir que o GetX está pronto
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // Processar a mensagem inicial
        _handleMessageOpenedApp(initialMessage);
      } else {
        print('🚀 App iniciado normalmente (não via notificação)');
      }
    } catch (e) {
      print('❌ Erro ao verificar mensagem inicial: $e');
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('💬 Mensagem recebida em foreground: ${message.notification?.title}');

    try {
      // Mostrar notificação local quando app está aberto
      await _showLocalNotification(
        title: message.notification?.title ?? 'Blinq',
        body: message.notification?.body ?? 'Nova notificação',
        data: message.data,
      );
    } catch (e) {
      print('❌ Erro ao processar mensagem em foreground: $e');
    }
  }

  static void _handleMessageOpenedApp(RemoteMessage message) {
    print('📱 App aberto via notificação: ${message.data}');

    try {
      final type = message.data['type'] ?? '';
      
      // ✅ Verificar se GetX está inicializado antes de navegar
      if (Get.currentRoute.isEmpty) {
        print('⚠️ GetX ainda não está pronto, agendando navegação...');
        
        // Aguardar GetX estar pronto
        Future.delayed(const Duration(milliseconds: 2000), () {
          _navigateBasedOnType(type);
        });
        return;
      }
      
      _navigateBasedOnType(type);
      
    } catch (e) {
      print('❌ Erro ao processar abertura via notificação: $e');
    }
  }

  static void _navigateBasedOnType(String type) {
    try {
      switch (type) {
        case 'transfer_received':
          print('🧭 Navegando para /transactions');
          if (Get.currentRoute != '/transactions') {
            Get.offAllNamed('/home');
            Future.delayed(const Duration(milliseconds: 500), () {
              Get.toNamed('/transactions');
            });
          }
          break;
        case 'deposit_confirmed':
          print('🧭 Navegando para /home');
          if (Get.currentRoute != '/home') {
            Get.offAllNamed('/home');
          }
          break;
        default:
          print('Tipo de notificação desconhecido: $type');
          // Navegar para home por padrão
          if (Get.currentRoute != '/home') {
            Get.offAllNamed('/home');
          }
      }
    } catch (e) {
      print('❌ Erro na navegação: $e');
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notificação local clicada: ${response.payload}');

    try {
      if (response.payload != null && response.payload!.isNotEmpty) {
        final data = response.payload!.split('|');
        final type = data.isNotEmpty ? data[0] : '';

        _navigateBasedOnType(type);
      }
    } catch (e) {
      print('❌ Erro ao processar clique na notificação: $e');
    }
  }

  /// Mostrar notificação local
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'blinq_transfers',
        'Transferências Blinq',
        channelDescription: 'Notificações de transferências e depósitos',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF6EE1C6),
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(''), // Para textos longos
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final payload = data != null ? '${data['type']}|${data['amount'] ?? ''}' : null;

      await _localNotifications.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );

      print('📱 Notificação local exibida: $title');
    } catch (e) {
      print('❌ Erro ao exibir notificação local: $e');
    }
  }

  /// Notificação de transferência recebida
  static Future<void> sendTransferReceivedNotification({
    required String receiverUserId,
    required double amount,
    required String senderName,
  }) async {
    try {
      print('📱 Enviando notificação de transferência...');

      // Mostrar notificação local
      await _showLocalNotification(
        title: '💰 Dinheiro recebido!',
        body: 'Você recebeu R\$ ${amount.toStringAsFixed(2)} de $senderName',
        data: {
          'type': 'transfer_received',
          'amount': amount.toString(),
          'sender': senderName,
          'receiverId': receiverUserId,
        },
      );

      // TODO: Implementar push notification via backend para outros dispositivos
      print('✅ Notificação enviada para $receiverUserId');

    } catch (e) {
      print('❌ Erro ao enviar notificação de transferência: $e');
    }
  }

  /// Notificação de depósito confirmado
  static Future<void> sendDepositConfirmedNotification({
    required double amount,
  }) async {
    try {
      await _showLocalNotification(
        title: '✅ Depósito confirmado!',
        body: 'R\$ ${amount.toStringAsFixed(2)} foram adicionados à sua conta',
        data: {
          'type': 'deposit_confirmed',
          'amount': amount.toString(),
        },
      );

      print('✅ Notificação de depósito enviada');
    } catch (e) {
      print('❌ Erro ao enviar notificação de depósito: $e');
    }
  }

  /// Obter token FCM atual
  static Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('❌ Erro ao obter FCM token: $e');
      return null;
    }
  }

  /// ✅ Método para verificar e processar mensagem inicial manualmente
  /// Útil para chamar após login ou mudança de rota
  static Future<void> checkForInitialMessage() async {
    if (!_isInitialized) {
      print('⚠️ NotificationService não foi inicializado ainda');
      return;
    }

    await _handleInitialMessage();
  }

  /// Cancelar todas as notificações
  static Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      print('🗑️ Todas as notificações canceladas');
    } catch (e) {
      print('❌ Erro ao cancelar notificações: $e');
    }
  }

  /// Verificar se notificações estão habilitadas
  static Future<bool> areNotificationsEnabled() async {
    try {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        // ✅ CORREÇÃO: Verificar se enabled não é null
        final bool enabled = await androidPlugin.areNotificationsEnabled() ?? false;
        return enabled;
      }
      
      return true; // Assumir true para iOS por simplicidade
    } catch (e) {
      print('❌ Erro ao verificar status das notificações: $e');
      return false;
    }
  }
}

// ✅ Handler para notificações em background (função top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 Mensagem em background: ${message.notification?.title}');
  
  // Processar notificação mesmo com app fechado
  try {
    if (message.data['type'] == 'transfer_received') {
      print('💰 Transferência recebida em background');
      // TODO: Salvar no banco local se necessário
    }
  } catch (e) {
    print('❌ Erro no handler de background: $e');
  }
}