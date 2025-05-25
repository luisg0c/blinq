// lib/core/services/email_validation_service.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_session_manager.dart';

class EmailValidationResult {
  final bool isValid;
  final bool userExists;
  final String? userName;
  final String? userId;
  final String? errorMessage;

  EmailValidationResult({
    required this.isValid,
    required this.userExists,
    this.userName,
    this.userId,
    this.errorMessage,
  });

  factory EmailValidationResult.invalid(String error) {
    return EmailValidationResult(
      isValid: false,
      userExists: false,
      errorMessage: error,
    );
  }

  factory EmailValidationResult.notFound() {
    return EmailValidationResult(
      isValid: true,
      userExists: false,
      errorMessage: 'Usuário não encontrado no Blinq',
    );
  }

  factory EmailValidationResult.found({
    required String userName,
    required String userId,
  }) {
    return EmailValidationResult(
      isValid: true,
      userExists: true,
      userName: userName,
      userId: userId,
    );
  }
}

/// Serviço de validação com isolamento por usuário
class EmailValidationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ✅ CACHE ISOLADO POR USUÁRIO
  static final Map<String, Map<String, EmailValidationResult>> _userCaches = {};
  static final Map<String, Map<String, DateTime>> _userCacheTimestamps = {};
  static const Duration _cacheExpiration = Duration(minutes: 5);

  /// ✅ VALIDAÇÃO COM VERIFICAÇÃO DE SESSÃO
  static Future<EmailValidationResult> validateRecipientEmail(String email) async {
    try {
      // Verificar sessão ativa
      if (!UserSessionManager.hasActiveSession()) {
        return EmailValidationResult.invalid('Sessão expirada');
      }

      final currentUserId = UserSessionManager.getCurrentUserId()!;
      
      print('📧 Validando email: $email para usuário: $currentUserId');

      // Validação de formato
      if (!isValidFormat(email)) {
        return EmailValidationResult.invalid('Formato de email inválido');
      }

      // Verificar auto-transferência
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser?.email?.toLowerCase() == email.toLowerCase()) {
        return EmailValidationResult.invalid('Você não pode transferir para si mesmo');
      }

      // Verificar cache isolado
      final cachedResult = _getCachedResult(currentUserId, email);
      if (cachedResult != null) {
        print('💾 Usando resultado do cache para: $email');
        return cachedResult;
      }

      // Buscar no Firestore
      final result = await _findUserInFirestore(email);
      
      // Salvar no cache isolado
      _setCachedResult(currentUserId, email, result);
      
      return result;

    } catch (e) {
      print('❌ Erro na validação de email: $e');
      return EmailValidationResult.invalid('Erro ao verificar destinatário');
    }
  }

  /// ✅ CACHE ISOLADO POR USUÁRIO
  static EmailValidationResult? _getCachedResult(String userId, String email) {
    final userCache = _userCaches[userId];
    final userTimestamps = _userCacheTimestamps[userId];
    
    if (userCache == null || userTimestamps == null) return null;
    
    final cacheKey = email.toLowerCase();
    final result = userCache[cacheKey];
    final timestamp = userTimestamps[cacheKey];
    
    if (result != null && timestamp != null) {
      if (DateTime.now().difference(timestamp) < _cacheExpiration) {
        return result;
      }
    }
    
    return null;
  }

  /// ✅ SALVAR NO CACHE ISOLADO
  static void _setCachedResult(String userId, String email, EmailValidationResult result) {
    if (!result.isValid) return; // Não cachear erros
    
    _userCaches[userId] ??= {};
    _userCacheTimestamps[userId] ??= {};
    
    final cacheKey = email.toLowerCase();
    _userCaches[userId]![cacheKey] = result;
    _userCacheTimestamps[userId]![cacheKey] = DateTime.now();
  }

  static bool isValidFormat(String email) {
    if (email.trim().isEmpty) return false;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    return emailRegex.hasMatch(email.trim().toLowerCase());
  }

  static Future<EmailValidationResult> _findUserInFirestore(String email) async {
    try {
      print('🔍 Buscando no Firestore: $email');

      final snapshot = await _firestore
          .collection('accounts')
          .where('user.email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();
        final userData = data['user'] as Map<String, dynamic>? ?? {};

        final userName = userData['name']?.toString() ?? 'Usuário Blinq';
        final userId = doc.id;

        print('✅ Usuário encontrado: $userName');

        return EmailValidationResult.found(
          userName: userName,
          userId: userId,
        );
      }

      print('❌ Usuário não encontrado');
      return EmailValidationResult.notFound();
    } catch (e) {
      print('❌ Erro ao buscar no Firestore: $e');
      return EmailValidationResult.invalid('Erro ao verificar usuário');
    }
  }

  /// ✅ LIMPAR CACHE ESPECÍFICO DO USUÁRIO
  static void clearUserCache(String? userId) {
    if (userId != null) {
      _userCaches.remove(userId);
      _userCacheTimestamps.remove(userId);
      print('🧹 Cache limpo para usuário: $userId');
    }
  }

  /// ✅ LIMPAR TODOS OS CACHES
  static void clearCache() {
    _userCaches.clear();
    _userCacheTimestamps.clear();
    print('🧹 Todos os caches de validação limpos');
  }
}