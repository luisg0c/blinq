import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  /// Inicializar serviço de notificações
  static Future<void> initialize() async {
    print('🔔 Inicializando NotificationService...');

    // 1. Solicitar permissões
    await _requestPermissions();

    // 2. Configurar notificações locais
    await _initializeLocalNotifications();

    // 3. Configurar Firebase Messaging
    await _initializeFirebaseMessaging();

    // 4. Configurar handlers
    _setupMessageHandlers();

    print('✅ NotificationService inicializado');
  }

  static Future<void> _requestPermissions() async {
    // Firebase Messaging permissions
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('🔔 Permission status: ${settings.authorizationStatus}');
  }

  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Canal Android para notificações de transferência
    const androidChannel = AndroidNotificationChannel(
      'blinq_transfers',
      'Transferências Blinq',
      description: 'Notificações de transferências recebidas',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static Future<void> _initializeFirebaseMessaging() async {
    // Obter token FCM
    final token = await _firebaseMessaging.getToken();
    print('🔑 FCM Token: $token');

    // TODO: Enviar token para backend/Firestore para notificações direcionadas
    // await _saveTokenToFirestore(token);

    // Listener para refresh do token
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('🔄 Token atualizado: $newToken');
      // TODO: Atualizar token no backend
    });
  }

  static void _setupMessageHandlers() {
    // App em foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // App em background (clique na notificação abre o app)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // App terminado (clique na notificação inicia o app)
    FirebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessageOpenedApp(message);
      }
    });
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('💬 Mensagem recebida em foreground: ${message.notification?.title}');

    // Mostrar notificação local quando app está aberto
    await _showLocalNotification(
      title: message.notification?.title ?? 'Blinq',
      body: message.notification?.body ?? 'Nova notificação',
      data: message.data,
    );
  }

  static void _handleMessageOpenedApp(RemoteMessage message) {
    print('📱 App aberto via notificação: ${message.data}');

    final type = message.data['type'];
    switch (type) {
      case 'transfer_received':
        // Navegar para tela de transações
        Get.toNamed('/transactions');
        break;
      case 'deposit_confirmed':
        // Navegar para home
        Get.toNamed('/home');
        break;
      default:
        print('Tipo de notificação desconhecido: $type');
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notificação local clicada: ${response.payload}');

    if (response.payload != null) {
      final data = response.payload!.split('|');
      final type = data.isNotEmpty ? data[0] : '';

      switch (type) {
        case 'transfer_received':
          Get.toNamed('/transactions');
          break;
        case 'deposit_confirmed':
          Get.toNamed('/home');
          break;
      }
    }
  }

  /// Mostrar notificação local
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'blinq_transfers',
      'Transferências Blinq',
      channelDescription: 'Notificações de transferências recebidas',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF6EE1C6),
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: data != null ? '${data['type']}|${data['amount'] ?? ''}' : null,
    );
  }

  /// Notificação de transferência recebida
  static Future<void> sendTransferReceivedNotification({
    required String receiverUserId,
    required double amount,
    required String senderName,
  }) async {
    try {
      // 1. Mostrar notificação local (simulação)
      await _showLocalNotification(
        title: '💰 Dinheiro recebido!',
        body: 'Você recebeu R\$ ${amount.toStringAsFixed(2)} de $senderName',
        data: {
          'type': 'transfer_received',
          'amount': amount.toString(),
          'sender': senderName,
        },
      );

      // 2. TODO: Enviar push notification via backend
      // await _sendPushToUser(receiverUserId, {...});

      print('📱 Notificação enviada para $receiverUserId');

    } catch (e) {
      print('❌ Erro ao enviar notificação: $e');
    }
  }

  /// Notificação de depósito confirmado
  static Future<void> sendDepositConfirmedNotification({
    required double amount,
  }) async {
    await _showLocalNotification(
      title: '✅ Depósito confirmado!',
      body: 'R\$ ${amount.toStringAsFixed(2)} foram adicionados à sua conta',
      data: {
        'type': 'deposit_confirmed',
        'amount': amount.toString(),
      },
    );
  }

  /// Obter token FCM atual
  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Salvar token no Firestore (para notificações direcionadas)
  static Future<void> saveTokenToFirestore(String userId, String token) async {
    try {
      // TODO: Implementar salvamento no Firestore
      // await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(userId)
      //     .update({
      //   'fcmTokens': FieldValue.arrayUnion([token]),
      //   'lastTokenUpdate': FieldValue.serverTimestamp(),
      // });
      
      print('💾 Token salvo para $userId: $token');
    } catch (e) {
      print('❌ Erro ao salvar token: $e');
    }
  }

  /// Cancelar todas as notificações
  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Configurar badge do app (iOS)
  static Future<void> setBadgeCount(int count) async {
    // TODO: Implementar badge count
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

// ✅ Handler para notificações em background (função top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 Mensagem em background: ${message.notification?.title}');
  
  // Processar notificação mesmo com app fechado
  if (message.data['type'] == 'transfer_received') {
    // Lógica específica para transferências
    print('💰 Transferência recebida em background');
  }
}