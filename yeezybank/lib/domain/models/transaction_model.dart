import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String senderId;
  final String receiverId;
  final double amount;
  final DateTime timestamp;
  final List<String> participants;
  final String type; // 🔥 Adicionado

  TransactionModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.timestamp,
    required this.participants,
    required this.type, // 🔥 Adicionado
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TransactionModel(
      id: documentId,
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      amount: (map['amount'] as num).toDouble(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      participants: List<String>.from(map['participants'] ?? []),
      type: map['type'] ?? 'unknown', // 🔥 Default se faltar
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'timestamp': Timestamp.fromDate(timestamp),
      'participants': participants,
      'type': type, // 🔥 Incluído
    };
  }

  TransactionModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    double? amount,
    DateTime? timestamp,
    List<String>? participants,
    String? type, // 🔥 Incluído
  }) {
    return TransactionModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      participants: participants ?? this.participants,
      type: type ?? this.type,
    );
  }
}
