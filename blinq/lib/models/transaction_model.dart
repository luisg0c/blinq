import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

enum TransactionType { deposit, transfer }
enum TransactionStatus { pending, completed, failed }

class TransactionModel {
  final String id;
  final String senderId;
  final String? receiverId;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime timestamp;
  final String? description;

  TransactionModel({
    String? id,
    required this.senderId,
    this.receiverId,
    required this.amount,
    required this.type,
    this.status = TransactionStatus.pending,
    DateTime? timestamp,
    this.description,
  }) : 
    id = id ?? const Uuid().v4(),
    timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'type': type.name,
      'status': status.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'description': description,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? const Uuid().v4(),
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'],
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : 0.0,
      type: TransactionType.values.byName(map['type'] ?? 'transfer'),
      status: TransactionStatus.values.byName(map['status'] ?? 'pending'),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: map['description'],
    );
  }

  factory TransactionModel.deposit({
    required String userId,
    required double amount,
    String? description,
  }) {
    return TransactionModel(
      senderId: userId,
      receiverId: userId,
      amount: amount,
      type: TransactionType.deposit,
      description: description,
    );
  }

  factory TransactionModel.transfer({
    required String senderId,
    required String receiverId,
    required double amount,
    String? description,
  }) {
    return TransactionModel(
      senderId: senderId,
      receiverId: receiverId,
      amount: amount,
      type: TransactionType.transfer,
      description: description,
    );
  }
}