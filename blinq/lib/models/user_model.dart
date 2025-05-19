import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String accountNumber;
  final double balance;
  final DateTime? birthDate;
  final bool isEmailVerified;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.accountNumber,
    this.balance = 0.0,
    this.birthDate,
    this.isEmailVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'accountNumber': accountNumber,
      'balance': balance,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'isEmailVerified': isEmailVerified,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      birthDate: (map['birthDate'] as Timestamp?)?.toDate(),
      isEmailVerified: map['isEmailVerified'] ?? false,
    );
  }
}