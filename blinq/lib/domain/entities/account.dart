import 'package:cloud_firestore/cloud_firestore.dart';

class AccountModel {
  final String id;
  final String email;
  final double balance;
  final String? transactionPassword;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  AccountModel({
    required this.id,
    required this.email,
    this.balance = 0.0,
    this.transactionPassword,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AccountModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AccountModel(
      id: documentId,
      email: map['email'] ?? '',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      transactionPassword: map['transactionPassword'],
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'balance': balance,
      'transactionPassword': transactionPassword,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AccountModel copyWith({
    String? id,
    String? email,
    double? balance,
    String? transactionPassword,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      email: email ?? this.email,
      balance: balance ?? this.balance,
      transactionPassword: transactionPassword ?? this.transactionPassword,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}