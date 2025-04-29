import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de conta bancária
class AccountModel {
  final String id;
  final String userId;
  final double balance;
  final String? transactionPassword; // Hash da senha de transação
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  AccountModel({
    required this.id,
    required this.userId,
    this.balance = 0.0,
    this.transactionPassword,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria uma cópia do modelo com novos valores
  AccountModel copyWith({
    double? balance,
    String? transactionPassword,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return AccountModel(
      id: this.id,
      userId: this.userId,
      balance: balance ?? this.balance,
      transactionPassword: transactionPassword ?? this.transactionPassword,
      isActive: isActive ?? this.isActive,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converte o modelo para um Map para armazenamento no Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'balance': balance,
      'transactionPassword': transactionPassword,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Cria um modelo a partir de um Map do Firestore
  factory AccountModel.fromMap(Map<String, dynamic> map, String id) {
    return AccountModel(
      id: id,
      userId: map['userId'] ?? '',
      balance: (map['balance'] is num) ? (map['balance'] as num).toDouble() : 0.0,
      transactionPassword: map['transactionPassword'],
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Cria um modelo a partir de um DocumentSnapshot do Firestore
  factory AccountModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AccountModel.fromMap(data, doc.id);
  }
  
  /// Cria uma nova conta para um usuário
  factory AccountModel.create(String userId) {
    final now = DateTime.now();
    return AccountModel(
      id: '', // Será definido pelo Firestore
      userId: userId,
      balance: 0.0,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }
}