import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  final String id;
  final String userId;
  final double balance;
<<<<<<< Updated upstream
  final String? transactionPassword;
=======
  final String? transactionPassword; // Hash da senha
>>>>>>> Stashed changes
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Account({
    required this.id,
    required this.userId,
    this.balance = 0.0,
    this.transactionPassword,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
<<<<<<< Updated upstream
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();
=======
  }) : 
    this.createdAt = createdAt ?? DateTime.now(),
    this.updatedAt = updatedAt ?? DateTime.now();
>>>>>>> Stashed changes

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

  factory Account.fromMap(Map<String, dynamic> map, String id) {
    return Account(
      id: id,
      userId: map['userId'] ?? '',
<<<<<<< Updated upstream
      balance:
          (map['balance'] is num) ? (map['balance'] as num).toDouble() : 0.0,
=======
      balance: (map['balance'] is num) ? (map['balance'] as num).toDouble() : 0.0,
>>>>>>> Stashed changes
      transactionPassword: map['transactionPassword'],
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
<<<<<<< Updated upstream
}
=======
}
>>>>>>> Stashed changes
