import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  String toString() {
    return 'EmailValidationResult(isValid: $isValid, userExists: $userExists, userName: $userName, userId: $userId)';
  }
}

class EmailValidationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ VALIDAÇÃO COMPLETA DE EMAIL PARA TRANSFERÊNCIA
  static Future<EmailValidationResult> validateRecipientEmail(String email) async {
    try {
      print('📧 Validando email do destinatário: $email');

      // 1. Validação de formato
      if (!isValidFormat(email)) {
        return EmailValidationResult.invalid('Formato de email inválido');
      }

      // 2. Verificar se não é o próprio usuário
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser?.email?.toLowerCase() == email.toLowerCase()) {
        return EmailValidationResult.invalid('Você não pode transferir para si mesmo');
      }

      // 3. Buscar usuário no Firestore
      final userResult = await _findUserInFirestore(email);
      return userResult;

    } catch (e) {
      print('❌ Erro na validação de email: $e');
      return EmailValidationResult.invalid('Erro ao verificar destinatário');
    }
  }

  /// ✅ VALIDAÇÃO DE FORMATO DE EMAIL
  static bool isValidFormat(String email) {
    if (email.trim().isEmpty) return false;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    return emailRegex.hasMatch(email.trim().toLowerCase());
  }

  /// ✅ BUSCAR USUÁRIO NO FIRESTORE
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

        print('✅ Usuário encontrado no Firestore: $userName');

        return EmailValidationResult.found(
          userName: userName,
          userId: userId,
        );
      }

      print('❌ Usuário não encontrado no Firestore');
      return EmailValidationResult.notFound();
    } catch (e) {
      print('❌ Erro ao buscar no Firestore: $e');
      return EmailValidationResult.invalid('Erro ao verificar usuário');
    }
  }

  /// ✅ VALIDAÇÃO RÁPIDA APENAS DE FORMATO (para uso em tempo real)
  static bool quickFormatValidation(String email) {
    return isValidFormat(email);
  }

  /// ✅ BUSCAR MÚLTIPLOS USUÁRIOS (para autocomplete)
  static Future<List<EmailValidationResult>> searchUsers(String query) async {
    try {
      if (query.length < 3) return [];

      print('🔍 Buscando usuários com query: $query');

      final snapshot = await _firestore
          .collection('accounts')
          .where('user.email', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('user.email', isLessThan: '${query.toLowerCase()}\uf8ff')
          .limit(5)
          .get();

      final results = <EmailValidationResult>[];
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final userData = data['user'] as Map<String, dynamic>? ?? {};
        
        final userName = userData['name']?.toString() ?? 'Usuário Blinq';
        final userEmail = userData['email']?.toString() ?? '';
        
        // Não incluir o próprio usuário
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser?.email?.toLowerCase() != userEmail.toLowerCase()) {
          results.add(EmailValidationResult.found(
            userName: userName,
            userId: doc.id,
          ));
        }
      }

      print('📋 ${results.length} usuários encontrados');
      return results;
    } catch (e) {
      print('❌ Erro na busca de usuários: $e');
      return [];
    }
  }

  /// ✅ CACHE SIMPLES PARA VALIDAÇÕES RECENTES
  static final Map<String, EmailValidationResult> _cache = {};
  static const Duration _cacheExpiration = Duration(minutes: 5);
  static final Map<String, DateTime> _cacheTimestamps = {};

  /// ✅ VALIDAÇÃO COM CACHE
  static Future<EmailValidationResult> validateWithCache(String email) async {
    final cacheKey = email.toLowerCase();
    
    // Verificar cache
    if (_cache.containsKey(cacheKey)) {
      final timestamp = _cacheTimestamps[cacheKey];
      if (timestamp != null && 
          DateTime.now().difference(timestamp) < _cacheExpiration) {
        print('💾 Usando resultado do cache para: $email');
        return _cache[cacheKey]!;
      }
    }

    // Buscar novo resultado
    final result = await validateRecipientEmail(email);
    
    // Salvar no cache apenas resultados válidos
    if (result.isValid) {
      _cache[cacheKey] = result;
      _cacheTimestamps[cacheKey] = DateTime.now();
    }

    return result;
  }

  /// ✅ LIMPAR CACHE
  static void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    print('🧹 Cache de validação de emails limpo');
  }

  /// ✅ STATUS DO SERVIÇO
  static Map<String, dynamic> getServiceStatus() {
    return {
      'cacheSize': _cache.length,
      'cacheKeys': _cache.keys.toList(),
      'isFirestoreConnected': _firestore != null,
      'currentUser': FirebaseAuth.instance.currentUser?.email,
    };
  }
}