import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// ✅ SERVIÇO CENTRALIZADO PARA OPERAÇÕES FIREBASE SEGURAS
class FirebaseSecurityService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ✅ VERIFICAR SE USUÁRIO ESTÁ AUTENTICADO
  static User? get currentUser => _auth.currentUser;
  
  static bool get isAuthenticated => currentUser != null;

  static String get currentUserId {
    final user = currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }
    return user.uid;
  }

  /// ✅ OPERAÇÕES SEGURAS DE CONTA
  static Future<void> createUserAccount({
    required String userId,
    required String email,
    required String name,
    double initialBalance = 1000.0,
  }) async {
    try {
      print('🏦 Criando conta para: $email');

      // Verificar se conta já existe
      final accountRef = _firestore.collection('accounts').doc(userId);
      final accountSnap = await accountRef.get();
      
      if (accountSnap.exists) {
        print('⚠️ Conta já existe para: $userId');
        return;
      }

      // Criar conta com transação atômica
      await _firestore.runTransaction((transaction) async {
        transaction.set(accountRef, {
          'balance': initialBalance,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'status': 'active',
          'user': {
            'id': userId,
            'email': email.toLowerCase(),
            'name': name,
          },
          'limits': {
            'daily': 5000.0,
            'perTransaction': 2000.0,
            'monthly': 50000.0,
          },
          'security': {
            'lastLogin': FieldValue.serverTimestamp(),
            'loginAttempts': 0,
            'isBlocked': false,
          },
        });

        // Criar transação de boas-vindas
        final welcomeTransactionRef = _firestore.collection('transactions').doc();
        transaction.set(welcomeTransactionRef, {
          'userId': userId,
          'type': 'bonus',
          'amount': initialBalance,
          'description': 'Bônus de boas-vindas - Bem-vindo ao Blinq! 🎉',
          'counterparty': 'Blinq',
          'status': 'completed',
          'date': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      print('✅ Conta criada com sucesso');
    } catch (e) {
      print('❌ Erro ao criar conta: $e');
      throw Exception('Erro ao criar conta: $e');
    }
  }

  /// ✅ VERIFICAR LIMITE DE TRANSAÇÃO
  static Future<bool> checkTransactionLimit({
    required String userId,
    required double amount,
    required String type,
  }) async {
    try {
      print('🔍 Verificando limites para: $userId');

      final accountDoc = await _firestore.collection('accounts').doc(userId).get();
      if (!accountDoc.exists) {
        throw Exception('Conta não encontrada');
      }

      final data = accountDoc.data()!;
      final limits = data['limits'] as Map<String, dynamic>? ?? {};

      // Verificar limite por transação
      final perTransactionLimit = (limits['perTransaction'] as num?)?.toDouble() ?? 2000.0;
      if (amount > perTransactionLimit) {
        throw Exception('Valor excede o limite por transação: R\$ ${perTransactionLimit.toStringAsFixed(2)}');
      }

      // Verificar limite diário
      final dailyLimit = (limits['daily'] as num?)?.toDouble() ?? 5000.0;
      final todaySpent = await _getTodaySpentAmount(userId);
      
      if ((todaySpent + amount) > dailyLimit) {
        final remaining = dailyLimit - todaySpent;
        throw Exception('Valor excede o limite diário. Disponível: R\$ ${remaining.toStringAsFixed(2)}');
      }

      print('✅ Limites verificados - OK');
      return true;

    } catch (e) {
      print('❌ Erro na verificação de limites: $e');
      rethrow;
    }
  }

  /// ✅ CALCULAR GASTOS DO DIA
  static Future<double> _getTodaySpentAmount(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .where('amount', isLessThan: 0) // Apenas saídas (valores negativos)
          .get();

      double totalSpent = 0;
      for (var doc in snapshot.docs) {
        final amount = (doc.data()['amount'] as num?)?.toDouble() ?? 0.0;
        totalSpent += amount.abs(); // Converter para positivo
      }

      return totalSpent;
    } catch (e) {
      print('❌ Erro ao calcular gastos do dia: $e');
      return 0.0;
    }
  }

  /// ✅ OPERAÇÃO SEGURA DE TRANSFERÊNCIA
  static Future<void> secureTransfer({
    required String senderId,
    required String receiverId,
    required double amount,
    required String description,
  }) async {
    try {
      print('💸 Iniciando transferência segura');
      print('   De: $senderId');
      print('   Para: $receiverId');
      print('   Valor: R\$ $amount');

      // Verificações de segurança
      await _performSecurityChecks(senderId, amount);

      // Executar transferência com transação atômica
      await _firestore.runTransaction((transaction) async {
        // Obter saldos atuais
        final senderRef = _firestore.collection('accounts').doc(senderId);
        final receiverRef = _firestore.collection('accounts').doc(receiverId);

        final senderSnap = await transaction.get(senderRef);
        final receiverSnap = await transaction.get(receiverRef);

        if (!senderSnap.exists || !receiverSnap.exists) {
          throw Exception('Uma das contas não foi encontrada');
        }

        final senderBalance = (senderSnap.data()!['balance'] as num).toDouble();
        final receiverBalance = (receiverSnap.data()!['balance'] as num).toDouble();

        // Verificar saldo
        if (senderBalance < amount) {
          throw Exception('Saldo insuficiente');
        }

        // Atualizar saldos
        transaction.update(senderRef, {
          'balance': senderBalance - amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        transaction.update(receiverRef, {
          'balance': receiverBalance + amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Criar transações
        final outTransactionRef = _firestore.collection('transactions').doc();
        transaction.set(outTransactionRef, {
          'userId': senderId,
          'type': 'transfer',
          'amount': -amount,
          'description': description,
          'counterparty': receiverId,
          'status': 'completed',
          'date': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        final inTransactionRef = _firestore.collection('transactions').doc();
        transaction.set(inTransactionRef, {
          'userId': receiverId,
          'type': 'receive',
          'amount': amount,
          'description': 'Transferência recebida',
          'counterparty': senderId,
          'status': 'completed',
          'date': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      print('✅ Transferência concluída com sucesso');

    } catch (e) {
      print('❌ Erro na transferência: $e');
      await _logSecurityEvent(senderId, 'TRANSFER_FAILED', {'error': e.toString(), 'amount': amount});
      rethrow;
    }
  }

  /// ✅ VERIFICAÇÕES DE SEGURANÇA
  static Future<void> _performSecurityChecks(String userId, double amount) async {
    // Verificar se conta está ativa
    final accountDoc = await _firestore.collection('accounts').doc(userId).get();
    if (!accountDoc.exists) {
      throw Exception('Conta não encontrada');
    }

    final data = accountDoc.data()!;
    final security = data['security'] as Map<String, dynamic>? ?? {};

    // Verificar se conta está bloqueada
    if (security['isBlocked'] == true) {
      throw Exception('Conta temporariamente bloqueada por segurança');
    }

    // Verificar limites
    await checkTransactionLimit(userId: userId, amount: amount, type: 'transfer');

    // Verificar padrão suspeito (muitas transações em pouco tempo)
    await _checkSuspiciousActivity(userId);
  }

  /// ✅ VERIFICAR ATIVIDADE SUSPEITA
  static Future<void> _checkSuspiciousActivity(String userId) async {
    try {
      final now = DateTime.now();
      final lastHour = now.subtract(const Duration(hours: 1));

      final recentTransactions = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThan: Timestamp.fromDate(lastHour))
          .get();

      // Se mais de 10 transações na última hora, considerar suspeito
      if (recentTransactions.docs.length > 10) {
        await _logSecurityEvent(userId, 'SUSPICIOUS_ACTIVITY', {
          'transactionCount': recentTransactions.docs.length,
          'timeWindow': '1 hour'
        });

        // Opcional: bloquear temporariamente
        // await _temporaryBlock(userId);
      }
    } catch (e) {
      print('❌ Erro ao verificar atividade suspeita: $e');
    }
  }

  /// ✅ LOG DE EVENTOS DE SEGURANÇA
  static Future<void> _logSecurityEvent(String userId, String eventType, Map<String, dynamic> details) async {
    try {
      await _firestore.collection('security_logs').add({
        'userId': userId,
        'eventType': eventType,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
        'userAgent': 'Flutter App',
        'ip': 'mobile', // Em produção, capturar IP real
      });

      print('🔒 Evento de segurança logado: $eventType para $userId');
    } catch (e) {
      print('❌ Erro ao logar evento de segurança: $e');
    }
  }

  /// ✅ ATUALIZAR ÚLTIMO LOGIN
  static Future<void> updateLastLogin(String userId) async {
    try {
      await _firestore.collection('accounts').doc(userId).update({
        'security.lastLogin': FieldValue.serverTimestamp(),
        'security.loginAttempts': 0,
      });
    } catch (e) {
      print('❌ Erro ao atualizar último login: $e');
    }
  }

  /// ✅ INCREMENTAR TENTATIVAS DE LOGIN
  static Future<void> incrementLoginAttempts(String email) async {
    try {
      // Buscar conta pelo email
      final snapshot = await _firestore
          .collection('accounts')
          .where('user.email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final security = doc.data()['security'] as Map<String, dynamic>? ?? {};
        final attempts = (security['loginAttempts'] as num?)?.toInt() ?? 0;

        await doc.reference.update({
          'security.loginAttempts': attempts + 1,
          'security.lastFailedLogin': FieldValue.serverTimestamp(),
        });

        // Bloquear após 5 tentativas
        if (attempts >= 4) {
          await doc.reference.update({
            'security.isBlocked': true,
            'security.blockedUntil': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print('❌ Erro ao incrementar tentativas de login: $e');
    }
  }

  /// ✅ VALIDAÇÃO DE DADOS DE ENTRADA
  static bool validateTransactionData({
    required double amount,
    required String description,
    String? recipientEmail,
  }) {
    // Validar valor
    if (amount <= 0 || amount > 50000) {
      return false;
    }

    // Validar descrição
    if (description.trim().isEmpty || description.length > 200) {
      return false;
    }

    // Validar email do destinatário se fornecido
    if (recipientEmail != null && !GetUtils.isEmail(recipientEmail)) {
      return false;
    }

    return true;
  }

  /// ✅ SANITIZAR DADOS DE ENTRADA
  static Map<String, dynamic> sanitizeTransactionData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};

    // Sanitizar valor
    if (data['amount'] is num) {
      sanitized['amount'] = (data['amount'] as num).toDouble();
    }

    // Sanitizar descrição
    if (data['description'] is String) {
      sanitized['description'] = (data['description'] as String)
          .trim()
          .replaceAll(RegExp(r'[<>"]'), '') // Remover caracteres perigosos
          .substring(0, 200); // Limitar tamanho
    }

    // Sanitizar email
    if (data['email'] is String) {
      sanitized['email'] = (data['email'] as String).toLowerCase().trim();
    }

    return sanitized;
  }

  /// ✅ VERIFICAR SAÚDE DA CONEXÃO FIREBASE
  static Future<bool> checkFirebaseHealth() async {
    try {
      // Tentar uma operação simples
      await _firestore.collection('health_check').limit(1).get();
      return true;
    } catch (e) {
      print('❌ Firebase não está saudável: $e');
      return false;
    }
  }

  /// ✅ CONFIGURAR REGRAS DE SEGURANÇA (para referência)
  static String getFirestoreSecurityRules() {
    return '''
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Regras para contas - apenas o próprio usuário
    match /accounts/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Regras para transações - apenas o próprio usuário
    match /transactions/{transactionId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Logs de segurança - apenas leitura pelos admins
    match /security_logs/{logId} {
      allow read: if request.auth != null && 
        request.auth.token.admin == true;
      allow write: if request.auth != null;
    }
    
    // Health check - público apenas para leitura
    match /health_check/{doc} {
      allow read: if true;
      allow write: if false;
    }
  }
}
''';
  }
}