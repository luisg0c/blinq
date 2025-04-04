import 'package:cloud_firestore/cloud_firestore.dart';

class AccountModel {
  final String id;
  final String email;
  final double balance;
  final String? txnPassword;
  final DateTime createdAt;
  final DateTime updatedAt;

  AccountModel({
    required this.id,
    required this.email,
    required this.balance,
    this.txnPassword,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AccountModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AccountModel(
      id: documentId,
      email: map['email'] ?? '',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      txnPassword: map['txnPassword'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'balance': balance,
      'txnPassword': txnPassword,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt) : FieldValue.serverTimestamp(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  AccountModel copyWith({
    String? id,
    String? email,
    double? balance,
    String? txnPassword,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      email: email ?? this.email,
      balance: balance ?? this.balance,
      txnPassword: txnPassword ?? this.txnPassword,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}