import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String senderId;
  final String receiverId;
  final double amount;
  final DateTime timestamp;
  final List<String> participants; // 🔥 Adicionado

  TransactionModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.timestamp,
    required this.participants, // 🔥 Adicionado
  });

  factory TransactionModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return TransactionModel(
      id: documentId,
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      amount: (map['amount'] as num).toDouble(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      participants: List<String>.from(
        map['participants'] ?? [],
      ), // 🔥 Adicionado
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'timestamp': Timestamp.fromDate(timestamp),
      'participants': participants, // 🔥 Mantido
    };
  }

  TransactionModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    double? amount,
    DateTime? timestamp,
    List<String>? participants, // 🔥 Adicionado
  }) {
    return TransactionModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      participants: participants ?? this.participants, // 🔥 Adicionado
    );
  }
}
