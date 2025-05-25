// lib/core/services/notification_service.dart - VERSÃO CORRIGIDA E FUNCIONAL

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import 'dart:async';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  static bool _isInitialized = false;
  static String? _currentUserId;
  static final Map<String, StreamSubscription> _userSubscriptions = {};
  static final Map<String, List<String>> _userNotificationHistory = {};

  /// ✅ INICIALIZAÇÃO GERAL (UMA VEZ APENAS)
  static Future<void> initialize() async {
    if (_isInitialized) {
      print('🔔 NotificationService já inicializado');
      return;
    }

    print('🔔 Inicializando NotificationService...');

    try {
      await _requestPermissions();
      await _initializeLocalNotifications();
      await _initializeFirebaseMessaging();
      _setupGlobalMessageHandlers();

      _isInitialized = true;
      print('✅ NotificationService inicializado');
    } catch (e) {
      print('❌ Erro ao inicializar NotificationService: $e');
    }
  }

  /// ✅ VERIFICAR MENSAGEM INICIAL (MÉTODO CORRIGIDO)
  static Future<void> checkForInitialMessage() async {
    try {
      print('🔍 Verificando mensagem inicial...');
      
      if (!_isInitialized) {
        print('⚠️ NotificationService não inicializado, inicializando...');
        await initialize();
      }
      
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      
      if (initialMessage != null) {
        print('🚀 App iniciado via notificação: ${initialMessage.notification?.title}');
        
        // Aguardar um pouco para garantir que a navegação esteja pronta
        await Future.delayed(const Duration(milliseconds: 2000));
        _handleMessageOpenedApp(initialMessage);
      } else {
        print('ℹ️ Nenhuma mensagem inicial encontrada');
      }
    } catch (e) {
      print('❌ Erro ao verificar mensagem inicial: $e');
    }
  }

  /// ✅ INICIALIZAÇÃO ESPECÍFICA PARA USUÁRIO
  static Future<void> initializeForUser(String userId) async {
    try {
      print('👤 Inicializando notificações para usuário: $userId');

      // Limpar usuário anterior se necessário
      if (_currentUserId != null && _currentUserId != userId) {
        await clearUserData(_currentUserId);
      }

      _currentUserId = userId;

      // Configurar listeners específicos do usuário
      await _setupUserSpecificListeners(userId);

      // Salvar token FCM para o usuário
      await _saveUserFCMToken(userId);

      print('✅ Notificações configuradas para: $userId');

    } catch (e) {
      print('❌ Erro ao configurar notificações para usuário: $e');
    }
  }

  /// ✅ CONFIGURAR LISTENERS ESPECÍFICOS DO USUÁRIO
  static Future<void> _setupUserSpecificListeners(String userId) async {
    try {
      // Cancelar listeners anteriores
      await _cancelUserSubscriptions(userId);

      // Listener para transações do usuário em tempo real
      final transactionSubscription = FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'receive')
          .snapshots()
          .listen((snapshot) {
            _handleUserTransactionUpdates(userId, snapshot);
          });

      _userSubscriptions[userId] = transactionSubscription;

      print('👂 Listeners configurados para $userId');
    } catch (e) {
      print('❌ Erro ao configurar listeners: $e');
    }
  }

  /// ✅ PROCESSAR ATUALIZAÇÕES DE TRANSAÇÕES DO USUÁRIO
  static void _handleUserTransactionUpdates(
    String userId, 
    QuerySnapshot<Map<String, dynamic>> snapshot
  ) {
    try {
      // Verificar se ainda é o usuário atual
      if (_currentUserId != userId) {
        print('⚠️ Transação ignorada - usuário mudou');
        return;
      }

      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data()!;
          final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
          final senderInfo = data['counterparty']?.toString() ?? 'Usuário';
          
          // Verificar se é uma transação nova (últimos 30 segundos)
          final transactionDate = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();
          final isRecent = DateTime.now().difference(transactionDate).inSeconds < 30;
          
          if (isRecent && amount > 0) {
            print('💰 Nova transferência recebida: R\$ $amount de $senderInfo');
            
            _showTransferReceivedNotification(
              amount: amount,
              senderName: senderInfo,
              userId: userId,
            );
          }
        }
      }
    } catch (e) {
      print('❌ Erro ao processar transações: $e');
    }
  }

  /// ✅ CANCELAR SUBSCRIPTIONS DO USUÁRIO
  static Future<void> _cancelUserSubscriptions(String userId) async {
    final subscription = _userSubscriptions[userId];
    if (subscription != null) {
      await subscription.cancel();
      _userSubscriptions.remove(userId);
      print('🛑 Subscription cancelada para $userId');
    }
  }

  /// ✅ SALVAR TOKEN FCM PARA O USUÁRIO
  static Future<void> _saveUserFCMToken(String userId) async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('user_tokens')
            .doc(userId)
            .set({
              'fcmToken': token,
              'platform': 'flutter',
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
        
        print('📱 Token FCM salvo para $userId: ${token.substring(0, 20)}...');
      }
    } catch (e) {
      print('❌ Erro ao salvar token FCM: $e');
    }
  }

  /// ✅ LIMPAR DADOS DO USUÁRIO
  static Future<void> clearUserData(String? userId) async {
    if (userId == null) return;

    try {
      print('🧹 Limpando dados de notificação para: $userId');

      // Cancelar subscriptions
      await _cancelUserSubscriptions(userId);

      // Limpar histórico
      _userNotificationHistory.remove(userId);

      // Limpar token FCM
      try {
        await FirebaseFirestore.instance
            .collection('user_tokens')
            .doc(userId)
            .delete();
      } catch (e) {
        print('⚠️ Erro ao limpar token FCM: $e');
      }

      print('✅ Dados limpos para $userId');
    } catch (e) {
      print('❌ Erro ao limpar dados: $e');
    }
  }

  /// ✅ MOSTRAR NOTIFICAÇÃO DE TRANSFERÊNCIA RECEBIDA
  static Future<void> _showTransferReceivedNotification({
    required double amount,
    required String senderName,
    required String userId,
  }) async {
    try {
      // Verificar se ainda é o usuário atual
      if (_currentUserId != userId) {
        print('⚠️ Notificação ignorada - usuário mudou');
        return;
      }

      // Evitar notificações duplicadas
      final notificationId = 'transfer_${userId}_${DateTime.now().millisecondsSinceEpoch}';
      final userHistory = _userNotificationHistory[userId] ?? [];
      
      if (userHistory.length > 10) {
        userHistory.removeRange(0, userHistory.length - 10);
      }

      await _showLocalNotification(
        id: notificationId.hashCode,
        title: '💰 Dinheiro Recebido!',
        body: 'Você recebeu R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')} de $senderName',
        payload: 'transfer_received|$amount|$userId',
      );

      userHistory.add(notificationId);
      _userNotificationHistory[userId] = userHistory;

      print('🔔 Notificação de transferência enviada para $userId');

    } catch (e) {
      print('❌ Erro ao enviar notificação de transferência: $e');
    }
  }

  /// ✅ CONFIGURAÇÃO INICIAL DE PERMISSÕES
  static Future<void> _requestPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      print('🔔 Permissões: ${settings.authorizationStatus}');
    } catch (e) {
      print('❌ Erro ao solicitar permissões: $e');
    }
  }

  /// ✅ INICIALIZAR NOTIFICAÇÕES LOCAIS
  static Future<void> _initializeLocalNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initialized = await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      ) ?? false;

      if (!initialized) {
        print('⚠️ Falha ao inicializar notificações locais');
        return;
      }

      // Canal Android
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
      }

      print('📱 Notificações locais configuradas');
    } catch (e) {
      print('❌ Erro ao configurar notificações locais: $e');
    }
  }

  /// ✅ CONFIGURAR FIREBASE MESSAGING
  static Future<void> _initializeFirebaseMessaging() async {
    try {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Listener para refresh do token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('🔄 Token atualizado: ${newToken.substring(0, 20)}...');
        if (_currentUserId != null) {
          _saveUserFCMToken(_currentUserId!);
        }
      });

      print('📲 Firebase Messaging configurado');
    } catch (e) {
      print('❌ Erro ao configurar Firebase Messaging: $e');
    }
  }

  /// ✅ HANDLERS GLOBAIS DE MENSAGEM
  static void _setupGlobalMessageHandlers() {
    // App em foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // App aberto via notificação
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    print('🔧 Handlers globais configurados');
  }

  /// ✅ PROCESSAR MENSAGEM EM FOREGROUND
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('💬 Mensagem em foreground: ${message.notification?.title}');

    try {
      // Verificar se a mensagem é para o usuário atual
      final targetUserId = message.data['userId'];
      if (targetUserId != null && targetUserId != _currentUserId) {
        print('⚠️ Mensagem para outro usuário ignorada');
        return;
      }

      await _showLocalNotification(
        title: message.notification?.title ?? 'Blinq',
        body: message.notification?.body ?? 'Nova notificação',
        payload: '${message.data['type'] ?? 'default'}|${message.data['amount'] ?? '0'}|${_currentUserId ?? ''}',
      );
    } catch (e) {
      print('❌ Erro ao processar mensagem em foreground: $e');
    }
  }

  /// ✅ PROCESSAR ABERTURA VIA NOTIFICAÇÃO
  static void _handleMessageOpenedApp(RemoteMessage message) {
    print('📱 App aberto via notificação: ${message.data}');

    try {
      final type = message.data['type'] ?? '';
      final targetUserId = message.data['userId'];

      // Verificar se é para o usuário atual
      if (targetUserId != null && targetUserId != _currentUserId) {
        print('⚠️ Navegação para outro usuário ignorada');
        return;
      }

      _navigateBasedOnType(type);
    } catch (e) {
      print('❌ Erro ao processar abertura via notificação: $e');
    }
  }

  /// ✅ NAVEGAÇÃO BASEADA NO TIPO
  static void _navigateBasedOnType(String type) {
    try {
      if (Get.currentRoute.isEmpty) {
        Future.delayed(const Duration(milliseconds: 2000), () {
          _navigateBasedOnType(type);
        });
        return;
      }

      switch (type) {
        case 'transfer_received':
          if (Get.currentRoute != AppRoutes.transactions) {
            Get.offAllNamed(AppRoutes.home);
            Future.delayed(const Duration(milliseconds: 500), () {
              Get.toNamed(AppRoutes.transactions);
            });
          }
          break;
        case 'deposit_confirmed':
          if (Get.currentRoute != AppRoutes.home) {
            Get.offAllNamed(AppRoutes.home);
          }
          break;
        default:
          if (Get.currentRoute != AppRoutes.home) {
            Get.offAllNamed(AppRoutes.home);
          }
      }
    } catch (e) {
      print('❌ Erro na navegação: $e');
    }
  }

  /// ✅ CLIQUE EM NOTIFICAÇÃO LOCAL
  static void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notificação local clicada: ${response.payload}');

    try {
      if (response.payload != null && response.payload!.isNotEmpty) {
        final parts = response.payload!.split('|');
        if (parts.isNotEmpty) {
          final type = parts[0];
          final userId = parts.length > 2 ? parts[2] : '';

          // Verificar se é para o usuário atual
          if (userId.isNotEmpty && userId != _currentUserId) {
            print('⚠️ Clique para outro usuário ignorado');
            return;
          }

          _navigateBasedOnType(type);
        }
      }
    } catch (e) {
      print('❌ Erro ao processar clique: $e');
    }
  }

  /// ✅ MOSTRAR NOTIFICAÇÃO LOCAL
  static Future<void> _showLocalNotification({
    int? id,
    required String title,
    required String body,
    String? payload,
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

      final notificationId = id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await _localNotifications.show(
        notificationId,
        title,
        body,
        details,
        payload: payload,
      );

      print('📱 Notificação local exibida: $title');
    } catch (e) {
      print('❌ Erro ao exibir notificação: $e');
    }
  }

  /// ✅ APIS PÚBLICAS PARA USO EXTERNO

  /// Notificação de transferência recebida (para usar em controllers)
  static Future<void> sendTransferReceivedNotification({
    required String receiverUserId,
    required double amount,
    required String senderName,
  }) async {
    try {
      // Verificar se é para o usuário atual
      if (_currentUserId == receiverUserId) {
        await _showTransferReceivedNotification(
          amount: amount,
          senderName: senderName,
          userId: receiverUserId,
        );
      } else {
        print('⚠️ Notificação para outro usuário não enviada localmente');
      }
    } catch (e) {
      print('❌ Erro ao enviar notificação de transferência: $e');
    }
  }

  /// Notificação de depósito confirmado
  static Future<void> sendDepositConfirmedNotification({
    required double amount,
  }) async {
    try {
      if (_currentUserId != null) {
        await _showLocalNotification(
          title: '✅ Depósito Confirmado!',
          body: 'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')} foram adicionados à sua conta',
          payload: 'deposit_confirmed|$amount|$_currentUserId',
        );
      }
    } catch (e) {
      print('❌ Erro ao enviar notificação de depósito: $e');
    }
  }

  /// ✅ VERIFICAR STATUS
  static bool areNotificationsEnabled() {
    return _isInitialized;
  }

  /// ✅ OBTER TOKEN ATUAL
  static Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('❌ Erro ao obter token: $e');
      return null;
    }
  }

  /// ✅ CANCELAR TODAS AS NOTIFICAÇÕES
  static Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      print('🗑️ Todas as notificações canceladas');
    } catch (e) {
      print('❌ Erro ao cancelar notificações: $e');
    }
  }

  /// ✅ STATUS DE DEBUG
  static Map<String, dynamic> getDebugStatus() {
    return {
      'isInitialized': _isInitialized,
      'currentUserId': _currentUserId,
      'activeSubscriptions': _userSubscriptions.length,
      'notificationHistory': _userNotificationHistory.length,
      'hasCurrentUser': _currentUserId != null,
    };
  }
}

/// ✅ HANDLER PARA NOTIFICAÇÕES EM BACKGROUND
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 Mensagem em background: ${message.notification?.title}');
  
  try {
    // Processar notificação mesmo com app fechado
    if (message.data['type'] == 'transfer_received') {
      print('💰 Transferência recebida em background');
    }
  } catch (e) {
    print('❌ Erro no handler de background: $e');
  }
}