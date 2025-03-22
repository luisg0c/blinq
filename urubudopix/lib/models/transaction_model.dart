import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String senderId;
  final String receiverId;
  final double amount;
  final DateTime timestamp;

  TransactionModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.timestamp,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TransactionModel(
      id: documentId,
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      amount: (map['amount'] as num).toDouble(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'timestamp': Timestamp.fromDate(timestamp),
      'participants': [senderId, receiverId], // 🔥 Firestore index para buscas
    };
  }

  /// 🔁 Atualiza campos específicos
  TransactionModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    double? amount,
    DateTime? timestamp,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
