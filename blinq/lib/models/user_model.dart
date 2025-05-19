import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String accountNumber;
  final double balance;
  final DateTime birthDate;
  final String? phoneNumber;
  final bool isEmailVerified;
  final bool isActive;
  final List<String> roles;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profileImageUrl;
  final String? transactionPasswordHash;

  UserModel({
    String? id,
    required this.email,
    required this.name,
    required this.accountNumber,
    this.balance = 0.0,
    required this.birthDate,
    this.phoneNumber,
    this.isEmailVerified = false,
    this.isActive = true,
    List<String>? roles,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.profileImageUrl,
    this.transactionPasswordHash,
  })  : id = id ?? const Uuid().v4(),
        roles = roles ?? ['user'],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now() {
    // Validações no construtor
    _validateModel();
  }

  // Método de criação com validações
  factory UserModel.create({
    required String email,
    required String name,
    required DateTime birthDate,
    String? phoneNumber,
    String? accountNumber,
  }) {
    // Validações de criação
    _validateEmail(email);
    _validateName(name);
    _validateBirthDate(birthDate);
    if (phoneNumber != null) _validatePhoneNumber(phoneNumber);

    // Gerar número de conta único se não fornecido
    final generatedAccountNumber =
        accountNumber ?? _generateUniqueAccountNumber();

    return UserModel(
      email: email,
      name: name,
      accountNumber: generatedAccountNumber,
      birthDate: birthDate,
      phoneNumber: phoneNumber,
    );
  }

  // Validações internas
  void _validateModel() {
    _validateEmail(email);
    _validateName(name);
    _validateBirthDate(birthDate);
    if (phoneNumber != null) _validatePhoneNumber(phoneNumber!);
    _validateAccountNumber(accountNumber);
  }

  // Validações estáticas
  static void _validateEmail(String email) {
    final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        caseSensitive: false);

    if (!emailRegex.hasMatch(email)) {
      throw FormatException('Email inválido');
    }
  }

  static void _validateName(String name) {
    if (name.trim().split(' ').length < 2) {
      throw FormatException('Nome completo é obrigatório');
    }

    if (name.length > 100) {
      throw FormatException('Nome muito longo');
    }
  }

  static void _validateBirthDate(DateTime birthDate) {
    final now = DateTime.now();
    final minAge = now.subtract(Duration(days: 365 * 18));
    final maxAge = now.subtract(Duration(days: 365 * 120));

    if (birthDate.isAfter(minAge) || birthDate.isBefore(maxAge)) {
      throw FormatException('Idade inválida');
    }
  }

  static void _validatePhoneNumber(String phoneNumber) {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final phoneRegex = RegExp(r'^[1-9]{2}9?[0-9]{8}$');

    if (!phoneRegex.hasMatch(cleanPhone)) {
      throw FormatException('Número de telefone inválido');
    }
  }

  // Correção do método de validação de número de conta
  static void _validateAccountNumber(String accountNumber) {
    if (accountNumber.length != 8) {
      throw FormatException('Número da conta deve ter 8 dígitos');
    }

    // Evitar sequências repetitivas
    final blockedSequences = [
      '00000000',
      '11111111',
      '22222222',
      '33333333',
      '44444444',
      '55555555',
      '66666666',
      '77777777',
      '88888888',
      '99999999',
      '12345678',
      '87654321'
    ];

    if (blockedSequences.contains(accountNumber)) {
      throw FormatException('Número de conta inválido');
    }
  }

  // Geração de número de conta
  static String _generateUniqueAccountNumber() {
    final random = Random.secure();
    String generateNumber() {
      return List.generate(8, (_) => random.nextInt(10)).join();
    }

    String accountNumber;
    do {
      accountNumber = generateNumber();
    } while (!_isValidAccountNumber(accountNumber));

    return accountNumber;
  }

  // Método auxiliar para validação de número de conta
  static bool _isValidAccountNumber(String accountNumber) {
    try {
      _validateAccountNumber(accountNumber);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Conversão para Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'accountNumber': accountNumber,
      'balance': balance,
      'birthDate': Timestamp.fromDate(birthDate),
      'phoneNumber': phoneNumber,
      'isEmailVerified': isEmailVerified,
      'isActive': isActive,
      'roles': roles,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'profileImageUrl': profileImageUrl,
    };
  }

  // Conversão do Firestore
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      birthDate: (map['birthDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      phoneNumber: map['phoneNumber'],
      isEmailVerified: map['isEmailVerified'] ?? false,
      isActive: map['isActive'] ?? true,
      roles: List<String>.from(map['roles'] ?? ['user']),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      profileImageUrl: map['profileImageUrl'],
    );
  }

  // Método para atualizar usuário
  UserModel copyWith({
    String? email,
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
    bool? isEmailVerified,
    bool? isActive,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      accountNumber: accountNumber,
      balance: balance,
      birthDate: birthDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      roles: roles,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  // Métodos de verificação
  bool get isAdult => DateTime.now().difference(birthDate).inDays >= 365 * 18;

  bool get canTransact => isActive && isEmailVerified;
}
